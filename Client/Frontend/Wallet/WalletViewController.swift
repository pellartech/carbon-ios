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
import SVProgressHUD
import SDWebImage
import Common
import Shared

typealias Chain = ParticleNetwork.ChainInfo
typealias SolanaNetwork = ParticleNetwork.SolanaNetwork
typealias EthereumNetwork = ParticleNetwork.EthereumNetwork

class WalletViewController: UIViewController {
    
// MARK: - UI Constants
    private struct UX {
        struct ScrollView {
            static let constant: CGFloat = 120
        }
        struct WelcomeView {
            static let heightGetStarted: CGFloat = 500
        }
        struct BalanceLabel{
            static let topValueCarbon: CGFloat = 10
            static let topValue: CGFloat = 0
            static let font: CGFloat = 45
            static let carbonFont: CGFloat = 12
            static let titleFont: CGFloat = 16
            static let top: CGFloat = 30
            static let width: CGFloat = 300
        }
        struct LogoView {
            static let top: CGFloat = 50
            static let width: CGFloat = 220
            static let height: CGFloat = 46
            static let heightBg: CGFloat = 120
        }
        struct ContentView {
            static let heightBackGround: CGFloat = 200
        }
        struct ActionView {
            static let heightActionBg: CGFloat = 25
            static let topActionBg: CGFloat = 10
        }
        struct UserTokenView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 20
            static let top: CGFloat = 30
        }
        struct WelcomeLabel {
            static let topValueCarbon: CGFloat = 25
            static let widthWelcome: CGFloat = 250
            static let heightWelcome: CGFloat = 20
            static let heightGetStarted: CGFloat = 300
            static let font: CGFloat = 13
            static let descrpFont: CGFloat = 16
            static let descrpHeight: CGFloat = 200
            static let common: CGFloat = 20
            static let topValue: CGFloat = 75
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
            static let bottom: CGFloat = 100
            static let width: CGFloat = 150
            static let height: CGFloat = 50
            static let corner: CGFloat = 25
        }
        struct ButtonView {
            static let top: CGFloat = -30
            static let centerX: CGFloat = 8
            static let height: CGFloat = 50
            static let width: CGFloat = 163
            static let font: CGFloat = 14
            static let corner: CGFloat = 10
            static let leading: CGFloat = 20
            static let addTop: CGFloat = 20
            static let seeAllheight: CGFloat = 24
            static let seeAllwidth: CGFloat = 100
            static let seeTop: CGFloat = -15
            static let seeCorner: CGFloat = 12
            static let seeFont: CGFloat = 10
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
            static let font: CGFloat = 18
        }
        
        struct DropDown {
            static let width: CGFloat = 180
            static let height: CGFloat = 400
            static let top: CGFloat = 20
            static let widthC: CGFloat = 180
            static let heightC: CGFloat = 30
        }
        struct CloseButton {
            static let top: CGFloat = 50
            static let leading: CGFloat = 20
            static let height: CGFloat = 40
            static let width: CGFloat = 40
            static let corner: CGFloat = 20
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
    private lazy var logoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    private lazy var seeAllBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.seeCorner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var buyBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var addTokenBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
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
    private lazy var settingsIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_wallet_settings")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.settingsIconTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    private lazy var infoIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_wallet_info")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.infoIconTapped))
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
    private lazy var totalBalanceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "TOTAL BALANCE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var noTokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: UX.WelcomeLabel.font)
        label.textAlignment = .center
        label.text = "You don’t have any tokes yet."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    private lazy var totalBalanceLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.font)
        label.textAlignment = .center
        label.text = "$0"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
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
        button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
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
    private lazy var seeAllButton : UIButton = {
        let button = UIButton()
        button.setTitle("SEE ALL", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.seeFont)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.seeAllBtnTapped(sender:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.seeCorner
        button.isUserInteractionEnabled = true
        return button
    }()
    private lazy var closeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeBtnTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.tintColor = Utilities().hexStringToUIColor(hex: "#FF2D08")
        button.isUserInteractionEnabled = true
        return button
    }()
    private lazy var buyButton : UIButton = {
        let button = UIButton()
        button.setTitle("BUY", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.buyBtnTapped), for: .touchUpInside)
        button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.isUserInteractionEnabled = true
        return button
    }()
    private lazy var addTokenButton : UIButton = {
        let button = UIButton()
        button.setTitle("ADD TOKEN", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.addTokenBtnTapped), for: .touchUpInside)
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
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TokensTVCell.self, forCellReuseIdentifier:"TokensTVCell")
        return tableView
    }()
    
    ///UIScrollView
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var scrollContentView : UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    
// MARK: - UI Properties
    var shownFromAppMenu: Bool = false
    private var data: [ConnectWalletModel] = []
    let bag = DisposeBag()
    private var publicAddress = String()
    private var tokensModel = [TokenModel]()
    let viewModel = WalletViewModel()
    var networkData = [String]()
    var heightForTokenViewNoToken =  NSLayoutConstraint()
    var heightForTokenView =  NSLayoutConstraint()
    var themeManager :  ThemeManager?
    
// MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpNetwork()
        setUpViewContraint()
        getLocalUserData()
    }
    
// MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpNetwork(){
        let chainInfo : Chain = .ethereum(EthereumNetwork(rawValue: EthereumNetwork.sepolia.rawValue)!)
        ParticleNetwork.setChainInfo(chainInfo)
    }
    
    func setUpView(){
        navigationController?.isNavigationBarHidden = true
        receiveBtnView.alpha = 0
        self.tokenLabel.isHidden = true
        heightForTokenViewNoToken = userTokensView.heightAnchor.constraint(equalToConstant: 130)
        heightForTokenView = userTokensView.heightAnchor.constraint(equalToConstant: 263)
        
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(infoIcon)
        actionsView.addSubview(totalBalanceTitleLabel)
        contentView.addSubview(actionsView)
        contentView.addSubview(totalBalanceLabel)
        contentView.addSubview(carbonBalanceLabel)
        contentView.addSubview(sendBtnView)
        contentView.addSubview(receiveBtnView)
        contentView.addSubview(buyBtnView)
        contentView.addSubview(sendButton)
        contentView.addSubview(receiveButton)
        contentView.addSubview(buyButton)
        userTokensView.addSubview(tokenLabel)
        userTokensView.addSubview(noTokenLabel)
        userTokensView.addSubview(tableView)
        scrollContentView.addSubview(contentView)
        scrollContentView.addSubview(userTokensView)
        scrollContentView.addSubview(addTokenBtnView)
        scrollContentView.addSubview(addTokenButton)
        scrollContentView.addSubview(seeAllBtnView)
        scrollContentView.addSubview(seeAllButton)
        scrollView.addSubview(scrollContentView)
        view.addSubview(scrollView)
        view.addSubview(logoBackgroundView)
        view.addSubview(closeButton)
    }
    
    func setUpViewContraint(){
        NSLayoutConstraint.activate([
            ///Scroll
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.ScrollView.constant),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            scrollContentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            ///Close Button
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:UX.CloseButton.leading),
            closeButton.topAnchor.constraint(equalTo: view.topAnchor,constant:UX.CloseButton.top),
            closeButton.widthAnchor.constraint(equalToConstant: UX.CloseButton.width),
            closeButton.heightAnchor.constraint(equalToConstant:UX.CloseButton.height),

            ///Top Logo View
            logoView.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.LogoView.top),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.widthAnchor.constraint(equalToConstant: UX.LogoView.width),
            logoView.heightAnchor.constraint(equalToConstant: UX.LogoView.height),
            
            logoBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            logoBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            logoBackgroundView.heightAnchor.constraint(equalToConstant: UX.LogoView.heightBg),
            
            ///Content view
            contentView.topAnchor.constraint(equalTo: scrollContentView.topAnchor),
            contentView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollContentView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: UX.ContentView.heightBackGround),
           
            ///Action View
            actionsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            ///User Token List View
            userTokensView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.UserTokenView.top),
            userTokensView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            userTokensView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),

            ///Receive Button View
            receiveBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant:UX.ButtonView.top),
            receiveBtnView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            receiveBtnView.widthAnchor.constraint(equalToConstant:  (view.frame.size.width/3) - 20),
            receiveBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            ///Send Button View
            sendBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant:  UX.ButtonView.top),
            sendBtnView.trailingAnchor.constraint(equalTo: receiveBtnView.leadingAnchor,constant: -UX.ButtonView.centerX),
            sendBtnView.widthAnchor.constraint(equalToConstant:  (view.frame.size.width/3) - 20),
            sendBtnView.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
               
            ///Buy Button View
            buyBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant:UX.ButtonView.top),
            buyBtnView.leadingAnchor.constraint(equalTo: receiveBtnView.trailingAnchor,constant: UX.ButtonView.centerX),
            buyBtnView.widthAnchor.constraint(equalToConstant: (view.frame.size.width/3) - 20),
            buyBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            ///Top header Logo ImageView
            logoImageView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoView.topAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: UX.LogoImageView.width),
            logoImageView.heightAnchor.constraint(equalToConstant: UX.LogoImageView.height),
            
            ///Top header Logo Text ImageView
            carbonImageView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor,constant: UX.CarbonImageView.leading),
            carbonImageView.topAnchor.constraint(equalTo: logoView.topAnchor),
            carbonImageView.widthAnchor.constraint(equalToConstant: UX.CarbonImageView.width),
            carbonImageView.heightAnchor.constraint(equalToConstant: UX.CarbonImageView.height),
            
            ///ActionView settings ImageView
            settingsIcon.leadingAnchor.constraint(equalTo: actionsView.leadingAnchor,constant: UX.ActionIcon.leading),
            settingsIcon.topAnchor.constraint(equalTo: actionsView.topAnchor),
            settingsIcon.widthAnchor.constraint(equalToConstant: UX.ActionIcon.width),
            settingsIcon.heightAnchor.constraint(equalToConstant: UX.ActionIcon.height),
            
            ///ActionView info ImageView
            infoIcon.trailingAnchor.constraint(equalTo: actionsView.trailingAnchor,constant: UX.ActionIcon.trailing),
            infoIcon.topAnchor.constraint(equalTo: actionsView.topAnchor),
            infoIcon.widthAnchor.constraint(equalToConstant: UX.ActionIcon.width),
            infoIcon.heightAnchor.constraint(equalToConstant: UX.ActionIcon.height),
            
            ///Wallet Label
            walletLabel.leadingAnchor.constraint(equalTo: carbonImageView.trailingAnchor,constant: UX.Wallet.leading),
            walletLabel.topAnchor.constraint(equalTo: logoView.topAnchor,constant:  UX.Wallet.top),
            walletLabel.widthAnchor.constraint(equalToConstant: UX.Wallet.width),
            walletLabel.heightAnchor.constraint(equalToConstant: UX.Wallet.height),
            
            ///Wallet balance title Label
            totalBalanceTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            totalBalanceTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor,constant: UX.BalanceLabel.topValue),
            
            ///Wallet balance Label
            totalBalanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            totalBalanceLabel.topAnchor.constraint(equalTo: totalBalanceTitleLabel.bottomAnchor,constant: UX.BalanceLabel.top),
            totalBalanceLabel.widthAnchor.constraint(equalToConstant: UX.BalanceLabel.width),

            ///Wallet carbon balance Label
            carbonBalanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            carbonBalanceLabel.topAnchor.constraint(equalTo: totalBalanceLabel.bottomAnchor,constant: UX.BalanceLabel.topValueCarbon),
            
            ///UserTokenView token Label
            tokenLabel.leadingAnchor.constraint(equalTo: userTokensView.leadingAnchor,constant: UX.TokenLabel.leading),
            tokenLabel.topAnchor.constraint(equalTo: userTokensView.topAnchor,constant: UX.TokenLabel.topValue),
            
            ///UserTokenView no token Label
            noTokenLabel.centerXAnchor.constraint(equalTo: userTokensView.centerXAnchor),
            noTokenLabel.centerYAnchor.constraint(equalTo: userTokensView.centerYAnchor),
            
            ///Receive Button
            receiveButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.ButtonView.top),
            receiveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            receiveButton.widthAnchor.constraint(equalToConstant:(view.frame.size.width/3) - 20),
            receiveButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            ///Send Button
            sendButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.ButtonView.top),
            sendButton.trailingAnchor.constraint(equalTo: receiveButton.leadingAnchor,constant: -UX.ButtonView.centerX),
            sendButton.widthAnchor.constraint(equalToConstant: (view.frame.size.width/3) - 20),
            sendButton.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
                
            ///Buy Button
            buyButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.ButtonView.top),
            buyButton.leadingAnchor.constraint(equalTo: receiveButton.trailingAnchor,constant: UX.ButtonView.centerX),
            buyButton.widthAnchor.constraint(equalToConstant:(view.frame.size.width/3) - 20),
            buyButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            ///UserTokenView TableView
            tableView.topAnchor.constraint(equalTo: userTokensView.topAnchor,constant: UX.TableView.top),
            tableView.leadingAnchor.constraint(equalTo: userTokensView.leadingAnchor,constant: UX.TableView.leading),
            tableView.trailingAnchor.constraint(equalTo: userTokensView.trailingAnchor,constant: UX.TableView.trailing),
            tableView.bottomAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant: UX.TableView.trailing),
            
            ///See all button view
            seeAllBtnView.topAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant:UX.ButtonView.seeTop),
            seeAllBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.seeAllwidth),
            seeAllBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.seeAllheight),
            seeAllBtnView.centerXAnchor.constraint(equalTo: userTokensView.centerXAnchor),
            
            ///See all button
            seeAllButton.topAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant: UX.ButtonView.seeTop),
            seeAllButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.seeAllwidth),
            seeAllButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.seeAllheight),
            seeAllButton.centerXAnchor.constraint(equalTo: userTokensView.centerXAnchor),

            ///Add token button view
            addTokenBtnView.topAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant:UX.ButtonView.addTop),
            addTokenBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.width),
            addTokenBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            addTokenBtnView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            addTokenBtnView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
          
            ///Add token button
            addTokenButton.topAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant: UX.ButtonView.addTop),
            addTokenButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            addTokenButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            addTokenButton.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            addTokenButton.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
            addTokenButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
        ])
        heightForTokenViewNoToken.isActive = true
    }
    
    func collapseTokenView(){
        heightForTokenViewNoToken.isActive = true
        heightForTokenView.isActive = false
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func expandTokenView(){
        heightForTokenViewNoToken.isActive = false
        heightForTokenView.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func getLocalUserData(){
        data = WalletManager.shared.getWallets().filter { connectWalletModel in
            let adapters = ParticleConnect.getAdapterByAddress(publicAddress: connectWalletModel.publicAddress).filter {
                $0.isConnected(publicAddress: connectWalletModel.publicAddress) && $0.walletType == connectWalletModel.walletType
            }
            return !adapters.isEmpty
        }
        if(data.count > 0){
            //TODO: -Need to replace with account preference values
            let filterData = data.filter{$0.walletType == .particle}
            setUIAndFetchData(address: filterData.first?.publicAddress ?? "")
        }else{
        }
    }
    
    
// MARK: - View Model Methods - Network actions
    func setUIAndFetchData(address: String){
        SVProgressHUD.show()
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
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.tokenLabel.isHidden = false
                        self.noTokenLabel.isHidden = true
                        self.expandTokenView()
                        self.tableView.reloadData()
                        var total = Decimal()
                        for token in self.tokensModel{
                            total = total + self.toEther(wei: token.amount)
                        }
                        self.totalBalanceLabel.text = "$\(total)"
                    }
                }
                SVProgressHUD.dismiss()
            case .failure(let error):
                print(error)
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.tokenLabel.isHidden = true
                        self.noTokenLabel.isHidden = false
                        SVProgressHUD.dismiss()
                    }
                }
            }
        }
    }
    
// MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func settingsIconTapped (){
        initiateDrawerVC()
    }
    
    @objc func infoIconTapped (){
        showToast()
    }

    @objc func sendBtnTapped (){
        showToast()
    }
    
    @objc func receiveBtnTapped (){
        showToast()
    }
    @objc func buyBtnTapped (){
        showToast()
    }
    
    @objc func seeAllBtnTapped(sender:UIButton){
        if (sender.tag == 0){
            sender.tag = 1
            collapseTokenView()
            heightForTokenView = userTokensView.heightAnchor.constraint(equalToConstant: CGFloat(self.tokensModel.count * 85))
            expandTokenView()
        }else{
            sender.tag = 0
            collapseTokenView()
            heightForTokenView = userTokensView.heightAnchor.constraint(equalToConstant: 263)
            expandTokenView()
        }
    }
    
    @objc func addTokenBtnTapped (){
        showToast()
    }
    
// MARK: - Helper Methods - Initiate view controller
    func initiateSendVC(){
        let vc = SendViewController()
        vc.publicAddress = publicAddress
        vc.tokens = self.tokensModel
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true)
    }
    
    func initiateDrawerVC(){
        let drawerController = DrawerMenuViewController()
        drawerController.delegate = self
        present(drawerController, animated: true)
    }
    
    func initiateReceiveVC(){
        let vc = ReceiveViewController()
        vc.modalPresentationStyle = .overCurrentContext
        vc.address = publicAddress
        self.present(vc, animated: false)
    }
    
    func toEther(wei: BInt) -> Decimal {
        let etherInWei = pow(Decimal(10), 18)
        if let decimalWei = Decimal(string: wei.description){
            return decimalWei / etherInWei
        }else{
            return Decimal()
        }
    }
    
    func showToast(){
        SimpleToast().showAlertWithText("Coming soon...",
                                        bottomContainer: self.view,
                                        theme: themeManager!.currentTheme)
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
        return 70
    }
}

