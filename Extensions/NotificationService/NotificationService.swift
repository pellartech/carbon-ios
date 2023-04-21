// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import Shared
import Storage
import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var display: SyncDataDisplay?
    var profile: ExtensionProfile?

    // This is run when an APNS notification with `mutable-content` is received.
    // If the app is backgrounded, then the alert notification is displayed.
    // If the app is foregrounded, then the notification.userInfo is passed straight to
    // AppDelegate.application(_:didReceiveRemoteNotification:completionHandler:)
    // Once the notification is tapped, then the same userInfo is passed to the same method in the AppDelegate.
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        let userInfo = request.content.userInfo

        let content = request.content.mutableCopy() as! UNMutableNotificationContent

        if self.profile == nil {
            self.profile = ExtensionProfile(localName: "profile")
        }

        guard let profile = self.profile else {
            self.didFinish(with: .noProfile)
            return
        }

        let queue = profile.queue
        let display = SyncDataDisplay(content: content, contentHandler: contentHandler, tabQueue: queue)
        self.display = display

        let handler = FxAPushMessageHandler(with: profile)

        handler.handle(userInfo: userInfo).upon { res in
            guard res.isSuccess, let events = res.successValue, let firstEvent = events.first else {
                self.didFinish(nil, with: res.failureValue as? PushMessageError)
                return
            }
            // We pass the first event to the notification handler, and add the rest directly
            // to our own handling of send tab if they are send tabs so users don't miss them
            for (idx, event) in events.enumerated() {
                if  idx != 0,
                    case let .commandReceived(tab) = event,
                    let urlString = tab["url"],
                    let url = URL(string: urlString),
                    url.isWebPage(),
                    let _ = tab["title"] {
                }
            }
            self.didFinish(firstEvent)
        }
    }

    func didFinish(_ what: PushMessage? = nil, with error: PushMessageError? = nil) {
        defer {
            // We cannot use tabqueue after the profile has shutdown;
            // however, we can't use weak references, because TabQueue isn't a class.
            // Rather than changing tabQueue, we manually nil it out here.
            self.display?.tabQueue = nil

            profile?.shutdown()
        }

        guard let display = self.display else { return }

        display.messageDelivered = false
        display.displayNotification(what, profile: profile, with: error)
        if !display.messageDelivered {
            display.displayUnknownMessageNotification(debugInfo: "Not delivered")
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        didFinish(with: .timeout)
    }
}

class SyncDataDisplay {
    var contentHandler: (UNNotificationContent) -> Void
    var notificationContent: UNMutableNotificationContent

    var tabQueue: TabQueue?
    var messageDelivered: Bool = false

    init(content: UNMutableNotificationContent,
         contentHandler: @escaping (UNNotificationContent) -> Void,
         tabQueue: TabQueue) {
        self.contentHandler = contentHandler
        self.notificationContent = content
        self.tabQueue = tabQueue
    }

    func displayNotification(_ message: PushMessage? = nil, profile: ExtensionProfile?, with error: PushMessageError? = nil) {
        guard let message = message, error == nil else {
            return displayUnknownMessageNotification(debugInfo: "Error \(error?.description ?? "")")
        }

        switch message {
        case .commandReceived(let tab):
            displayNewSentTabNotification(tab: tab)
        case .deviceConnected(let deviceName):
            displayDeviceConnectedNotification(deviceName)
        case .deviceDisconnected(let deviceName):
            displayDeviceDisconnectedNotification(deviceName)
        case .thisDeviceDisconnected:
            displayThisDeviceDisconnectedNotification()
        default:
            displayUnknownMessageNotification(debugInfo: "Unknown: \(message)")
            break
        }
    }
}

extension SyncDataDisplay {
    func displayDeviceConnectedNotification(_ deviceName: String) {
        presentNotification(title: .FxAPush_DeviceConnected_title,
                            body: .FxAPush_DeviceConnected_body,
                            bodyArg: deviceName)
    }

    func displayDeviceDisconnectedNotification(_ deviceName: String?) {
        if let deviceName = deviceName {
            presentNotification(title: .FxAPush_DeviceDisconnected_title,
                                body: .FxAPush_DeviceDisconnected_body,
                                bodyArg: deviceName)
        } else {
            // We should never see this branch
            presentNotification(title: .FxAPush_DeviceDisconnected_title,
                                body: .FxAPush_DeviceDisconnected_UnknownDevice_body)
        }
    }

