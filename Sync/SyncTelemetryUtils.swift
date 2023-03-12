// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import UIKit
import Glean
import Shared
import Account
import Storage
import SwiftyJSON
import SyncTelemetry

public typealias OldSyncReason = SyncReason

public enum SyncReason: String {
    case startup = "startup"
    case scheduled = "scheduled"
    case backgrounded = "backgrounded"
    case user = "user"
    case syncNow = "syncNow"
    case didLogin = "didLogin"
    case push = "push"
    case engineEnabled = "engineEnabled"
    case clientNameChanged = "clientNameChanged"
}

public enum SyncPingReason: String {
    case shutdown = "shutdown"
    case schedule = "schedule"
    case idChanged = "idchanged"
}

public protocol Stats {
    func hasData() -> Bool
}

private protocol DictionaryRepresentable {
    func asDictionary() -> [String: Any]
}

public struct SyncUploadStats: Stats {
    var sent: Int = 0
    var sentFailed: Int = 0

    public func hasData() -> Bool {
        return sent > 0 || sentFailed > 0
    }
}

extension SyncUploadStats: DictionaryRepresentable {
    func asDictionary() -> [String: Any] {
        return [
            "sent": sent,
            "failed": sentFailed
        ]
    }
}

public struct SyncDownloadStats: Stats {
    var applied: Int = 0
    var succeeded: Int = 0
    var failed: Int = 0
    var newFailed: Int = 0
    var reconciled: Int = 0

    public func hasData() -> Bool {
        return applied > 0 ||
               succeeded > 0 ||
               failed > 0 ||
               newFailed > 0 ||
               reconciled > 0
    }
}

extension SyncDownloadStats: DictionaryRepresentable {
    func asDictionary() -> [String: Any] {
        return [
            "applied": applied,
            "succeeded": succeeded,
            "failed": failed,
            "newFailed": newFailed,
            "reconciled": reconciled
        ]
    }
}

public struct ValidationStats: Stats, DictionaryRepresentable {
    let problems: [ValidationProblem]
    let took: Int64
    let checked: Int?

    public func hasData() -> Bool {
        return !problems.isEmpty
    }

    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "problems": problems.map { $0.asDictionary() },
            "took": took
        ]
        if let checked = self.checked {
            dict["checked"] = checked
        }
        return dict
    }
}

public struct ValidationProblem: DictionaryRepresentable {
    let name: String
    let count: Int

    func asDictionary() -> [String: Any] {
        return ["name": name, "count": count]
    }
}

public class StatsSession {
    var took: Int64 = 0
    var when: Timestamp?

    private var startUptimeNanos: UInt64?

    public func start(when: UInt64 = Date.now()) {
        self.when = when
        self.startUptimeNanos = DispatchTime.now().uptimeNanoseconds
    }

    public func hasStarted() -> Bool {
        return startUptimeNanos != nil
    }

    public func end() -> Self {
        guard let startUptime = startUptimeNanos else {
            assertionFailure("SyncOperationStats called end without first calling start!")
            return self
        }

        // Casting to Int64 should be safe since we're using uptime since boot in both cases.
        // Convert to milliseconds as stated in the sync ping format
        took = (Int64(DispatchTime.now().uptimeNanoseconds) - Int64(startUptime)) / 1000000
        return self
    }
}

// Stats about a single engine's sync.
public class SyncEngineStatsSession: StatsSession {
    public var validationStats: ValidationStats?

    private(set) var uploadStats: SyncUploadStats
    private(set) var downloadStats: SyncDownloadStats

    public init(collection: String) {
        self.uploadStats = SyncUploadStats()
        self.downloadStats = SyncDownloadStats()
    }

    public func recordDownload(stats: SyncDownloadStats) {
        self.downloadStats.applied += stats.applied
        self.downloadStats.succeeded += stats.succeeded
        self.downloadStats.failed += stats.failed
        self.downloadStats.newFailed += stats.newFailed
        self.downloadStats.reconciled += stats.reconciled
    }

