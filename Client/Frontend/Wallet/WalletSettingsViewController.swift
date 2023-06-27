//
//  WalletSettingsViewController.swift
//  Client
//
//  Created by Ashok on 26/06/23.
//
import Foundation
import UIKit
import Common
import Shared
import ParticleNetworkBase

class WalletSettingsViewController: UIViewController {
    
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
            static let top: CGFloat = 0
            static let heightBackGround: CGFloat = 100
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
            static let leading: CGFloat = 20
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
        struct ButtonView {
            static let font: CGFloat = 14
            static let corner: CGFloat = 10
        }
        struct TableView{
            static let common: CGFloat = 15
            static let leading: CGFloat = 10
            static let top: CGFloat = 15
            static let trailing: CGFloat = -20
            static let bottom: CGFloat = -30
            static let height: CGFloat = 500
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
            static let corner: CGFloat = 15
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
    private lazy var actionsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        label.text = "SETTINGS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var walletDetailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.NetworkView.font)
        label.textAlignment = .center
        label.text = "WALLET DETAILS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var securityDetailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.NetworkView.font)
        label.textAlignment = .center
        label.text = "SECURITY"
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
    private lazy var walletTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = true
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SettingsChevronTVCell.self, forCellReuseIdentifier:"SettingsChevronTVCell")
        return tableView
    }()
    
    private lazy var securityTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isUserInteractionEnabled = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.alpha = 0.4
        tableView.isUserInteractionEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.register(SettingsSecurityTVCell.self, forCellReuseIdentifier:"SettingsSecurityTVCell")
        tableView.register(SettingsChevronTVCell.self, forCellReuseIdentifier:"SettingsChevronTVCell")
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
    //    let bag = DisposeBag()
    var themeManager :  ThemeManager?
    private let walletDetails = ["Your Carbon Wallet","Change Network","Connect Wallet","Add Token"]
    private let security = ["Wallet Seed Phrase","Allow scan QR Codes","Save Transaction History","Allow Push Notifications"]
    private var networkName = String()
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        networkName = ParticleNetwork.getChainInfo().name
        navigationController?.isNavigationBarHidden = true
        self.walletTableView.reloadData()
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        actionsView.addSubview(addTokenTitleLabel)
        contentView.addSubview(actionsView)
        contentView.addSubview(walletDetailsLabel)
        contentView.addSubview(walletTableView)
        contentView.addSubview(securityTableView)
        contentView.addSubview(securityDetailsLabel)
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
            contentView.heightAnchor.constraint(equalToConstant: view.frame.height - 100),
            contentView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            ///Action View
            actionsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            ///Network Label
            walletDetailsLabel.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant:  UX.NetworkView.top),
            walletDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.NetworkView.leading),
            walletDetailsLabel.heightAnchor.constraint(equalToConstant: UX.NetworkView.detailHeight),
            
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
            
            ///Wallet Label
            walletLabel.leadingAnchor.constraint(equalTo: carbonImageView.trailingAnchor,constant: UX.Wallet.leading),
            walletLabel.topAnchor.constraint(equalTo: logoView.topAnchor,constant:  UX.Wallet.top),
            walletLabel.widthAnchor.constraint(equalToConstant: UX.Wallet.width),
            walletLabel.heightAnchor.constraint(equalToConstant: UX.Wallet.height),
            
            ///Wallet balance title Label
            addTokenTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            addTokenTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor,constant: UX.BalanceLabel.topValue),
            
            ///UserTokenView TableView
            walletTableView.topAnchor.constraint(equalTo: walletDetailsLabel.bottomAnchor),
            walletTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            walletTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            walletTableView.heightAnchor.constraint(equalToConstant: 270),
            
            ///Network Label
            securityDetailsLabel.topAnchor.constraint(equalTo: walletTableView.bottomAnchor,constant:  UX.NetworkView.top),
            securityDetailsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.NetworkView.leading),
            securityDetailsLabel.heightAnchor.constraint(equalToConstant: UX.NetworkView.detailHeight),
            
            securityTableView.topAnchor.constraint(equalTo: securityDetailsLabel.bottomAnchor),
            securityTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            securityTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            securityTableView.heightAnchor.constraint(equalToConstant: 600),
        ])
    }
    // MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    // MARK: - Helper Methods - Initiate view controller
    func initiateChangeNetworkVC(){
        let changeNetworkVC = ChangeNetworkViewController()
        for each in networks{
            changeNetworkVC.platforms.append(Platforms(name: each.name, address: "", isTest: each.isTest,nativeSymbol:each.nativeSymbol, isSelected: each.isSelected))
        }
        changeNetworkVC.modalPresentationStyle = .overCurrentContext
        changeNetworkVC.isSettings = true
        self.navigationController?.pushViewController(changeNetworkVC, animated: true)
    }
    
    func initiateAddWalletVC(){
        let addWalletVC = AddWalletViewController()
        addWalletVC.delegate = self
        self.navigationController?.pushViewController(addWalletVC, animated: true)
    }
    func initiateAddTokenVC(){
        let vc = AddCustomTokenViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: false)
    }
}

