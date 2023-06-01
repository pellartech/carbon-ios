//
//  AddTokenViewController.swift
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

var tokens: [Tokens] = []
var userTokens  = [TokenModel]()

protocol AddTokenDelegate{
    func initiateAddToken()
}

class AddTokenViewController: UIViewController {
    
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
            static let heightBackGround: CGFloat = 70
        }
        struct SearchView {
            static let height: CGFloat = 50
            static let cornerRadius: CGFloat = 10
            static let font: CGFloat = 14

        }
        struct ActionView {
            static let heightActionBg: CGFloat = 25
            static let topActionBg: CGFloat = 10
        }
        struct UserTokenView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 0
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
    private lazy var userTokensView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = UX.UserTokenView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
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
    private lazy var addTokenIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_add_token")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.addTokenTapped))
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
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
            string: "Search token name",
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
        label.text = "ADD NEW TOKEN"
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
    var shownFromAppMenu: Bool = false
    private var data: [ConnectWalletModel] = []
    let bag = DisposeBag()
    var publicAddress = String()
    var tokensModel = [TokenModel]()
    let viewModel = WalletViewModel()
    var networkData = [String]()
    var themeManager :  ThemeManager?
    var isFiltered = false
    var searchResult = [Tokens]()
    var searchText = [Tokens]()

// MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpNetwork()
        setUpViewContraint()
        checkAddedToken()
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
        
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(addTokenIcon)
        actionsView.addSubview(addTokenTitleLabel)
        contentView.addSubview(actionsView)
        searchView.addSubview(searchButton)
        searchView.addSubview(searchTextField)
        contentView.addSubview(searchView)
        userTokensView.addSubview(tableView)
        scrollContentView.addSubview(contentView)
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
            userTokensView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.UserTokenView.top),
            userTokensView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            userTokensView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            userTokensView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),

            ///Action View
            actionsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            ///Search View
            searchView.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant: 30),
            searchView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 10),
            searchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            searchView.heightAnchor.constraint(equalToConstant: UX.SearchView.height),
            
            ///Search button
            searchButton.topAnchor.constraint(equalTo: searchView.topAnchor,constant: 5),
            searchButton.leadingAnchor.constraint(equalTo: searchView.leadingAnchor,constant: 10),
            searchButton.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 24),
            searchButton.heightAnchor.constraint(equalToConstant: 24),
            
            ///Search textField
            searchTextField.topAnchor.constraint(equalTo: searchView.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: searchButton.trailingAnchor,constant: 5),
            searchTextField.trailingAnchor.constraint(equalTo: searchView.trailingAnchor),
            searchTextField.bottomAnchor.constraint(equalTo: searchView.bottomAnchor),

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
            addTokenIcon.trailingAnchor.constraint(equalTo: actionsView.trailingAnchor,constant: UX.ActionIcon.trailing),
            addTokenIcon.topAnchor.constraint(equalTo: actionsView.topAnchor),
            addTokenIcon.widthAnchor.constraint(equalToConstant: UX.ActionIcon.width),
            addTokenIcon.heightAnchor.constraint(equalToConstant: UX.ActionIcon.height),
            
            ///Wallet Label
            walletLabel.leadingAnchor.constraint(equalTo: carbonImageView.trailingAnchor,constant: UX.Wallet.leading),
            walletLabel.topAnchor.constraint(equalTo: logoView.topAnchor,constant:  UX.Wallet.top),
            walletLabel.widthAnchor.constraint(equalToConstant: UX.Wallet.width),
            walletLabel.heightAnchor.constraint(equalToConstant: UX.Wallet.height),
            
            ///Wallet balance title Label
            addTokenTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            addTokenTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor,constant: UX.BalanceLabel.topValue),
            
            ///UserTokenView TableView
            tableView.topAnchor.constraint(equalTo: userTokensView.topAnchor,constant: UX.TableView.top),
            tableView.leadingAnchor.constraint(equalTo: userTokensView.leadingAnchor,constant: UX.TableView.leading),
            tableView.trailingAnchor.constraint(equalTo: userTokensView.trailingAnchor,constant: UX.TableView.trailing),
            tableView.bottomAnchor.constraint(equalTo: userTokensView.bottomAnchor,constant: UX.TableView.trailing),
            tableView.heightAnchor.constraint(equalToConstant: view.frame.height - 200),

        ])
    }
    
    func checkAddedToken(){
        for token in self.tokensModel{
            if let filterToken = tokens.enumerated().first(where: {$0.element.address == token.address}) {
                tokens[filterToken.offset].isAdded = true
            }
        }
        self.tableView.reloadData()
    }
        
