//
//  ConnectViewController.swift
//  Client
//
//  Created by Ashok on 14/05/23.
//

import Foundation
import UIKit
import ParticleAuthService
import ParticleNetworkBase
import RxSwift
import ParticleConnect
import ConnectCommon
import Common
import Shared

class ConnectViewController: UIViewController{
    
    // MARK: - UI Constants
    private struct UX {
        struct TopBarView {
            static let corner: CGFloat = 2
            static let width: CGFloat = 76
            static let height: CGFloat = 4
            static let top: CGFloat = 15
        }
        struct ContainerView {
            static let corner: CGFloat = 16
            static let spacing: CGFloat = 12
            static let common: CGFloat = 10
        }
        struct TitleLabel{
            static let font: CGFloat = 15
        }
        struct AuthLabel{
            static let font: CGFloat = 28
        }
        struct TableView {
            static let top: CGFloat = 100
            static let common: CGFloat = 10
        }
        
        struct ContainerStackView {
            static let top: CGFloat = 36
            static let common: CGFloat = 20
        }
    }
    // MARK: - UI Elements
    ///UIView
    lazy var topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#6C6C6C")
        view.layer.cornerRadius = UX.TopBarView.corner
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: UX.TopBarView.width, height: UX.TopBarView.height)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius =  UX.ContainerView.corner
        view.clipsToBounds = true
        return view
    }()
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    ///UILabel
    
    var dummyLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: UX.TitleLabel.font)
        return label
    }()
    
    private lazy var walletAuthTitleLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: UX.AuthLabel.font)
        label.textAlignment = .center
        label.text = "Wallet - Auth"
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
        tableView.register(ConnectTableCell.self, forCellReuseIdentifier:"ConnectTableCell")
        return tableView
    }()
    
    ///UIStackView
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [dummyLabel,walletAuthTitleLabel,spacer])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = UX.ContainerView.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - UI Properties
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    let defaultHeight: CGFloat = 400
    let maxDimmedAlpha: CGFloat = 0.6
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    var currentContainerHeight: CGFloat = 400
    
    var delegate : ConnectProtocol?
    let bag = DisposeBag()
    var single: Single<Account?>?
    var data: [ConnectWalletModel] = []
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        addBlurEffect()
        addTapGesture()
        setupPanGesture()
        setUpViewContraint()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingUpUI()
    }
    // MARK: - UI Methods
    func applyTheme() {
        view.backgroundColor = .clear
        let themeManager :  ThemeManager?
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        containerView.backgroundColor = theme?.colors.layer1
        dimmedView.backgroundColor = .clear
    }
  
    func addBlurEffect(){
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.95
        view.addSubview(blurEffectView)
    }
    
    func addTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    
    func setUpViewContraint() {
        view.addSubview(containerView)
        containerView.addSubview(topBarView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            ///UIView
            topBarView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: UX.TopBarView.top),
            topBarView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: UX.TopBarView.height),
            topBarView.widthAnchor.constraint(equalToConstant: UX.TopBarView.width),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.ContainerView.common),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.ContainerView.common),
            
            ///UITableView
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: UX.TableView.top),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,constant: UX.TableView.common),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,constant: -UX.TableView.common),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tableView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            
            ///UIStackView
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UX.ContainerStackView.top),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UX.ContainerStackView.common),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UX.ContainerStackView.common),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UX.ContainerStackView.common),
        ])
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    func settingUpUI(){
        var filterParticle = data.filter{$0.walletType == .particle}
        accountModel[0].isConnected = filterParticle.count > 0 ? true : false
        var filterMeta = data.filter{$0.walletType == .metaMask}
        accountModel[1].isConnected = filterMeta.count > 0 ? true : false
    }
    
    // MARK: - Objc Methodss
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        let newHeight = currentContainerHeight - translation.y
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    // MARK: - Helper Methods - Animations
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }
   
}

// MARK: Extension - UITableViewDelegate and UITableViewDataSource
extension ConnectViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accountModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectTableCell", for: indexPath) as! ConnectTableCell
        cell.setUI(data: accountModel[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adapters = ParticleConnect.getAdapters(chainType: .evm)
        var adapter: ConnectAdapter = adapters[0]
        if (indexPath.row == 0 &&  accountModel[indexPath.row].isConnected == false){
            adapter = adapters.first {
                $0.walletType == .particle
            }!
            single = adapter.connect(ParticleConnectConfig(loginType: .email))
            saveUserAddress()
        }else if(indexPath.row == 1 &&  accountModel[indexPath.row].isConnected == false){
            adapter = adapters.first {
                $0.walletType == .metaMask
            }!
            single = adapter.connect(ConnectConfig.none)
            saveUserAddress()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func saveUserAddress(){
        single?.subscribe {result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let account):
                if let account = account {
                    let connectWalletModel = ConnectWalletModel(publicAddress: account.publicAddress, name: account.name, url: account.url, icons: account.icons, description: account.description, isSelected: false, walletType: account.walletType, chainId: ConnectManager.getChainId())
                    WalletManager.shared.updateWallet(connectWalletModel)
                    self.dismiss(animated: true) {
                        self.delegate?.accountPublicAddress(address: account.publicAddress)
                    }
                }
            }
            
        }.disposed(by: bag)
    }
}

class ConnectTableCell: UITableViewCell {
    
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
            static let font: CGFloat = 20
            static let top: CGFloat = 20
            static let leading: CGFloat = 80
            static let height: CGFloat = 30
        }
        struct Value {
            static let font: CGFloat = 15
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 20
            static let topAt: CGFloat = 45
            static let trailing: CGFloat = -30
            static let height: CGFloat = 20
            static let width: CGFloat = 50
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
    
    ///UIImageView
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    ///UILabel
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel : GradientLabel = {
        let label = GradientLabel()
        label.text = "Connect"
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconView.addSubview(iconImageView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        setUpConstraints()
    }
    // MARK: - UI Methods
    
    func setUpConstraints(){
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Title.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Value.top),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            
        ]
        )
    }
    
    func setUI(data : AccountModel){
        titleLabel.text = data.title
        iconImageView.image = UIImage(named: data.image!)
        self.valueLabel.isHidden = data.isConnected ?? false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
