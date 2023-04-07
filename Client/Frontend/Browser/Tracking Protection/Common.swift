// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import UIKit

protocol ModalDelegate {
    func presentModal(viewController: UIViewController, animated: Bool)
    func presentSheet(viewController: UIViewController)
    func dismiss(animated: Bool)
}

class DataSource: UITableViewDiffableDataSource<SectionType, SectionItem> {

    init(
        tableView: UITableView,
        cellProvider: @escaping UITableViewDiffableDataSource<SectionType, SectionItem>.CellProvider,
        headerForSection: @escaping (SectionType) -> String?,
        footerForSection: @escaping (SectionType) -> String?
    ) {
        self.headerForSection = headerForSection
        self.footerForSection = footerForSection
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    private var headerForSection: (SectionType) -> String?
    private var footerForSection: (SectionType) -> String?

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionType = self.snapshot().sectionIdentifiers[section]
        return headerForSection(sectionType)
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionType = self.snapshot().sectionIdentifiers[section]
        return footerForSection(sectionType)
    }
}

struct SectionItem {

    let id = UUID()

    let configureCell: (UITableView, IndexPath) -> UITableViewCell
    let action: (() -> Void)?

    init(configureCell: @escaping (UITableView, IndexPath) -> UITableViewCell, action: (() -> Void)? = nil) {
        self.configureCell = configureCell
        self.action = action
    }
}

extension SectionItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension UIViewController {
    func install(_ child: UIViewController, on view: UIView) {
        addChild(child)

        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)

        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        child.didMove(toParent: self)
    }

    func removeAsChild() {
        self.view.removeFromSuperview()
        self.removeFromParent()
        self.didMove(toParent: nil)
    }
}

enum SectionType: Int, Hashable {
    case tip
    case secure
    case enableTrackers
    case trackers
    case stats
}
