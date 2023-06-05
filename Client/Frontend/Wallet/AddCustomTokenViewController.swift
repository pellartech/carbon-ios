//
//  AddCustomTokenViewController.swift
//  Client
//
//  Created by Ashok on 29/05/23.
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

class AddCustomTokenViewController: UIViewController {
    
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
            static let font1: CGFloat = 12

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
            static let top: CGFloat = 40
            static let height: CGFloat = 155
        }
        struct ScamAlertView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 10
            static let top: CGFloat = 20
            static let top2: CGFloat = 15
            static let height: CGFloat = 110
            static let icWidth: CGFloat = 22
            static let icheight: CGFloat = 19
            static let heightConstant: CGFloat = 50
            static let widthConstant: CGFloat = 180
            static let top1: CGFloat = 40
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
            static let common: CGFloat = 15
            static let leading: CGFloat = 10
            static let top: CGFloat = 35
            static let trailing: CGFloat = -10
            static let bottom: CGFloat = -30
        }
        struct WalletLabel {
            static let font: CGFloat = 18
        }
        struct UserTokenView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 0
            static let top: CGFloat = 30
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
    private lazy var searchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        view.layer.cornerRadius = UX.SearchView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var actionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var networkView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        view.layer.cornerRadius = UX.NetworkView.corner
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var scamAlertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#351B1B")
        view.layer.cornerRadius = UX.NetworkView.corner
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var userTokensView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = UX.UserTokenView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
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
    private lazy var alertImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_scam_alert")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_chevron")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var searchButton: UIButton = {
        let searchButton = UIButton()
        searchButton.clipsToBounds = false
        searchButton.tintColor = UIColor.Photon.Grey50
        searchButton.contentHorizontalAlignment = .center
        searchButton.setImage(UIImage(named: "search"), for: .normal)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.isUserInteractionEnabled = false
        return searchButton
    }()
    
    ///UITextField
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder =
        NSAttributedString(
            string: "Search by token name",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray,NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: UX.SearchView.font)]
        )
        textField.backgroundColor = .clear
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = true
        textField.delegate = self
        return textField
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
        label.text = "ADD CUSTOM TOKEN"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.NetworkView.font)
        label.textAlignment = .center
        label.text = "DETAILS:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tokenNetworktitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Token Network"
        return label
    }()
    private lazy var tokenNetworkValueLabel : UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.text = "BCD80"
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var scamTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "SCAM ALERT"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var scamDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.font1)
        label.textAlignment = .left
        label.text = "Make sure that token address that you provide is right, because a lot of projects posted on internet can be a scam projects. Check it before adding to your wallet."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 10
        return label
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
    private lazy var addTokenButton : UIButton = {
        let button = UIButton()
        button.setTitle("ADD NEW TOKEN", for: .normal)
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
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TokenDetailsTVCell.self, forCellReuseIdentifier:"TokenDetailsTVCell")
        return tableView
    }()
    private lazy var tokensTableView: UITableView = {
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
        tableView.register(AddTokensTVCell.self, forCellReuseIdentifier:"AddTokensTVCell")
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
    let bag = DisposeBag()
    var publicAddress = String()
    var networkData = [String]()
    var themeManager :  ThemeManager?
    var tokenDetails = TokensDetails(network: "BBC30", name: "USDC", address: "JFSDHJFXFBDKNSLCXNCZXZSADVCC", symbol: "USDC", notes: "JDSVHBBDNKL;SCXK JBHJBNKLC")
    var tokens = [TokenList]()
    
// MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
        fetchTokens()

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
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(infoIcon)
        actionsView.addSubview(addTokenTitleLabel)
        contentView.addSubview(actionsView)
        searchView.addSubview(searchButton)
        searchView.addSubview(searchTextField)
        contentView.addSubview(searchView)
        contentView.addSubview(detailsLabel)
        networkView.addSubview(tokenNetworktitleLabel)
        networkView.addSubview(tokenNetworkValueLabel)
        networkView.addSubview(chevronImageView)
        contentView.addSubview(networkView)
        detailsView.addSubview(tableView)
        scamAlertView.addSubview(alertImageView)
        scamAlertView.addSubview(scamTitleLabel)
        scamAlertView.addSubview(scamDescriptionLabel)
        userTokensView.addSubview(tokensTableView)
        scrollContentView.addSubview(contentView)
        scrollContentView.addSubview(detailsView)
        scrollContentView.addSubview(addTokenBtnView)
        scrollContentView.addSubview(addTokenButton)
        scrollContentView.addSubview(scamAlertView)
        scrollContentView.addSubview(userTokensView)        
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
            
            ///User Token List View
            detailsView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.DetailsView.top),
            detailsView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.DetailsView.common),
            detailsView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.DetailsView.common),
            detailsView.heightAnchor.constraint(equalToConstant: UX.DetailsView.height),

            ///Action View
            actionsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            ///Search View
            searchView.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant:  UX.SearchView.top),
            searchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.SearchView.leading),
            searchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -UX.SearchView.leading),
            searchView.heightAnchor.constraint(equalToConstant: UX.SearchView.height),
            
            ///Search button
            searchButton.topAnchor.constraint(equalTo: searchView.topAnchor,constant: UX.SearchView.constant),
            searchButton.leadingAnchor.constraint(equalTo: searchView.leadingAnchor,constant: UX.SearchView.leading),
            searchButton.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: UX.SearchView.button),
            searchButton.heightAnchor.constraint(equalToConstant: UX.SearchView.button),
            
            ///Search textField
            searchTextField.topAnchor.constraint(equalTo: searchView.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchButton.trailingAnchor,constant: UX.SearchView.constant),
            searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchView.bottomAnchor),
            
            ///Details Label
            detailsLabel.topAnchor.constraint(equalTo: searchView.bottomAnchor,constant:  UX.NetworkView.top),
            detailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.NetworkView.leading),
            detailsLabel.heightAnchor.constraint(equalToConstant: UX.NetworkView.detailHeight),
            
            ///Network View
            networkView.topAnchor.constraint(equalTo: detailsLabel.bottomAnchor,constant:  UX.NetworkView.netWorkTop),
            networkView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.NetworkView.leading),
            networkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -UX.NetworkView.leading),
            networkView.heightAnchor.constraint(equalToConstant: UX.NetworkView.height),

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
            
            tokenNetworktitleLabel.centerYAnchor.constraint(equalTo: networkView.centerYAnchor),
            tokenNetworktitleLabel.leadingAnchor.constraint(equalTo: networkView.leadingAnchor,constant: UX.Title.leading),
            tokenNetworktitleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            chevronImageView.centerYAnchor.constraint(equalTo: networkView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: networkView.trailingAnchor,constant: UX.Value.trailing),

            
            tokenNetworkValueLabel.centerYAnchor.constraint(equalTo: networkView.centerYAnchor),
            tokenNetworkValueLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor,constant: UX.Value.trailing),
            tokenNetworkValueLabel.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            tokenNetworkValueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
                        
            ///UserTokenView TableView
            tableView.topAnchor.constraint(equalTo: detailsView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor,constant: -UX.TableView.common),
            tableView.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor),

            ///Add token button view
            addTokenBtnView.topAnchor.constraint(equalTo: detailsView.bottomAnchor,constant:UX.ButtonView.addTop),
            addTokenBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.width),
            addTokenBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            addTokenBtnView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            addTokenBtnView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
          
            ///Add token button
            addTokenButton.topAnchor.constraint(equalTo: detailsView.bottomAnchor,constant: UX.ButtonView.addTop),
            addTokenButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            addTokenButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            addTokenButton.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            addTokenButton.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
            
            //Scam Alert View
            scamAlertView.topAnchor.constraint(equalTo: addTokenBtnView.bottomAnchor ,constant: UX.ScamAlertView.top),
            scamAlertView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.ScamAlertView.common),
            scamAlertView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.ScamAlertView.common),
            scamAlertView.heightAnchor.constraint(equalToConstant: UX.ScamAlertView.height),
