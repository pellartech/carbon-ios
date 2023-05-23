//
//  AddWalletViewController.dart.swift
//  Example
//
//  Created by Ashok on 23/05/23.
//

import ConnectCommon
import ConnectEVMAdapter
import ConnectPhantomAdapter
import ConnectSolanaAdapter
import ConnectWalletConnectAdapter
import Foundation
import ParticleConnect
import ParticleNetworkBase
import RxSwift
import UIKit
import SVProgressHUD

protocol AddWalletProtocol{
    func addWalletDelegate()
}

class AddWalletViewController: UITableViewController {
    
    // MARK: - UI Properties
    let bag = DisposeBag()
    var data: [WalletType] = []
    var delegate: AddWalletProtocol?
    let viewModel = WalletViewModel()
    
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadData()
    }
    
    // MARK: - UI methods
    func setUpView(){
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#1E1E1E")
        tableView.backgroundColor = Utilities().hexStringToUIColor(hex: "#1E1E1E")
        tableView.register(AddWalletCell.self, forCellReuseIdentifier: NSStringFromClass(AddWalletCell.self))
        tableView.rowHeight = 62
        tableView.showsVerticalScrollIndicator = false
        tableView.reloadData()
    }
    
    func loadData() {
        data = WalletType.allCases
    }
}

// MARK: Extension - UITableViewDelegate and UITableViewDataSource
extension AddWalletViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AddWalletCell.self), for: indexPath) as! AddWalletCell
        let wallet = data[indexPath.row]
        if let imageUrl = URL(string: wallet.imageName) {
            cell.iconImageView.sd_setImage(with: imageUrl)
        }
        cell.nameLabel.text = wallet.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let walletType = data[indexPath.row]
        viewModel.walletLogin(vc: self, walletType: walletType) { result in
            switch result {
            case .success(_):
                self.navigationController?.popViewController(animated: true)
                self.delegate?.addWalletDelegate()
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

class AddWalletCell: UITableViewCell {
    
    // MARK: - UI Elements
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        backgroundColor = Utilities().hexStringToUIColor(hex: "#1E1E1E")
        contentView.backgroundColor = Utilities().hexStringToUIColor(hex: "#1E1E1E")
        contentView.addSubview(iconImageView)
        contentView.addSubview(nameLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(iconImageView.snp.right).offset(10)
        }
    }
}

