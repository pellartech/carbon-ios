// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import Foundation
import WebKit
import Storage
import Shared

// MARK: - TabManagerDelegate
@objc protocol TabManagerDelegate: AnyObject {
    func tabManager(_ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?, isRestoring: Bool)
    func tabManager(_ tabManager: TabManager, didAddTab tab: Tab, placeNextToParentTab: Bool, isRestoring: Bool)
    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool)

    func tabManagerDidRestoreTabs(_ tabManager: TabManager)
    func tabManagerDidAddTabs(_ tabManager: TabManager)
    func tabManagerDidRemoveAllTabs(_ tabManager: TabManager, toast: ButtonToast?)
    @objc optional func tabManagerUpdateCount()
}

// MARK: - WeakTabManagerDelegate
// We can't use a WeakList here because this is a protocol.
class WeakTabManagerDelegate {
    weak var value: TabManagerDelegate?

    init(value: TabManagerDelegate) {
        self.value = value
    }

    func get() -> TabManagerDelegate? {
        return value
    }
}

// MARK: - TabManagerProtocol
protocol TabManagerProtocol {
    var recentlyAccessedNormalTabs: [Tab] { get }
    var tabs: [Tab] { get }
    var selectedTab: Tab? { get }

    func selectTab(_ tab: Tab?, previous: Tab?)
    func addTab(_ request: URLRequest?, afterTab: Tab?, isPrivate: Bool) -> Tab
    func getMostRecentHomepageTab() -> Tab?
}

// TabManager must extend NSObjectProtocol in order to implement WKNavigationDelegate
class TabManager: NSObject, FeatureFlaggable, TabManagerProtocol {
    // MARK: - Variables
    private let tabEventHandlers: [TabEventHandler]
    private let store: TabManagerStore
    private let profile: Profile
    private var isRestoringTabs = false
    private(set) var tabs = [Tab]()
    private var _selectedIndex = -1
    var selectedIndex: Int { return _selectedIndex }
    private let logger: Logger

    var didChangedPanelSelection: Bool = true
    var didAddNewTab: Bool = true
    var tabDisplayType: TabDisplayType = .TabGrid
    let delaySelectingNewPopupTab: TimeInterval = 0.1

    // Enables undo of recently closed tabs
    var recentlyClosedForUndo = [SavedTab]()

    var normalTabs: [Tab] {
        return tabs.filter { !$0.isPrivate }
    }

    var privateTabs: [Tab] {
        return tabs.filter { $0.isPrivate }
    }

    /// This variable returns all normal tabs, sorted chronologically, excluding any
    /// home page tabs.
    var recentlyAccessedNormalTabs: [Tab] {
        var eligibleTabs = viableTabs()

        eligibleTabs = eligibleTabs.filter { tab in
            if tab.lastKnownUrl == nil {
                return false
            } else if let lastKnownUrl = tab.lastKnownUrl {
                if lastKnownUrl.absoluteString.hasPrefix("internal://") { return false }
                return true
            }
            return tab.isURLStartingPage
        }

        eligibleTabs = SponsoredContentFilterUtility().filterSponsoredTabs(from: eligibleTabs)

        // sort the tabs chronologically
        eligibleTabs = eligibleTabs.sorted {
            let firstTab = $0.lastExecutedTime ?? $0.sessionData?.lastUsedTime ?? $0.firstCreatedTime ?? 0
            let secondTab = $1.lastExecutedTime ?? $1.sessionData?.lastUsedTime ?? $0.firstCreatedTime ?? 0
            return firstTab > secondTab
        }

        return eligibleTabs
    }

    var count: Int {
        return tabs.count
    }

    var selectedTab: Tab? {
        if !(0..<count ~= _selectedIndex) {
            return nil
        }

        return tabs[_selectedIndex]
    }

    subscript(index: Int) -> Tab? {
        if index >= tabs.count {
            return nil
        }
        return tabs[index]
    }

    subscript(webView: WKWebView) -> Tab? {
        for tab in tabs where tab.webView === webView {
            return tab
        }

        return nil
    }

    // MARK: - Initializer

    init(profile: Profile,
         imageStore: DiskImageStore?,
         logger: Logger = DefaultLogger.shared
    ) {
        self.profile = profile
        self.navDelegate = TabManagerNavDelegate()
        self.tabEventHandlers = TabEventHandlers.create(with: profile)
        self.logger = logger

        self.store = TabManagerStoreImplementation(prefs: profile.prefs, imageStore: imageStore)
        super.init()

        register(self, forTabEvents: .didSetScreenshot)

        addNavigationDelegate(self)

        NotificationCenter.default.addObserver(self, selector: #selector(prefsDidChange), name: UserDefaults.didChangeNotification, object: nil)
    }

    // MARK: - Delegates
    private var delegates = [WeakTabManagerDelegate]()
    private let navDelegate: TabManagerNavDelegate

    func addDelegate(_ delegate: TabManagerDelegate) {
        self.delegates.append(WeakTabManagerDelegate(value: delegate))
    }

    func addNavigationDelegate(_ delegate: WKNavigationDelegate) {
        self.navDelegate.insert(delegate)
    }

    func removeDelegate(_ delegate: TabManagerDelegate, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [unowned self] in
            for index in 0 ..< self.delegates.count {
                let del = self.delegates[index]
                if delegate === del.get() || del.get() == nil {
                    self.delegates.remove(at: index)
                    return
                }
            }
            completion?()
        }
    }