// MARK: - Extension - AddWalletProtocol
extension WalletSettingsViewController : AddWalletProtocol{
    func addWalletDelegate() {
        self.dismissVC()
    }
}
// MARK: - Extension - ConnectProtocol
extension WalletSettingsViewController : ConnectProtocol{
    func accountPublicAddress(address: String) {
    }
    func logout() {
        self.dismiss(animated: true)
    }
}
// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension WalletSettingsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  tableView == walletTableView ? walletDetails.count : security.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == walletTableView){
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsChevronTVCell", for: indexPath) as! SettingsChevronTVCell
            cell.setUI(title: walletDetails[indexPath.row], subTitle: indexPath.row == 1 ? networkName : "" , isScan: indexPath.row == 2 ? true : false)
            return cell
        }else{
            if (indexPath.row == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsChevronTVCell", for: indexPath) as! SettingsChevronTVCell
                cell.setUI(title:security[indexPath.row], subTitle: "", isScan:false)
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSecurityTVCell", for: indexPath) as! SettingsSecurityTVCell
                cell.setUI(title:security[indexPath.row])
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  tableView == walletTableView ? 66 : indexPath.row == 0 ? 66 : 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == walletTableView){
            switch indexPath.row{
            case 0: self.dismissVC()
            case 1 : initiateChangeNetworkVC()
            case 2:  initiateAddWalletVC()
            case 3: initiateAddTokenVC()
            default: break
            }
        }else{
            switch indexPath.row{
            case 1 : initiateChangeNetworkVC()
            default: break
            }
        }
    }
    
    
}
class SettingsChevronTVCell: UITableViewCell {
    private struct UX {
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
            static let width: CGFloat = 20
            static let valueWidth: CGFloat = 50
            static let valueHeight: CGFloat = 30
            static let chevronWidth: CGFloat = 12
            static let chevronHeight: CGFloat = 8
            static let corner: CGFloat = 15
        }
    }
    private lazy var tokenNetworktitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Token Network"
        label.isUserInteractionEnabled = true
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
        return label
    }()
    private lazy var chevronImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 12, left: 10, bottom: 0, right: 10))
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(tokenNetworktitleLabel)
        contentView.addSubview(tokenNetworkValueLabel)
        contentView.addSubview(chevronImageView)
        backgroundColor = .clear
        contentView.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            tokenNetworktitleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tokenNetworktitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            tokenNetworktitleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            
            tokenNetworkValueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tokenNetworkValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -UX.Value.valueWidth),
            tokenNetworkValueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
        ]
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(title:String,subTitle:String ,isScan: Bool){
        tokenNetworktitleLabel.text = title
        tokenNetworkValueLabel.text = subTitle
        chevronImageView.image = UIImage(named: isScan ? "ic_scan":"ic_chevron")
    }
    
}
class SettingsSecurityTVCell: UITableViewCell {
    
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
            static let top: CGFloat = 8
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
    private lazy var switchView: UIView = {
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
        label.font = UIFont.boldSystemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var symbolLabel : UILabel = {
        let label = UILabel()
        label.text = "You can turn off this in settings"
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
    
    var tokenAddress = String()
    
    //    private var wallpaperManager =  WallpaperManager()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        switchButton = SwitchButton(frame: CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: 50, height: 30))
        switchButton.delegate = self
        switchView.addSubview(switchButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(symbolLabel)
        contentView.addSubview(switchView)
        
        backgroundColor = .clear
        contentView.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        layer.cornerRadius = 10
        contentView.layer.cornerRadius = 10
        NSLayoutConstraint.activate([
            
            ///UILabel
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Title.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:UX.Value.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            symbolLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: UX.Value.topAt),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Value.leading),
            
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            switchView.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            switchView.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
        ]
                                    
        )
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 12, left: 10, bottom: 0, right: 10))
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
    func setUI(title:String){
        titleLabel.text = title
        switchButton.status = true
    }
}

extension SettingsSecurityTVCell : NetworkSwitchDelegate{
    func networkSwitchTapped(value: Bool) {
        
    }
}
