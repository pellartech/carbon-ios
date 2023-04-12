// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import SnapKit
import UIKit
import Telemetry
import Glean
import Combine
import Shared
import Common



class TrackingProtectionViewController: UIViewController, Themeable {
    
    var themeObserver: NSObjectProtocol?
    var notificationCenter: Common.NotificationProtocol
    var themeManager: ThemeManager
    var tooltipHeight: Constraint?
    var viewModel: TrackingProtectionVM
    var prefs: Prefs

    // MARK: - Data source
    
    lazy var dataSource = DataSource(
        tableView: self.tableView,
        cellProvider: { tableView, indexPath, itemIdentifier in
            return itemIdentifier.configureCell(tableView, indexPath)
        },
        headerForSection: { section in
            switch section {
            case .trackers:
                return UIConstantss.strings.trackersHeader.uppercased()
            case .tip, .secure, .enableTrackers, .stats:
                return nil
            }
        },
        footerForSection: { [trackingProtectionItem] section in
            switch section {
            case .enableTrackers:
                return trackingProtectionItem.settingsValue ? UIConstantss.strings.trackingProtectionOn : UIConstantss.strings.trackingProtectionOff
            case .tip, .secure, .trackers, .stats:
                return nil
            }
        })
    
    // MARK: - Toggles items
    private lazy var trackingProtectionItem = ToggleItem(
        label: UIConstantss.strings.trackingProtectionToggleLabel,
        settingsKey: SettingsToggle.trackingProtection
    )
    private lazy var toggleItems = [
        ToggleItem(label: UIConstantss.strings.labelBlockAds2, settingsKey: .blockAds),
        ToggleItem(label: UIConstantss.strings.labelBlockAnalytics, settingsKey: .blockAnalytics),
        ToggleItem(label: UIConstantss.strings.labelBlockSocial, settingsKey: .blockSocial)
    ]
    private let blockOtherItem = ToggleItem(label: UIConstantss.strings.labelBlockOther, settingsKey: .blockOther)
    
    // MARK: - Sections
    func secureConnectionSectionItems(title: String, image: UIImage) -> [SectionItem] {
        [
            SectionItem(configureCell: { _, _ in
                ImageCell(image: image, title: title,theme:self.themeManager)
            })
        ]
    }
    
    lazy var tooltipSectionItems = [
        SectionItem(configureCell: { [unowned self] tableView, indexPath in
            let cell = TooltipTableViewCell(title: UIConstantss.strings.tooltipTitleTextForPrivacy, body: UIConstantss.strings.tooltipBodyTextForPrivacy)
            cell.delegate = self
            return cell
        })
    ]
    
    lazy var enableTrackersSectionItems = [
        SectionItem(
            configureCell: { [unowned self] tableView, indexPath in
                let cell = SwitchTableViewCell(
                    item: self.trackingProtectionItem,
                    reuseIdentifier: "SwitchTableViewCell",
                    theme :  themeManager
                )                
                cell.valueChanged.sink { [unowned self] isOn in
                    self.trackingProtectionItem.settingsValue = isOn
                    if isOn {
                        var snapshot = self.dataSource.snapshot()
                        snapshot.insertSections([.trackers], afterSection: .enableTrackers)
                        snapshot.appendItems(self.trackersSectionItems, toSection: .trackers)
                        self.dataSource.apply(snapshot, animatingDifferences: true)
                        snapshot.reloadSections([.enableTrackers])
                        self.dataSource.apply(snapshot, animatingDifferences: false)
                    } else {
                        var snapshot = self.dataSource.snapshot()
                        snapshot.deleteSections([.trackers])
                        snapshot.reloadSections([.enableTrackers])
                        self.dataSource.apply(snapshot, animatingDifferences: true)
                    }
                    self.calculatePreferredSize()
                    viewModel.toggleSiteSafelistStatus()
                }
                .store(in: &self.subscriptions)
                return cell
            }
        )
    ]
    
