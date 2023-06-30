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
        struct BalanceLabel{
            static let topValueCarbon: CGFloat = 10
            static let topValue: CGFloat = 0
            static let font: CGFloat = 45
            static let carbonFont: CGFloat = 12
            static let titleFont: CGFloat = 16
            static let top: CGFloat = 30
            static let width: CGFloat = 300
            static let font1: CGFloat = 12
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
            static let height: CGFloat = 155
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
            static let top: CGFloat = 15
            static let trailing: CGFloat = -10
            static let bottom: CGFloat = -30
            static let height: CGFloat = 120
            static let tokenInfoTop: CGFloat = 10
            
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
        textField.autocorrectionType = .no
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
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.tintColor = Utilities().hexStringToUIColor(hex: "#FF2D08")
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
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(CustomTokensTVCell.self, forCellReuseIdentifier:"CustomTokensTVCell")
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
    var networkData = [String]()
    var themeManager :  ThemeManager?
    var tokenInfo : TokensInfo?
    var selectedIndexes = IndexPath()
    var searchTokenList = [Tokens]()
    var platforms = [Platforms]()
    var heightForTokenViewNoToken =  NSLayoutConstraint()
    var heightForTokenView =  NSLayoutConstraint()
    var trailingForNoChevron =  NSLayoutConstraint()
    var trailingForChevron =  NSLayoutConstraint()
    var delegate : ConnectProtocol?
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
        fetchDefaultNetwork()
        checkCoreDataValue()
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        navigationController?.isNavigationBarHidden = true
        heightForTokenViewNoToken = tokensTableView.heightAnchor.constraint(equalToConstant: 0)
        heightForTokenView = tokensTableView.heightAnchor.constraint(equalToConstant: 120)
        trailingForNoChevron = tokenNetworkValueLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: 0)
        trailingForChevron = tokenNetworkValueLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -20)
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
        contentView.addSubview(tokensTableView)
        contentView.addSubview(tokenInfoLabel)
        contentView.addSubview(detailsLabel)
        networkView.addSubview(tokenNetworktitleLabel)
        networkView.addSubview(tokenNetworkValueLabel)
        networkView.addSubview(chevronImageView)
        contentView.addSubview(networkView)
        detailsView.addSubview(tableView)
        contentView.addSubview(detailsView)
        contentView.addSubview(addTokenBtnView)
        contentView.addSubview(addTokenButton)
        scrollContentView.addSubview(contentView)
        scrollView.addSubview(scrollContentView)
        view.addSubview(scrollView)
        view.addSubview(logoBackgroundView)
        view.addSubview(closeButton)
    }
    
    func setUpViewContraint(){
        heightForTokenViewNoToken.isActive = true
        trailingForNoChevron.isActive = true
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
            contentView.heightAnchor.constraint(equalToConstant: view.frame.height - 100),
            contentView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            ///User Token List View
            detailsView.topAnchor.constraint(equalTo: networkView.bottomAnchor ,constant: UX.DetailsView.top),
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
            
            ///Token Tableview
            tokensTableView.topAnchor.constraint(equalTo: searchView.bottomAnchor,constant: UX.TableView.top),
            tokensTableView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.TableView.leading),
            tokensTableView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: UX.TableView.trailing),
            
            ///Token info Label
            tokenInfoLabel.topAnchor.constraint(equalTo: tokensTableView.bottomAnchor,constant: UX.TableView.tokenInfoTop),
            tokenInfoLabel.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor),
            
            ///Details Label
            detailsLabel.topAnchor.constraint(equalTo: tokensTableView.bottomAnchor,constant:  UX.NetworkView.top),
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
        ])
        
    }
    // MARK: - View Helper Methods - Check coredata stored values
    func checkCoreDataValue() {
        tokens = CoreDataManager.shared.fetchTokens(network:selectedNetwork)
        tokens = tokens.filter{$0.isAdded == false}
        self.tokensTableView.reloadData()
    }
    
    // MARK: - View Model Methods - Network actions
    func addToken(tokenArray : [String]){
        WalletViewModel.shared.addTokenToUserAccount(address: publicAddress,tokens: tokenArray) {result in
            switch result {
            case .success(let result):
                print(result)
                guard let index = tokens.firstIndex(where: {$0.name == self.tokenInfo?.name}) else {return}
                tokens[index].isAdded = true
                tokens[index].address = self.tokenInfo?.contract_address
                tokens[index].imageUrl = self.tokenInfo?.image?.large
                CoreDataManager.shared.save()
                SVProgressHUD.dismiss()
                self.delegate?.accountPublicAddress(address: "")
                self.dismissVC()
            case .failure(let error):
                SVProgressHUD.dismiss()
                print(error)
                self.showToast(message: error.localizedDescription)
            }
        }
    }
    
    func fetchDefaultNetwork(){
        let networkData =  CoreDataManager.shared.fetchNetworks()
        selectedNetwork = networkData.filter{$0.nativeSymbol ==  ParticleNetwork.getChainInfo().nativeSymbol}.first ?? networkData[0]
    }
    
    func fetchTokenInfo(token : Tokens){
        SVProgressHUD.show()
        WalletViewModel.shared.getTokenDetails(tokenID: token.id ?? "") {result in
            switch result {
            case .success(let token):
                SVProgressHUD.dismiss()
                self.platforms = []
                self.tokenInfo = token
                DispatchQueue.global().async {
                    DispatchQueue.main.async {
                        self.setUpData()
                    }
                }
            case .failure(let error):
                SVProgressHUD.dismiss()
                print(error)
            }
        }
    }
    
    func setUpData(){
        for (key, value) in self.tokenInfo?.platforms ?? ["": ""] {
            self.platforms.append(Platforms(name: key, address: value, chainID: 0, isTest: false, nativeSymbol: "",isSelected: false))
        }
        self.platforms =  self.platforms.filter {
        $0.name?.uppercased() == NetworkEnum.Ethereum.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.BinanceSmartChain.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.EthereumGoerliTest.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.EthereumSepoliaTest.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.BinanceSmartChainTest.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.KucoinCommunityChain.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.OkexChain.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.Polygon.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.PolygonTest.rawValue.uppercased() ||
        $0.name?.uppercased() == NetworkEnum.Solana.rawValue.uppercased()
        }
        if (self.platforms.count > 1 ){
            self.chevronImageView.isHidden = false
            self.trailingForChevron.isActive = true
            self.trailingForNoChevron.isActive = false
        }else{
            self.chevronImageView.isHidden = true
            self.trailingForChevron.isActive = false
            self.trailingForNoChevron.isActive = true
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.tokenNetworkValueLabel.text = self.platforms.first?.name?.capitalized
        self.tableView.reloadData()
    }
    
    
    // MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func settingsIconTapped (){
        initiateDrawerVC()
    }
    
    @objc func networkViewTapped() {
        if self.platforms.count > 1{
            initiateChangeNetworkVC()
        }
    }
    
    @objc func infoIconTapped (){
        showToast(message: "Stay tunned! Dev in progress...")
    }
    @objc func addTokenBtnTapped (){
        if ( self.tokenNetworkValueLabel.text  == selectedNetwork.name?.capitalized){
            SVProgressHUD.show()
                let contractAddress = self.tokenInfo?.contract_address ?? ""
                self.addToken(tokenArray: [contractAddress])
        }else{
            self.view.makeToast("Sorry! Unable to add. Please select different token or network", duration: 3.0, position: .bottom)
        }
    }
    
    
    // MARK: - Helper Methods - Initiate view controller
    
    func initiateDrawerVC(){
        let drawerController = DrawerMenuViewController()
        drawerController.delegate = self
        self.present(drawerController, animated: true)
    }
    
    func initiateChangeNetworkVC(){
        let changeNetworkVC = ChangeNetworkViewController()
        changeNetworkVC.modalPresentationStyle = .overCurrentContext
        changeNetworkVC.platforms = self.platforms
        changeNetworkVC.delegate = self
        self.present(changeNetworkVC, animated: true)
    }
    
    func showToast(message: String){
        SimpleToast().showAlertWithText(message,
                                        bottomContainer: self.view,
                                        theme: themeManager!.currentTheme)
    }
}
// MARK: - Extension - UITextFieldDelegate
extension AddCustomTokenViewController: UITextFieldDelegate{
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        var searchText  = textField.text! + string
        if searchText.count >= 3 {
            self.emptyList()
            searchText = String(searchText.dropLast(range.length))
            for each in  tokens{
                if (each.name?.hasPrefix(searchText) ?? false){
                    self.searchTokenList.append(each)
                }
            }
            self.filteredList()
        }else{
            self.emptyList()
        }
        return true
    }
    
    func filteredList(){
        if self.searchTokenList.count > 0{
            self.tokenInfoLabel.text =  self.searchTokenList.count > 4 ? "\(self.searchTokenList.count) results. Scroll to see more" :  self.searchTokenList.count == 0 ? "0 result" :"\(self.searchTokenList.count) results"
            self.expandTableView()
            self.tokensTableView.reloadData()
        }else{
            self.emptyList()
        }
    }
    
    func emptyList(){
        self.selectedIndexes = IndexPath()
        self.tokenInfoLabel.text = "0 result"
        self.searchTokenList = []
        self.tokensTableView.reloadData()
        self.collapseTableView()
    }
    
    func expandTableView(){
        heightForTokenViewNoToken.isActive = false
        heightForTokenView.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func collapseTableView(){
        heightForTokenView.isActive = false
        heightForTokenViewNoToken.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension AddCustomTokenViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tableView == self.tokensTableView  ? self.searchTokenList.count : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.tokensTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTokensTVCell", for: indexPath) as! CustomTokensTVCell
            cell.setUI(token: self.searchTokenList[indexPath.row])
            cell.selectionStyle = .none
            cell.tintColor = Utilities().hexStringToUIColor(hex: "#FF2D08")
            if (self.selectedIndexes == indexPath) {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TokenDetailsTVCell", for: indexPath) as! TokenDetailsTVCell
            cell.setUI(token: self.tokenInfo , index: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == self.tokensTableView ? 30 : 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.tokensTableView){
            self.view.endEditing(true)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = .checkmark
            self.selectedIndexes = indexPath
            tableView.reloadData()
            self.fetchTokenInfo(token: self.searchTokenList[indexPath.row])
        }
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
// MARK: - Extension - AddTokenDelegate
extension AddCustomTokenViewController: AddTokenDelegate{
    func initiateAddToken() {
        
    }
}
// MARK: - Extension - ChangeNetwork
extension AddCustomTokenViewController :  ChangeNetwork{
    func changeNetworkDelegate(platforms: Platforms) {
        guard let detailPlatforms = self.tokenInfo?.detail_platforms else {return}
        for (platform, value) in detailPlatforms {
            if (platform == platforms.name){
                self.tokenNetworkValueLabel.text = platform.capitalized
                self.tokenInfo?.contract_address = value.contract_address
                self.tokenInfo?.network = platform
                self.tableView.reloadData()
            }
        }
    }
    
}

class TokenDetailsTVCell: UITableViewCell {
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
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var valueGradiantLabel : GradientLabel = {
        let label = GradientLabel()
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
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
            valueLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width/2),
            valueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
            
            valueGradiantLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            valueGradiantLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            valueGradiantLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width/2),
            valueGradiantLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
        ]
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(token : TokensInfo?,index: Int){
        switch index{
        case 0:
            self.titleLabel.text = "Address:"
            self.valueGradiantLabel.text = token?.contract_address ?? ""
            self.valueLabel.text = ""
        case 1:
            self.titleLabel.text = "Token Name:"
            self.valueLabel.text = token?.name ?? ""
            self.valueGradiantLabel.text = ""
        default:
            self.titleLabel.text = "Notes:"
            self.valueLabel.text = token?.description?.en ?? ""
            self.valueGradiantLabel.text = ""
        }
        
    }
    
}
class CustomTokensTVCell: UITableViewCell {
    
    private struct UX {
        struct Title {
            static let font: CGFloat = 14
            static let leading: CGFloat = 30
            static let height: CGFloat = 30
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            ///UILabel
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
        ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUI(token : Tokens){
        titleLabel.text = "\(token.name ?? "") (\(token.symbol?.uppercased() ?? ""))"
    }
}