    // MARK: - Webview configuration
    public static func makeWebViewConfig(isPrivate: Bool, prefs: Prefs?,forType type: WebViewType, messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {

        let webViewConfig = WKWebViewConfiguration()
        var js = ""
        if (walletAddress != ""){
            
            switch type {
            case .dappBrowser(let server):
                  if let filepath = Bundle.main.path(forResource: "Carbon-min", ofType: "js") {
                      do {
                          js += try String(contentsOfFile: filepath)
                      } catch { }
                  }
                  js += javaScriptForDappBrowser(server: server, address: walletAddress)
            case .tokenScriptRenderer:
                js += javaScriptForTokenScriptRenderer(address: walletAddress)
                js += """
                      \n
                      web3.tokens = {
                          data: {
                              currentInstance: {
                              },
                              token: {
                              },
                              card: {
                              },
                          },
                          dataChanged: (old, updated, tokenCardId) => {
                            console.log(\"web3.tokens.data changed. You should assign a function to `web3.tokens.dataChanged` to monitor for changes like this:\\n    `web3.tokens.dataChanged = (old, updated, tokenCardId) => { //do something }`\")
                          }
                      }
                      """
            }
            let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            webViewConfig.userContentController.addUserScript(userScript)

            switch type {
            case .dappBrowser:
                break
            case .tokenScriptRenderer:
                //TODO enable content blocking rules to support whitelisting
                webViewConfig.setURLSchemeHandler(webViewConfig, forURLScheme: "tokenscript-resource")
            }

            HackToAllowUsingSafaryExtensionCodeInDappBrowser.injectJs(to: webViewConfig)
            webViewConfig.userContentController.add(messageHandler, name: Method.sendTransaction.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: Method.signTransaction.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: Method.signPersonalMessage.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: Method.signMessage.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: Method.signTypedMessage.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: Method.ethCall.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: AddCustomChainCommand.Method.walletAddEthereumChain.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: SwitchChainCommand.Method.walletSwitchEthereumChain.rawValue)
            webViewConfig.userContentController.add(messageHandler, name: Browser.locationChangedEventName)
            webViewConfig.userContentController.add(messageHandler, name: TokenScript.SetProperties.setActionProps)
        }
        return webViewConfig
    }
    
    fileprivate static func javaScriptForDappBrowser(server: RPCServer, address: String) -> String {
        return """
               //Space is needed here because it is sometimes cut off by websites.
               
               const addressHex = "\(address)"
               const rpcURL = "\(server.web3InjectedRpcURL.absoluteString)"
               const chainID = "\(server.chainID)"

               function executeCallback (id, error, value) {
                   AlphaWallet.executeCallback(id, error, value)
               }

               AlphaWallet.init(rpcURL, {
                   getAccounts: function (cb) { cb(null, [addressHex]) },
                   processTransaction: function (tx, cb){
                       console.log('signing a transaction', tx)
                       const { id = 8888 } = tx
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object":     tx, id: id})
                   },
                   signMessage: function (msgParams, cb) {
                       const { data } = msgParams
                       const { id = 8888 } = msgParams
                       console.log("signing a message", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.signMessage.postMessage({"name": "signMessage", "object": { data }, id:    id} )
                   },
                   signPersonalMessage: function (msgParams, cb) {
                       const { data } = msgParams
                       const { id = 8888 } = msgParams
                       console.log("signing a personal message", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object":  { data }, id: id})
                   },
                   signTypedMessage: function (msgParams, cb) {
                       const { data } = msgParams
                       const { id = 8888 } = msgParams
                       console.log("signing a typed message", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.signTypedMessage.postMessage({"name": "signTypedMessage", "object":     { data }, id: id})
                   },
                   ethCall: function (msgParams, cb) {
                       const data = msgParams
                       const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
                       console.log("eth_call", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.ethCall.postMessage({"name": "ethCall", "object": data, id: id})
                   },
                   walletAddEthereumChain: function (msgParams, cb) {
                       const data = msgParams
                       const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
                       console.log("walletAddEthereumChain", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.walletAddEthereumChain.postMessage({"name": "walletAddEthereumChain", "object": data, id: id})
                   },
                   walletSwitchEthereumChain: function (msgParams, cb) {
                       const data = msgParams
                       const { id = Math.floor((Math.random() * 100000) + 1) } = msgParams
                       console.log("walletSwitchEthereumChain", msgParams)
                       AlphaWallet.addCallback(id, cb)
                       webkit.messageHandlers.walletSwitchEthereumChain.postMessage({"name": "walletSwitchEthereumChain", "object": data, id: id})
                   },
                   enable: function() {
                      return new Promise(function(resolve, reject) {
                          //send back the coinbase account as an array of one
                          resolve([addressHex])
                      })
                   }
               }, {
                   address: addressHex,
                   networkVersion: "0x" + parseInt(chainID).toString(16) || null
               })

               web3.setProvider = function () {
                   console.debug('AlphaWallet Wallet - overrode web3.setProvider')
               }

               web3.eth.defaultAccount = addressHex

               web3.version.getNetwork = function(cb) {
                   cb(null, chainID)
               }

              web3.eth.getCoinbase = function(cb) {
               return cb(null, addressHex)
             }
             window.ethereum = web3.currentProvider
               
             // So we can detect when sites use History API to generate the page location. Especially common with React and similar frameworks
             ;(function() {
               var pushState = history.pushState;
               var replaceState = history.replaceState;

               history.pushState = function() {
                 pushState.apply(history, arguments);
                 window.dispatchEvent(new Event('locationchange'));
               };

               history.replaceState = function() {
                 replaceState.apply(history, arguments);
                 window.dispatchEvent(new Event('locationchange'));
               };

               window.addEventListener('popstate', function() {
                 window.dispatchEvent(new Event('locationchange'))
               });
             })();

             window.addEventListener('locationchange', function(){
               webkit.messageHandlers.\(Browser.locationChangedEventName).postMessage(window.location.href)
             })
             """
    }
// swiftlint:enable function_body_length

    fileprivate static func javaScriptForTokenScriptRenderer(address: String) -> String {
        return """
               window.web3CallBacks = {}
               window.tokenScriptCallBacks = {}

               function executeCallback (id, error, value) {
                   window.web3CallBacks[id](error, value)
                   delete window.web3CallBacks[id]
               }

               function executeTokenScriptCallback (id, error, value) {
                   let cb = window.tokenScriptCallBacks[id]
                   if (cb) {
                       window.tokenScriptCallBacks[id](error, value)
                       delete window.tokenScriptCallBacks[id]
                   } else {
                   }
               }

               web3 = {
                 personal: {
                   sign: function (msgParams, cb) {
                     const { data } = msgParams
                     const { id = 8888 } = msgParams
                     window.web3CallBacks[id] = cb
                     webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object":  { data }, id: id})
                   }
                 },
                 action: {
                   setProps: function (object, cb) {
                     const id = 8888
                     window.tokenScriptCallBacks[id] = cb
                     webkit.messageHandlers.\(TokenScript.SetProperties.setActionProps).postMessage({"object":  object, id: id})
                   }
                 }
               }
               """
    }
    
    fileprivate static func contentBlockingRulesJson() -> String {
        let whiteListedUrls = [
            "https://unpkg.com/",
            "^tokenscript-resource://",
            "^http://stormbird.duckdns.org:8080/api/getChallenge$",
            "^http://stormbird.duckdns.org:8080/api/checkSignature"
        ]
        var json = """
                   [
                       {
                           "trigger": {
                               "url-filter": ".*"
                           },
                           "action": {
                               "type": "block"
                           }
                       }
                   """
        for each in whiteListedUrls {
            json += """
                    ,
                    {
                        "trigger": {
                            "url-filter": "\(each)"
                        },
                        "action": {
                            "type": "ignore-previous-rules"
                        }
                    }
                    """
        }
        json += "]"
        return json
    }

     private var configuration = WKWebViewConfiguration()

     private var privateConfiguration = WKWebViewConfiguration()
    // MARK: Get tabs
    func getTabFor(_ url: URL) -> Tab? {
        for tab in tabs {
            if let webViewUrl = tab.webView?.url,
                url.isEqual(webViewUrl) {
                return tab
            }

            // Also look for tabs that haven't been restored yet.
            if let sessionData = tab.sessionData,
                0..<sessionData.urls.count ~= sessionData.currentPage,
                sessionData.urls[sessionData.currentPage] == url {
                return tab
            }
        }

        return nil
    }

    func getTabForURL(_ url: URL) -> Tab? {
        return tabs.first(where: { $0.webView?.url == url })
    }

    func getTabForUUID(uuid: String) -> Tab? {
        let filterdTabs = tabs.filter { tab -> Bool in
            tab.tabUUID == uuid
        }
        return filterdTabs.first
    }

    // MARK: - Select tab
    // This function updates the _selectedIndex.
    // Note: it is safe to call this with `tab` and `previous` as the same tab, for use in the case where the index of the tab has changed (such as after deletion).
    func selectTab(_ tab: Tab?, previous: Tab? = nil) {
        let previous = previous ?? selectedTab

        previous?.metadataManager?.updateTimerAndObserving(state: .tabSwitched, isPrivate: previous?.isPrivate ?? false)
        tab?.metadataManager?.updateTimerAndObserving(state: .tabSelected, isPrivate: tab?.isPrivate ?? false)

        // Make sure to wipe the private tabs if the user has the pref turned on
        if shouldClearPrivateTabs(), !(tab?.isPrivate ?? false) {
            removeAllPrivateTabs()
        }

        if let tab = tab {
            _selectedIndex = tabs.firstIndex(of: tab) ?? -1
        } else {
            _selectedIndex = -1
        }

        store.preserveTabs(tabs, selectedTab: selectedTab)

        assert(tab === selectedTab, "Expected tab is selected")
        selectedTab?.createWebview()
        selectedTab?.lastExecutedTime = Date.now()

        delegates.forEach { $0.get()?.tabManager(self, didSelectedTabChange: tab, previous: previous, isRestoring: store.isRestoringTabs) }
        if let tab = previous {
            TabEvent.post(.didLoseFocus, for: tab)
        }
        if let tab = selectedTab {
            TabEvent.post(.didGainFocus, for: tab)
            tab.applyTheme()
        }
        TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .tab)

        // Note: we setup last session private case as the session is tied to user's selected
        // tab but there are times when tab manager isn't available and we need to know
        // users's last state (Private vs Regular)
        UserDefaults.standard.set(selectedTab?.isPrivate ?? false, forKey: "wasLastSessionPrivate")
    }

