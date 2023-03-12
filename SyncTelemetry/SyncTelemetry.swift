// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import Foundation
import SwiftyJSON
import Shared

private let ServerURL = "https://incoming.telemetry.mozilla.org".asURL!
private let AppName = "Fennec"

public enum TelemetryDocType: String {
    case core = "core"
    case sync = "sync"
}

public protocol SyncTelemetryEvent {
    func record(_ prefs: Prefs)
}

open class SyncTelemetry {
    private static var prefs: Prefs?
    private static var telemetryVersion: Int = 4

    open class func initWithPrefs(_ prefs: Prefs) {
        assert(self.prefs == nil, "Prefs already initialized")
        self.prefs = prefs
    }

    open class func recordEvent(_ event: SyncTelemetryEvent) {
        guard let prefs = prefs else {
            assertionFailure("Prefs not initialized")
            return
        }

        event.record(prefs)
    }

    open class func send(ping: SyncTelemetryPing,
                         docType: TelemetryDocType,
                         logger: Logger = DefaultLogger.shared) {
        let docID = UUID().uuidString
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let buildID = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String

        let channel = AppConstants.buildChannel.rawValue
        let path = "/submit/telemetry/\(docID)/\(docType.rawValue)/\(AppName)/\(appVersion)/\(channel)/\(buildID)"
        let url = ServerURL.appendingPathComponent(path)
        var request = URLRequest(url: url)

        // Don't add the common ping format for the mobile core ping.
        let pingString: String?
        if docType != .core {
            var json = JSON(commonPingFormat(forType: docType))
            json["payload"] = ping.payload
            pingString = json.stringify()
        } else {
            pingString = ping.payload.stringify()
        }

        guard let body = pingString?.data(using: .utf8) else {
            logger.log("Invalid data",
                       level: .warning,
                       category: .sync)
            assertionFailure()
            return
        }

        guard channel != "default" else {
            logger.log("Non-release build; not sending ping",
                       level: .debug,
                       category: .sync)
            return
        }

        request.httpMethod = "POST"
        request.httpBody = body
        request.addValue(Date().toRFC822String(), forHTTPHeaderField: "Date")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        makeURLSession(userAgent: UserAgent.fxaUserAgent, configuration: URLSessionConfiguration.ephemeral).dataTask(with: request) { (_, response, error) in
            let code = (response as? HTTPURLResponse)?.statusCode
            logger.log("Ping response: \(code ?? -1).",
                       level: .debug,
                       category: .sync)
        }.resume()
    }

    private static func commonPingFormat(forType type: TelemetryDocType) -> [String: Any] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = formatter.string(from: NSDate() as Date)
        let displayVersion = [
            AppInfo.appVersion,
            "b",
            AppInfo.buildNumber
        ].joined()
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"

        return [
            "type": type.rawValue,
            "id": UUID().uuidString,
            "creationDate": date,
            "version": SyncTelemetry.telemetryVersion,
            "application": [
                "architecture": "arm",
                "buildId": AppInfo.buildNumber,
                "name": AppInfo.displayName,
                "version": AppInfo.appVersion,
                "displayVersion": displayVersion,
                "platformVersion": osVersion,
                "channel": AppConstants.buildChannel.rawValue
            ]
        ]
    }
}

public protocol SyncTelemetryPing {
    var payload: JSON { get }
}