    func displayThisDeviceDisconnectedNotification() {
        presentNotification(title: .FxAPush_DeviceDisconnected_ThisDevice_title,
                            body: .FxAPush_DeviceDisconnected_ThisDevice_body)
    }

    func displayAccountVerifiedNotification() {
        #if MOZ_CHANNEL_BETA || DEBUG
            presentNotification(title: .SentTab_NoTabArrivingNotification_title, body: "DEBUG: Account Verified")
            return
        #else
        presentNotification(title: .SentTab_NoTabArrivingNotification_title, body: .SentTab_NoTabArrivingNotification_body)
        #endif
    }

    func displayUnknownMessageNotification(debugInfo: String) {
        #if MOZ_CHANNEL_BETA || DEBUG
            presentNotification(title: .SentTab_NoTabArrivingNotification_title, body: "DEBUG: " + debugInfo)
            return
        #else
        presentNotification(title: .SentTab_NoTabArrivingNotification_title, body: .SentTab_NoTabArrivingNotification_body)
        #endif
    }
}

extension SyncDataDisplay {
    func displayNewSentTabNotification(tab: [String: String]) {
        if let urlString = tab["url"], let url = URL(string: urlString), url.isWebPage(), let title = tab["title"] {
            let tab = [
                "title": title,
                "url": url.absoluteString,
                "displayURL": url.absoluteDisplayExternalString,
                "deviceName": nil
            ] as NSDictionary

            notificationContent.userInfo["sentTabs"] = [tab] as NSArray

            // Add tab to the queue.
            let item = ShareItem(url: urlString, title: title)
            _ = tabQueue?.addToQueue(item).value // Force synchronous.

            presentNotification(title: .SentTab_TabArrivingNotification_NoDevice_title, body: url.absoluteDisplayExternalString)
        }
    }
}

extension SyncDataDisplay {
    func presentSentTabsNotification(_ tabs: [NSDictionary]) {
        let title: String
        let body: String

        if tabs.isEmpty {
            title = .SentTab_NoTabArrivingNotification_title
            #if MOZ_CHANNEL_BETA || DEBUG
                body = "DEBUG: Sent Tabs with no tab"
            #else
                body = .SentTab_NoTabArrivingNotification_body
            #endif
        } else {
            let deviceNames = Set(tabs.compactMap { $0["deviceName"] as? String })
            if let deviceName = deviceNames.first, deviceNames.count == 1 {
                title = String(format: .SentTab_TabArrivingNotification_WithDevice_title, deviceName)
            } else {
                title = .SentTab_TabArrivingNotification_NoDevice_title
            }

            if tabs.count == 1 {
                // We give the fallback string as the url,
                // because we have only just introduced "displayURL" as a key.
                body = (tabs[0]["displayURL"] as? String) ??
                    (tabs[0]["url"] as! String)
            } else if deviceNames.isEmpty {
                body = .SentTab_TabArrivingNotification_NoDevice_body
            } else {
                body = String(format: .SentTab_TabArrivingNotification_WithDevice_body, AppInfo.displayName)
            }
        }

        presentNotification(title: title, body: body)
    }

    func presentNotification(title: String, body: String, titleArg: String? = nil, bodyArg: String? = nil) {
        func stringWithOptionalArg(_ s: String, _ a: String?) -> String {
            if let a = a {
                return String(format: s, a)
            }
            return s
        }

        notificationContent.title = stringWithOptionalArg(title, titleArg)
        notificationContent.body = stringWithOptionalArg(body, bodyArg)

        // This is the only place we call the contentHandler.
        contentHandler(notificationContent)
        // This is the only place we change messageDelivered. We can check if contentHandler hasn't be called because of
        // our logic (rather than something funny with our environment, or iOS killing us).
        messageDelivered = true
    }
}

extension SyncDataDisplay {
    func displaySentTab(for url: URL, title: String, from deviceName: String?) {
        if url.isWebPage() {
            let item = ShareItem(url: url.absoluteString, title: title)
            _ = tabQueue?.addToQueue(item).value // Force synchronous.
        }
    }
}

