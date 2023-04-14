// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Common
import WebKit
import Shared

struct ContentBlockingConfig {
    struct Prefs {
        static let advertisingKey = "prefkey.trackingprotection.advertising"
        static let analyticsKey = "prefkey.trackingprotection.analytics"
        static let socialKey = "prefkey.trackingprotection.social"
        static let contentKey = "prefkey.trackingprotection.content"
        static let EnabledKey = "prefkey.trackingprotection.normalbrowsing"
    }

    struct Defaults {
        static let NormalBrowsing = !AppInfo.isChinaEdition
    }
}

enum BlockingStrength: String {
    case advertising
    case analytics
    case social
    case content
    static let allOptions: [BlockingStrength] = [.advertising, .analytics, .social ,.content]
}

/**
 Firefox-specific implementation of tab content blocking.
 */
class FirefoxTabContentBlocker: TabContentBlocker, TabContentScript {
    let userPrefs: Prefs

    class func name() -> String {
        return "TrackingProtectionStats"
    }

    var isUserEnabled: Bool? {
        didSet {
            guard let tab = tab as? Tab else { return }
            setupForTab()
            TabEvent.post(.didChangeContentBlocking, for: tab)
            tab.reload()
        }
    }

    override var isEnabled: Bool {
        if let enabled = isUserEnabled {
            return enabled
        }

        return isEnabledInPref
    }

    var isEnabledInPref: Bool {
        return userPrefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    var blockingAdvertisingPref: BlockingStrength {
        return userPrefs.stringForKey(ContentBlockingConfig.Prefs.advertisingKey).flatMap(BlockingStrength.init) ?? .advertising
    }
    var blockingAnalyticsPref: BlockingStrength {
        return userPrefs.stringForKey(ContentBlockingConfig.Prefs.analyticsKey).flatMap(BlockingStrength.init) ?? .advertising
    }
    var blockingSocialPref: BlockingStrength {
        return userPrefs.stringForKey(ContentBlockingConfig.Prefs.socialKey).flatMap(BlockingStrength.init) ?? .advertising
    }
    var blockingContentPref: BlockingStrength {
        return userPrefs.stringForKey(ContentBlockingConfig.Prefs.contentKey).flatMap(BlockingStrength.init) ?? .advertising
    }
    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        var rules1 = [BlocklistFileName]()
        var rules2 = [BlocklistFileName]()
        var rules3 = [BlocklistFileName]()
        var rules4 = [BlocklistFileName]()
        
        if (blockingAdvertisingPref == .advertising){
            rules1 = BlocklistFileName.advertising
        }
        if (blockingAnalyticsPref == .analytics){
            rules2 = BlocklistFileName.analytics
        }
        if (blockingSocialPref == .social){
            rules3 = BlocklistFileName.social
        }
        if (blockingContentPref == .content){
            rules4 = BlocklistFileName.content
        }
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: isEnabled, rules: rules1 + rules2 + rules3 + rules4 )
    }

    override func notifiedTabSetupRequired() {
        setupForTab()
        if let tab = tab as? Tab {
            TabEvent.post(.didChangeContentBlocking, for: tab)
        }
    }

    override func currentlyEnabledLists() -> [BlocklistFileName] {
        var rules1 = [BlocklistFileName]()
        var rules2 = [BlocklistFileName]()
        var rules3 = [BlocklistFileName]()
        var rules4 = [BlocklistFileName]()
        
        if (blockingAdvertisingPref == .advertising){
            rules1 = BlocklistFileName.advertising
        }
        if (blockingAnalyticsPref == .analytics){
            rules2 = BlocklistFileName.analytics
        }
        if (blockingSocialPref == .social){
            rules3 = BlocklistFileName.social
        }
        if (blockingContentPref == .content){
            rules4 = BlocklistFileName.content
        }
        return rules1 + rules2 + rules3 + rules4 
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }

    func noImageMode(enabled: Bool) {
        guard let tab = tab else { return }
        ContentBlocker.shared.noImageMode(enabled: enabled, forTab: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension FirefoxTabContentBlocker {
    static func setTrackingProtection(enabled: Bool, prefs: Prefs) {
        let key = ContentBlockingConfig.Prefs.EnabledKey
        prefs.setBool(enabled, forKey: key)
        ContentBlocker.shared.prefsChanged()
    }

    static func isTrackingProtectionEnabled(prefs: Prefs) -> Bool {
        return prefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    static func toggleTrackingProtectionEnabled(prefs: Prefs) {
        let isEnabled = FirefoxTabContentBlocker.isTrackingProtectionEnabled(prefs: prefs)
        setTrackingProtection(enabled: !isEnabled, prefs: prefs)
    }
}
