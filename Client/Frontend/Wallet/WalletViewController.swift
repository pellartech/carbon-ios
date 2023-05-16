//
//  WalletViewController.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//

import Foundation
import UIKit
import ParticleConnect
import ConnectCommon
import ParticleWalletAPI
import RxSwift
import ParticleNetworkBase
import SVProgressHUD
import ParticleAuthService

var accountModel = [
    AccountModel(title: "Particle", image: "particle", isConnected: false,walletType: WalletType.particle),
    AccountModel(title: "Metamask", image: "metamask",isConnected: false,walletType: WalletType.metaMask),
]

class WalletViewController: UIViewController {
    
// MARK: - UI Constants
    private struct UX {
        struct WelcomeView {
            static let heightGetStarted: CGFloat = 300
        }
        struct BalanceLabel{
            static let topValueCarbon: CGFloat = 10
            static let topValue: CGFloat = 20
            static let font: CGFloat = 45
            static let carbonFont: CGFloat = 12
            static let titleFont: CGFloat = 16
        }
        struct LogoView {
            static let top: CGFloat = 60
            static let width: CGFloat = 220
            static let height: CGFloat = 46
            static let heightBg: CGFloat = 120
        }
        struct ContentView {
            static let heightBackGround: CGFloat = 350
        }
        struct ActionView {
            static let heightActionBg: CGFloat = 30
            static let topActionBg: CGFloat = 20
        }
        struct UserTokenView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 20
        }
        struct WelcomeLabel {
            static let topValueCarbon: CGFloat = 10
            static let widthWelcome: CGFloat = 250
            static let heightWelcome: CGFloat = 150
            static let heightGetStarted: CGFloat = 300
            static let font: CGFloat = 20

        }
        struct LogoImageView {
            static let height: CGFloat = 32
            static let width: CGFloat = 32
        }
        
        struct CarbonImageView {
            static let leading: CGFloat = 10
            static let width: CGFloat = 118
            static let height: CGFloat = 30
        }
        
        struct Wallet {
            static let top: CGFloat = 15
            static let leading: CGFloat = 2
            static let width: CGFloat = 65
            static let height: CGFloat = 16
        }
        
        struct ActionIcon {
            static let top: CGFloat = 20
            static let leading: CGFloat = 20
            static let trailing: CGFloat = -20
            static let width: CGFloat = 20
            static let height: CGFloat = 20
        }
        struct StartButtonView {
            static let bottom: CGFloat = -100
            static let width: CGFloat = 150
            static let height: CGFloat = 50
            static let corner: CGFloat = 25
        }
        struct ButtonView {
            static let top: CGFloat = -50
            static let centerX: CGFloat = 90
            static let height: CGFloat = 50
            static let width: CGFloat = 163
            static let font: CGFloat = 14
            static let corner: CGFloat = 15
        }
        struct TokenLabel{
            static let leading: CGFloat = 20
            static let topValue: CGFloat = 10
            static let font: CGFloat = 13
        }
        struct TableView{
            static let leading: CGFloat = 10
            static let top: CGFloat = 35
            static let trailing: CGFloat = -10
            static let bottom: CGFloat = -30

        }
        struct WalletLabel {
            static let font: CGFloat = 20

        }
    
    }