//            scamAlertView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),

            alertImageView.topAnchor.constraint(equalTo: scamAlertView.topAnchor,constant: UX.ScamAlertView.top2),
            alertImageView.leadingAnchor.constraint(equalTo: scamAlertView.leadingAnchor,constant: UX.ScamAlertView.top2),
            alertImageView.widthAnchor.constraint(equalToConstant: UX.ScamAlertView.icWidth),
            alertImageView.heightAnchor.constraint(equalToConstant: UX.ScamAlertView.icheight),
            
            scamTitleLabel.topAnchor.constraint(equalTo: scamAlertView.topAnchor,constant: UX.ScamAlertView.top2),
            scamTitleLabel.leadingAnchor.constraint(equalTo: alertImageView.trailingAnchor,constant: UX.ScamAlertView.common),
            
            scamDescriptionLabel.topAnchor.constraint(equalTo: scamAlertView.topAnchor,constant: UX.ScamAlertView.top1),
            scamDescriptionLabel.leadingAnchor.constraint(equalTo: scamAlertView.leadingAnchor,constant: UX.ScamAlertView.top2),
            scamDescriptionLabel.trailingAnchor.constraint(equalTo: scamAlertView.trailingAnchor,constant: -UX.ScamAlertView.top2),
            scamDescriptionLabel.heightAnchor.constraint(equalToConstant: UX.ScamAlertView.heightConstant),
            scamDescriptionLabel.widthAnchor.constraint(equalToConstant: view.frame.width - UX.ScamAlertView.widthConstant),
            
            userTokensView.topAnchor.constraint(equalTo: scamAlertView.bottomAnchor ,constant: UX.UserTokenView.top),
            userTokensView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            userTokensView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            userTokensView.heightAnchor.constraint(equalToConstant: 300),
            userTokensView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            tokensTableView.topAnchor.constraint(equalTo: userTokensView.topAnchor,constant: UX.TableView.top),
            tokensTableView.leadingAnchor.constraint(equalTo: userTokensView.leadingAnchor,constant: UX.TableView.leading),
            tokensTableView.trailingAnchor.constraint(equalTo: userTokensView.trailingAnchor,constant: UX.TableView.trailing),
            tokensTableView.bottomAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant: UX.TableView.trailing),
            tokensTableView.heightAnchor.constraint(equalToConstant:300),

        ])
    }
        
    func fetchTokens() {
        SVProgressHUD.show()
    WalletViewModel.shared.getTokenList{result in
            switch result {
            case .success(let tokens):
                SVProgressHUD.dismiss()
                if (tokens.count > 0){
                    self.showToast(message: "Added")
                }else{
                    self.showToast(message: "Something went wrong! Please try again")
                }
            case .failure(let error):
                SVProgressHUD.dismiss()
                print(error)
                self.showToast(message: "Error occurred! Please try again after sometimes")
            }
        }
    }
    