// MARK: - Extension - ConnectProtocol
extension WalletViewController : ConnectProtocol{
    func accountPublicAddress(address: String) {
        getLocalUserData()
        setUIAndFetchData(address: address)
    }
    func logout() {
        self.dismiss(animated: true)
    }
}

class TokensTVCell: UITableViewCell {
    
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
            static let font: CGFloat = 14
            static let top: CGFloat = 20
            static let leading: CGFloat = 80
            static let height: CGFloat = 30
        }
        struct Value {
            static let font: CGFloat = 15
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 20
            static let topAt: CGFloat = 0
            static let trailing: CGFloat = -10
            static let height: CGFloat = 20
            static let width: CGFloat = 50
            static let valueWidth: CGFloat = 150
            static let valueHeight: CGFloat = 30
        }
    }
    
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
    private lazy var valueLabel : UILabel = {
        let label = UILabel()
        label.textColor =  UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var valueAtLabel : UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#818181")
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.fontAt)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    private var wallpaperManager =  WallpaperManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconView.addSubview(iconImageView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(valueAtLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            ///UIView
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            ///UIImageView
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconImageView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconImageView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            ///UILabel
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Title.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Value.top),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            valueLabel.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            valueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),

            valueAtLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor,constant: UX.Value.topAt),
            valueAtLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
        ]
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(token : TokenModel){
        let value = toEther(wei: token.amount)
        titleLabel.text = token.tokenInfo.name
        valueLabel.text = "\(value) \(token.tokenInfo.symbol)"
        if #available(iOS 15.0, *) {
            valueAtLabel.text = value.formatted(.currency(code: "USD"))
        }
        if (token.tokenInfo.logoURI != ""){
            iconImageView.sd_setImage(with: URL(string: token.imageUrl)!)
        }else{
            var defaultImage = ""
            switch token.tokenInfo.symbol {
            case "ETH":
                defaultImage = "ic_eth"
                iconImageView.image = UIImage(named: defaultImage)
            case "USDC":
                defaultImage = "ic_usdc"
                iconImageView.image = UIImage(named: defaultImage)
            case "USDT":
                defaultImage = "ic_usdt"
                iconImageView.image = UIImage(named: defaultImage)
            case "WETH":
                defaultImage = "ic_weth"
                iconImageView.image = UIImage(named: defaultImage)
            default: break
            }
        }
    }
    
    
    func toEther(wei: BInt) -> Decimal {
        let etherInWei = pow(Decimal(10), 18)
        if let decimalWei = Decimal(string: wei.description){
            return decimalWei / etherInWei
        }else{
            return Decimal()
        }
    }
    
}