    func getMostRecentHomepageTab() -> Tab? {
        let tabsToFilter = selectedTab?.isPrivate ?? false ? privateTabs : normalTabs
        let homePageTabs = tabsToFilter.filter { $0.isFxHomeTab }

        return mostRecentTab(inTabs: homePageTabs)
    }

    // MARK: - Clear and store
    func preserveTabs() {
        store.preserveTabs(tabs, selectedTab: selectedTab)
    }

    private func shouldClearPrivateTabs() -> Bool {
        return profile.prefs.boolForKey("settings.closePrivateTabs") ?? false
    }

    func cleanupClosedTabs(_ closedTabs: [Tab], previous: Tab?, isPrivate: Bool = false) {
        DispatchQueue.main.async { [unowned self] in
            // select normal tab if there are no private tabs, we need to do this
            // to accommodate for the case when a user dismisses tab tray while
            // they are in private mode and there are no tabs
            if isPrivate && self.privateTabs.count < 1 && !self.normalTabs.isEmpty {
                self.selectTab(mostRecentTab(inTabs: self.normalTabs) ?? self.normalTabs.last,
                               previous: previous)
            }
        }

        // perform remaining tab cleanup related to removing wkwebview
        // observers which can only happen on main thread in close() call
        closedTabs.forEach { tab in
            DispatchQueue.main.async {
                tab.close()
                TabEvent.post(.didClose, for: tab)
            }
        }
    }