struct SentTab {
    let url: URL
    let title: String
    let deviceName: String?
}

import Shared
import MozillaAppServices
import Common

let PendingAccountDisconnectedKey = "PendingAccountDisconnect"

/// This class provides handles push messages from FxA.
/// For reference, the [message schema][0] and [Android implementation][1] are both useful resources.
/// [0]: https://github.com/mozilla/fxa-auth-server/blob/master/docs/pushpayloads.schema.json#L26
/// [1]: https://dxr.mozilla.org/mozilla-central/source/mobile/android/services/src/main/java/org/mozilla/gecko/fxa/FxAccountPushHandler.java
/// The main entry points are `handle` methods, to accept the raw APNS `userInfo` and then to process the resulting JSON.
class FxAPushMessageHandler {
    let profile: Profile
    private let logger: Logger

    init(with profile: Profile, logger: Logger = DefaultLogger.shared) {
        self.profile = profile
        self.logger = logger
    }
}

extension FxAPushMessageHandler {
    /// Accepts the raw Push message from Autopush.
    /// This method then decrypts it according to the content-encoding (aes128gcm or aesgcm)
    /// and then effects changes on the logged in account.
    @discardableResult func handle(userInfo: [AnyHashable: Any]) -> PushMessageResults {
        let keychain = MZKeychainWrapper.sharedClientAppContainerKeychain


        guard let _ = userInfo["con"] as? String, // content-encoding
              let _ = userInfo["body"] as? String
        else { return deferMaybe(PushMessageError.messageIncomplete("missing con or body")) }
        // ver == endpointURL path, chid == channel id, aps == alert text and content_available.

   

         let string = "plaintext"

        // return handle(plaintext: string)
        let deferred = PushMessageResults()
        // Reconfig has to happen on the main thread, since it calls `startup`
        // and `startup` asserts that we are on the main thread. Otherwise the notification
        // service will crash.

        return deferred
    }
}

enum PushMessageType: String {
    case commandReceived = "fxaccounts:command_received"
    case deviceConnected = "fxaccounts:device_connected"
    case deviceDisconnected = "fxaccounts:device_disconnected"
    case profileUpdated = "fxaccounts:profile_updated"
    case passwordChanged = "fxaccounts:password_changed"
    case passwordReset = "fxaccounts:password_reset"
}

enum PushMessage: Equatable {
    case commandReceived(tab: [String: String])
    case deviceConnected(String)
    case deviceDisconnected(String?)
    case profileUpdated
    case passwordChanged
    case passwordReset

    // This is returned when we detect that it is us that has been disconnected.
    case thisDeviceDisconnected

    var messageType: PushMessageType {
        switch self {
        case .commandReceived:
            return .commandReceived
        case .deviceConnected:
            return .deviceConnected
        case .deviceDisconnected:
            return .deviceDisconnected
        case .thisDeviceDisconnected:
            return .deviceDisconnected
        case .profileUpdated:
            return .profileUpdated
        case .passwordChanged:
            return .passwordChanged
        case .passwordReset:
            return .passwordReset
        }
    }

    public static func == (lhs: PushMessage, rhs: PushMessage) -> Bool {
        guard lhs.messageType == rhs.messageType else {
            return false
        }

        switch (lhs, rhs) {
        case (.commandReceived(let lIndex), .commandReceived(let rIndex)):
            return lIndex == rIndex
        case (.deviceConnected(let lName), .deviceConnected(let rName)):
            return lName == rName
        default:
            return true
        }
    }
}

typealias PushMessageResults = Deferred<Maybe<[PushMessage]>>

enum PushMessageError: MaybeErrorType {
    case notDecrypted
    case messageIncomplete(String)
    case unimplemented(PushMessageType)
    case timeout
    case accountError
    case noProfile
    case subscriptionOutOfDate

    public var description: String {
        switch self {
        case .notDecrypted: return "notDecrypted"
        case .messageIncomplete(let message): return "messageIncomplete=\(message)"
        case .unimplemented(let what): return "unimplemented=\(what)"
        case .timeout: return "timeout"
        case .accountError: return "accountError"
        case .noProfile: return "noProfile"
        case .subscriptionOutOfDate: return "subscriptionOutOfDate"
        }
    }
}
