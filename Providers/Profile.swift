// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

// IMPORTANT!: Please take into consideration when adding new imports to
// this file that it is utilized by external components besides the core
// application (i.e. App Extensions). Introducing new dependencies here
// may have unintended negative consequences for App Extensions such as
// increased startup times which may lead to termination by the OS.

import Common
import Account
import Shared
import Storage
import AuthenticationServices
import MozillaAppServices

public protocol SyncManager {
    var lastSyncFinishTime: Timestamp? { get set }
    func endTimedSyncs()
    func applicationDidBecomeActive()
    func applicationDidEnterBackground()
}


class ProfileFileAccessor: FileAccessor {
    convenience init(profile: Profile) {
        self.init(localName: profile.localName())
    }

    init(localName: String, logger: Logger = DefaultLogger.shared) {
        let profileDirName = "profile.\(localName)"

        // Bug 1147262: First option is for device, second is for simulator.
        var rootPath: String
        let sharedContainerIdentifier = AppInfo.sharedContainerIdentifier
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: sharedContainerIdentifier) {
            rootPath = url.path
        } else {
            logger.log("Unable to find the shared container. Defaulting profile location to ~/Documents instead.",
                       level: .warning,
                       category: .unlabeled)
            rootPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        }

        super.init(rootPath: URL(fileURLWithPath: rootPath).appendingPathComponent(profileDirName).path)
    }
}

class CommandStoringSyncDelegate {
    let profile: Profile

    init(profile: Profile) {
        self.profile = profile
    }

    public func displaySentTab(for url: URL, title: String, from deviceName: String?) {
        let item = ShareItem(url: url.absoluteString, title: title)
        _ = self.profile.queue.addToQueue(item)
    }
}

/**
 * A Profile manages access to the user's data.
 */
protocol Profile: AnyObject {
    var places: RustPlaces { get }
    var prefs: Prefs { get }
    var queue: TabQueue { get }
    var searchEngines: SearchEngines { get }
    var files: FileAccessor { get }
    var pinnedSites: PinnedSites { get }
    var logins: RustLogins { get }
    var certStore: CertStore { get }
    var recentlyClosedTabs: ClosedTabsStore { get }

    #if !MOZ_TARGET_NOTIFICATIONSERVICE
        var readingList: ReadingList { get }
    #endif

    var isShutdown: Bool { get }

    /// WARNING: Only to be called as part of the app lifecycle from the AppDelegate
    /// or from App Extension code.
    func shutdown()

    /// WARNING: Only to be called as part of the app lifecycle from the AppDelegate
    /// or from App Extension code.
    func reopen()

    // I got really weird EXC_BAD_ACCESS errors on a non-null reference when I made this a getter.
    // Similar to <http://stackoverflow.com/questions/26029317/exc-bad-access-when-indirectly-accessing-inherited-member-in-swift>.
    func localName() -> String

    // Async call to wait for result
    func hasSyncAccount(completion: @escaping (Bool) -> Void)

    // Do we have an account at all?
    func hasAccount() -> Bool

    // Do we have an account that (as far as we know) is in a syncable state?
    func hasSyncableAccount() -> Bool

    var rustFxA: RustFirefoxAccounts { get }

    func removeAccount()

    func getCachedClientsAndTabs(completion: @escaping ([ClientAndTabs]) -> Void)
    func getCachedClientsAndTabs() -> Deferred<Maybe<[ClientAndTabs]>>

    func cleanupHistoryIfNeeded()

    @discardableResult func storeTabs(_ tabs: [RemoteTab]) -> Deferred<Maybe<Int>>

    func sendItem(_ item: ShareItem, toDevices devices: [RemoteDevice]) -> Success
    func pollCommands(forcePoll: Bool)

    var syncManager: SyncManager! { get }
    func hasSyncedLogins() -> Deferred<Maybe<Bool>>

    func syncCredentialIdentities() -> Deferred<Result<Void, Error>>
    func updateCredentialIdentities() -> Deferred<Result<Void, Error>>
    func clearCredentialStore() -> Deferred<Result<Void, Error>>
}

extension Profile {
    func syncCredentialIdentities() -> Deferred<Result<Void, Error>> {
        let deferred = Deferred<Result<Void, Error>>()
        self.clearCredentialStore().upon { clearResult in
            self.updateCredentialIdentities().upon { updateResult in
                switch (clearResult, updateResult) {
                case (.success, .success):
                    deferred.fill(.success(()))
                case (.failure(let error), _):
                    deferred.fill(.failure(error))
                case (_, .failure(let error)):
                    deferred.fill(.failure(error))
                }
            }
        }
        return deferred
    }