    private func saveTabs(toProfile profile: Profile, _ tabs: [Tab]) {
        // It is possible that not all tabs have loaded yet, so we filter out tabs with a nil URL.
        let storedTabs: [RemoteTab] = tabs.compactMap( Tab.toRemoteTab )

        // Don't insert into the DB immediately. We tend to contend with more important
        // work like querying for top sites.
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            profile.storeTabs(storedTabs)
        }
    }

    func storeChanges() {
        saveTabs(toProfile: profile, normalTabs)
        store.preserveTabs(tabs, selectedTab: selectedTab)
    }

    func hasTabsToRestoreAtStartup() -> Bool {
        return store.hasTabsToRestoreAtStartup
    }

    func restoreTabs(_ forced: Bool = false) {
        defer { checkForSingleTab() }
        guard forced || tabs.isEmpty,
              !AppConstants.isRunningUITests,
              !DebugSettingsBundleOptions.skipSessionRestore,
              store.hasTabsToRestoreAtStartup
        else { return }

        isRestoringTabs = true

        var tabToSelect = store.restoreStartupTabs(clearPrivateTabs: shouldClearPrivateTabs(),
                                                   addTabClosure: addTabForRestoration(isPrivate:))

        // If tabToSelect is nil after restoration, force selection of first tab normal tab
        if tabToSelect == nil {
            tabToSelect = tabs.first(where: { $0.isPrivate == false })

            // If tabToSelect is still nil, create a new tab
            if tabToSelect == nil {
                tabToSelect = addTab()
            }
        }

        selectTab(tabToSelect)

        for delegate in self.delegates {
            delegate.get()?.tabManagerDidRestoreTabs(self)
        }

        isRestoringTabs = false
    }

    private func addTabForRestoration(isPrivate: Bool) -> Tab {
        return addTab(flushToDisk: false, zombie: true, isPrivate: isPrivate)
    }

    private func checkForSingleTab() {
        // Always make sure there is a single normal tab.
        if normalTabs.isEmpty {
            let tab = addTab()
            if selectedTab == nil { selectTab(tab) }
        }
    }

    /// When all history gets deleted, we use this special way to handle Tab History deletion. To make it appear like
    /// the currently open tab also has its history deleted, we close the tab and reload that URL in a new tab.
    /// We handle it this way because, as far as I can tell, clearing history REQUIRES we nil the webView. The backForwardList
    /// is not directly mutable. When niling out the webView, we should properly close it since it affects KVO.
    func clearAllTabsHistory() {
        guard let selectedTab = selectedTab, let url = selectedTab.url else { return }

        for tab in tabs where tab !== selectedTab {
            tab.clearAndResetTabHistory()
        }

        removeTab(selectedTab)

        let tabToSelect: Tab
        if url.isFxHomeUrl {
            tabToSelect = addTab(PrivilegedRequest(url: url) as URLRequest, isPrivate: selectedTab.isPrivate)
        } else {
            let request = URLRequest(url: url)
            tabToSelect = addTab(request, isPrivate: selectedTab.isPrivate)
        }

        selectTab(tabToSelect)
    }

    // MARK: - Add tabs
    func addTab(_ request: URLRequest?, afterTab: Tab?, isPrivate: Bool) -> Tab {
        return addTab(request,
                      configuration: nil,
                      afterTab: afterTab,
                      flushToDisk: true,
                      zombie: false,
                      isPrivate: isPrivate)
    }

    @discardableResult func addTab(_ request: URLRequest! = nil,
                                   configuration: WKWebViewConfiguration! = nil,
                                   afterTab: Tab? = nil,
                                   zombie: Bool = false,
                                   isPrivate: Bool = false
    ) -> Tab {
        return addTab(request,
                      configuration: configuration,
                      afterTab: afterTab,
                      flushToDisk: true,
                      zombie: zombie,
                      isPrivate: isPrivate)
    }

    func addTabsForURLs(_ urls: [URL], zombie: Bool) {
        if urls.isEmpty {
            return
        }

        var tab: Tab!
        for url in urls {
            tab = addTab(URLRequest(url: url), flushToDisk: false, zombie: zombie)
        }

        // Select the most recent.
        selectTab(tab)
        // Okay now notify that we bulk-loaded so we can adjust counts and animate changes.
        delegates.forEach { $0.get()?.tabManagerDidAddTabs(self) }

        // Flush.
        storeChanges()
    }

    func addTab(_ request: URLRequest? = nil,
                configuration: WKWebViewConfiguration? = nil,
                afterTab: Tab? = nil,
                flushToDisk: Bool,
                zombie: Bool,
                isPrivate: Bool = false
    ) -> Tab {
        // Take the given configuration. Or if it was nil, take our default configuration for the current browsing mode.
        if isPrivate{
            privateConfiguration = TabManager.makeWebViewConfig(isPrivate: true, prefs: profile.prefs,forType: .dappBrowser(server), messageHandler:   ScriptMessageProxy(delegate: self))
        }else{
            self.configuration = TabManager.makeWebViewConfig(isPrivate: false, prefs: profile.prefs,forType: .dappBrowser(server), messageHandler:   ScriptMessageProxy(delegate: self))
        }
        let tab = Tab(profile: profile, configuration: isPrivate ? privateConfiguration : self.configuration, isPrivate: isPrivate)
        tab.delegate = self
        configureTab(tab, request: request, afterTab: afterTab, flushToDisk: flushToDisk, zombie: zombie)
        return tab
    }
    
    func notifyFinish(callbackId: Int, value: Swift.Result<DappCallback, JsonRpcError>) {
        switch value {
        case .success(let result):
            self.selectedTab?.webView?.evaluateJavaScript("executeCallback(\(callbackId), null, \"\(result.value.object)\")")
        case .failure(let error):
            self.selectedTab?.webView?.evaluateJavaScript("executeCallback(\(callbackId), {message: \"\(error.message)\", code: \(error.code)}, null)")
        }
    }

    func addPopupForParentTab(profile: Profile, parentTab: Tab, configuration: WKWebViewConfiguration) -> Tab {
        let popup = Tab(profile: profile, configuration: configuration, isPrivate: parentTab.isPrivate)
        configureTab(popup, request: nil, afterTab: parentTab, flushToDisk: true, zombie: false, isPopup: true)

        // Wait momentarily before selecting the new tab, otherwise the parent tab
        // may be unable to set `window.location` on the popup immediately after
        // calling `window.open("")`.
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySelectingNewPopupTab) {
            self.selectTab(popup)
        }

        return popup
    }

    func configureTab(_ tab: Tab,
                      request: URLRequest?,
                      afterTab parent: Tab? = nil,
                      flushToDisk: Bool,
                      zombie: Bool,
                      isPopup: Bool = false
    ) {
        // If network is not available webView(_:didCommit:) is not going to be called
        // We should set request url in order to show url in url bar even no network
        tab.url = request?.url
        var placeNextToParentTab = false
        if parent == nil || parent?.isPrivate != tab.isPrivate {
            tabs.append(tab)
        } else if let parent = parent, var insertIndex = tabs.firstIndex(of: parent) {
            placeNextToParentTab = true
            insertIndex += 1

            // If we are on iPad (.TopTabTray), the new tab should be inserted immediately after the parent tab.
            // In this scenario the while loop shouldn't be executed.
            while insertIndex < tabs.count && tabs[insertIndex].isDescendentOf(parent) && tabDisplayType == .TabGrid {
                insertIndex += 1
            }

            tab.parent = parent
            tabs.insert(tab, at: insertIndex)
        }

        delegates.forEach { $0.get()?.tabManager(self,
                                                 didAddTab: tab,
                                                 placeNextToParentTab: placeNextToParentTab,
                                                 isRestoring: store.isRestoringTabs) }

        if !zombie {
            tab.createWebview()
        }
        tab.navigationDelegate = self.navDelegate

        if let request = request {
            tab.loadRequest(request)
        } else if !isPopup {
            let newTabChoice = NewTabAccessors.getNewTabPage(profile.prefs)
            tab.newTabPageType = newTabChoice
            switch newTabChoice {
            case .homePage:
                // We definitely have a homepage if we've got here
                // (so we can safely dereference it).
                let url = NewTabHomePageAccessors.getHomePage(profile.prefs)!
                tab.loadRequest(URLRequest(url: url))
            case .blankPage:
                // If we're showing "about:blank" in a webview, set
                // the <html> `background-color` to match the theme.
                if let webView = tab.webView as? TabWebView {
                    webView.applyTheme()
                }
                break
            default:
                // The common case, where the NewTabPage enum defines
                // one of the about:home pages.
                if let url = newTabChoice.url {
                    tab.loadRequest(PrivilegedRequest(url: url) as URLRequest)
                    tab.url = url
                }
            }
        }

        tab.nightMode = NightModeHelper.isActivated()
        tab.noImageMode = NoImageModeHelper.isActivated(profile.prefs)

        if flushToDisk {
            storeChanges()
        }
    }

    // MARK: - Move tabs
    func moveTab(isPrivate privateMode: Bool, fromIndex visibleFromIndex: Int, toIndex visibleToIndex: Int) {
        let currentTabs = privateMode ? privateTabs : normalTabs

        guard visibleFromIndex < currentTabs.count, visibleToIndex < currentTabs.count else { return }

        let fromIndex = tabs.firstIndex(of: currentTabs[visibleFromIndex]) ?? tabs.count - 1
        let toIndex = tabs.firstIndex(of: currentTabs[visibleToIndex]) ?? tabs.count - 1

        let previouslySelectedTab = selectedTab

        tabs.insert(tabs.remove(at: fromIndex), at: toIndex)

        if let previouslySelectedTab = previouslySelectedTab, let previousSelectedIndex = tabs.firstIndex(of: previouslySelectedTab) {
            _selectedIndex = previousSelectedIndex
        }

        storeChanges()
    }

    // MARK: - Privacy change
    enum SwitchPrivacyModeResult { case createdNewTab; case usedExistingTab }
    func switchPrivacyMode() -> SwitchPrivacyModeResult {
        var result = SwitchPrivacyModeResult.usedExistingTab
        guard let selectedTab = selectedTab else { return result }
        let nextSelectedTab: Tab?

        if selectedTab.isPrivate {
            nextSelectedTab = mostRecentTab(inTabs: normalTabs)
        } else if privateTabs.isEmpty {
            nextSelectedTab = addTab(isPrivate: true)
            result = .createdNewTab
        } else {
            nextSelectedTab = mostRecentTab(inTabs: privateTabs)
        }

        selectTab(nextSelectedTab)

        let notificationObject = [Tab.privateModeKey: nextSelectedTab?.isPrivate ?? true]
        NotificationCenter.default.post(name: .TabsPrivacyModeChanged, object: notificationObject)
        return result
    }

    // Called by other classes to signal that they are entering/exiting private mode
    // This is called by TabTrayVC when the private mode button is pressed and BEFORE we've switched to the new mode
    // we only want to remove all private tabs when leaving PBM and not when entering.
    func willSwitchTabMode(leavingPBM: Bool) {
        recentlyClosedForUndo.removeAll()

        // Clear every time entering/exiting this mode.
        Tab.ChangeUserAgent.privateModeHostList = Set<String>()
    }

    // MARK: - Remove tabs
    func removeTab(_ tab: Tab, completion: (() -> Void)? = nil) {
        guard let index = tabs.firstIndex(where: { $0 === tab }) else { return }
        DispatchQueue.main.async { [unowned self] in
            // gather the index of the deleted tab within the viable tabs array
            // so we can select the correct next tab after deletion
            let viableTabsIndex = deletedIndexForViableTabs(tab)
            self.removeTab(tab, flushToDisk: true)
            self.updateIndexAfterRemovalOf(tab, deletedIndex: index, viableTabsIndex: viableTabsIndex)
            completion?()
        }

        TelemetryWrapper.recordEvent(
            category: .action,
            method: .close,
            object: .tab,
            value: tab.isPrivate ? .privateTab : .normalTab
        )
    }

    /// Remove a tab, will notify delegate of the tab removal
    /// - Parameters:
    ///   - tab: the tab to remove
    ///   - flushToDisk: Will store changes if true, and update selected index
    private func removeTab(_ tab: Tab, flushToDisk: Bool) {
        guard let removalIndex = tabs.firstIndex(where: { $0 === tab }) else {
            logger.log("Could not find index of tab to remove",
                       level: .warning,
                       category: .tabs,
                       description: "Tab count: \(count)")
            return
        }

        let prevCount = count
        tabs.remove(at: removalIndex)
        assert(count == prevCount - 1, "Make sure the tab count was actually removed")

        if tab.isPrivate && privateTabs.count < 1 {

            privateConfiguration = TabManager.makeWebViewConfig(isPrivate: true, prefs: profile.prefs, forType: .dappBrowser(server), messageHandler:  ScriptMessageProxy(delegate: self))
        }

        tab.close()

        // Notify of tab removal
        ensureMainThread { [unowned self] in
            delegates.forEach { $0.get()?.tabManager(self, didRemoveTab: tab, isRestoring: store.isRestoringTabs) }
            TabEvent.post(.didClose, for: tab)
        }

        if flushToDisk {
            storeChanges()
        }
    }

    func removeTabs(_ tabs: [Tab]) {
        for tab in tabs {
            self.removeTab(tab, flushToDisk: false)
        }
        storeChanges()
    }

    func backgroundRemoveAllTabs(isPrivate: Bool = false,
                                 didClearTabs: @escaping (_ tabsToRemove: [Tab],
                                                          _ isPrivate: Bool,
                                                          _ previousTabUUID: String) -> Void) {
        let previousSelectedTabUUID = selectedTab?.tabUUID ?? ""
        // moved closing of multiple tabs to background thread
        DispatchQueue.global(qos: .background).async { [unowned self] in
            let tabsToRemove = isPrivate ? self.privateTabs : self.normalTabs

            if isPrivate && self.privateTabs.count < 1 {
                // Bugzilla 1646756: close last private tab clears the WKWebViewConfiguration (#6827)
                DispatchQueue.main.async { [unowned self] in
                    self.privateConfiguration = TabManager.makeWebViewConfig(isPrivate: true,

                                                                             prefs: self.profile.prefs, forType: .dappBrowser(server), messageHandler:  ScriptMessageProxy(delegate: self))
                }
            }

            // clear Tabs from the list that we need to remove
            self.tabs = self.tabs.filter { !tabsToRemove.contains($0) }

            // update tab manager count
            DispatchQueue.main.async { [unowned self] in
                self.delegates.forEach { $0.get()?.tabManagerUpdateCount?() }
            }

            DispatchQueue.main.async { [unowned self] in
                // after closing all normal tabs we should add a normal tab
                if self.normalTabs.isEmpty {
                    self.selectTab(self.addTab())
                    storeChanges()
                }
            }

            DispatchQueue.main.async {
                didClearTabs(tabsToRemove, isPrivate, previousSelectedTabUUID)
            }
        }
    }

    // MARK: - Snackbars
    func expireSnackbars() {
        for tab in tabs {
            tab.expireSnackbars()
        }
    }

    // MARK: - Toasts
    func makeToastFromRecentlyClosedUrls(_ recentlyClosedTabs: [Tab],
                                         isPrivate: Bool,
                                         previousTabUUID: String) {
        guard !recentlyClosedTabs.isEmpty else { return }

        // Add last 10 tab(s) to recently closed list
        // Note: The recently closed tab list is only updated when the undo
        // snackbar disappears and does not update if someone taps on undo button
        recentlyClosedTabs.suffix(10).forEach { tab in
            if let url = tab.lastKnownUrl, !(InternalURL(url)?.isAboutURL ?? false), !tab.isPrivate {
                profile.recentlyClosedTabs.addTab(url as URL,
                                                  title: tab.lastTitle,
                                                  lastExecutedTime: tab.lastExecutedTime)
            }
        }

        // Toast
        let viewModel = ButtonToastViewModel(
            labelText: String.localizedStringWithFormat(.TabsDeleteAllUndoTitle, recentlyClosedTabs.count),
            buttonText: .TabsDeleteAllUndoAction)
        // Passing nil theme because themeManager is not available,
        // calling to applyTheme with proper theme before showing
        let toast = ButtonToast(viewModel: viewModel,
                                theme: nil,
                                completion: { buttonPressed in
            // Handles undo to Close tabs
            if buttonPressed {
                self.reAddTabs(tabsToAdd: recentlyClosedTabs,
                               previousTabUUID: previousTabUUID)
                NotificationCenter.default.post(name: .DidTapUndoCloseAllTabToast, object: nil)
            } else {
                // Finish clean up for recently close tabs
                DispatchQueue.global(qos: .background).async { [unowned self] in
                    let previousTab = tabs.first(where: { $0.tabUUID == previousTabUUID })

                    self.cleanupClosedTabs(recentlyClosedTabs,
                                           previous: previousTab,
                                           isPrivate: isPrivate)
                }
            }
        })
        delegates.forEach { $0.get()?.tabManagerDidRemoveAllTabs(self, toast: toast) }
    }

    // MARK: - Private
    @objc private func prefsDidChange() {
        DispatchQueue.main.async {
            let allowPopups = !(self.profile.prefs.boolForKey(PrefsKeys.KeyBlockPopups) ?? true)
            // Each tab may have its own configuration, so we should tell each of them in turn.
            for tab in self.tabs {
                tab.webView?.configuration.preferences.javaScriptCanOpenWindowsAutomatically = allowPopups
            }
            // The default tab configurations also need to change.
            self.configuration.preferences.javaScriptCanOpenWindowsAutomatically = allowPopups
            self.privateConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = allowPopups
        }
    }

    // returns all activate tabs (private or normal)
    private func viableTabs(isPrivate: Bool = false) -> [Tab] {
        if !isPrivate, featureFlags.isFeatureEnabled(.inactiveTabs, checking: .buildAndUser) {
            // only use active tabs as viable tabs
            // we cannot use recentlyAccessedNormalTabs as this is filtering for sponsored and sorting tabs
            return InactiveTabViewModel.getActiveEligibleTabsFrom(normalTabs, profile: profile)
        } else {
            return isPrivate ? privateTabs : normalTabs
        }
    }

    // returns the index of a deleted tab in the viable tabs array
    private func deletedIndexForViableTabs(_ tab: Tab) -> Int {
        let viableTabs = viableTabs(isPrivate: tab.isPrivate)
        return viableTabs.firstIndex(of: tab) ?? -1
    }

    private func updateIndexAfterRemovalOf(_ tab: Tab, deletedIndex: Int, viableTabsIndex: Int) {
        let closedLastNormalTab = !tab.isPrivate && normalTabs.isEmpty
        let closedLastPrivateTab = tab.isPrivate && privateTabs.isEmpty

        if closedLastNormalTab {
            selectTab(addTab(), previous: tab)
        } else if closedLastPrivateTab {
            selectTab(mostRecentTab(inTabs: tabs) ?? tabs.last, previous: tab)
        } else if deletedIndex == _selectedIndex {
            if !selectParentTab(afterRemoving: tab) {
                let viableTabs = viableTabs(isPrivate: tab.isPrivate)

                if let rightOrLeftTab = viableTabs[safe: viableTabsIndex] ?? viableTabs[safe: viableTabsIndex - 1] {
                    selectTab(rightOrLeftTab, previous: tab)
                } else {
                    selectTab(mostRecentTab(inTabs: viableTabs) ?? viableTabs.last, previous: tab)
                }
            }
        } else if deletedIndex < _selectedIndex {
            let selected = tabs[safe: _selectedIndex - 1]
            selectTab(selected, previous: selected)
        }
    }

    private func reAddTabs(tabsToAdd: [Tab], previousTabUUID: String) {
        tabs.append(contentsOf: tabsToAdd)
        let tabToSelect = tabs.first(where: { $0.tabUUID == previousTabUUID })
        let currentlySelectedTab = selectedTab
        if let tabToSelect = tabToSelect, let currentlySelectedTab = currentlySelectedTab {
            // remove currently selected tab
            removeTabs([currentlySelectedTab])
            // select previous tab
            selectTab(tabToSelect, previous: nil)
        }
        delegates.forEach { $0.get()?.tabManagerUpdateCount?() }
        storeChanges()
    }

    // Select the most recently visited tab, IFF it is also the parent tab of the closed tab.
    private func selectParentTab(afterRemoving tab: Tab) -> Bool {
        let viableTabs = (tab.isPrivate ? privateTabs : normalTabs).filter { $0 != tab }
        guard let parentTab = tab.parent,
              parentTab != tab,
              !viableTabs.isEmpty,
              viableTabs.contains(parentTab)
        else { return false }

        let parentTabIsMostRecentUsed = mostRecentTab(inTabs: viableTabs) == parentTab

        if parentTabIsMostRecentUsed, parentTab.lastExecutedTime != nil {
            selectTab(parentTab, previous: tab)
            return true
        }
        return false
    }

    private func removeAllPrivateTabs() {
        // reset the selectedTabIndex if we are on a private tab because we will be removing it.
        if selectedTab?.isPrivate ?? false {
            _selectedIndex = -1
        }
        privateTabs.forEach { $0.close() }
        tabs = normalTabs
        privateConfiguration = TabManager.makeWebViewConfig(isPrivate: true, prefs: profile.prefs, forType: .dappBrowser(server), messageHandler:  ScriptMessageProxy(delegate: self))
    }

    // MARK: - Start at Home

    /// Public interface for checking whether the StartAtHome Feature should run.
    func startAtHomeCheck() {
        let startAtHomeManager = StartAtHomeHelper(isRestoringTabs: isRestoringTabs)

        guard !startAtHomeManager.shouldSkipStartHome else { return }

        if startAtHomeManager.shouldStartAtHome() {
            let wasLastSessionPrivate = selectedTab?.isPrivate ?? false
            let scannableTabs = wasLastSessionPrivate ? privateTabs : normalTabs
            let existingHomeTab = startAtHomeManager.scanForExistingHomeTab(in: scannableTabs,
                                                                            with: profile.prefs)
            let tabToSelect = createStartAtHomeTab(withExistingTab: existingHomeTab,
                                                   inPrivateMode: wasLastSessionPrivate,
                                                   and: profile.prefs)
            selectTab(tabToSelect)
        }
    }

    /// Provides a tab on which to open if the start at home feature is enabled. This tab
    /// can be an existing one, or, if no suitable candidate exists, a new one.
    ///
    /// - Parameters:
    ///   - existingTab: A `Tab` that is the user's homepage, that is already open
    ///   - privateMode: Whether the last session was private or not, so that, if there's
    ///   no homepage open, we open a new tab in the correct state.
    ///   - profilePreferences: Preferences, stored in the user's `Profile`
    /// - Returns: A selectable tab
    private func createStartAtHomeTab(withExistingTab existingTab: Tab?,
                                      inPrivateMode privateMode: Bool,
                                      and profilePreferences: Prefs
    ) -> Tab? {
        let page = NewTabAccessors.getHomePage(profilePreferences)
        let customUrl = HomeButtonHomePageAccessors.getHomePage(profilePreferences)
        let homeUrl = URL(string: "internal://local/about/home")

        if page == .homePage, let customUrl = customUrl {
            return existingTab ?? addTab(URLRequest(url: customUrl), isPrivate: privateMode)
        } else if page == .topSites, let homeUrl = homeUrl {
            let home = existingTab ?? addTab(isPrivate: privateMode)
            home.loadRequest(PrivilegedRequest(url: homeUrl) as URLRequest)
            home.url = homeUrl
            return home
        }

        return selectedTab ?? addTab()
    }
}

