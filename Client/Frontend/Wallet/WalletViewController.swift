// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Shared

class WalletViewController: UIViewController {
    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = String.walletTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: .AppSettingsDone,
            style: .done,
            target: navigationController,
            action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "WalletTableViewController.navigationItem.leftBarButtonItem"

    }
}