    public func recordUpload(stats: SyncUploadStats) {
        self.uploadStats.sent += stats.sent
        self.uploadStats.sentFailed += stats.sentFailed
    }
}

extension SyncEngineStatsSession: DictionaryRepresentable {
    func asDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "took": took,
        ]

        if downloadStats.hasData() {
            dict["incoming"] = downloadStats.asDictionary()
        }

        if uploadStats.hasData() {
            dict["outgoing"] = [uploadStats.asDictionary()]
        }

        if let validation = self.validationStats, validation.hasData() {
            dict["validation"] = validation.asDictionary()
        }

        return dict
    }
}

// Stats and metadata for a sync operation.
public class SyncOperationStatsSession: StatsSession {
    public let why: OldSyncReason
    public var uid: String?
    public var deviceID: String?

    fileprivate let didLogin: Bool

    public init(why: OldSyncReason, uid: String, deviceID: String?) {
        self.why = why
        self.uid = uid
        self.deviceID = deviceID
        self.didLogin = (why == .didLogin)
    }
}

extension SyncOperationStatsSession: DictionaryRepresentable {
    func asDictionary() -> [String: Any] {
        let whenValue = when ?? 0
        return [
            "when": whenValue,
            "took": took,
            "didLogin": didLogin,
            "why": why.rawValue
        ]
    }
}

public enum SyncPingError: MaybeErrorType {
    case failedToRestoreScratchpad
    case emptyPing

    public var description: String {
        switch self {
        case .failedToRestoreScratchpad: return "Failed to restore Scratchpad from prefs"
        case .emptyPing: return "Can't send ping without events or syncs"
        }
    }
}

public enum SyncPingFailureReasonName: String {
    case httpError = "httperror"
    case unexpectedError = "unexpectederror"
    case sqlError = "sqlerror"
    case otherError = "othererror"
}

public protocol SyncPingFailureFormattable {
    var failureReasonName: SyncPingFailureReasonName { get }
}

public struct SyncPing: SyncTelemetryPing {
    public private(set) var payload: JSON

    static func pingFields(
        prefs: Prefs,
        why: SyncPingReason,
        completion: @escaping (((token: TokenServerToken, fields: [String: Any])?) -> Void)
    ) {
        // Grab our token so we can use the hashed_fxa_uid and clientGUID from our scratchpad for
        // our ping's identifiers
        RustFirefoxAccounts.shared.syncAuthState.token(Date.now(), canBeExpired: false).upon { result in
            guard let (token, kSync) = result.successValue else {
                completion(nil)
                return
            }
            let scratchpadPrefs = prefs.branch("sync.scratchpad")
            guard let scratchpad = Scratchpad.restoreFromPrefs(scratchpadPrefs, syncKeyBundle: KeyBundle.fromKSync(kSync)) else {
                completion(nil)
                return
            }

            let ping: [String: Any] = pingCommonData(
                why: why,
                hashedUID: token.hashedFxAUID,
                hashedDeviceID: (scratchpad.clientGUID + token.hashedFxAUID).sha256.hexEncodedString
            )

            completion((token, ping))
        }
    }

    public static func from(
        result: SyncOperationResult,
        remoteClientsAndTabs: RemoteClientsAndTabs,
        prefs: Prefs,
        why: SyncPingReason,
        completion: @escaping ((SyncPing?) -> Void)
    ) {
        pingFields(prefs: prefs, why: why) {
            guard let (token, fields) = $0 else {
                completion(nil)
                return
            }

            var ping = fields

            // TODO: We don't cache our sync pings so if it fails, it fails. Once we add
            // some kind of caching we'll want to make sure we don't dump the events if
            // the ping has failed.
            let events = Event.takeAll(fromPrefs: prefs).map { $0.toArray() }
            ping["events"] = events

            dictionaryFrom(
                result: result,
                storage: remoteClientsAndTabs,
                token: token
            ) { syncDict in
                // TODO: Split the sync ping metadata from storing a single sync.
                ping["syncs"] = [syncDict]
                completion(SyncPing(payload: JSON(ping)))
            }
        }
    }