// MARK: - WKNavigationDelegate
extension TabManager: WKNavigationDelegate {
    // Note the main frame JSContext (i.e. document, window) is not available yet.
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let tab = self[webView], let blocker = tab.contentBlocker {
            blocker.clearPageStats()
        }
    }

    // The main frame JSContext is available, and DOM parsing has begun.
    // Do not execute JS at this point that requires running prior to DOM parsing.
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let tab = self[webView] else { return }

        if let tpHelper = tab.contentBlocker, !tpHelper.isEnabled {
            webView.evaluateJavascriptInDefaultContentWorld("window.__firefox__.TrackingProtectionStats.setEnabled(false, \(UserScriptManager.appIdToken))")
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // tab restore uses internal pages, so don't call storeChanges unnecessarily on startup
        if let url = webView.url {
            if let internalUrl = InternalURL(url), internalUrl.isSessionRestore {
                return
            }

            storeChanges()
        }
    }

    /// Called when the WKWebView's content process has gone away. If this happens for the currently selected tab
    /// then we immediately reload it.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        if let tab = selectedTab, tab.webView == webView {
            tab.consecutiveCrashes += 1

            // Only automatically attempt to reload the crashed
            // tab three times before giving up.
            if tab.consecutiveCrashes < 3 {
                webView.reload()
            } else {
                tab.consecutiveCrashes = 0
            }
        }
    }
}

