import Foundation
import UIKit
import QRCode
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

class SendViewController: UIViewController {
    
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
            static let heightBackGround: CGFloat = 30
        }
        struct ActionView {
            static let heightActionBg: CGFloat = 25
            static let topActionBg: CGFloat = 10
        }
        struct UserTokenView {
            static let cornerRadius: CGFloat = 10
            static let common: CGFloat = 20
            static let top: CGFloat = 30
            static let spacing: CGFloat = 10
            static let commonLarge: CGFloat = 100
            static let commonAmountLarge: CGFloat = 120
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
        struct TitleLabel{
            static let font: CGFloat = 20
            static let holder: CGFloat = 15
            static let top: CGFloat = 20
            static let height: CGFloat = 50
            
        }
        struct WalletLabel {
            static let font: CGFloat = 18
        }
        struct QRCodeView {
            static let top: CGFloat = -30
            static let width: CGFloat = 200
            static let height: CGFloat = 200
        }
        struct TokenView {
            static let height: CGFloat = 80
            static let common: CGFloat = 20
            static let top: CGFloat = 10
            static let logoHeight: CGFloat = 48
            static let logoWidth: CGFloat = 48
            static let shareHeight: CGFloat = 24
            static let shareWidth: CGFloat = 24
        }
        struct CloseButton {
            static let top: CGFloat = 50
            static let leading: CGFloat = 20
            static let height: CGFloat = 40
            static let width: CGFloat = 40
            static let corner: CGFloat = 20
        }
        struct Value {
            static let font: CGFloat = 12
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 10
            static let topAt: CGFloat = 0
            static let trailing: CGFloat = -10
            static let height: CGFloat = 20
            static let width: CGFloat = 50
            static let valueHeight: CGFloat = 60
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
    private lazy var sendContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = UX.UserTokenView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var recepientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        view.layer.cornerRadius = UX.UserTokenView.cornerRadius
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var tokenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    private lazy var amountView: UIView = {
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
    private lazy var sendTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = .boldSystemFont(ofSize: UX.BalanceLabel.titleFont)
        label.textAlignment = .center
        label.text = "SEND"
        label.translatesAutoresizingMaskIntoConstraints = false
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
    private lazy var sendButton : UIButton = {
        let button = UIButton()
        button.setTitle("GO NEXT", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.sendBtnTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        button.isUserInteractionEnabled = true
        return button
    }()
    
    ///UITextField
    lazy var receipientTextField:UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.tintColor = Utilities().hexStringToUIColor(hex: "#FF4412")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: UX.TitleLabel.font)
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.delegate = self
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        let attributes = [
            NSAttributedString.Key.foregroundColor:Utilities().hexStringToUIColor(hex: "#6D6D6D"),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UX.TitleLabel.holder)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Recepient address", attributes:attributes)
        return textField
    }()
    
    lazy var amountTextField:UITextField = {
        let textField = UITextField()
        textField.tintColor = Utilities().hexStringToUIColor(hex: "#FF4412")
        textField.backgroundColor = .clear
        textField.textColor = .white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: UX.TitleLabel.font)
        textField.clearButtonMode = UITextField.ViewMode.whileEditing
        textField.delegate = self
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        let attributes = [
            NSAttributedString.Key.foregroundColor:Utilities().hexStringToUIColor(hex: "#6D6D6D"),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UX.TitleLabel.holder)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Amount", attributes:attributes)
        return textField
    }()
    
    private lazy var scanImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_scan")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var tokenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_carbon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tokenBtnTapped))
        imageView.addGestureRecognizer(tapRecognizer)
        return imageView
    }()
    private lazy var receipientGradiantLabel : GradientLabel = {
        let label = GradientLabel()
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.text = "PASTE"
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(pasteBtnTapped))
        label.addGestureRecognizer(tapRecognizer)
        return label
    }()
    
    private lazy var amountGradiantLabel : GradientLabel = {
        let label = GradientLabel()
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.text = "MAX"
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    private lazy var tokenSymbolLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.lineBreakMode = .byTruncatingMiddle
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tokenBtnTapped))
        label.addGestureRecognizer(tapRecognizer)
        return label
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
    
    var toolBar = UIToolbar()
    var pickerView = UIPickerView()

    
    // MARK: - UI Properties
    var shownFromAppMenu: Bool = false
    var themeManager :  ThemeManager?
    var delegate :  ChangeNetwork?
    var publicAddress : String = ""
    var tokensModel = [TokenModel]()
    var pickerArray = [String]()
    var selectedToken : TokenModel?

    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        for token in self.tokensModel {
            pickerArray.append(token.symbol.uppercased())
        }
        self.selectedToken = self.tokensModel.first
        self.tokenSymbolLabel.text = pickerArray.first
        sendBtnView.alpha = 0
        navigationController?.isNavigationBarHidden = true
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        actionsView.addSubview(settingsIcon)
        actionsView.addSubview(infoIcon)
        actionsView.addSubview(sendTitleLabel)
        contentView.addSubview(actionsView)
        recepientView.addSubview(receipientTextField)
        recepientView.addSubview(scanImageView)
        recepientView.addSubview(receipientGradiantLabel)
        amountView.addSubview(amountTextField)
        amountView.addSubview(tokenImageView)
        amountView.addSubview(amountGradiantLabel)
        amountView.addSubview(tokenSymbolLabel)
        sendContentView.addSubview(recepientView)
        sendContentView.addSubview(amountView)
        scrollContentView.addSubview(contentView)
        scrollContentView.addSubview(sendContentView)
        scrollContentView.addSubview(sendBtnView)
        scrollContentView.addSubview(sendButton)
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
            
            ///Send Content View
            sendContentView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.UserTokenView.common),
            sendContentView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            sendContentView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            sendContentView.heightAnchor.constraint(equalToConstant: view.frame.height - 300),
            
            recepientView.topAnchor.constraint(equalTo: sendContentView.topAnchor ,constant: UX.UserTokenView.common),
            recepientView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            recepientView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            recepientView.heightAnchor.constraint(equalToConstant: 50),
            
            receipientTextField.topAnchor.constraint(equalTo: recepientView.topAnchor),
            receipientTextField.leadingAnchor.constraint(equalTo: recepientView.leadingAnchor,constant: UX.UserTokenView.common),
            receipientTextField.trailingAnchor.constraint(equalTo: recepientView.trailingAnchor,constant: -UX.UserTokenView.commonLarge),
            receipientTextField.heightAnchor.constraint(equalToConstant: 50),
            
            scanImageView.centerYAnchor.constraint(equalTo: recepientView.centerYAnchor),
            scanImageView.trailingAnchor.constraint(equalTo: recepientView.trailingAnchor,constant: -UX.UserTokenView.common),
            scanImageView.heightAnchor.constraint(equalToConstant: 20),
            scanImageView.widthAnchor.constraint(equalToConstant: 20),
            
            receipientGradiantLabel.centerYAnchor.constraint(equalTo: recepientView.centerYAnchor),
            receipientGradiantLabel.trailingAnchor.constraint(equalTo: scanImageView.leadingAnchor,constant: -UX.UserTokenView.spacing),
            
            amountView.topAnchor.constraint(equalTo: recepientView.bottomAnchor ,constant: UX.UserTokenView.common),
            amountView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            amountView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            amountView.heightAnchor.constraint(equalToConstant: 50),
            
            tokenSymbolLabel.centerYAnchor.constraint(equalTo: amountView.centerYAnchor),
            tokenSymbolLabel.trailingAnchor.constraint(equalTo: amountView.trailingAnchor,constant: -UX.UserTokenView.spacing),
            
            tokenImageView.centerYAnchor.constraint(equalTo: amountView.centerYAnchor),
            tokenImageView.trailingAnchor.constraint(equalTo: tokenSymbolLabel.leadingAnchor,constant: -UX.UserTokenView.spacing),
            tokenImageView.heightAnchor.constraint(equalToConstant: 25),
            tokenImageView.widthAnchor.constraint(equalToConstant: 25),
            
            amountGradiantLabel.centerYAnchor.constraint(equalTo: amountView.centerYAnchor),
            amountGradiantLabel.trailingAnchor.constraint(equalTo: tokenImageView.leadingAnchor,constant: -UX.UserTokenView.spacing),
            
            amountTextField.topAnchor.constraint(equalTo: amountView.topAnchor),
            amountTextField.leadingAnchor.constraint(equalTo: amountView.leadingAnchor,constant: UX.UserTokenView.common),
            amountTextField.trailingAnchor.constraint(equalTo: amountView.trailingAnchor,constant: -UX.UserTokenView.commonAmountLarge),
            amountTextField.heightAnchor.constraint(equalToConstant: 50),
            
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
            sendTitleLabel.centerXAnchor.constraint(equalTo: actionsView.centerXAnchor),
            sendTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor),
            
            ///Send button view
            sendBtnView.topAnchor.constraint(equalTo: sendContentView.bottomAnchor,constant:UX.ButtonView.addTop),
            sendBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            sendBtnView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            sendBtnView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
            sendBtnView.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
            
            ///Send button
            sendButton.topAnchor.constraint(equalTo: sendContentView.bottomAnchor,constant:UX.ButtonView.addTop),
            sendButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            sendButton.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant:UX.ButtonView.leading),
            sendButton.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant:-UX.ButtonView.leading),
            sendButton.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor),
        ])
    }
        // MARK: - View Model Methods - Network actions
        func sendNativeEVM(amountString: String,receiver: String,sender:String) {
            let details = SendDetails(amount: amountString, symbol:  self.selectedToken?.symbol, logo: self.selectedToken?.imageUrl, address: receiver, network: ParticleNetwork.getChainInfo().network.capitalized, gas: "", date: self.getDateTime(), status: "Completed")
            SVProgressHUD.show()
            WalletViewModel.shared.sendNativeEVM(amountString: amountString,sender:sender ,receiver: receiver){ result in
                switch result {
                case .success(let tokens):
                    print(tokens)
                    SVProgressHUD.dismiss()
                    self.initiateSendConfirmationVC(details: details)
                case .failure(let error):
                    print(error)
                    SVProgressHUD.dismiss()
                }
            }
        }
    func getDateTime() -> String{
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: date)
    }
  
    // MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func settingsIconTapped (){
        initiateSettingsVC()
    }
    @objc func tokenBtnTapped (){
        initiatePickerPopUp()
    }
    @objc func pasteBtnTapped (){
        helperMethodToAnimate(view: sendBtnView, button: sendButton)
        receipientTextField.text = UIPasteboard.general.string
        if (receipientTextField.text != ""){
            self.view.makeToast( "Added!", duration: 3.0, position: .bottom)
        }
    }
    
    @objc func infoIconTapped (){
        self.view.makeToast( "Stay tunned! Dev in progress...", duration: 3.0, position: .bottom)
    }
    
    
    @objc func sendBtnTapped (){
        helperMethodToAnimate(view: sendBtnView, button: sendButton)
        if (receipientTextField.text != "" && amountTextField.text != ""){
            self.sendNativeEVM(amountString: amountTextField.text!, receiver: receipientTextField.text!, sender: publicAddress)
        }else{
            self.view.makeToast( "Please enter both values", duration: 3.0, position: .bottom)
        }
    }
    
    func initiatePickerPopUp(){
        pickerView = UIPickerView.init()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        pickerView.setValue(UIColor.white, forKey: "textColor")
        pickerView.autoresizingMask = .flexibleWidth
        pickerView.contentMode = .center
        pickerView.tintColor = UIColor.white
        pickerView.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(pickerView)
                
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.barStyle = .black
        toolBar.backgroundColor = Utilities().hexStringToUIColor(hex: "#292929")
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))
        doneButton.tintColor = Utilities().hexStringToUIColor(hex: "#FF2D08")
        toolBar.items = [doneButton]
        self.view.addSubview(toolBar)
    }
    
    @objc func onDoneButtonTapped (){
        UIView.animate(withDuration: 0.3) {
            self.toolBar.removeFromSuperview()
            self.pickerView.removeFromSuperview()
        }
    }
    
    
    // MARK: - Helper Methods - Initiate view controller
    func initiateSettingsVC(){
        let settingsVC = WalletSettingsViewController()
        let navController = ThemedNavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true)
    }
    
    func initiateSendConfirmationVC(details: SendDetails){
        let vc = SendConfirmationViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.details = details
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
extension SendViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerArray.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerArray[row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedToken = self.tokensModel[row]
        self.tokenSymbolLabel.text = self.pickerArray[row]
    }
}
extension SendViewController: UITextFieldDelegate{
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if (textField == amountTextField){
            let amount  = textField.text! + string
            if amount.count > 0 {
                let balance = self.tokensModel.filter{$0.symbol == self.tokenSymbolLabel.text}.first
                if( BInt(amount) ?? 0 > balance?.amount ?? 0){
                    self.view.endEditing(true)
                    self.view.makeToast( "Insufficient balance! Please enter lesser amount.", duration: 3.0, position: .bottom)
                }
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

}
