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
//import UIHelpers
//import Onboarding

protocol TrackingProtectionDelegate: AnyObject {
    func trackingProtectionDidToggleProtection(enabled: Bool)
}
class TrackingProtectionViewController: UIViewController, Themeable {
    var themeObserver: NSObjectProtocol?
    
    var notificationCenter: Common.NotificationProtocol
    
    func applyTheme() {
        
    }
    var themeManager: ThemeManager
    var tooltipHeight: Constraint?

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
                    self.toggleProtection(isOn: isOn)
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

//                    GleanMetrics
//                        .TrackingProtection
//                        .trackerSettingChanged
//                        .record(.init(
//                            isEnabled: isOn,
//                            sourceOfChange: self.sourceOfChange,
//                            trackerChanged: toggleItem.settingsKey.trackerChanged)
//                        )
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
                            // TODO: Make sure to reset the toggle
                            cell.isOn = false
                            self.blockOtherItem.settingsValue = false
                            self.updateTelemetry(self.blockOtherItem.settingsKey, false)
//                            GleanMetrics
//                                .TrackingProtection
//                                .trackerSettingChanged
//                                .record(.init(
//                                    isEnabled: false,
//                                    sourceOfChange: self.sourceOfChange,
//                                    trackerChanged: self.blockOtherItem.settingsKey.trackerChanged
//                                ))
                        })
                        alertController.addAction(UIAlertAction(title: UIConstantss.strings.settingsBlockOtherYes, style: .destructive) { [unowned self] _ in
                            self.blockOtherItem.settingsValue = true
                            self.updateTelemetry(self.blockOtherItem.settingsKey, true)
//                            GleanMetrics
//                                .TrackingProtection
//                                .trackerSettingChanged
//                                .record(.init(
//                                    isEnabled: true,
//                                    sourceOfChange: self.sourceOfChange,
//                                    trackerChanged: self.blockOtherItem.settingsKey.trackerChanged
//                                ))
                        })
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.blockOtherItem.settingsValue = isOn
                        self.updateTelemetry(blockOtherItem.settingsKey, isOn)
//                        GleanMetrics
//                            .TrackingProtection
//                            .trackerSettingChanged
//                            .record(.init(
//                                isEnabled: isOn,
//                                sourceOfChange: self.sourceOfChange,
//                                trackerChanged: blockOtherItem.settingsKey.trackerChanged
//                            ))
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

//    private lazy var header = TrackingHeaderView()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.registers(SwitchTableViewCell.self)
        return tableView
    }()

    weak var delegate: TrackingProtectionDelegate?

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
         themeManager: ThemeManager = AppContainer.shared.resolve(),
         notificationCenter: NotificationProtocol = NotificationCenter.default,
         favIconPublisher: AnyPublisher<URL?, Never>? = nil) {
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

        if case let .browsing(browsingStatus) = state,
           let baseDomain = browsingStatus.url.baseDomain {
//            view.addSubview(header)
//            header.snp.makeConstraints { make in
//                self.headerHeight = make.height.equalTo(UIConstantss.layout.trackingProtectionHeaderHeight).constraint
//                make.leading.trailing.equalToSuperview()
//                make.top.equalTo(view.safeAreaLayoutGuide).offset(UIConstantss.layout.trackingProtectionHeaderTopOffset)
//            }
            if let publisher = favIconPublisher {
//                header.configure(domain: baseDomain, publisher: publisher)
            }
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            if case .browsing = state {
//                make.top.equalTo(header.snp.bottom)
            } else {
                make.top.equalTo(view).inset(self.tableViewTopInset)
            }
            make.leading.trailing.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
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
//        let telemetryEvent = TelemetryEvent(category: TelemetryEventCategory.action, method: TelemetryEventMethod.change, object: "setting", value: settingsKey.rawValue)
//        telemetryEvent.addExtra(key: "to", value: isOn)
//        Telemetry.default.recordEvent(telemetryEvent)

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

    private func toggleProtection(isOn: Bool) {
//        let telemetryEvent = TelemetryEvent(
//            category: TelemetryEventCategory.action,
//            method: TelemetryEventMethod.change,
//            object: "setting",
//            value: SettingsToggle.trackingProtection.rawValue
//        )
//        telemetryEvent.addExtra(key: "to", value: isOn)
//        Telemetry.default.recordEvent(telemetryEvent)
//
//        GleanMetrics.TrackingProtection.trackingProtectionChanged.record(.init(isEnabled: isOn))
//        GleanMetrics.TrackingProtection.hasEverChangedEtp.set(true)

        delegate?.trackingProtectionDidToggleProtection(enabled: isOn)
    }
}

extension TrackingProtectionViewController: TooltipViewDelegate {
    func didTapTooltipDismissButton() {
    }
}

public protocol OnboardingEventsHandling: AnyObject {
    var route: ToolTipRoute? { get set }
    var routePublisher: Published<ToolTipRoute?>.Publisher { get }
    func send(_ action: Action)
}

public enum ToolTipRoute: Equatable, Hashable, Codable {
    case onboarding(OnboardingVersion)
    case trackingProtection
    case trackingProtectionShield(OnboardingVersion)
    case trash(OnboardingVersion)
    case searchBar
    case widget
    case widgetTutorial
    case menu
}

public enum OnboardingVersion: Equatable, Hashable, Codable {
    init(_ shouldShowNewOnboarding: Bool) {
        self = shouldShowNewOnboarding ? .v2 : .v1
    }
    case v2
    case v1
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