    func updateCredentialIdentities() -> Deferred<Result<Void, Error>> {
        let deferred = Deferred<Result<Void, Error>>()
        self.logins.listLogins().upon { loginResult in
            switch loginResult {
            case let .failure(error):
                deferred.fill(.failure(error))
            case let .success(logins):

                self.populateCredentialStore(
                        identities: logins.map(\.passwordCredentialIdentity)
                ).upon(deferred.fill)
            }
        }
        return deferred
    }

    func populateCredentialStore(identities: [ASPasswordCredentialIdentity]) -> Deferred<Result<Void, Error>> {
        let deferred = Deferred<Result<Void, Error>>()
        ASCredentialIdentityStore.shared.saveCredentialIdentities(identities) { (success, error) in
            if success {
                deferred.fill(.success(()))
            } else if let err = error {
                deferred.fill(.failure(err))
            }
        }
        return deferred
    }

    func clearCredentialStore() -> Deferred<Result<Void, Error>> {
        let deferred = Deferred<Result<Void, Error>>()

        ASCredentialIdentityStore.shared.removeAllCredentialIdentities { (success, error) in
            if success {
                deferred.fill(.success(()))
            } else if let err = error {
                deferred.fill(.failure(err))
            }
        }

        return deferred
    }
}

open class BrowserProfile: Profile {
    private let logger: Logger
    fileprivate let name: String
    fileprivate let keychain: MZKeychainWrapper
    var isShutdown = false

    internal let files: FileAccessor

    let database: BrowserDB
    let readingListDB: BrowserDB
    var syncManager: SyncManager!


