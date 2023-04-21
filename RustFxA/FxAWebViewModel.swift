/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Foundation
import MozillaAppServices
import Shared
import Common

enum FxAPageType {
    case emailLoginFlow
    case qrCode(url: String)
    case settingsPage
}

// See https://mozilla.github.io/ecosystem-platform/docs/fxa-engineering/fxa-webchannel-protocol
// For details on message types.
private enum RemoteCommand: String {
    // case canLinkAccount = "can_link_account"
    // case loaded = "fxaccounts:loaded"
    case status = "fxaccounts:fxa_status"
    case login = "fxaccounts:oauth_login"
    case changePassword = "fxaccounts:change_password"
    case signOut = "fxaccounts:logout"
    case deleteAccount = "fxaccounts:delete_account"
    case profileChanged = "profile:change"
}

class FxAWebViewModel {
    fileprivate let pageType: FxAPageType
    fileprivate let profile: Profile
    fileprivate var deepLinkParams: FxALaunchParams
    fileprivate(set) var baseURL: URL?
    let fxAWebViewTelemetry = FxAWebViewTelemetry()
    private let logger: Logger
    // This is not shown full-screen, use mobile UA
    static let mobileUserAgent = UserAgent.mobileUserAgent()

    func setupUserScript(for controller: WKUserContentController) {
        guard let path = Bundle.main.path(forResource: "FxASignIn", ofType: "js"),
              let source = try? String(contentsOfFile: path, encoding: .utf8)
        else {
            assertionFailure("Error unwrapping contents of file to set up user script")
            return
        }

        let userScript = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        controller.addUserScript(userScript)
    }

    /**
     init() FxAWebViewModel.
     - parameter pageType: Specify login flow or settings page if already logged in.
     - parameter profile: a Profile.
     - parameter deepLinkParams: url parameters that originate from a deep link
     */
    required init(pageType: FxAPageType,
                  profile: Profile,
                  deepLinkParams: FxALaunchParams,
                  logger: Logger = DefaultLogger.shared) {
        self.pageType = pageType
        self.profile = profile
        self.deepLinkParams = deepLinkParams
        self.logger = logger

        // If accountMigrationFailed then the app menu has a caution icon,
        // and at this point the user has taken sufficient action to clear the caution.
    }

    var onDismissController: (() -> Void)?

    func composeTitle(basedOn url: URL?, hasOnlySecureContent: Bool) -> String {
        return (hasOnlySecureContent ? "🔒 " : "") + (url?.host ?? "")
    }

    func setupFirstPage(completion: @escaping (URLRequest, TelemetryWrapper.EventMethod?) -> Void) {
    }

    private func makeRequest(_ url: URL) -> URLRequest {
        let args = deepLinkParams.query.filter { $0.key.starts(with: "utm_") }.map {
            return URLQueryItem(name: $0.key, value: $0.value)
        }

        var comp = URLComponents(url: url, resolvingAgainstBaseURL: false)
        comp?.queryItems?.append(contentsOf: args)
        if let url = comp?.url {
            return URLRequest(url: url)
        }

        return URLRequest(url: url)
    }
}

// MARK: - Commands
extension FxAWebViewModel {
    func handle(scriptMessage message: WKScriptMessage) {
        guard let url = baseURL,
              let webView = message.webView
        else { return }

        let origin = message.frameInfo.securityOrigin
        guard origin.`protocol` == url.scheme && origin.host == url.host && origin.port == (url.port ?? 0) else {
            logger.log("Ignoring message - \(origin) does not match expected origin: \(url.origin ?? "nil")",
                       level: .warning,
                       category: .sync)
            return
        }

        guard message.name == "accountsCommandHandler" else { return }
        guard let body = message.body as? [String: Any],
              let detail = body["detail"] as? [String: Any],
              let msg = detail["message"] as? [String: Any],
              let cmd = msg["command"] as? String
        else { return }

        let id = Int(msg["messageId"] as? String ?? "")
        handleRemote(command: cmd, id: id, data: msg["data"], webView: webView)
    }

    // Handle a message coming from the content server.
    private func handleRemote(command rawValue: String, id: Int?, data: Any?, webView: WKWebView) {
        if let command = RemoteCommand(rawValue: rawValue) {
            switch command {
            case .login:
                if let data = data {
                    onLogin(data: data, webView: webView)
                }
            case .changePassword:
                if let data = data {
                    onPasswordChange(data: data, webView: webView)
                }
            case .status:
                if let id = id {
                    onSessionStatus(id: id, webView: webView)
                }
            case .deleteAccount, .signOut:
                profile.removeAccount()
                onDismissController?()
            case .profileChanged:
                // dismiss keyboard after changing profile in order to see notification view
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    /// Send a message to web content using the required message structure.
    private func runJS(webView: WKWebView, typeId: String, messageId: Int, command: String, data: String = "{}") {
        let msg = """
            var msg = {
                id: "\(typeId)",
                message: {
                    messageId: \(messageId),
                    command: "\(command)",
                    data : \(data)
                }
            };
            window.dispatchEvent(new CustomEvent('WebChannelMessageToContent', { detail: JSON.stringify(msg) }));
        """

        webView.evaluateJavascriptInDefaultContentWorld(msg)
    }

    /// Respond to the webpage session status notification by either passing signed in
    /// user info (for settings), or by passing CWTS setup info (in case the user is
    /// signing up for an account). This latter case is also used for the sign-in state.
    private func onSessionStatus(id: Int, webView: WKWebView) {
        let cmd = "fxaccounts:fxa_status"
        let typeId = "account_updates"
        let data: String
        switch pageType {
        case .settingsPage:
            // Both email and uid are required at this time to properly link the FxA settings session
         
            data = """
                {
                    capabilities: {},
                    signedInUser: {
                        sessionToken: "",
                        email: "",
                        uid: "",
                        verified: true,
                    }
                }
                """
        case .emailLoginFlow, .qrCode:
            data = """
                    { capabilities:
                        { choose_what_to_sync: true, engines: ["bookmarks", "history", "tabs", "passwords"] },
                    }
                """
        }

        runJS(webView: webView, typeId: typeId, messageId: id, command: cmd, data: data)
    }

    private func onLogin(data: Any, webView: WKWebView) {
        guard let data = data as? [String: Any],
              let code = data["code"] as? String,
              let state = data["state"] as? String
        else { return }

        if let declinedSyncEngines = data["declinedSyncEngines"] as? [String] {
            // Stash the declined engines so on first sync we can disable them!
            UserDefaults.standard.set(declinedSyncEngines, forKey: "fxa.cwts.declinedSyncEngines")
        }

        let auth = FxaAuthData(code: code, state: state, actionQueryParam: "signin")
        // Record login or registration completed telemetry
        fxAWebViewTelemetry.recordTelemetry(for: .completed)
        onDismissController?()
    }

    private func onPasswordChange(data: Any, webView: WKWebView) {
        guard let data = data as? [String: Any],
              let _ = data["sessionToken"] as? String
        else { return }

    }

    func shouldAllowRedirectAfterLogIn(basedOn navigationURL: URL?) -> WKNavigationActionPolicy {
        // Cancel navigation that happens after login to an account, which is when a redirect to `redirectURL` happens.
        // The app handles this event fully in native UI.
      
        return .allow
    }
}