    public static func fromQueuedEvents(
        prefs: Prefs,
        why: SyncPingReason,
        completion: @escaping ((SyncPing?) -> Void)
    ) {
        if !Event.hasQueuedEvents(inPrefs: prefs) {
            completion(nil)
            return
        }
        pingFields(prefs: prefs, why: why) {
            guard let (_, fields) = $0 else {
                completion(nil)
                return
            }
            var ping = fields
            ping["events"] = Event.takeAll(fromPrefs: prefs).map { $0.toArray() }
            completion(SyncPing(payload: JSON(ping)))
        }
    }

    static func pingCommonData(why: SyncPingReason, hashedUID: String, hashedDeviceID: String) -> [String: Any] {
         return [
            "version": 1,
            "why": why.rawValue,
            "uid": hashedUID,
            "deviceID": hashedDeviceID,
            "os": [
                "name": "iOS",
                "version": UIDevice.current.systemVersion,
                "locale": Locale.current.identifier
            ]
        ]
    }

    // Generates a single sync ping payload that is stored in the 'syncs' list in the sync ping.
    private static func dictionaryFrom(
        result: SyncOperationResult,
        storage: RemoteClientsAndTabs,
        token: TokenServerToken,
        completion: @escaping (([String: Any]) -> Void)
    ) {
        connectedDevices(
            fromStorage: storage,
            token: token
        ) { devices in
            guard let stats = result.stats else {
                completion([String: Any]())
                return
            }

            var dict = stats.asDictionary()
            if let engineResults = result.engineResults.successValue {
                dict["engines"] = SyncPing.enginePingDataFrom(engineResults: engineResults)
            } else if let failure = result.engineResults.failureValue {
                var errorName: SyncPingFailureReasonName
                if let formattableFailure = failure as? SyncPingFailureFormattable {
                    errorName = formattableFailure.failureReasonName
                } else {
                    errorName = .unexpectedError
                }

                dict["failureReason"] = [
                    "name": errorName.rawValue,
                    "error": "\(type(of: failure))",
                ]
            }

            dict["devices"] = devices
            completion(dict)
        }
    }

    // Returns a list of connected devices formatted for use in the 'devices' property in the sync ping.
    private static func connectedDevices(
        fromStorage storage: RemoteClientsAndTabs,
        token: TokenServerToken,
        completion: @escaping (([[String: Any]]) -> Void)
    ) {
        func dictionaryFrom(client: RemoteClient) -> [String: Any]? {
            var device = [String: Any]()
            if let os = client.os {
                device["os"] = os
            }
            if let version = client.version {
                device["version"] = version
            }
            if let guid = client.guid {
                device["id"] = (guid + token.hashedFxAUID).sha256.hexEncodedString
            }
            return device
        }

        storage.getClients().upon { result in
            guard let clients = result.successValue else {
                completion([])
                return
            }
            completion(clients.compactMap(dictionaryFrom))
        }
    }

    private static func enginePingDataFrom(engineResults: EngineResults) -> [[String: Any]] {
        return engineResults.map { result in
            let (name, status) = result
            var engine: [String: Any] = [
                "name": name
            ]

            // For complete/partial results, extract out the collect stats
            // and add it to engine information. For syncs that were not able to
            // start, return why and a reason.
            switch status {
            case .completed(let stats):
                engine = engine.merge(with: stats.asDictionary())
            case .partial(let stats):
                engine = engine.merge(with: stats.asDictionary())
            case .notStarted(let reason):
                engine = engine.merge(with: [
                    "status": reason.telemetryId
                ])
            }

            return engine
        }
    }
}

public class GleanSyncOperationHelper {
    public init () {}

    public func start() {
        _ = GleanMetrics.Sync.syncUuid.generateAndSet()
    }