    /**
     * N.B., BrowserProfile is used from our extensions, often via a pattern like
     *
     *   BrowserProfile(…).foo.saveSomething(…)
     *
     * This can break if BrowserProfile's initializer does async work that
     * subsequently — and asynchronously — expects the profile to stick around:
     * see Bug 1218833. Be sure to only perform synchronous actions here.
     *
     * A SyncDelegate can be provided in this initializer, or once the profile is initialized.
     * However, if we provide it here, it's assumed that we're initializing it from the application.
     */
    init(localName: String,
         clear: Bool = false,
         logger: Logger = DefaultLogger.shared) {
        logger.log("Initing profile \(localName) on thread \(Thread.current).",
                   level: .debug,
                   category: .setup)
        self.name = localName
        self.files = ProfileFileAccessor(localName: localName)
        self.keychain = MZKeychainWrapper.sharedClientAppContainerKeychain
        self.logger = logger

        if clear {
            do {
                // Remove the contents of the directory…
                try self.files.removeFilesInDirectory()
                // …then remove the directory itself.
                try self.files.remove("")
            } catch {
                logger.log("Cannot clear profile: \(error)",
                           level: .info,
                           category: .setup)
            }
        }

        // If the profile dir doesn't exist yet, this is first run (for this profile). The check is made here
        // since the DB handles will create new DBs under the new profile folder.
        let isNewProfile = !files.exists("")

        // Set up our database handles.
        self.database = BrowserDB(filename: "browser.db", schema: BrowserSchema(), files: files)
        self.readingListDB = BrowserDB(filename: "ReadingList.db", schema: ReadingListSchema(), files: files)

        if isNewProfile {
            logger.log("New profile. Removing old Keychain/Prefs data.",
                       level: .info,
                       category: .setup)
            MZKeychainWrapper.wipeKeychain()
            prefs.clearAll()
        }

        // Set up logging from Rust.
        if !RustLog.shared.tryEnable({ (level, tag, message) -> Bool in
            let logString = "[RUST][\(tag ?? "no-tag")] \(message)"

            switch level {
            case .trace:
                break
            case .debug:
                logger.log(logString,
                           level: .debug,
                           category: .sync)
            case .info:
                logger.log(logString,
                           level: .info,
                           category: .sync)
            case .warn:
                logger.log(logString,
                           level: .warning,
                           category: .sync)
            case .error:
                logger.log(logString,
                           level: .warning,
                           category: .sync)
            }

            return true
        }) {
            logger.log("Unable to enable logging from Rust",
                       level: .warning,
                       category: .setup)
        }

        // By default, filter logging from Rust below `.info` level.
        try? RustLog.shared.setLevelFilter(filter: .info)

        // This has to happen prior to the databases being opened, because opening them can trigger
        // events to which the SyncManager listens.
        self.syncManager = BrowserSyncManager(profile: self)

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(onLocationChange), name: .OnLocationChange, object: nil)
        notificationCenter.addObserver(self, selector: #selector(onPageMetadataFetched), name: .OnPageMetadataFetched, object: nil)

        if AppInfo.isChinaEdition {
            // Set the default homepage.
            prefs.setString(PrefsDefaults.ChineseHomePageURL, forKey: PrefsKeys.KeyDefaultHomePageURL)

            if prefs.stringForKey(PrefsKeys.KeyNewTab) == nil {
                prefs.setString(PrefsDefaults.ChineseHomePageURL, forKey: PrefsKeys.NewTabCustomUrlPrefKey)
                prefs.setString(PrefsDefaults.ChineseNewTabDefault, forKey: PrefsKeys.KeyNewTab)
            }

            if prefs.stringForKey(PrefsKeys.HomePageTab) == nil {
                prefs.setString(PrefsDefaults.ChineseHomePageURL, forKey: PrefsKeys.HomeButtonHomePageURL)
                prefs.setString(PrefsDefaults.ChineseNewTabDefault, forKey: PrefsKeys.HomePageTab)
            }
        } else {
            // Remove the default homepage. This does not change the user's preference,
            // just the behaviour when there is no homepage.
            prefs.removeObjectForKey(PrefsKeys.KeyDefaultHomePageURL)
        }

        // Create the "Downloads" folder in the documents directory.
        if let downloadsPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Downloads").path {
            try? FileManager.default.createDirectory(atPath: downloadsPath, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func reopen() {
        logger.log("Reopening profile.",
                   level: .debug,
                   category: .storage)
        isShutdown = false

        database.reopenIfClosed()
        _ = logins.reopenIfClosed()
        // it's possible we are going through a history migration
        // lets make sure that if the places connection is already open
        // we don't try to reopen it
        if !places.isOpen {
            _ = places.reopenIfClosed()
        }
        _ = tabs.reopenIfClosed()
        _ = autofill.reopenIfClosed()
    }

    func shutdown() {
        logger.log("Shutting down profile.",
                   level: .debug,
                   category: .storage)
        isShutdown = true

        database.forceClose()
        _ = logins.forceClose()
        _ = places.forceClose()
        _ = tabs.forceClose()
        _ = autofill.forceClose()
    }

    @objc
    func onLocationChange(notification: NSNotification) {
        if let v = notification.userInfo!["visitType"] as? Int,
           let visitType = VisitType(rawValue: v),
           let url = notification.userInfo!["url"] as? URL, !isIgnoredURL(url),
           let title = notification.userInfo!["title"] as? NSString {
            // Only record local vists if the change notification originated from a non-private tab
            if !(notification.userInfo!["isPrivate"] as? Bool ?? false) {
                let result = self.places.applyObservation(
                    visitObservation: VisitObservation(
                        url: url.description,
                        title: title as String,
                        visitType: VisitTransition.fromVisitType(visitType: visitType)
                    )
                )
                result.upon { result in
                    guard result.isSuccess else {
                        self.logger.log(result.failureValue?.localizedDescription ?? "Unknown error adding history visit",
                                        level: .warning,
                                        category: .sync)
                        return
                    }
                }
            }
        } else {
            logger.log("Ignoring location change",
                       level: .debug,
                       category: .lifecycle)
        }
    }

    @objc
    func onPageMetadataFetched(notification: NSNotification) {
        let isPrivate = notification.userInfo?["isPrivate"] as? Bool ?? true
        guard !isPrivate else {
            logger.log("Private mode - Ignoring page metadata.",
                       level: .debug,
                       category: .lifecycle)
            return
        }
        guard let pageURL = notification.userInfo?["tabURL"] as? URL,
              let pageMetadata = notification.userInfo?["pageMetadata"] as? PageMetadata else {
            logger.log("Metadata notification doesn't contain any metadata!",
                       level: .debug,
                       category: .lifecycle)
            return
        }
        let defaultMetadataTTL: UInt64 = 3 * 24 * 60 * 60 * 1000 // 3 days for the metadata to live
        self.metadata.storeMetadata(pageMetadata, forPageURL: pageURL, expireAt: defaultMetadataTTL + Date.now())
    }

    deinit {
        self.syncManager.endTimedSyncs()
    }

    func localName() -> String {
        return name
    }

    lazy var queue: TabQueue = {
        withExtendedLifetime(self.legacyPlaces) {
            return SQLiteQueue(db: self.database)
        }
    }()

    /**
     * Any other class that needs to access any one of these should ensure
     * that this is initialized first.
     */
    private lazy var legacyPlaces: PinnedSites  = {
        return BrowserDBSQLite(database: self.database, prefs: self.prefs)
    }()

    var pinnedSites: PinnedSites {
        return self.legacyPlaces
    }

    lazy var metadata: Metadata = {
        return SQLiteMetadata(db: self.database)
    }()

    lazy var placesDbPath = URL(fileURLWithPath: (try! files.getAndEnsureDirectory()), isDirectory: true).appendingPathComponent("places.db").path
    lazy var browserDbPath =  URL(fileURLWithPath: (try! self.files.getAndEnsureDirectory())).appendingPathComponent("browser.db").path
    lazy var places: RustPlaces = RustPlaces(databasePath: self.placesDbPath)

    public func migrateHistoryToPlaces(callback: @escaping (HistoryMigrationResult) -> Void, errCallback: @escaping (Error?) -> Void) {
        guard FileManager.default.fileExists(atPath: browserDbPath) else {
            // This is the user's first run of the app, they don't have a browserDB, so lets report a successful
            // migration with zero visits
            callback(HistoryMigrationResult(numTotal: 0, numSucceeded: 0, numFailed: 0, totalDuration: 0))
            return
        }
        let lastSyncTimestamp = Int64(syncManager.lastSyncFinishTime ?? 0)
        places.migrateHistory(
            dbPath: browserDbPath,
            lastSyncTimestamp: lastSyncTimestamp,
            completion: callback,
            errCallback: errCallback
        )
    }

    lazy var tabsDbPath = URL(fileURLWithPath: (try! files.getAndEnsureDirectory()), isDirectory: true).appendingPathComponent("tabs.db").path

    lazy var tabs = RustRemoteTabs(databasePath: tabsDbPath)

    lazy var autofillDbPath = URL(fileURLWithPath: (try! files.getAndEnsureDirectory()), isDirectory: true).appendingPathComponent("autofill.db").path

    lazy var autofill = RustAutofill(databasePath: autofillDbPath)

    lazy var searchEngines: SearchEngines = {
        return SearchEngines(prefs: self.prefs, files: self.files)
    }()

    func makePrefs() -> Prefs {
        return NSUserDefaultsPrefs(prefix: self.localName())
    }

    lazy var prefs: Prefs = {
        return self.makePrefs()
    }()

    lazy var readingList: ReadingList = {
        return SQLiteReadingList(db: self.readingListDB)
    }()

    lazy var remoteClientsAndTabs: RemoteClientsAndTabs & ResettableSyncStorage & AccountRemovalDelegate & RemoteDevices = {
        return SQLiteRemoteClientsAndTabs(db: self.database)
    }()

    lazy var certStore: CertStore = {
        return CertStore()
    }()

    lazy var recentlyClosedTabs: ClosedTabsStore = {
        return ClosedTabsStore(prefs: self.prefs)
    }()



    func getTabsWithNativeClients() -> Deferred<Maybe<[ClientAndTabs]>> {
        // Because we are now using the application services tabs component with
        // the iOS clients component (which has additional client data), we need
        // to ensure that the clients we get from the tabs `getAll` call also
        // exists in the clients BrowserDB table. This function will be obsolete
        // once the sync manager component has been integrated into iOS and the
        // iOS client synchronizer has been removed.

        return self.tabs.getAll().bind { tabsResult in
            if let tabsError = tabsResult.failureValue { return deferMaybe(tabsError) }

            guard let clientRemoteTabs = tabsResult.successValue else { return
                deferMaybe([])
            }

            return self.remoteClientsAndTabs.getClients().bind { result in
                if let error = result.failureValue { return deferMaybe(error) }

                guard let clients = result.successValue else { return deferMaybe([]) }

                let clientAndTabs: [ClientAndTabs] = clientRemoteTabs.map { record in
                    // We check if the application services clientId matches any client
                    // GUID. If a client is found we return a record, otherwise we
                    // continue to the next application services record.
                    let localClient = clients.first(where: { $0.guid == record.clientId })

                    if let client = localClient {
                        return record.toClientAndTabs(client: client)
                    }

                    self.logger.log("Could not find client data for appservices client ID \(record.clientId).",
                                    level: .debug,
                                    category: .tabs)
                    return nil
                }.compactMap { $0 }

                return deferMaybe(clientAndTabs)
            }
        }
    }

 
    public func getCachedClientsAndTabs(completion: @escaping ([ClientAndTabs]) -> Void) {
        let defferedResponse = self.getTabsWithNativeClients()
        defferedResponse.upon { result in
            completion(result.successValue ?? [])
        }
    }

    public func getCachedClientsAndTabs() -> Deferred<Maybe<[ClientAndTabs]>> {
        return self.getTabsWithNativeClients()
    }

    public func cleanupHistoryIfNeeded() {
        // We run the cleanup in the background, this is a low priority task
        // that compacts the places db and reduces it's size to be under the limit.
        DispatchQueue.global(qos: .background).async {
            self.places.runMaintenance(dbSizeLimit: AppConstants.databaseSizeLimitInBytes)
        }
    }

    public func sendQueuedSyncEvents() {
        if !hasAccount() {
            // We shouldn't be called at all if the user isn't signed in.
            return
        }
      
    }

    func storeTabs(_ tabs: [RemoteTab]) -> Deferred<Maybe<Int>> {
        return self.tabs.setLocalTabs(localTabs: tabs)
    }

    public func sendItem(_ item: ShareItem, toDevices devices: [RemoteDevice]) -> Success {
        let deferred = Success()
        RustFirefoxAccounts.shared.accountManager.uponQueue(.main) { accountManager in
            guard let constellation = accountManager.deviceConstellation() else {
                deferred.fill(Maybe(failure: NoAccountError()))
                return
            }
            devices.forEach {
                if let id = $0.id {
                    constellation.sendEventToDevice(targetDeviceId: id, e: .sendTab(title: item.title ?? "", url: item.url))
                }
            }
            if let _ = try? accountManager.gatherTelemetry() {
               
            }
            self.sendQueuedSyncEvents()
            deferred.fill(Maybe(success: ()))
        }
        return deferred
    }

    /// Polls for missed send tabs and handles them
    /// The method will not poll FxA if the interval hasn't passed
    /// See AppConstants.fxaCommandsInterval for the interval value
    public func pollCommands(forcePoll: Bool = false) {
        // We should only poll if the interval has passed to not
        // overwhelm FxA
        let lastPoll = self.prefs.timestampForKey(PrefsKeys.PollCommandsTimestamp)
        let now = Date.now()
        if let lastPoll = lastPoll, !forcePoll, now - lastPoll < AppConstants.fxaCommandsInterval {
            return
        }
        self.prefs.setTimestamp(now, forKey: PrefsKeys.PollCommandsTimestamp)
        let accountManager = self.rustFxA.accountManager.peek()
        accountManager?.deviceConstellation()?.pollForCommands { commands in
            if let commands = try? commands.get() {
                for command in commands {
                    switch command {
                    case .tabReceived( _, let tabData):
                        // The tabData.entries is the tabs history
                        // we only want the last item, which is the tab
                        // to display
                        let title = tabData.entries.last?.title ?? ""
                        let url = tabData.entries.last?.url ?? ""
                        if let _ = try? accountManager?.gatherTelemetry() {
                          
                        }
                        if let _ = URL(string: url) {
                        }
                    }
                }
            }
        }
    }

    lazy var logins: RustLogins = {
        let sqlCipherDatabasePath = URL(fileURLWithPath: (try! files.getAndEnsureDirectory()), isDirectory: true).appendingPathComponent("logins.db").path
        let databasePath = URL(fileURLWithPath: (try! files.getAndEnsureDirectory()), isDirectory: true).appendingPathComponent("loginsPerField.db").path

        return RustLogins(sqlCipherDatabasePath: sqlCipherDatabasePath, databasePath: databasePath)
    }()

    func hasSyncAccount(completion: @escaping (Bool) -> Void) {
        rustFxA.hasAccount { hasAccount in
            completion(hasAccount)
        }
    }

    func hasAccount() -> Bool {
        return rustFxA.hasAccount()
    }

    func hasSyncableAccount() -> Bool {
        return hasAccount() && !rustFxA.accountNeedsReauth()
    }

    var rustFxA: RustFirefoxAccounts {
        return RustFirefoxAccounts.shared
    }

    func removeAccount() {
        RustFirefoxAccounts.shared.disconnect()

        // Not available in extensions
        #if !MOZ_TARGET_NOTIFICATIONSERVICE && !MOZ_TARGET_SHARETO && !MOZ_TARGET_CREDENTIAL_PROVIDER
        unregisterRemoteNotifiation()
        #endif

        // remove Account Metadata
        prefs.removeObjectForKey(PrefsKeys.KeyLastRemoteTabSyncTime)

        // Save the keys that will be restored
        let rustAutofillKey = RustAutofillEncryptionKeys()
        let creditCardKey = keychain.string(forKey: rustAutofillKey.ccKeychainKey)
        let rustLoginsKeys = RustLoginEncryptionKeys()
        let perFieldKey = keychain.string(forKey: rustLoginsKeys.loginPerFieldKeychainKey)
        let sqlCipherKey = keychain.string(forKey: rustLoginsKeys.loginsUnlockKeychainKey)
        let sqlCipherSalt = keychain.string(forKey: rustLoginsKeys.loginPerFieldKeychainKey)

        // Remove all items, removal is not key-by-key specific (due to the risk of failing to delete something), simply restore what is needed.
        keychain.removeAllKeys()

        // Restore the keys that are still needed
        if let sqlCipherKey = sqlCipherKey {
            keychain.set(sqlCipherKey, forKey: rustLoginsKeys.loginsUnlockKeychainKey, withAccessibility: MZKeychainItemAccessibility.afterFirstUnlock)
        }

        if let sqlCipherSalt = sqlCipherSalt {
            keychain.set(sqlCipherSalt, forKey: rustLoginsKeys.loginsSaltKeychainKey, withAccessibility: MZKeychainItemAccessibility.afterFirstUnlock)
        }

        if let perFieldKey = perFieldKey {
            keychain.set(perFieldKey, forKey: rustLoginsKeys.loginPerFieldKeychainKey, withAccessibility: .afterFirstUnlock)
        }

        if let creditCardKey = creditCardKey {
            keychain.set(creditCardKey, forKey: rustAutofillKey.ccKeychainKey, withAccessibility: .afterFirstUnlock)
        }

        // Tell any observers that our account has changed.
        NotificationCenter.default.post(name: .FirefoxAccountChanged, object: nil)

        // Trigger cleanup. Pass in the account in case we want to try to remove
        // client-specific data from the server.
    }

    public func hasSyncedLogins() -> Deferred<Maybe<Bool>> {
        return logins.hasSyncedLogins()
    }

    // Profile exists in extensions, UIApp is unavailable there, make this code run for the main app only
    @available(iOSApplicationExtension, unavailable, message: "UIApplication.shared is unavailable in application extensions")
    private func unregisterRemoteNotifiation() {
        if let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication {
            application.unregisterForRemoteNotifications()
        }
    }

    class NoAccountError: MaybeErrorType {
        var description = "No account."
    }

    // Extends NSObject so we can use timers.
    public class BrowserSyncManager: NSObject, SyncManager {        
        // We shouldn't live beyond our containing BrowserProfile, either in the main app or in
        // an extension.
        // But it's possible that we'll finish a side-effect sync after we've ditched the profile
        // as a whole, so we hold on to our Prefs, potentially for a little while longer. This is
        // safe as a strong reference, because there's no cycle.
        unowned fileprivate let profile: BrowserProfile
        fileprivate let prefs: Prefs
        fileprivate var constellationStateUpdate: Any?

        let FifteenMinutes = TimeInterval(60 * 15)
        let OneMinute = TimeInterval(60)

        fileprivate var syncTimer: Timer?

        fileprivate var backgrounded: Bool = true
        private let logger: Logger

        deinit {
            if let c = constellationStateUpdate {
                NotificationCenter.default.removeObserver(c)
            }
        }

        public func applicationDidBecomeActive() {
            backgrounded = false

            guard self.profile.hasSyncableAccount() else { return }

            self.beginTimedSyncs()

            // Sync now if it's been more than our threshold.
            let now = Date.now()
            let then = self.lastSyncFinishTime ?? 0
            guard now >= then else {
                logger.log("Time was modified since last sync.",
                           level: .debug,
                           category: .sync)
                return
            }
            let since = now - then

            logger.log("\(since)msec since last sync.",
                       level: .debug,
                       category: .sync)
          
        }

        public func applicationDidEnterBackground() {
            backgrounded = true
        }

        // The dispatch queue for coordinating syncing and resetting the database.
        fileprivate let syncQueue = DispatchQueue(label: "com.mozilla.firefox.sync")

        fileprivate func beginSyncing() {
            notifySyncing(notification: .ProfileDidStartSyncing)
        }

        func canSendUsageData() -> Bool {
            return profile.prefs.boolForKey(AppConstants.prefSendUsageData) ?? true
        }

        private func notifySyncing(notification: Notification.Name) {
        }

        init(profile: BrowserProfile,
             logger: Logger = DefaultLogger.shared) {
            self.profile = profile
            self.prefs = profile.prefs
            self.logger = logger

            super.init()

            let center = NotificationCenter.default

            center.addObserver(self, selector: #selector(onDatabaseWasRecreated), name: .DatabaseWasRecreated, object: nil)
            center.addObserver(self, selector: #selector(onStartSyncing), name: .ProfileDidStartSyncing, object: nil)
            center.addObserver(self, selector: #selector(onFinishSyncing), name: .ProfileDidFinishSyncing, object: nil)
        }

        // TODO: Do we still need this/do we need to do this for our new DB too?
        private func handleRecreationOfDatabaseNamed(name: String?) -> Success {
            let browserCollections = ["history", "tabs"]
            let dbName = name ?? "<all>"
            switch dbName {
            case "<all>", "browser.db":
                return self.locallyResetCollections(browserCollections)
            default:
                logger.log("Unknown database \(dbName).",
                           level: .debug,
                           category: .sync)
                return succeed()
            }
        }

        func doInBackgroundAfter(_ millis: Int64, _ block: @escaping () -> Void) {
            let queue = DispatchQueue.global(qos: DispatchQoS.background.qosClass)
            // Pretty ambiguous here. I'm thinking .now was DispatchTime.now() and not Date.now()
            queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(millis)), execute: block)
        }

        @objc
        func onDatabaseWasRecreated(notification: NSNotification) {
            let name = notification.object as? String
            logger.log("Database was recreated with \(name ?? "nil").",
                       level: .debug,
                       category: .storage)

            // We run this in the background after a few hundred milliseconds;
            // it doesn't really matter when it runs, so long as it doesn't
            // happen in the middle of a sync.

            let resetDatabase = {
                return self.handleRecreationOfDatabaseNamed(name: name) >>== {
                    self.logger.log("Reset of \(name ?? "nil") done",
                                    level: .debug,
                                    category: .storage)
                }
            }
        }

        public var lastSyncFinishTime: Timestamp? {
            get {
                return self.prefs.timestampForKey(PrefsKeys.KeyLastSyncFinishTime)
            }

            set(value) {
                if let value = value {
                    self.prefs.setTimestamp(value, forKey: PrefsKeys.KeyLastSyncFinishTime)
                } else {
                    self.prefs.removeObjectForKey(PrefsKeys.KeyLastSyncFinishTime)
                }
            }
        }

        @objc func onStartSyncing(_ notification: NSNotification) {
        }

        @objc func onFinishSyncing(_ notification: NSNotification) {
          
        }

        var prefsForSync: Prefs {
            return self.prefs.branch("sync")
        }

        func locallyResetCollections(_ collections: [String]) -> Success {
            return walk(collections, f: self.locallyResetCollection)
        }

        func locallyResetCollection(_ collection: String) -> Success {
            switch collection {
            case "bookmarks":
                return self.profile.places.resetBookmarksMetadata()
            case "clients":
                fallthrough
            case "tabs":
                // When tabs and clients were managed in the same database, we reset them together so we're
                // continuting to do that here although it may no longer be necessary

                return self.profile.tabs.resetSync()

            case "history":
                return self.profile.places.resetHistoryMetadata()
            case "passwords":
                return self.profile.logins.resetSync()
            case "forms":
                logger.log("Requested reset for forms, but this client doesn't sync them yet.",
                           level: .debug,
                           category: .sync)
                return succeed()
            case "addons":
                logger.log("Requested reset for addons, but this client doesn't sync them yet.",
                           level: .debug,
                           category: .sync)
                return succeed()
            case "prefs":
                logger.log("Requested reset for prefs, but this client doesn't sync them yet.",
                           level: .debug,
                           category: .sync)
                return succeed()
            default:
                logger.log("Asked to reset collection \(collection), which we don't know about.",
                           level: .warning,
                           category: .sync)
                return succeed()
            }
        }

        public func onRemovedAccount() -> Success {
            let profile = self.profile

            // Run these in order, because they might write to the same DB!

            let remove = [
                profile.remoteClientsAndTabs.onRemovedAccount,
                profile.logins.resetSync,
                profile.places.resetBookmarksMetadata,
                profile.places.resetHistoryMetadata,
            ]
            let clearPrefs: () -> Success = {
                withExtendedLifetime(self) {
                    // Clear prefs after we're done clearing everything else -- just in case
                    // one of them needs the prefs and we race. Clear regardless of success
                    // or failure.

                    // This will remove keys from the Keychain if they exist, as well
                    // as wiping the Sync prefs.
                }
                return succeed()
            }

            return accumulate(remove) >>> clearPrefs
        }

        fileprivate func repeatingTimerAtInterval(_ interval: TimeInterval, selector: Selector) -> Timer {
            return Timer.scheduledTimer(timeInterval: interval, target: self, selector: selector, userInfo: nil, repeats: true)
        }

        private func beginTimedSyncs() {
            if self.syncTimer != nil {
                logger.log("Already running sync timer.",
                           level: .debug,
                           category: .sync)
                return
            }

            let interval = FifteenMinutes
            let selector = #selector(syncOnTimer)
            logger.log("Starting sync timer.",
                       level: .info,
                       category: .sync)
            self.syncTimer = repeatingTimerAtInterval(interval, selector: selector)
        }

        /**
         * The caller is responsible for calling this on the same thread on which it called
         * beginTimedSyncs.
         */
        public func endTimedSyncs() {
            if let t = self.syncTimer {
                logger.log("Stopping sync timer.",
                           level: .info,
                           category: .sync)
                self.syncTimer = nil
                t.invalidate()
            }
        }


        public class ScopedKeyError: MaybeErrorType {
            public var description = "No key data found for scope."
        }

        public class SyncUnlockGetURLError: MaybeErrorType {
            public var description = "Failed to get token server endpoint url."
        }

        public class EncryptionKeyError: MaybeErrorType {
            public var description = "Failed to get stored key."
        }

        public class DeviceIdError: MaybeErrorType {
            public var description = "Failed to get deviceId."
        }

        fileprivate func syncUnlockInfo() -> Deferred<Maybe<SyncUnlockInfo>> {
            let syncUnlockInfo = Deferred<Maybe<SyncUnlockInfo>>()
            profile.rustFxA.accountManager.uponQueue(.main) { accountManager in
                guard let deviceId = accountManager.deviceConstellation()?.state()?.localDevice?.id else {
                    self.logger.log("Device Id could not be retrieved",
                                    level: .warning,
                                    category: .sync)
                    syncUnlockInfo.fill(Maybe(failure: DeviceIdError()))
                    return
                }

                accountManager.getAccessToken(scope: OAuthScope.oldSync) { result in
                    guard let accessTokenInfo = try? result.get(), let key = accessTokenInfo.key else {
                        syncUnlockInfo.fill(Maybe(failure: ScopedKeyError()))
                        return
                    }

                    accountManager.getTokenServerEndpointURL { result in
                        guard case .success(let tokenServerEndpointURL) = result else {
                            syncUnlockInfo.fill(Maybe(failure: SyncUnlockGetURLError()))
                            return
                        }

                        guard let encryptionKey = try? self.profile.logins.getStoredKey() else {
                            self.logger.log("Stored logins encryption could not be retrieved",
                                            level: .warning,
                                            category: .sync)
                            syncUnlockInfo.fill(Maybe(failure: EncryptionKeyError()))
                            return
                        }

                        syncUnlockInfo.fill( Maybe(success: SyncUnlockInfo(
                            kid: key.kid,
                            fxaAccessToken: accessTokenInfo.token,
                            syncKey: key.k,
                            tokenserverURL: tokenServerEndpointURL.absoluteString,
                            loginEncryptionKey: encryptionKey,
                            tabsLocalId: deviceId)))
                    }
                }
            }
            return syncUnlockInfo
        }
        func getProfileAndDeviceId() -> (MozillaAppServices.Profile, String)? {
            guard let fxa = RustFirefoxAccounts.shared.accountManager.peek(),
                  let profile = fxa.accountProfile(),
                  let deviceID = fxa.deviceConstellation()?.state()?.localDevice?.id
            else { return nil }

            return (profile, deviceID)
        }

        /**
         * Runs each of the provided synchronization functions with the same inputs.
         * Returns an array of IDs and SyncStatuses at least length as the input.
         * The statuses returned will be a superset of the ones that are requested here.
         * While a sync is ongoing, each engine from successive calls to this method will only be called once.
         */

        func engineEnablementChangesForAccount() -> [String: Bool]? {
            var enginesEnablements: [String: Bool] = [:]
            // We just created the account, the user went through the Choose What to Sync screen on FxA.
            if let declined = UserDefaults.standard.stringArray(forKey: "fxa.cwts.declinedSyncEngines") {
                declined.forEach { enginesEnablements[$0] = false }
                UserDefaults.standard.removeObject(forKey: "fxa.cwts.declinedSyncEngines")
            } else {
            }
            return enginesEnablements
        }

        /**
         * Allows selective sync of different collections, for use by external APIs.
         * Some help is given to callers who use different namespaces (specifically: `passwords` is mapped to `logins`)
         * and to preserve some ordering rules.
         */

        @objc func syncOnTimer() {
            self.profile.pollCommands()
        }
    }
}