// MARK: - UI Elements

    ///UIView
    private lazy var logoView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var userTokensView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        view.layer.cornerRadius = UX.UserTokenView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var welcomeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#2C2C2C")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var actionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sendBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var receiveBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var getStartButtonView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.StartButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var getStartGradientView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = UX.StartButtonView.corner
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }()
    
    ///UIImageView
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_carbon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var carbonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_carbon_text")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var connectIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_wallet_connect")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.connectIconTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var accountIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_wallet_account")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.accountIconTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    ///UILabel
    private lazy var walletLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: UX.WalletLabel.font)
        label.textAlignment = .center
        label.text = "wallet"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var getStartedLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize:  UX.WalletLabel.font)
        label.textAlignment = .center
        label.text = "Get started"
        label.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.getStartedTapped))
        label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private lazy var totalBalanceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "Total balance"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var totalBalanceLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.font)
        label.textAlignment = .center
        label.text = "$0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var carbonBalanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .systemFont(ofSize: UX.BalanceLabel.carbonFont)
        label.textAlignment = .center
        label.text = "0 Carbon (CSIX)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .systemFont(ofSize: UX.WelcomeLabel.font)
        label.textAlignment = .center
        label.text = "Welcome to carbon wallet"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var tokenLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.TokenLabel.font)
        label.textAlignment = .center
        label.text = "Tokens"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        return label
    }()
    
    ///UIButton
    private lazy var sendButton : UIButton = {
        let button = UIButton()
        button.setTitle("SEND", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.sendBtnTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private lazy var receiveButton : UIButton = {
        let button = UIButton()
        button.setTitle("RECEIVE", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.receiveBtnTapped), for: .touchUpInside)
        button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.isUserInteractionEnabled = true
        return button
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
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        tableView.register(TokensTVCell.self, forCellReuseIdentifier:"TokensTVCell")
        return tableView
    }()
    
// MARK: - UI Properties
    private var data: [ConnectWalletModel] = []
    let bag = DisposeBag()
    private var publicAddress = String()
    private var tokensModel = [TokenModel]()
    let viewModel = WalletViewModel()
    
// MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpViewContraint()
        getLocalUserData()
    }
    
