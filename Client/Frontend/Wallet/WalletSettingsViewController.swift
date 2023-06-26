//
//  WalletSettingsViewController.swift
//  Client
//
//  Created by Ashok on 26/06/23.
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
    private lazy var addTokenTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "SETTINGS"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var networkLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.NetworkView.font)
        label.textAlignment = .center
        label.text = "NETWORKS:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var testNetworkLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .boldSystemFont(ofSize: UX.NetworkView.font)
        label.textAlignment = .center
        label.text = "Test Network"
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
    
    private lazy var switchView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = UX.Value.corner
        view.clipsToBounds = true
        return view
    }()

    var switchButton : SwitchButton = {
        let switchButton = SwitchButton()
        switchButton.setStatus(true)
        return switchButton
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
        tableView.allowsSelection = true
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.register(NetworkTVCell.self, forCellReuseIdentifier:"NetworkTVCell")
        return tableView
    }()
    
    // MARK: - UI Properties
    let bag = DisposeBag()
    var themeManager :  ThemeManager?
    var selectedIndexes = IndexPath.init(row: 0, section: 0)
    var delegate :  ChangeNetwork?
    var platforms = [Platforms]()
    var copyPlatforms = [Platforms]()
    var isSettings = false
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
        setUpNetwork()
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        switchButton = SwitchButton(frame: CGRect(x: contentView.frame.origin.x, y: contentView.frame.origin.y, width: 50, height: 30))
        switchButton.delegate = self
        navigationController?.isNavigationBarHidden = true
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        switchView.addSubview(switchButton)
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(infoIcon)
        actionsView.addSubview(addTokenTitleLabel)
        contentView.addSubview(actionsView)
        contentView.addSubview(networkLabel)
        contentView.addSubview(testNetworkLabel)
        contentView.addSubview(switchView)

        view.addSubview(contentView)
        view.addSubview(tableView)
        view.addSubview(logoBackgroundView)
        view.addSubview(closeButton)
    }
    
    func setUpViewContraint(){
        NSLayoutConstraint.activate([
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
            contentView.topAnchor.constraint(equalTo: logoBackgroundView.bottomAnchor,constant: UX.ContentView.top),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: UX.ContentView.heightBackGround),
            
            ///Action View
            actionsView.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionsView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            actionsView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionsView.heightAnchor.constraint(equalToConstant: UX.ActionView.heightActionBg),
            
            ///Network Label
            networkLabel.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant:  UX.NetworkView.top),
            networkLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:  UX.NetworkView.leading),
            networkLabel.heightAnchor.constraint(equalToConstant: UX.NetworkView.detailHeight),
            
            //Network switch
            switchView.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant: UX.NetworkView.top),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            switchView.widthAnchor.constraint(equalToConstant: UX.Value.width),
            switchView.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),
            
            //Test Network
            testNetworkLabel.topAnchor.constraint(equalTo: actionsView.bottomAnchor,constant:  UX.NetworkView.top),
            testNetworkLabel.trailingAnchor.constraint(equalTo: switchView.leadingAnchor,constant: -UX.NetworkView.corner),
            testNetworkLabel.heightAnchor.constraint(equalToConstant: UX.NetworkView.detailHeight),
            
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
            
            ///UserTokenView TableView
            tableView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: UX.TableView.trailing),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setUpNetwork(){
        if isSettings{
            self.copyPlatforms = self.platforms
            if  let isSwitch = UserDefaults.standard.value(forKey: "NetworkSwitch") as? Bool{
            switchButton.status = isSwitch
            self.platforms = isSwitch ? self.copyPlatforms : self.copyPlatforms.filter{$0.isTest == false}
            }
            let selectedIndex = self.platforms.firstIndex{$0.isSelected == true}
            selectedIndexes = IndexPath(row: selectedIndex ?? 0, section: 0)
            self.tableView.reloadData()
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
        showToast(message: "Stay tunned! Dev in progress...")
    }
    @objc func addTokenBtnTapped (){
        showToast(message: "Stay tunned! Dev in progress...")

    }
    
    
    // MARK: - Helper Methods - Initiate view controller
    
    func initiateDrawerVC(){
        let drawerController = DrawerMenuViewController()
        drawerController.delegate = self
        self.present(drawerController, animated: true)
    }
    func initiateChangeNetworkVC(){
        let changeNetworkVC = ChangeNetworkViewController()
        for each in networks{
            changeNetworkVC.platforms.append(Platforms(name: each.name, address: "", isTest: each.isTest,nativeSymbol:each.nativeSymbol, isSelected: each.isSelected))
        }
        changeNetworkVC.modalPresentationStyle = .overCurrentContext
        changeNetworkVC.delegate = self
        changeNetworkVC.isSettings = true
        self.present(changeNetworkVC, animated: true)
    }
    
    func showToast(message: String){
        SimpleToast().showAlertWithText(message,
                                        bottomContainer: self.view,
                                        theme: themeManager!.currentTheme)
    }
}
// MARK: - Extension - NetworkSwitchDelegate
extension WalletSettingsViewController : NetworkSwitchDelegate{
    func networkSwitchTapped(value: Bool) {
        if selectedIndexes.row > 0{
            selectedIndexes = IndexPath(row: 0, section: 0)
        }
        self.platforms = value ? self.copyPlatforms : self.copyPlatforms.filter{$0.isTest == false}
        UserDefaults.standard.setValue(value, forKey: "NetworkSwitch")
        self.tableView.reloadData()
    }
}
// MARK: - Extension - UITableViewDelegate and UITableViewDataSource
extension WalletSettingsViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.platforms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkTVCell", for: indexPath) as! NetworkTVCell
        cell.setUI(platforms:self.platforms[indexPath.row])
        cell.selectionStyle = .none
        if (self.selectedIndexes == indexPath) {
            cell.iconView.isHidden = false
            cell.gradientView.isHidden = false
        }
        else {
            cell.iconView.isHidden = true
            cell.gradientView.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexes = indexPath
        tableView.reloadData()
        networks.forEach( { network in
            network.isSelected = ( network.name?.uppercased() == self.platforms[indexPath.row].name?.uppercased() ) ? true : false
        })
        self.setUpNetworkDAppBrowsing(platform:self.platforms[indexPath.row])
        self.delegate?.changeNetworkDelegate(platforms: self.platforms[indexPath.row])
        self.dismissVC()
    }
    
    func setUpNetworkDAppBrowsing(platform : Platforms){
        var chainInfo : Chain?

        switch platform.name?.uppercased(){
          
        //Ethereum
        case NetworkEnum.Ethereum.rawValue.uppercased():
            server = RPCServer.allCases[0]
            chainInfo  = .ethereum(EthereumNetwork(rawValue:EthereumNetwork.mainnet.rawValue)!)
            
       //Goerli-Ethereum Testnet
        case NetworkEnum.EthereumGoerliTest.rawValue.uppercased():
            server = RPCServer.allCases[3]
            chainInfo  = .ethereum(EthereumNetwork(rawValue: EthereumNetwork.goerli.rawValue)!)
           
       //Sepolia-Ethereum Testnet
        case NetworkEnum.EthereumSepoliaTest.rawValue.uppercased():
            server = RPCServer.allCases[25]
            chainInfo  = .ethereum(EthereumNetwork(rawValue: EthereumNetwork.sepolia.rawValue)!)

        //BinanceSmartChain
        case NetworkEnum.BinanceSmartChain.rawValue.uppercased():
            server = RPCServer.allCases[5]
            chainInfo  = .bsc(BscNetwork(rawValue:BscNetwork.mainnet.rawValue)!)

        //BinanceSmartChain Testnet
        case NetworkEnum.BinanceSmartChainTest.rawValue.uppercased():
            server = RPCServer.allCases[4]
            chainInfo  = .bsc(BscNetwork(rawValue:BscNetwork.testnet.rawValue)!)
            
        //Solana
        case NetworkEnum.Solana.rawValue.uppercased():
            server = RPCServer.allCases[0] //Solana
            chainInfo  = .solana(SolanaNetwork(rawValue: SolanaNetwork.mainnet.rawValue)!)

        //KucoinCommunityChain
        case NetworkEnum.KucoinCommunityChain.rawValue.uppercased():
            server = RPCServer.allCases[0]
            chainInfo  = .kcc(KccNetwork(rawValue: KccNetwork.mainnet.rawValue)!)

        //OkexChain
        case NetworkEnum.OkexChain.rawValue.uppercased():
            server = RPCServer.allCases[24]
            chainInfo  = .okc(OKCNetwork(rawValue: OKCNetwork.mainnet.rawValue)!)

         //Polygon
        case NetworkEnum.Polygon.rawValue.uppercased():
            server = RPCServer.allCases[11]
            chainInfo  = .polygon(PolygonNetwork(rawValue: PolygonNetwork.mainnet.rawValue)!)
          
        //Polygon-Mumbai Testnet
        case NetworkEnum.PolygonTest.rawValue.uppercased():
            server = RPCServer.allCases[13]
            chainInfo  = .polygon(PolygonNetwork(rawValue: PolygonNetwork.mainnet.rawValue)!)

        default:
            server = RPCServer.allCases[0]
            chainInfo  = .bsc(BscNetwork(rawValue:EthereumNetwork.mainnet.rawValue)!)
        }
        
        ParticleNetwork.setChainInfo(chainInfo!)
        tabManager.addTab()
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
// MARK: - Extension - AddTokenDelegate
extension WalletSettingsViewController: AddTokenDelegate{
    func initiateAddToken() {
        
    }
}
// MARK: - Extension - ChangeNetwork
extension WalletSettingsViewController :  ChangeNetwork{
    func changeNetworkDelegate(platforms: Platforms) {

    }
}
