//
//  WalletViewController.swift
//  Client
//
//  Created by Ashok on 06/07/23.
//

import Foundation
import UIKit
import QRCode
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
import Toast_Swift

class ReceiveViewController: UIViewController {
    
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
            static let topValue: CGFloat = 20
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
            static let heightBackGround: CGFloat = 30
        }
        struct ActionView {
            static let heightActionBg: CGFloat = 25
            static let topActionBg: CGFloat = 10
        }
        struct UserTokenView {
            static let cornerRadius: CGFloat = 20
            static let common: CGFloat = 30
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
        struct AddressLabel{
            static let centerY: CGFloat = 50
            static let font: CGFloat = 15
            static let width: CGFloat = 250
            static let height: CGFloat = 30
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
        }
        struct TokenLabel{
            static let leading: CGFloat = 20
            static let topValue: CGFloat = 10
            static let font: CGFloat = 13
        }
        struct DescriptionLabel {
            static let top: CGFloat = 30
            static let font: CGFloat = 12
            static let width: CGFloat = 290
            static let height: CGFloat = 65
            
        }
        struct WalletLabel {
            static let font: CGFloat = 18
        }
        struct QRCodeView {
            static let top: CGFloat = -30
            static let width: CGFloat = 200
            static let height: CGFloat = 200
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
    private lazy var receiveContentView: UIView = {
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
    private lazy var copyBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var shareBtnView: GradientView = {
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
    private lazy var receiveTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "RECEIVE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .systemFont(ofSize: UX.DescriptionLabel.font)
        label.textAlignment = .center
        label.text = "Remember that you have to send only Carbon $CSIX BEP20 on this address. Sending any other token can be a mistake and you can lose all your tokens that you send in this transaction"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        return label
    }()
    lazy var walletAddressTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#818181")
        label.text = "Wallet Address:"
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: UX.AddressLabel.font)
        return label
    }()
    lazy var walletAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 3
        label.font = .boldSystemFont(ofSize: UX.AddressLabel.font)
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
    private lazy var copyButton : UIButton = {
        let button = UIButton()
        button.setTitle("COPY", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.copyBtnTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        button.isUserInteractionEnabled = true
        return button
    }()
    private lazy var shareButton : UIButton = {
        let button = UIButton()
        button.setTitle("SHARE", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.shareBtnTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        button.isUserInteractionEnabled = true
        return button
    }()
    
    ///UIImageView
    private lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_qr")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: UX.QRCodeView.width, height: UX.QRCodeView.height)
        return imageView
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
    var themeManager :  ThemeManager?
    var delegate :  ChangeNetwork?
    var address : String = ""
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        walletAddressLabel.text = self.address 
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        shareBtnView.alpha = 0
        copyBtnView.alpha = 0
        navigationController?.isNavigationBarHidden = true
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(infoIcon)
        actionsView.addSubview(receiveTitleLabel)
        contentView.addSubview(actionsView)
        receiveContentView.addSubview(qrImageView)
        receiveContentView.addSubview(walletAddressTitleLabel)
        receiveContentView.addSubview(walletAddressLabel)
        scrollContentView.addSubview(contentView)
        scrollContentView.addSubview(receiveContentView)
        scrollContentView.addSubview(descriptionLabel)
        scrollContentView.addSubview(copyBtnView)
        scrollContentView.addSubview(shareBtnView)
        scrollContentView.addSubview(copyButton)
        scrollContentView.addSubview(shareButton)
        scrollView.addSubview(scrollContentView)
        view.addSubview(scrollView)
        view.addSubview(logoBackgroundView)
        view.addSubview(closeButton)
        qrImageView.image = generateQRcode()
    }
    
    func generateQRcode() -> UIImage?{
        let doc = QRCode.Document(utf8String: self.address, errorCorrection: .high)
        doc.design.additionalQuietZonePixels = 0
        doc.design.backgroundColor(CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0))
        doc.design.style.onPixels = QRCode.FillStyle.Solid(1, 1, 1, alpha: 1.000)
        doc.design.style.eye   = QRCode.FillStyle.Solid(CGColor(srgbRed: 1, green: 0.25882, blue: 0.06667, alpha: 1))
        doc.design.shape.eye = QRCode.EyeShape.Square()
        doc.design.shape.pupil = QRCode.PupilShape.Square()
        doc.design.shape.onPixels = QRCode.PixelShape.RoundedRect()
        let image = UIImage(named: "ic_qr_logo")!
        doc.logoTemplate = QRCode.LogoTemplate(
            image: image.cgImage!,
            path: CGPath(rect: CGRect(x: 0.35, y: 0.35, width: 0.35, height: 0.35), transform: nil),
            inset: 2
        )
        return doc.uiImage(CGSize(width: 200, height: 200))
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
            receiveContentView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.UserTokenView.top),
            receiveContentView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            receiveContentView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            receiveContentView.heightAnchor.constraint(equalToConstant: 340),
            
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
            receiveTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            receiveTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor,constant: UX.BalanceLabel.topValue),
            
            qrImageView.centerYAnchor.constraint(equalTo: receiveContentView.centerYAnchor,constant:  UX.QRCodeView.top),
            qrImageView.centerXAnchor.constraint(equalTo: receiveContentView.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: UX.QRCodeView.width),
            qrImageView.heightAnchor.constraint(equalToConstant: UX.QRCodeView.height),
            
            ///Wallet Address Title Label
            walletAddressTitleLabel.topAnchor.constraint(equalTo:qrImageView.bottomAnchor,constant: UX.BalanceLabel.topValue),
            walletAddressTitleLabel.centerXAnchor.constraint(equalTo: receiveContentView.centerXAnchor),
            
            ///Wallet Address Title Label
            walletAddressLabel.topAnchor.constraint(equalTo:walletAddressTitleLabel.bottomAnchor,constant: UX.BalanceLabel.topValueCarbon),
            walletAddressLabel.centerXAnchor.constraint(equalTo: receiveContentView.centerXAnchor),
            
            ///Description Label
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: receiveContentView.bottomAnchor,constant:  UX.DescriptionLabel.top),
            descriptionLabel.widthAnchor.constraint(equalToConstant: UX.DescriptionLabel.width),
            descriptionLabel.heightAnchor.constraint(equalToConstant: UX.DescriptionLabel.height),
            
            ///Copy button view
            copyBtnView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor,constant:-80),
            copyBtnView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant:UX.ButtonView.addTop),
            copyBtnView.widthAnchor.constraint(equalToConstant: 145),
            copyBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            
            ///Share button view
            shareBtnView.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor,constant: 80),
            shareBtnView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant:UX.ButtonView.addTop),
            shareBtnView.widthAnchor.constraint(equalToConstant: 145),
            shareBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            shareBtnView.leadingAnchor.constraint(equalTo: copyButton.trailingAnchor,constant:UX.ButtonView.leading),
            
            ///Copy button
            copyButton.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor,constant: -80),
            copyButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: UX.ButtonView.addTop),
            copyButton.widthAnchor.constraint(equalToConstant: 145),
            copyButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            copyButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            ///Share button
            shareButton.centerXAnchor.constraint(equalTo: scrollContentView.centerXAnchor,constant:80),
            shareButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: UX.ButtonView.addTop),
            shareButton.widthAnchor.constraint(equalToConstant: 145),
            shareButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            shareButton.leadingAnchor.constraint(equalTo: copyButton.trailingAnchor,constant:UX.ButtonView.leading),
            shareButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
        ])
    }
    
    
    // MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func settingsIconTapped (){
        initiateSettingsVC()
    }
    
    @objc func infoIconTapped (){
        self.view.makeToast( "Stay tunned! Dev in progress...", duration: 3.0, position: .bottom)
    }
    
    
    @objc func copyBtnTapped (){
        helperMethodToAnimate(view: copyBtnView, button: copyButton)
        UIPasteboard.general.string = self.address
        SimpleToast().showAlertWithText("Copied!", bottomContainer: view, theme: themeManager!.currentTheme)
    }
    
    @objc func shareBtnTapped (){
        helperMethodToAnimate(view: shareBtnView, button: shareButton)
        let textToShare = [ self.address ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods - Initiate view controller
    func initiateSettingsVC(){
        let settingsVC = WalletSettingsViewController()
        let navController = ThemedNavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true)
    }
    
    func initiateReceiveVC(){
        let vc = ReceiveViewController()
        vc.address = publicAddress
        self.present(vc, animated: false)
    }
    func helperMethodToAnimate(view: UIView, button: UIButton){
        UIView.animate(withDuration: 0.1, animations: {
            view.alpha = 1
            button.backgroundColor = UIColor.clear
        }, completion: {
            (value: Bool) in
            view.alpha = 0
            button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        })
    }
}