// MARK: - View Model Methods - Network actions
    func addToken(tokens : [String]){
        SVProgressHUD.show()
        WalletViewModel.shared.addTokenToUserAccount(address: publicAddress,tokens: tokens) {result in
            switch result {
            case .success(let tokens):
                SVProgressHUD.dismiss()
                userTokens = tokens
                if (tokens.count > 0){
                    self.showToast(message: "Added")
                }else{
                    self.showToast(message: "Something went wrong! Please try again")
                }
                self.tokensTableView.reloadData()
            case .failure(let error):
                SVProgressHUD.dismiss()
                print(error)
                self.showToast(message: "Error occurred! Please try again after sometimes")
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
        showToast(message: "Coming soon...")
    }
    @objc func addTokenBtnTapped (){
        showToast(message: "Coming soon...")
    }
    
    
// MARK: - Helper Methods - Initiate view controller
   
    func initiateDrawerVC(){
        let drawerController = DrawerMenuViewController()
        drawerController.delegate = self
        self.present(drawerController, animated: true)
    }

    func showToast(message: String){
        SimpleToast().showAlertWithText(message,
                                        bottomContainer: self.view,
                                        theme: themeManager!.currentTheme)
    }
}
extension AddCustomTokenViewController: UITextFieldDelegate{

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let searchText  = textField.text! + string
        if searchText.count >= 3 {
            tableView.isHidden = false
//            searchResult = tokens.filter({(($0.address!).localizedCaseInsensitiveContains(searchText))})
            tableView.reloadData()
        }
        else{
//            searchResult = []
        }
        return true
    }
}

// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension AddCustomTokenViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tableView == self.tokensTableView ? self.tokens.count : tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tokensTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddTokensTVCell", for: indexPath) as! AddTokensTVCell
            cell.setUITokens(token: tokens[indexPath.row])
            cell.selectionStyle = .none
            cell.delegate = self
            cell.switchButton.tag = indexPath.row
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokenDetailsTVCell", for: indexPath) as! TokenDetailsTVCell
            cell.setUI(token: self.tokenDetails, index: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == self.tokensTableView ? 70 : 45
    }
}

// MARK: - Extension - ConnectProtocol
extension AddCustomTokenViewController : ConnectProtocol{
    func accountPublicAddress(address: String) {

    }
    func logout() {
        self.dismiss(animated: true)
    }
}

extension AddCustomTokenViewController: AddTokenDelegate{
    func initiateAddToken() {
     
    }
}


class TokenDetailsTVCell: UITableViewCell {
    
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
            static let valueWidth: CGFloat = 150
            static let valueHeight: CGFloat = 30
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
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var valueGradiantLabel : GradientLabel = {
        let label = GradientLabel()
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    //    private var wallpaperManager =  WallpaperManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(valueGradiantLabel)

        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            ///UILabel
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            valueLabel.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            valueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),

            valueGradiantLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueGradiantLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            valueGradiantLabel.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            valueGradiantLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
        ]
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(token : TokensDetails,index: Int){
        switch index{
        case 0:
            self.titleLabel.text = "Address:"
            self.valueGradiantLabel.text = token.address
            self.valueLabel.text = ""
        case 1:
            self.titleLabel.text = "Token Name:"
            self.valueLabel.text = token.name
            self.valueGradiantLabel.text = ""
        default:
            self.titleLabel.text = "Notes:"
            self.valueLabel.text = token.notes
            self.valueGradiantLabel.text = ""
        }
        
    }
    
}
