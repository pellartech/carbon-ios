//
//  DrawerMenuViewController.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//

import Foundation
import ParticleAuthService
import RxSwift
import Foundation
import ParticleNetworkBase
import RxSwift
import UIKit
import ParticleConnect
import ConnectCommon
import SDWebImage

class DrawerMenuViewController: UIViewController{
    
    // MARK: - UI Constants
    private struct UX {
        struct NetworkLabel {
            static let font: CGFloat = 20
            static let top: CGFloat = 20
        }
        struct TableView {
            static let top: CGFloat = 50
        }
    }

    // MARK: - UI Elements
    ///UILabel
    private lazy var networkLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: UX.NetworkLabel.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.networkLabelTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    ///UITableView
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        tableView.register(DrawerTVCell.self, forCellReuseIdentifier:"DrawerTVCell")
        return tableView
    }()
    
    // MARK: - UI Properties
    var selectedIndexes = [IndexPath(row: 0, section: 0)]
    let transitionManager = DrawerTransitionManager()
    let bag = DisposeBag()
    var delegate : ConnectProtocol?
    var data: [ConnectWalletModel] = []
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpViewConstraint()
        updateUI()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = transitionManager
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        getLocalUserData()
    }
    
    // MARK: - UI Methods
    func setUpView() {
        self.view.backgroundColor = Utilities().hexStringToUIColor(hex: "#2C2C2C")
        view.addSubview(networkLabel)
        view.addSubview(tableView)
    
    }
    
    func setUpViewConstraint() {
        NSLayoutConstraint.activate([
            
            ///UILabel
            networkLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.NetworkLabel.top),
            networkLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            ///UITableView
            tableView.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.TableView.top),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
   
    func getLocalUserData(){
        data = WalletManager.shared.getWallets().filter { connectWalletModel in
            let adapters = ParticleConnect.getAdapterByAddress(publicAddress: connectWalletModel.publicAddress).filter {
                $0.isConnected(publicAddress: connectWalletModel.publicAddress) && $0.walletType == connectWalletModel.walletType
            }
            return !adapters.isEmpty
        }
        tableView.reloadData()
    }
    
    // MARK: - Objc Methods
    @objc func networkLabelTapped (){
        let vc = SwitchChainViewController()
        vc.selectHandler = { [weak self] in
            self?.updateUI()
        }
        present(vc, animated: true)
    }
    
    func updateUI(){
        let name = ParticleNetwork.getChainInfo().name
        let network = ParticleNetwork.getChainInfo().network
        networkLabel.text = "Network : \(name) \n \(network.lowercased())"
    }
}
// MARK: - Extension - UITableViewDataSource
extension DrawerMenuViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrawerTVCell", for: indexPath) as! DrawerTVCell
        cell.setUI(model: data[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - Extension - UITableViewDelegate
extension DrawerMenuViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true,completion: {
            self.delegate?.accountPublicAddress(address:  self.data[indexPath.row].publicAddress)
        })
    }
}
