//
//  SendConfirmationViewController.swift
//  Client
//
//  Created by Ashok on 07/07/23.
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

class SendConfirmationViewController: UIViewController {
    
    // MARK: - UI Constants
    private struct UX {
        struct ScrollView {
            static let constant: CGFloat = 120
        }
        struct BalanceLabel{
            static let topValueCarbon: CGFloat = 10
            static let topValue: CGFloat = 0
            static let font: CGFloat = 45
            static let carbonFont: CGFloat = 12
            static let titleFont: CGFloat = 16
            static let top: CGFloat = 30
            static let width: CGFloat = 300
            static let font1: CGFloat = 12
            static let font2: CGFloat = 20
            static let tokenFont: CGFloat = 11
            
        }
        struct LogoView {
            static let top: CGFloat = 50
            static let width: CGFloat = 220
            static let height: CGFloat = 46
            static let heightBg: CGFloat = 120
        }
        struct ContentView {
            static let heightBackGround: CGFloat = 350
        }
        struct SearchView {
            static let height: CGFloat = 50
            static let cornerRadius: CGFloat = 10
            static let font: CGFloat = 14
            static let top: CGFloat = 30
            static let leading: CGFloat = 10
            static let button: CGFloat = 24
            static let constant: CGFloat = 5
            
        }
        struct NetworkView {
            static let detailHeight: CGFloat = 20
            static let height: CGFloat = 54
            static let top: CGFloat = 30
            static let netWorkTop: CGFloat = 15
            static let leading: CGFloat = 10
            static let corner: CGFloat = 10
            static let font: CGFloat = 15
        }
        struct ActionView {
            static let heightActionBg: CGFloat = 25
            static let topActionBg: CGFloat = 10
        }
        struct DetailsView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 10
            static let top: CGFloat = 15
            static let height: CGFloat = 220
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
            static let addTop: CGFloat = 300
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
            static let common: CGFloat = 15
            static let leading: CGFloat = 10
            static let top: CGFloat = 15
            static let trailing: CGFloat = -10
            static let bottom: CGFloat = -30
            static let height: CGFloat = 120
            static let tokenInfoTop: CGFloat = 10
            
        }
        struct TokenView {
            static let height: CGFloat = 80
            static let common: CGFloat = 20
            static let top: CGFloat = 5
            static let logoHeight: CGFloat = 48
            static let logoWidth: CGFloat = 48
            static let shareHeight: CGFloat = 24
            static let shareWidth: CGFloat = 24
        }
        struct WalletLabel {
            static let font: CGFloat = 18
        }
        struct Divider {
            static let common: CGFloat = 15
            static let height: CGFloat = 2
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
        struct Title {
            static let font: CGFloat = 14
            static let top: CGFloat = 20
            static let leading: CGFloat = 20
            static let height: CGFloat = 30
        }
        struct Value {
            static let font: CGFloat = 15
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 10
            static let topAt: CGFloat = 0
            static let trailing: CGFloat = -20
            static let height: CGFloat = 20
            static let width: CGFloat = 50
            static let valueWidth: CGFloat = 150
            static let valueHeight: CGFloat = 30
            static let chevronWidth: CGFloat = 12
            static let chevronHeight: CGFloat = 8
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
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var logoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var tokenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var actionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var transactionView: UIView = {
        let view = UIView()
        view.alpha = 0.6
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        view.layer.cornerRadius = UX.NetworkView.corner
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(networkViewTapped))
        view.addGestureRecognizer(tapRecognizer)
        return view
    }()
    private lazy var detailsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        view.layer.cornerRadius = UX.DetailsView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var backBtnView: GradientView = {
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
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_down_chevron")
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
    private lazy var addTokenTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "SEND TOKEN"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var transactiontitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Transaction Details"
        label.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(networkViewTapped))
        label.addGestureRecognizer(tapRecognizer)
        return label
    }()
    private lazy var tokenNetworkValueLabel : UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        label.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(networkViewTapped))
        label.addGestureRecognizer(tapRecognizer)
        return label
    }()
    private lazy var tokenInfoLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.tokenFont)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var tokenTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.font2)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var tokenNetworkLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#818181")
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.font1)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var tokenLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var shareImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_share")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(shareBtnTapped))
        imageView.addGestureRecognizer(tapRecognizer)
        return imageView
    }()
    ///UIButton
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
    private lazy var backButton : UIButton = {
        let button = UIButton()
        button.setTitle("GO BACK", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.backBtnTapped), for: .touchUpInside)
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
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        tableView.separatorColor = Utilities().hexStringToUIColor(hex: "#373737")
        tableView.showsVerticalScrollIndicator = false
        tableView.tintColor = Utilities().hexStringToUIColor(hex: "#FF2D08")
        tableView.register(ConfirmationDetailsTVCell.self, forCellReuseIdentifier:"ConfirmationDetailsTVCell")
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
    var themeManager: ThemeManager?
    var details : SendDetails?
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
        setUpUI()
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        navigationController?.isNavigationBarHidden = true
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        tokenView.addSubview(tokenLogoImageView)
        tokenView.addSubview(shareImageView)
        tokenView.addSubview(tokenTitleLabel)
        tokenView.addSubview(tokenNetworkLabel)
        contentView.addSubview(tokenView)
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(infoIcon)
        actionsView.addSubview(addTokenTitleLabel)
        contentView.addSubview(actionsView)
        contentView.addSubview(tokenInfoLabel)
        transactionView.addSubview(transactiontitleLabel)
        transactionView.addSubview(tokenNetworkValueLabel)
        transactionView.addSubview(chevronImageView)
        contentView.addSubview(transactionView)
        detailsView.addSubview(tableView)
        contentView.addSubview(detailsView)
        contentView.addSubview(backBtnView)
        contentView.addSubview(backButton)
        scrollContentView.addSubview(contentView)
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
            contentView.heightAnchor.constraint(equalToConstant: view.frame.height - 50),
            contentView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            ///User Token List View
            detailsView.topAnchor.constraint(equalTo: tokenView.bottomAnchor ,constant: UX.DetailsView.top),
            detailsView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.DetailsView.common),
            detailsView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.DetailsView.common),
            detailsView.heightAnchor.constraint(equalToConstant: UX.DetailsView.height),
            
            ///Token View
            tokenView.topAnchor.constraint(equalTo: actionsView.bottomAnchor),
            tokenView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tokenView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            tokenView.heightAnchor.constraint(equalToConstant: UX.TokenView.height),
            
            tokenLogoImageView.centerYAnchor.constraint(equalTo: tokenView.centerYAnchor),
            tokenLogoImageView.leadingAnchor.constraint(equalTo: tokenView.leadingAnchor,constant: UX.TokenView.common),
            tokenLogoImageView.widthAnchor.constraint(equalToConstant: UX.TokenView.logoWidth),
            tokenLogoImageView.heightAnchor.constraint(equalToConstant: UX.TokenView.logoHeight),
            
            tokenTitleLabel.topAnchor.constraint(equalTo: tokenView.topAnchor,constant:UX.TokenView.common),
            tokenTitleLabel.leadingAnchor.constraint(equalTo: tokenLogoImageView.trailingAnchor,constant: UX.TokenView.common),
            
            tokenNetworkLabel.topAnchor.constraint(equalTo: tokenTitleLabel.bottomAnchor,constant: UX.TokenView.top),
            tokenNetworkLabel.leadingAnchor.constraint(equalTo: tokenLogoImageView.trailingAnchor,constant: UX.TokenView.common),
            
            shareImageView.centerYAnchor.constraint(equalTo: tokenView.centerYAnchor),
            shareImageView.trailingAnchor.constraint(equalTo: tokenView.trailingAnchor,constant: -UX.TokenView.common),
            shareImageView.widthAnchor.constraint(equalToConstant: UX.TokenView.shareWidth),
            shareImageView.heightAnchor.constraint(equalToConstant: UX.TokenView.shareHeight),
            
            ///Action View
            actionsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            ///Token info Label
            tokenInfoLabel.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant: UX.TableView.tokenInfoTop),
            tokenInfoLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            
            ///Network View
            transactionView.topAnchor.constraint(equalTo: detailsView.bottomAnchor,constant:  UX.NetworkView.netWorkTop),
            transactionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.NetworkView.leading),
            transactionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -UX.NetworkView.leading),
            transactionView.heightAnchor.constraint(equalToConstant: UX.NetworkView.height),
            
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
            addTokenTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            addTokenTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor,constant: UX.BalanceLabel.topValue),
            
            transactiontitleLabel.centerYAnchor.constraint(equalTo: transactionView.centerYAnchor),
            transactiontitleLabel.leadingAnchor.constraint(equalTo: transactionView.leadingAnchor,constant: UX.Title.leading),
            transactiontitleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            chevronImageView.centerYAnchor.constraint(equalTo: transactionView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: transactionView.trailingAnchor,constant: UX.Value.trailing),
            
            
            tokenNetworkValueLabel.centerYAnchor.constraint(equalTo: transactionView.centerYAnchor),
            tokenNetworkValueLabel.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            tokenNetworkValueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
            
            ///UserTokenView TableView
            tableView.topAnchor.constraint(equalTo: detailsView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor,constant: -UX.TableView.common),
            tableView.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor),
            
            ///Add token button view
            backBtnView.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -UX.ButtonView.addTop),
            backBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.width),
            backBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            backBtnView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            backBtnView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
            
            ///Add token button
            backButton.topAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -UX.ButtonView.addTop),
            backButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            backButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            backButton.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            backButton.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
        ])
    }
    
    func setUpUI(){
        self.tokenTitleLabel.text = "\(self.details?.amount ?? "") \(self.details?.symbol ?? "")"
        self.tokenNetworkLabel.text = "\(self.details?.network ?? "")"
        if let imageUrl = URL(string: self.details?.logo ?? "" ) {
            tokenLogoImageView.sd_setImage(with: imageUrl)
        }else{
            let symbol =  self.details?.symbol ?? ""
            var defaultImage = ""
            switch symbol {
            case "BNB","TBNB" :
                defaultImage = "ic_binance"
            case "ETH","GETH", "SETH":
                defaultImage = "ic_eth"
            case "SOL":
                defaultImage = "ic_sol"
            case "CSIX":
                defaultImage = "ic_carbon_pro"
            case "MATIC":
                defaultImage = "ic_matic"
            case "KCS":
                defaultImage = "ic_kcc"
            case "OKT":
                defaultImage = "ic_okc"
            default: break
            }
            tokenLogoImageView.image = UIImage(named: defaultImage)
        }
    }
    
    
    // MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func settingsIconTapped (){
        initiateDrawerVC()
    }
    
    @objc func networkViewTapped() {
        
    }
    
    @objc func infoIconTapped (){
        showToast(message: "Stay tunned! Dev in progress...")
    }
    @objc func backBtnTapped (){
        self.dismiss(animated: true)
    }
    @objc func shareBtnTapped (){
        let shareText = "Hey, I have sent \(self.details?.amount ?? "") \(self.details?.symbol ?? "") to this address \(self.details?.address ?? "")"
        let textToShare = [ shareText ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - Helper Methods - Initiate view controller
    
    func initiateDrawerVC(){
        //        let drawerController = DrawerMenuViewController()
        //        drawerController.delegate = self
        //        self.present(drawerController, animated: true)
    }
    
    func initiateChangeNetworkVC(){
        //        let changeNetworkVC = ChangeNetworkViewController()
        //        changeNetworkVC.modalPresentationStyle = .overCurrentContext
        //        changeNetworkVC.platforms = self.platforms
        //        changeNetworkVC.delegate = self
        //        self.present(changeNetworkVC, animated: true)
    }
    
    func showToast(message: String){
        //        SimpleToast().showAlertWithText(message,
        //                                        bottomContainer: self.view,
        //                                        theme: themeManager!.currentTheme)
    }
}

// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension SendConfirmationViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfirmationDetailsTVCell", for: indexPath) as! ConfirmationDetailsTVCell
        cell.setUI( index: indexPath.row,details: self.details!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  50
    }
}