// MARK: - TabEventHandler
extension TabManager: TabEventHandler {
    func tabDidSetScreenshot(_ tab: Tab, hasHomeScreenshot: Bool) {
        guard tab.screenshot != nil else {
            // Remove screenshot from image store so we can use favicon
            // when a screenshot isn't available for the associated tab url
            removeScreenshot(tab: tab)
            return
        }
        storeScreenshot(tab: tab)
    }

    private func storeScreenshot(tab: Tab) {
        store.preserveScreenshot(forTab: tab)
        storeChanges()
    }

    private func removeScreenshot(tab: Tab) {
        store.removeScreenshot(forTab: tab)
        storeChanges()
    }
}

// MARK: - Test cases helpers
extension TabManager {
    func testRemoveAll() {
        assert(AppConstants.isRunningTest)
        removeTabs(self.tabs)
    }

    func testClearArchive() {
        assert(AppConstants.isRunningTest)
        store.clearArchive()
    }
}
extension TabManager: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let command = DappAction.fromMessage(message) else {
            if message.name == Browser.locationChangedEventName {
                recordUrlSubject.send(())
            }
            return
        }
        print("[Browser] dapp command: \(command)")
        let action = DappAction.fromCommand(command, server: server)

        print("[Browser] dapp action: \(action)")
        dappActionSubject.send((action: action, callbackId: command.id))
    }
}