// MARK: - UI Methods
    func setUpView(){
        view.backgroundColor = UIColor.black
        receiveBtnView.alpha = 0
        
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        
        actionsView.addSubview(connectIcon)
        actionsView.addSubview(accountIcon)
        actionsView.addSubview(totalBalanceTitleLabel)
        
        welcomeView.addSubview(welcomeLabel)
        welcomeView.addSubview(getStartButtonView)
        welcomeView.addSubview(getStartGradientView)
        welcomeView.addSubview(getStartedLabel)
        
        contentView.addSubview(actionsView)
        contentView.addSubview(totalBalanceLabel)
        contentView.addSubview(carbonBalanceLabel)
        contentView.addSubview(sendBtnView)
        contentView.addSubview(receiveBtnView)
        contentView.addSubview(sendButton)
        contentView.addSubview(receiveButton)
        
        userTokensView.addSubview(tokenLabel)
        userTokensView.addSubview(tableView)
        
        view.addSubview(contentView)
        view.addSubview(logoBackgroundView)
        view.addSubview(welcomeView)
        view.addSubview(userTokensView)
        
    }
    
    func setUpViewContraint(){
        NSLayoutConstraint.activate([
            
            ///UIView
            logoView.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.LogoView.top),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.widthAnchor.constraint(equalToConstant: UX.LogoView.width),
            logoView.heightAnchor.constraint(equalToConstant: UX.LogoView.height),
            
            logoBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            logoBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            logoBackgroundView.heightAnchor.constraint(equalToConstant: UX.LogoView.heightBg),
            
            actionsView.topAnchor.constraint(equalTo: logoBackgroundView.bottomAnchor,constant: UX.ActionView.topActionBg),
            actionsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            welcomeView.topAnchor.constraint(equalTo: logoBackgroundView.bottomAnchor),
            welcomeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeView.widthAnchor.constraint(equalTo: view.widthAnchor),
            welcomeView.heightAnchor.constraint(equalToConstant: UX.WelcomeView.heightGetStarted),
            
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: UX.ContentView.heightBackGround),
            
            userTokensView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.UserTokenView.common),
            userTokensView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.UserTokenView.common),
            userTokensView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.UserTokenView.common),
            userTokensView.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -UX.UserTokenView.common),
            
            sendBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant:  UX.ButtonView.top),
            sendBtnView.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: -UX.ButtonView.centerX),
            sendBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.width),
            sendBtnView.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
            
            receiveBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant:UX.ButtonView.top),
            receiveBtnView.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant:  UX.ButtonView.centerX),
            receiveBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.width),
            receiveBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            getStartButtonView.bottomAnchor.constraint(equalTo: welcomeView.bottomAnchor,constant: UX.StartButtonView.bottom),
            getStartButtonView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartButtonView.widthAnchor.constraint(equalToConstant: UX.StartButtonView.width),
            getStartButtonView.heightAnchor.constraint(equalToConstant: UX.StartButtonView.height),
            
            getStartGradientView.bottomAnchor.constraint(equalTo: welcomeView.bottomAnchor,constant: UX.StartButtonView.bottom),
            getStartGradientView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartGradientView.widthAnchor.constraint(equalToConstant: UX.StartButtonView.width),
            getStartGradientView.heightAnchor.constraint(equalToConstant: UX.StartButtonView.height),
            
            ///UIImage View
            logoImageView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoView.topAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: UX.LogoImageView.width),
            logoImageView.heightAnchor.constraint(equalToConstant: UX.LogoImageView.height),
            
            carbonImageView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor,constant: UX.CarbonImageView.leading),
            carbonImageView.topAnchor.constraint(equalTo: logoView.topAnchor),
            carbonImageView.widthAnchor.constraint(equalToConstant: UX.CarbonImageView.width),
            carbonImageView.heightAnchor.constraint(equalToConstant: UX.CarbonImageView.height),
            
            connectIcon.leadingAnchor.constraint(equalTo: actionsView.leadingAnchor,constant: UX.ActionIcon.leading),
            connectIcon.topAnchor.constraint(equalTo: actionsView.topAnchor),
            connectIcon.widthAnchor.constraint(equalToConstant: UX.ActionIcon.width),
            connectIcon.heightAnchor.constraint(equalToConstant: UX.ActionIcon.height),
            
            accountIcon.trailingAnchor.constraint(equalTo: actionsView.trailingAnchor,constant: UX.ActionIcon.trailing),
            accountIcon.topAnchor.constraint(equalTo: actionsView.topAnchor),
            accountIcon.widthAnchor.constraint(equalToConstant: UX.ActionIcon.width),
            accountIcon.heightAnchor.constraint(equalToConstant: UX.ActionIcon.height),
            
            ///UILabel
            walletLabel.leadingAnchor.constraint(equalTo: carbonImageView.trailingAnchor,constant: UX.Wallet.leading),
            walletLabel.topAnchor.constraint(equalTo: logoView.topAnchor,constant:  UX.Wallet.top),
            walletLabel.widthAnchor.constraint(equalToConstant: UX.Wallet.width),
            walletLabel.heightAnchor.constraint(equalToConstant: UX.Wallet.height),
            
            totalBalanceTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            totalBalanceTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor),
            
            totalBalanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalBalanceLabel.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant: UX.BalanceLabel.topValue),
            
            carbonBalanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            carbonBalanceLabel.topAnchor.constraint(equalTo: totalBalanceLabel.bottomAnchor,constant: UX.BalanceLabel.topValueCarbon),
            
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: welcomeView.topAnchor,constant: UX.WelcomeLabel.topValueCarbon),
            welcomeLabel.widthAnchor.constraint(equalToConstant:  UX.WelcomeLabel.widthWelcome),
            welcomeLabel.heightAnchor.constraint(equalToConstant:  UX.WelcomeLabel.heightWelcome),
            
            getStartedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedLabel.bottomAnchor.constraint(equalTo: welcomeView.bottomAnchor,constant: UX.StartButtonView.bottom),
            getStartedLabel.heightAnchor.constraint(equalToConstant: UX.StartButtonView.height),
            
            tokenLabel.leadingAnchor.constraint(equalTo: userTokensView.leadingAnchor,constant: UX.TokenLabel.leading),
            tokenLabel.topAnchor.constraint(equalTo: userTokensView.topAnchor,constant: UX.TokenLabel.topValue),
            
            ///UIButton
            sendButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.ButtonView.top),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: -UX.ButtonView.centerX),
            sendButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            sendButton.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
            
            receiveButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.ButtonView.top),
            receiveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: UX.ButtonView.centerX),
            receiveButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            receiveButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            ///UITableView
            tableView.topAnchor.constraint(equalTo: userTokensView.topAnchor,constant: UX.TableView.top),
            tableView.leadingAnchor.constraint(equalTo: userTokensView.leadingAnchor,constant:   UX.TableView.leading),
            tableView.trailingAnchor.constraint(equalTo: userTokensView.trailingAnchor,constant: UX.TableView.trailing),
            tableView.bottomAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant:  UX.TableView.bottom),
            
        ])
    }
    
    func getLocalUserData(){
        data = WalletManager.shared.getWallets().filter { connectWalletModel in
            let adapters = ParticleConnect.getAdapterByAddress(publicAddress: connectWalletModel.publicAddress).filter {
                $0.isConnected(publicAddress: connectWalletModel.publicAddress) && $0.walletType == connectWalletModel.walletType
            }
            return !adapters.isEmpty
        }
        if(data.count > 0){
            setUIAndFetchData(address: data.first?.publicAddress ?? "")
        }else{
            welcomeView.isHidden =  false
            contentView.isHidden = true
            userTokensView.isHidden = true
        }
    }
    