// MARK: - View Model Methods - Network actions
    func addToken(tokens : [String]){
        SVProgressHUD.show()
        self.viewModel.addTokenToUserAccount(address: publicAddress,tokens: tokens) {result in
            switch result {
            case .success(let tokens):
                SVProgressHUD.dismiss()
                userTokens = tokens
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
        
// MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func settingsIconTapped (){
        initiateDrawerVC()
    }
    
    @objc func addTokenTapped (){
        showToast(message: "Coming soon...")
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

    func showToast(message: String){
        SimpleToast().showAlertWithText(message,
                                        bottomContainer: self.view,
                                        theme: themeManager!.currentTheme)
    }
}
extension AddTokenViewController: UITextFieldDelegate{

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let searchText  = textField.text! + string
        if searchText.count >= 3 {
            tableView.isHidden = false
            searchResult = tokens.filter({(($0.address!).localizedCaseInsensitiveContains(searchText))})
            tableView.reloadData()
        }
        else{
            searchResult = []
        }
        return true
    }
}

// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension AddTokenViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddTokensTVCell", for: indexPath) as! AddTokensTVCell
        cell.setUI(token: tokens[indexPath.row])
        cell.selectionStyle = .none
        cell.delegate = self
        cell.switchButton.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - Extension - ConnectProtocol
extension AddTokenViewController : ConnectProtocol{
    func accountPublicAddress(address: String) {

    }
    func logout() {
        self.dismiss(animated: true)
    }
}

extension AddTokenViewController: AddTokenDelegate{
    func initiateAddToken() {
        var selectedToken = [String]()
        let tokensArray = tokens.filter{$0.isAdded == true}
        for eachToken in tokensArray{
            selectedToken.append(eachToken.address ?? "")
        }
        self.addToken(tokens: selectedToken)
    }
}

protocol SwitchDelegate{
    func switchTapped(value: Bool,index:Int)
    
}

class AddTokensTVCell: UITableViewCell {
    
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
            static let valueWidth: CGFloat = 50
            static let valueHeight: CGFloat = 30
            static let leading: CGFloat = 20

        }
        struct Switch {
            static let top: CGFloat = 20
            static let trailing: CGFloat = -10
            static let height: CGFloat = 20
            static let width: CGFloat = 41
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
    private lazy var switchView: UIView = {
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
    
    private lazy var symbolLabel : UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#818181")
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.fontAt)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var switchButton : SwitchButton = {
        let switchButton = SwitchButton()
        return switchButton
    }()
    
    var delegate : AddTokenDelegate?
    var tokenAddress = String()
    
    //    private var wallpaperManager =  WallpaperManager()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        switchButton = SwitchButton(frame: CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: 50, height: 30))
        switchButton.delegate = self
        iconView.addSubview(iconImageView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        switchView.addSubview(switchButton)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(switchView)
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

            symbolLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: UX.Value.topAt),
            symbolLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor,constant: UX.Value.leading),
            
            switchView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Value.top),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            switchView.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            switchView.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
        ]

    )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch!)
       {
           if (sender.isOn == true){
               print("UISwitch state is now ON")
           }
           else{
               print("UISwitch state is now Off")
           }
       }
    
    func setUI(token : Tokens){
        self.tokenAddress = token.address ?? ""
        titleLabel.text = "\(token.title!) (\(token.symbol!))"
        symbolLabel.text = token.symbol ?? ""
        iconImageView.image = token.icon!
        switchButton.status = token.isAdded ?? false
    }
    
}

extension AddTokensTVCell : SwitchDelegate{
    func switchTapped(value: Bool,index:Int) {
        tokens[index].isAdded = value
        self.delegate?.initiateAddToken()
    }
}

class SwitchButton: UIButton {

    var status: Bool = false {
        didSet {
            self.update()
        }
    }
    var onImage = UIImage(named: "switch_on")
    var offImage = UIImage(named: "switch_off")
    var delegate : SwitchDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setStatus(false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.status ? self.setImage(self.onImage, for: .normal) : self.setImage(self.offImage, for: .normal)
        }, completion:{_ in
        })
    }
    func toggle() {
        self.status ? self.setStatus(false) : self.setStatus(true)
        self.delegate?.switchTapped(value: self.status,index: self.tag)
    }
    
    func setStatus(_ status: Bool) {
        self.status = status
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.sendHapticFeedback()
        self.toggle()
    }
    
    func sendHapticFeedback() {
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator.prepare()
        impactFeedbackgenerator.impactOccurred()
    }
    
}

