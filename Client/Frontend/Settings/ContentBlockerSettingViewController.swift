// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import Shared

extension BlockingStrength {
    var settingStatus: String {
        switch self {
        case .advertising:
            return "Advertising"
        case .analytics:
            return "Analytics"
        case .social:
            return "Social"
        case .content:
            return "Content"
        }
    }

    var settingTitle: String {
        switch self {
        case .advertising:
            return "Advertising"
        case .analytics:
            return "Analytics"
        case .social:
            return "Social"
        case .content:
            return "Content"
        }
    }

    var settingSubtitle: String {
        switch self {
        case .advertising,.analytics,.social:
            return ""
        case .content:
            return ""
        }
    }

    static func accessibilityId(for strength: BlockingStrength) -> String {
        switch strength {
        case .advertising,.analytics,.social:
            return "Settings.TrackingProtectionOption.BlockListBasic"
        case .content:
            return "Settings.TrackingProtectionOption.BlockListStrict"
        }
    }
}

// MARK: Additional information shown when the info accessory button is tapped.
class TPAccessoryInfo: ThemedTableViewController {
    var isStrictMode = false

    override func viewDidLoad() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        applyTheme()
        listenForThemeChange(view)
    }

    func headerView() -> UIView {
        let stack = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
        stack.axis = .vertical

        let header = UILabel()
        header.text = .TPAccessoryInfoBlocksTitle
        header.font = DynamicFontHelper.defaultHelper.DefaultMediumBoldFont
        header.textColor = themeManager.currentTheme.colors.textSecondary

        stack.addArrangedSubview(UIView())
        stack.addArrangedSubview(header)

        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true

        let topStack = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        topStack.axis = .vertical
        let sep = UIView()
        topStack.addArrangedSubview(stack)
        topStack.addArrangedSubview(sep)
        topStack.spacing = 10

        topStack.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        topStack.isLayoutMarginsRelativeArrangement = true

        sep.backgroundColor = themeManager.currentTheme.colors.borderPrimary
        sep.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.width.equalToSuperview()
        }
        return topStack
    }

    override func applyTheme() {
        super.applyTheme()
        tableView.tableHeaderView = headerView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isStrictMode ? 5 : 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ThemedTableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.applyTheme(theme: themeManager.currentTheme)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = .TPSocialBlocked
            } else {
                cell.textLabel?.text = .TPCategoryDescriptionSocial
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = .TPCrossSiteBlocked
            } else {
                cell.textLabel?.text = .TPCategoryDescriptionCrossSite
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.textLabel?.text = .TPCryptominersBlocked
            } else {
                cell.textLabel?.text = .TPCategoryDescriptionCryptominers
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                cell.textLabel?.text = .TPFingerprintersBlocked
            } else {
                cell.textLabel?.text = .TPCategoryDescriptionFingerprinters
            }
        } else if indexPath.section == 4 {
            if indexPath.row == 0 {
                cell.textLabel?.text = .TPContentBlocked
            } else {
                cell.textLabel?.text = .TPCategoryDescriptionContentTrackers
            }
        }
        cell.imageView?.tintColor = themeManager.currentTheme.colors.iconPrimary
        if indexPath.row == 1 {
            cell.textLabel?.font = DynamicFontHelper.defaultHelper.DefaultMediumFont
        }
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = themeManager.currentTheme.colors.textPrimary
        cell.selectionStyle = .none
        return cell
    }
}

class ContentBlockerSettingViewController: SettingsTableViewController {
    private let button = UIButton()
    let prefs: Prefs
    var advertisingStrength : BlockingStrength
    var analyticsStrength : BlockingStrength
    var socialStrength : BlockingStrength
    var contentStrength : BlockingStrength
    var adCount = 0
    
    init(prefs: Prefs) {
        self.prefs = prefs

        advertisingStrength = prefs.stringForKey(ContentBlockingConfig.Prefs.analyticsKey).flatMap({BlockingStrength(rawValue: $0)}) ?? .advertising
        analyticsStrength = prefs.stringForKey(ContentBlockingConfig.Prefs.analyticsKey).flatMap({BlockingStrength(rawValue: $0)}) ?? .analytics
        socialStrength = prefs.stringForKey(ContentBlockingConfig.Prefs.socialKey).flatMap({BlockingStrength(rawValue: $0)}) ?? .social
        contentStrength = prefs.stringForKey(ContentBlockingConfig.Prefs.contentKey).flatMap({BlockingStrength(rawValue: $0)}) ?? .content
        super.init(style: .grouped)
        self.adCount = getNumberOfLifetimeTrackersBlocked()
        self.title = .SettingsTrackingProtectionSectionName
    }
    private func getNumberOfLifetimeTrackersBlocked(userDefaults: UserDefaults = UserDefaults.standard) -> Int {
        return  UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
    }