    public func end(_ result: SyncOperationResult) {
        if let engineResults = result.engineResults.successValue {
            engineResults.forEach { result in
                let (name, status) = result
                switch status {
                case .completed(let stats):
                    self.recordSyncEngineStats(name, stats)
                case .partial(let stats):
                    self.recordSyncEngineStats(name, stats)
                case .notStarted(let reason):
                    self.recordSyncEngineFailure(name, reason.telemetryId)
                }

                self.submitSyncEnginePing(name)
            }
        } else if let failure = result.engineResults.failureValue {
            var errorName: SyncPingFailureReasonName
            if let formattableFailure = failure as? SyncPingFailureFormattable {
                errorName = formattableFailure.failureReasonName
            } else {
                errorName = .unexpectedError
            }

            GleanMetrics.Sync.failureReason[errorName.rawValue].add()
        }

        GleanMetrics.Pings.shared.tempSync.submit()
    }

    private func recordSyncEngineStats(_ engineName: String, _ stats: SyncEngineStatsSession) {
        // Create maps on labels to stat value,
        // keeping only the values that are above zero.
        //
        // If we attempt to add 0 to a Glean counter,
        // Glean will record an error. We don't want that here.
        let incomingLabelsToValue = [
            ("applied", stats.downloadStats.succeeded),
            ("reconciled", stats.downloadStats.reconciled),
            ("failed_to_apply", stats.downloadStats.failed)
        ].filter { (_, stat) in stat > 0 }
        let outgoingLabelsToValue = [
            ("uploaded", stats.uploadStats.sent),
            ("failed_to_upload", stats.uploadStats.sentFailed)
        ].filter { (_, stat) in stat > 0 }

        switch engineName {
        case "tabs":
            incomingLabelsToValue.forEach { (l, v) in GleanMetrics.RustTabsSync.incoming[l].add(Int32(v))}
            outgoingLabelsToValue.forEach { (l, v) in GleanMetrics.RustTabsSync.outgoing[l].add(Int32(v)) }
        case "bookmarks":
            incomingLabelsToValue.forEach { (l, v) in GleanMetrics.BookmarksSync.incoming[l].add(Int32(v))}
            outgoingLabelsToValue.forEach { (l, v) in GleanMetrics.BookmarksSync.outgoing[l].add(Int32(v)) }
        case "history":
            incomingLabelsToValue.forEach { (l, v) in GleanMetrics.HistorySync.incoming[l].add(Int32(v))}
            outgoingLabelsToValue.forEach { (l, v) in GleanMetrics.HistorySync.outgoing[l].add(Int32(v)) }
        case "logins":
            incomingLabelsToValue.forEach { (l, v) in GleanMetrics.LoginsSync.incoming[l].add(Int32(v))}
            outgoingLabelsToValue.forEach { (l, v) in GleanMetrics.LoginsSync.outgoing[l].add(Int32(v)) }
        case "clients":
            incomingLabelsToValue.forEach { (l, v) in GleanMetrics.ClientsSync.incoming[l].add(Int32(v))}
            outgoingLabelsToValue.forEach { (l, v) in GleanMetrics.ClientsSync.outgoing[l].add(Int32(v)) }
        default:
            break
        }
    }

    private func recordSyncEngineFailure(_ engineName: String, _ reason: String) {
        let correctedReson = String(reason.dropFirst("sync.not_started.reason.".count))

        switch engineName {
        case "tabs": GleanMetrics.RustTabsSync.failureReason[correctedReson].add()
        case "bookmarks": GleanMetrics.BookmarksSync.failureReason[correctedReson].add()
        case "history": GleanMetrics.HistorySync.failureReason[correctedReson].add()
        case "logins": GleanMetrics.LoginsSync.failureReason[correctedReson].add()
        case "clients": GleanMetrics.ClientsSync.failureReason[correctedReson].add()
        default:
            break
        }
    }

    private func submitSyncEnginePing(_ engineName: String) {
        switch engineName {
        case "tabs": GleanMetrics.Pings.shared.tempRustTabsSync.submit()
        case "bookmarks": GleanMetrics.Pings.shared.tempBookmarksSync.submit()
        case "history": GleanMetrics.Pings.shared.tempHistorySync.submit()
        case "logins": GleanMetrics.Pings.shared.tempLoginsSync.submit()
        case "clients": GleanMetrics.Pings.shared.tempClientsSync.submit()
        default:
            break
        }
    }
}