// MARK: - View Model Methods - Network actions
    func setUIAndFetchData(address: String){
        SVProgressHUD.show()
        
        welcomeView.isHidden = data.count > 0 ? true : false
        contentView.isHidden = data.count > 0 ? false : true
        userTokensView.isHidden = data.count > 0 ? false : true
        publicAddress = address
        
        self.viewModel.addCustomTokenToUserAccount(address: publicAddress) {result in
            switch result {
            case .success(let tokens):
                self.fetchUserTokens(tokens: tokens)
            case .failure(let error):
                print(error)
                self.fetchUserTokens(tokens: [])
            }
        }
    }
    
    func fetchUserTokens(tokens: [TokenModel]){
        self.viewModel.getUserTokenListsForNativeTokens(address: publicAddress, tokenArray: tokens) { result in
            switch result {
            case .success(let tokens):
                self.tokensModel = tokens
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                SVProgressHUD.dismiss()
            case .failure(let error):
                print(error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
// MARK: - Objc Methods
    @objc func connectIconTapped (){
        initiateDrawerVC()
    }
    
    @objc func accountIconTapped (){
        initiateConnetVC()
    }
    @objc func getStartedTapped (){
        initiateConnetVC()
    }
    
    @objc func sendBtnTapped (){
        receiveBtnView.alpha = 0
        sendBtnView.alpha = 1
        receiveButton.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        sendButton.backgroundColor = UIColor.clear
        initiateSendVC()
    }
    
    @objc func receiveBtnTapped (){
        receiveBtnView.alpha = 1
        sendBtnView.alpha = 0
        sendButton.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        receiveButton.backgroundColor = UIColor.clear
        initiateReceiveVC()
    }
    
// MARK: - Helper Methods - Initiate view controller
    func initiateSendVC(){
        let vc = SendViewController()
        vc.address = publicAddress
        vc.tokens = self.tokensModel
        self.present(vc, animated: true)
    }
    
    func initiateDrawerVC(){
        let drawerController = DrawerMenuViewController()
        drawerController.delegate = self
        present(drawerController, animated: true)
    }
    
    func initiateConnetVC(){
        let vc = ConnectViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        vc.data = data
        self.present(vc, animated: false)
    }
    
    func initiateReceiveVC(){
        let vc = ReceiveViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.address = publicAddress
        self.present(vc, animated: false)
    }
}

// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension WalletViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokensModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokensTVCell", for: indexPath) as! TokensTVCell
        cell.setUI(token: tokensModel[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - Extension - ConnectProtocol
extension WalletViewController : ConnectProtocol{
    func accountPublicAddress(address: String) {
        setUIAndFetchData(address: address)
    }
}

