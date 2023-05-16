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
import Common
import Shared

class DrawerMenuViewController: UIViewController{
    
    // MARK: - UI Constants
    private struct UX {
        struct NetworkLabel {
            static let font: CGFloat = 20
            static let top: CGFloat = 50
        }
        struct TableView {
            static let top: CGFloat = 100
        }
    }

    // MARK: - UI Elements
    ///UILabel
    private lazy var networkLabel : GradientLabel = {
        let label = GradientLabel()
        label.textColor = UIColor.white
        label.text = "Accounts"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: UX.NetworkLabel.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
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
        applyTheme()
        setUpView()
        setUpViewConstraint()
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
    
    func applyTheme() {
        let themeManager :  ThemeManager?
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView() {
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

class DrawerTVCell: UITableViewCell {
    
    // MARK: - UI Constants
    private struct UX {
        struct Icon {
            static let font: CGFloat = 10
            static let top: CGFloat = 12
            static let leading: CGFloat = 10
            static let height: CGFloat = 53
            static let width: CGFloat = 53
            static let corner: CGFloat = 15
            
        }
        struct Title {
            static let font: CGFloat = 16
            static let top: CGFloat = 10
            static let leading: CGFloat = 80
            static let height: CGFloat = 30
        }
        struct Value {
            static let font: CGFloat = 12
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 20
            static let topAt: CGFloat = 0
            static let trailing: CGFloat = -15
            static let height: CGFloat = 20
            static let width: CGFloat = 50
            static let connectTrailing: CGFloat = -20
            
        }
    }
    // MARK: - UI Elements
    
    ///UIView
    private lazy var iconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UX.Icon.corner
        view.clipsToBounds = true
        return view
    }()
    
    ///UILabel
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .left
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///UIImageView
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
        setUpViewConstraint()
    }
    
    // MARK: - UI Methods
    func setUpView(){
        iconView.addSubview(iconImageView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setUpViewConstraint(){
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconImageView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconImageView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Title.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: UX.Value.topAt),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.connectTrailing),
            
        ]
        )
    }
    
    func setUI(model : ConnectWalletModel){
        titleLabel.text = model.name
        if let imageUrl = URL(string: model.walletType.imageName) {
            iconImageView.sd_setImage(with: imageUrl)
        }
        valueLabel.text = "Public address: \(model.publicAddress)"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