    func valueChanged(option:BlockingStrength) -> Bool{
        var value = false
        switch option{
        case .advertising:
            let  prefsValue = prefs.stringForKey(ContentBlockingConfig.Prefs.advertisingKey)
            value = prefsValue == advertisingStrength.rawValue
        case .analytics:
            let  prefsValue = prefs.stringForKey(ContentBlockingConfig.Prefs.analyticsKey)
            value = prefsValue == analyticsStrength.rawValue
        case .social:
            let  prefsValue = prefs.stringForKey(ContentBlockingConfig.Prefs.socialKey)
            value = prefsValue == socialStrength.rawValue
        case .content:
            let  prefsValue = prefs.stringForKey(ContentBlockingConfig.Prefs.contentKey)
            value = prefsValue == contentStrength.rawValue
        }
        return value
    }
    override func generateSettings() -> [SettingSection] {
        let strengthSetting: [TrackerBlockSetting] = BlockingStrength.allOptions.map { option in
            let id = BlockingStrength.accessibilityId(for: option)
            let setting = TrackerBlockSetting(
                title: NSAttributedString(string: option.settingTitle),
                subtitle: NSAttributedString(string: option.settingSubtitle),
                accessibilityIdentifier: id,
                isChecked: valueChanged(option: option),
                onChecked:
                    {
                        switch option{
                        case .advertising:
                            self.prefs.setString(self.advertisingStrength.rawValue,
                                                 forKey: ContentBlockingConfig.Prefs.advertisingKey)
                           
                        case .analytics:
                            self.prefs.setString(self.analyticsStrength.rawValue,
                                                 forKey: ContentBlockingConfig.Prefs.analyticsKey)
                        case .social:
                            self.prefs.setString(self.socialStrength.rawValue,
                                                 forKey: ContentBlockingConfig.Prefs.socialKey)
                        case .content:
                            self.prefs.setString(self.contentStrength.rawValue,
                                                 forKey: ContentBlockingConfig.Prefs.contentKey)
                        }
                        TabContentBlocker.prefsChanged()
                    if option == .content {
                        self.button.isHidden = true
                    }
                    
                    
            })

            setting.onAccessoryButtonTapped = {
                let vc = TPAccessoryInfo()
                vc.isStrictMode = option == .content
                self.navigationController?.pushViewController(vc, animated: true)
            }

            if self.prefs.boolForKey(ContentBlockingConfig.Prefs.EnabledKey) == false {
                setting.enabled = false
            }
            return setting
        }

        let enabledSetting = BoolSetting(
            prefs: profile.prefs,
            prefKey: ContentBlockingConfig.Prefs.EnabledKey,
            defaultValue: ContentBlockingConfig.Defaults.NormalBrowsing,
            attributedTitleText: NSAttributedString(string: .TrackingProtectionEnableTitle)) { [weak self] enabled in
                TabContentBlocker.prefsChanged()
                strengthSetting.forEach { item in
                    item.enabled = enabled
                }
                self?.tableView.reloadData()
        }

        let firstSection = SettingSection(title: nil, footerTitle: NSAttributedString(string: .TrackingProtectionCellFooter), children: [enabledSetting])

        let optionalFooterTitle = NSAttributedString(string: .TrackingProtectionLevelFooter)

        // The bottom of the block lists section has a More Info button, implemented as a custom footer view,
        // SettingSection needs footerTitle set to create a footer, which we then override the view for.
        let blockListsTitle: String = .TrackingProtectionOptionProtectionLevelTitle
        let secondSection = SettingSection(title:NSAttributedString(string: "Trackers and Scripts to block") , footerTitle: optionalFooterTitle, children: strengthSetting)
        
        let endSetting = TrackingSetting(
            title: NSAttributedString(string: "Trackers blocked since Apr 14, 2023"),
            subtitle: NSAttributedString(string: "\(self.adCount)",attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 25)]),
            accessibilityIdentifier: "id",
            isChecked: { return false },
            onChecked: {
               
        })
        let thirdSection = SettingSection(title:nil, footerTitle: nil, children: [endSetting])

        return [firstSection, secondSection, thirdSection]
    }

    // The first section header gets a More Info link
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let _defaultFooter = super.tableView(tableView, viewForFooterInSection: section) as? ThemedTableSectionHeaderFooterView
        guard let defaultFooter = _defaultFooter else { return nil }

        if section == 0 {
            // TODO: Get a dedicated string for this.
            let title: String = .TrackerProtectionLearnMore

            let font = DynamicFontHelper.defaultHelper.preferredFont(withTextStyle: .subheadline, size: 12.0)
            var attributes = [NSAttributedString.Key: AnyObject]()
            attributes[NSAttributedString.Key.foregroundColor] = themeManager.currentTheme.colors.actionPrimary
            attributes[NSAttributedString.Key.font] = font

            button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: .normal)
            button.addTarget(self, action: #selector(moreInfoTapped), for: .touchUpInside)
            button.isHidden = false

            defaultFooter.addSubview(button)

            button.snp.makeConstraints { (make) in
                make.top.equalTo(defaultFooter.titleLabel.snp.bottom)
                make.leading.equalTo(defaultFooter.titleLabel)
            }
            return defaultFooter
        }

        if advertisingStrength == .advertising {
            return nil
        }

        return defaultFooter
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    @objc func moreInfoTapped() {
        let viewController = SettingsContentViewController()
        viewController.url = SupportUtils.URLForTopic("tracking-protection-ios")
        navigationController?.pushViewController(viewController, animated: true)
    }
}