class ConfirmationDetailsTVCell: UITableViewCell {
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
            static let font: CGFloat = 14
            static let top: CGFloat = 20
            static let leading: CGFloat = 20
            static let height: CGFloat = 30
        }
        struct Value {
            static let font: CGFloat = 15
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 10
            static let topAt: CGFloat = 0
            static let trailing: CGFloat = -10
            static let height: CGFloat = 20
            static let width: CGFloat = 50
            static let valueHeight: CGFloat = 60
        }
    }
    
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
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    private lazy var valueSubLabel : UILabel = {
        let label = UILabel()
        label.textColor =   Utilities().hexStringToUIColor(hex: "#6D6D6D")
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var completedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_completed")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(completedImageView)
        contentView.addSubview(valueSubLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            valueLabel.widthAnchor.constraint(lessThanOrEqualToConstant: contentView.frame.width/2),
            valueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
            
            completedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            completedImageView.trailingAnchor.constraint(equalTo: valueLabel.leadingAnchor,constant: UX.Value.trailing),
            completedImageView.widthAnchor.constraint(equalToConstant: 17),
            completedImageView.heightAnchor.constraint(equalToConstant: 17),
            
            valueSubLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueSubLabel.trailingAnchor.constraint(equalTo: completedImageView.leadingAnchor),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(index: Int, details: SendDetails){
        switch index{
        case 0:
            self.titleLabel.text = "Date:"
            self.valueLabel.text = details.date
            self.completedImageView.isHidden = true
        case 1:
            self.titleLabel.text = "Status:"
            self.valueLabel.text = details.status
            self.completedImageView.isHidden = false
        case 2:
            self.titleLabel.text = "Sent to:"
            self.valueLabel.text = details.address
            self.completedImageView.isHidden = true
        default:
            self.titleLabel.text = "Gas:"
            self.valueLabel.text = details.gas
            self.completedImageView.isHidden = true
            self.valueSubLabel.text = ""
        }
    }
}