    lazy var trackersSectionItems = toggleItems.map { toggleItem in
        SectionItem(
            configureCell: { [unowned self] _, _ in
                let cell = SwitchTableViewCell(item: toggleItem, reuseIdentifier: "SwitchTableViewCell", theme: themeManager)
                cell.valueChanged.sink { isOn in
                    toggleItem.settingsValue = isOn
                    self.updateTelemetry(toggleItem.settingsKey, isOn)
                    if(toggleItem.title == UIConstantss.strings.labelBlockAds2 ){
                        self.prefs.setString(BlockingStrength.adblock.rawValue,
                                             forKey: ContentBlockingConfig.Prefs.StrengthKey)
                    }else if(toggleItem.title == UIConstantss.strings.labelBlockAnalytics ){
                        self.prefs.setString(BlockingStrength.analytics.rawValue,
                                             forKey: ContentBlockingConfig.Prefs.StrengthKey)
                    } else {
                        self.prefs.setString(BlockingStrength.social.rawValue,
                                             forKey: ContentBlockingConfig.Prefs.StrengthKey)
                    }
                    TabContentBlocker.prefsChanged()
                    self.tableView.reloadData()
                }
                .store(in: &self.subscriptions)
                return cell
            }
        )
    }
    +
    [
        SectionItem(
            configureCell: { [unowned self] _, _ in
                let cell = SwitchTableViewCell(item: blockOtherItem, reuseIdentifier: "SwitchTableViewCell", theme: themeManager)
                cell.valueChanged.sink { [unowned self] isOn in
                    if isOn {
                        let alertController = UIAlertController(title: nil, message: UIConstantss.strings.settingsBlockOtherMessage, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: UIConstantss.strings.settingsBlockOtherNo, style: .default) { [unowned self] _ in
                            cell.isOn = false
                            self.blockOtherItem.settingsValue = false
                            self.updateTelemetry(self.blockOtherItem.settingsKey, false)
                            self.prefs.setString(BlockingStrength.content.rawValue,
                                                 forKey: ContentBlockingConfig.Prefs.StrengthKey)
                            TabContentBlocker.prefsChanged()
                        })
                        alertController.addAction(UIAlertAction(title: UIConstantss.strings.settingsBlockOtherYes, style: .destructive) { [unowned self] _ in
                            self.blockOtherItem.settingsValue = true
                            self.updateTelemetry(self.blockOtherItem.settingsKey, true)
                            self.prefs.setString(BlockingStrength.content.rawValue,
                                                 forKey: ContentBlockingConfig.Prefs.StrengthKey)
                            TabContentBlocker.prefsChanged()
                        })
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.blockOtherItem.settingsValue = isOn
                        self.updateTelemetry(blockOtherItem.settingsKey, isOn)
                        self.prefs.setString(BlockingStrength.content.rawValue,
                                             forKey: ContentBlockingConfig.Prefs.StrengthKey)
                        TabContentBlocker.prefsChanged()
                    }
                }
                .store(in: &self.subscriptions)
                return cell
            }
        )
    ]
    
    lazy var statsSectionItems = [
        SectionItem(
            configureCell: { [unowned self] _, _ in
                SubtitleCell(
                    title: String(format: UIConstantss.strings.trackersBlockedSince, self.getAppInstallDate()),
                    subtitle: self.getNumberOfTrackersBlocked(),
                    theme: themeManager
                )
            }
        )
    ]
    
    // MARK: - Views
    private var headerHeight: Constraint?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        let theme = themeManager.currentTheme
        tableView.backgroundColor = theme.colors.layer1
        tableView.registers(SwitchTableViewCell.self)
        return tableView
    }()
    
    private var modalDelegate: ModalDelegate?
    private var sourceOfChange: String {
        if case .settings = state { return "Settings" }  else { return "Panel" }
    }
    private var subscriptions = Set<AnyCancellable>()
    private var trackersSectionIndex: Int {
        if case .browsing = state { return 2 }  else { return 1 }
    }
    private var tableViewTopInset: CGFloat {
        if case .settings = state { return 0 }  else { return UIConstantss.layout.trackingProtectionTableViewTopInset }
    }
    var state: TrackingProtectionStates
    let favIconPublisher: AnyPublisher<URL?, Never>?
    private var cancellable: AnyCancellable?
    
    // MARK: - VC Lifecycle
    init(state: TrackingProtectionStates,
         prefs: Prefs,
         viewModel: TrackingProtectionVM,
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default,
         favIconPublisher: AnyPublisher<URL?, Never>? = nil) {
        self.viewModel = viewModel
        self.prefs = prefs
        self.state = state
        self.themeManager = themeManager
        self.notificationCenter = notificationCenter
        self.favIconPublisher = favIconPublisher
        super.init(nibName: nil, bundle: nil)
        
        dataSource.defaultRowAnimation = .middle
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionType, SectionItem>()
        
        if case let .browsing(browsingStatus) = state {
            let title = browsingStatus.isSecureConnection ? UIConstantss.strings.connectionSecure : UIConstantss.strings.connectionNotSecure
            let image = browsingStatus.isSecureConnection ? UIImage.connectionSecure : UIImage.connectionNotSecure
            let secureSectionItems = self.secureConnectionSectionItems(title: title, image: image)
            snapshot.appendSections([.secure])
            snapshot.appendItems(secureSectionItems, toSection: .secure)
        }
        
        snapshot.appendSections([.enableTrackers])
        snapshot.appendItems(enableTrackersSectionItems, toSection: .enableTrackers)
        
        if self.trackingProtectionItem.settingsValue {
            snapshot.appendSections([.trackers])
            snapshot.appendItems(trackersSectionItems, toSection: .trackers)
        }
        
        snapshot.appendSections([.stats])
        snapshot.appendItems(statsSectionItems, toSection: .stats)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLegacyTheme()
        applyTheme()
        title = UIConstantss.strings.trackingProtectionLabel
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: themeManager.currentTheme.colors.actionPrimary]
        navigationController?.navigationBar.tintColor = themeManager.currentTheme.colors.actionPrimary
        
        if case .settings = state {
            let doneButton = UIBarButtonItem(title: UIConstantss.strings.done, style: .plain, target: self, action: #selector(doneTapped))
            doneButton.tintColor = themeManager.currentTheme.colors.actionPrimary
            navigationItem.rightBarButtonItem = doneButton
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for:.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.layoutIfNeeded()
            self.navigationController?.navigationBar.isTranslucent = false
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view).inset(self.tableViewTopInset)
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    private func updateLegacyTheme() {
        if !NightModeHelper.isActivated() && LegacyThemeManager.instance.systemThemeIsOn {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            LegacyThemeManager.instance.current = userInterfaceStyle == .dark ? LegacyDarkTheme() : LegacyNormalTheme()
        }
    }
    
    func applyTheme() {
        let theme = themeManager.currentTheme
        view.backgroundColor = theme.colors.layer1
    }
    
    private func calculatePreferredSize() {
        guard state != .settings else { return }
        
        preferredContentSize = CGSize(
            width: tableView.contentSize.width,
            height: tableView.contentSize.height + (headerHeight?.layoutConstraints[0].constant ?? .zero)
        )
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.presentingViewController?.presentedViewController?.preferredContentSize = CGSize(
                width: tableView.contentSize.width,
                height: tableView.contentSize.height + (headerHeight?.layoutConstraints[0].constant ?? .zero)
            )
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize()
    }
    
    @objc private func doneTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func updateTelemetry(_ settingsKey: SettingsToggle, _ isOn: Bool) {
        Settings.set(isOn, forToggle: settingsKey)
        ContentBlocker.shared.prefsChanged()
    }
    
    private func getAppInstallDate() -> String {
        let urlToDocumentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        if let installDate = (try! FileManager.default.attributesOfItem(atPath: urlToDocumentsFolder.path)[FileAttributeKey.creationDate]) as? Date {
            let stringDate = dateFormatter.string(from: installDate)
            return stringDate
        }
        return dateFormatter.string(from: Date())
    }
    
    private func getNumberOfTrackersBlocked() -> String {
        let numberOfTrackersBlocked = NSNumber(integerLiteral: UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey))
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: numberOfTrackersBlocked) ?? "0"
    }
}

extension TrackingProtectionViewController: TooltipViewDelegate {
    func didTapTooltipDismissButton() {
    }
}

public enum Action {
    case applicationDidLaunch
    case enterHome
    case showTrackingProtection
    case trackerBlocked
    case showTrash
    case clearTapped
    case startBrowsing
    case widgetDismissed
}

public extension UITableView {
    func dequeueReusableCells<Cell: UITableViewCell>(_ type: Cell.Type, withIdentifier identifier: String) -> Cell? {
        return self.dequeueReusableCell(withIdentifier: identifier) as? Cell
    }
    
    func dequeueReusableCells<Cell: UITableViewCell>(_ type: Cell.Type, for indexPath: IndexPath) -> Cell? {
        return self.dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? Cell
    }
    
    func registers<Cell: UITableViewCell>(_ type: Cell.Type) {
        register(type, forCellReuseIdentifier: String(describing: type))
    }
}

public extension UIImage {
    static let connectionNotSecure = UIImage(named: "lock_blocked")!
    static let connectionSecure = UIImage(named: "lock_verified")!
}

