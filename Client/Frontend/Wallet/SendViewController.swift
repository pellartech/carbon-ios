//
//  SendViewController.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//

//import Foundation
//import UIKit
//import SVProgressHUD
//import ParticleWalletAPI
//import iOSDropDown
//import ParticleAuthService
//import ParticleNetworkBase
//import RxSwift
//import ConnectCommon
//import ParticleConnect
//import Common
//import Shared
//class SendViewController: UIViewController {
//    // MARK: - UI Constants
//    private struct UX {
//        struct TopBarView {
//            static let corner: CGFloat = 2
//            static let width: CGFloat = 76
//            static let height: CGFloat = 4
//            static let top: CGFloat = 15
//        }
//        struct ContainerView {
//            static let corner: CGFloat = 16
//            static let spacing: CGFloat = 12
//            static let common: CGFloat = 10
//        }
//
//        struct AddressLabel{
//            static let font: CGFloat = 15
//            static let width: CGFloat = 250
//            static let height: CGFloat = 30
//        }
//
//        struct QRCodeView {
//            static let top: CGFloat = 170
//            static let width: CGFloat = 200
//            static let height: CGFloat = 200
//        }
//
//        struct ContainerStackView {
//            static let top: CGFloat = 25
//            static let leading: CGFloat = 40
//            static let trailing: CGFloat = -40
//            static let bottom: CGFloat = -20
//        }
//
//        struct DropDown {
//            static let width: CGFloat = 120
//            static let height: CGFloat = 200
//            static let top: CGFloat = 20
//            static let widthC: CGFloat = 120
//            static let heightC: CGFloat = 40
//        }
//
//        struct TitleLabel{
//            static let font: CGFloat = 25
//            static let holder: CGFloat = 15
//            static let top: CGFloat = 20
//            static let height: CGFloat = 50
//
//        }
//        struct TokenLabel{
//            static let font: CGFloat = 20
//        }
//        struct ToLabel{
//            static let top: CGFloat = 30
//            static let leading: CGFloat = 20
//        }
//        struct AmountLabel{
//            static let top: CGFloat = 100
//            static let leading: CGFloat = 20
//        }
//        struct ButtonView {
//            static let corner: CGFloat = 15
//            static let font: CGFloat = 14
//            static let top: CGFloat = 80
//            static let height: CGFloat = 50
//            static let width: CGFloat = 163
//        }
//        struct TextField {
//            static let common: CGFloat = 20
//
//        }
//    }
//
//    // MARK: - UI Elements
//    ///UIView
//
//    lazy var containerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
//        view.layer.cornerRadius =  UX.ContainerView.corner
//        view.clipsToBounds = true
//        return view
//    }()
//
//    lazy var dimmedView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear
//        view.alpha = maxDimmedAlpha
//        return view
//    }()
//
//    ///UILabel
//    var dummyLabel: UILabel = {
//        let label = UILabel()
//        label.text = ""
//        label.font = .systemFont(ofSize: UX.TitleLabel.font)
//        return label
//    }()
//
//    private lazy var sendBtnView: GradientView = {
//        let view = GradientView()
//        view.clipsToBounds = true
//        view.layer.cornerRadius = UX.ButtonView.corner
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    ///UILabel
//    var titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "SEND"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .boldSystemFont(ofSize: UX.TitleLabel.font)
//        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
//        return label
//    }()
//
//    var tokenLabel: UILabel = {
//        let label = UILabel()
//        label.text = "ETH"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .boldSystemFont(ofSize: UX.TokenLabel.font)
//        label.textColor = UIColor.white
//        return label
//    }()
//
//    var toLabel: UILabel = {
//        let label = UILabel()
//        label.text = "To"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .boldSystemFont(ofSize:  UX.TokenLabel.font)
//        label.textColor = UIColor.white
//        return label
//    }()
//    var amountLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Amount"
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.font = .boldSystemFont(ofSize:  UX.TokenLabel.font)
//        label.textColor = UIColor.white
//        return label
//    }()
//
//    ///DropDown
//    var dropDown: DropDown = {
//        let dropDown = DropDown()
//        dropDown.backgroundColor = UIColor.clear
//        dropDown.rowBackgroundColor = Utilities().hexStringToUIColor(hex: "#5B5B65")
//        dropDown.textColor =  Utilities().hexStringToUIColor(hex: "#FF581A")
//        dropDown.itemsColor = UIColor.white
//        dropDown.tintColor = Utilities().hexStringToUIColor(hex: "#FF581A")
//        dropDown.itemsTintColor =  Utilities().hexStringToUIColor(hex: "#FF581A")
//        dropDown.selectedRowColor = Utilities().hexStringToUIColor(hex: "#5B5B65")
//        dropDown.borderColor = Utilities().hexStringToUIColor(hex: "#5B5B65")
//        dropDown.arrowColor = UIColor.clear
//        dropDown.isSearchEnable = false
//        dropDown.translatesAutoresizingMaskIntoConstraints = false
//        dropDown.font = .boldSystemFont(ofSize:  UX.TokenLabel.font)
//        dropDown.frame = CGRect(x: 0, y: 0, width: UX.DropDown.width, height: UX.DropDown.height)
//        dropDown.textAlignment = .center
//        dropDown.borderWidth = 1
//        dropDown.layer.cornerRadius = 20
//        return dropDown
//    }()
//
//
//    ///UITextField
//    lazy var toTextField:UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.keyboardType = UIKeyboardType.default
//        textField.returnKeyType = UIReturnKeyType.done
//        textField.autocorrectionType = UITextAutocorrectionType.no
//        textField.font = UIFont.systemFont(ofSize: UX.TitleLabel.font)
//        textField.borderStyle = UITextField.BorderStyle.roundedRect
//        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
//        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
//        let attributes = [
//            NSAttributedString.Key.foregroundColor: UIColor.gray,
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UX.TitleLabel.holder)
//        ]
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter receiver address", attributes:attributes)
//        return textField
//    }()
//
//    ///UIButton
//    private lazy var sendButton : UIButton = {
//        let button = UIButton()
//        button.setTitle("SEND", for: .normal)
//        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(self.sendBtnTapped), for: .touchUpInside)
//        button.clipsToBounds = true
//        button.layer.cornerRadius = UX.ButtonView.corner
//        button.isUserInteractionEnabled = true
//        return button
//    }()
//
//    ///UITextField
//    lazy var amountTextField:UITextField = {
//        let textField = UITextField()
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
//        textField.returnKeyType = UIReturnKeyType.done
//        textField.autocorrectionType = UITextAutocorrectionType.no
//        textField.font = UIFont.systemFont(ofSize: UX.TitleLabel.font)
//        textField.borderStyle = UITextField.BorderStyle.roundedRect
//        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
//        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
//        let attributes = [
//            NSAttributedString.Key.foregroundColor: UIColor.gray,
//            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UX.TitleLabel.holder)
//        ]
//        textField.attributedPlaceholder = NSAttributedString(string: "Enter amount", attributes:attributes)
//        return textField
//    }()
//
//    ///UIStackView
//    lazy var contentStackView: UIStackView = {
//        let spacer = UIView()
//        let stackView = UIStackView(arrangedSubviews: [titleLabel,dummyLabel,spacer])
//        stackView.alignment = .center
//        stackView.axis = .vertical
//        stackView.spacing = UX.ContainerView.spacing
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//
//    // MARK: - UI Properties
//    var containerViewHeightConstraint: NSLayoutConstraint?
//    var containerViewBottomConstraint: NSLayoutConstraint?
//
//    let defaultHeight: CGFloat = 400
//    let maxDimmedAlpha: CGFloat = 0.6
//    let dismissibleHeight: CGFloat = 300
//    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
//    var currentContainerHeight: CGFloat = 400
//
//    let bag = DisposeBag()
//    var single: Single<Account?>?
//    var data: [ConnectWalletModel] = []
//    var themeManager: ThemeManager?
//    var tokens = [TokenModel]()
//    var publicAddress = String()
//    var adapter: ConnectAdapter!
//
//    // MARK: - View Lifecycles
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        applyTheme()
//        addBlurEffect()
//        addTapGesture()
//        setupPanGesture()
//        setUpView()
//        setUpViewContraint()
//        setUpDropDownValue()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        animateShowDimmedView()
//        animatePresentContainer()
//    }
//
//    // MARK: - UI Methods
//    func applyTheme() {
//        view.backgroundColor = .clear
//        themeManager =  AppContainer.shared.resolve()
//        let theme = themeManager?.currentTheme
//        containerView.backgroundColor = theme?.colors.layer1
//        dimmedView.backgroundColor = .clear
//    }
//
//    func addBlurEffect(){
//        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
//        blurEffectView.frame = self.view.bounds
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        blurEffectView.alpha = 0.95
//        view.addSubview(blurEffectView)
//    }
//
//    func addTapGesture(){
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
//        dimmedView.addGestureRecognizer(tapGesture)
//    }
//    func setupPanGesture() {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
//        panGesture.delaysTouchesBegan = false
//        panGesture.delaysTouchesEnded = false
//        view.addGestureRecognizer(panGesture)
//    }
//
//    func setUpView(){
//        view.addSubview(containerView)
//        containerView.addSubview(contentStackView)
//        view.addSubview(dropDown)
//        view.addSubview(toLabel)
//        view.addSubview(amountLabel)
//        view.addSubview(toTextField)
//        view.addSubview(amountTextField)
//        view.addSubview(sendBtnView)
//        view.addSubview(sendButton)
//    }
//
//    func setUpViewContraint(){
//        NSLayoutConstraint.activate([
//
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.ContainerView.common),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.ContainerView.common),
//
//            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UX.ContainerStackView.top),
//            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: UX.ContainerStackView.bottom),
//            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UX.ContainerStackView.leading),
//            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: UX.ContainerStackView.trailing),
//
//            dropDown.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: UX.DropDown.top),
//            dropDown.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            dropDown.heightAnchor.constraint(equalToConstant:  UX.DropDown.heightC),
//            dropDown.widthAnchor.constraint(equalToConstant: UX.DropDown.widthC),
//
//
//            toLabel.topAnchor.constraint(equalTo: dropDown.bottomAnchor,constant: UX.ToLabel.top),
//            toLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:  UX.ToLabel.leading),
//
//            toTextField.topAnchor.constraint(equalTo: toLabel.bottomAnchor,constant: UX.TextField.common),
//            toTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.TextField.common),
//            toTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.TextField.common),
//
//            amountLabel.topAnchor.constraint(equalTo: toLabel.bottomAnchor,constant: UX.AmountLabel.top),
//            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.AmountLabel.leading),
//
//            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor,constant: UX.TextField.common),
//            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.TextField.common),
//            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.TextField.common),
//
//            sendBtnView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor,constant: UX.ButtonView.top),
//            sendBtnView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            sendBtnView.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
//            sendBtnView.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
//
//            sendButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor,constant: UX.ButtonView.top),
//            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            sendButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
//            sendButton.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
//
//        ])
//
//        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
//        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
//        containerViewHeightConstraint?.isActive = true
//        containerViewBottomConstraint?.isActive = true
//
//    }
//
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//    // MARK: - Objc Methodss
//
//    func setUpDropDownValue(){
//        for token in tokens {
//            dropDown.optionArray.append(token.symbol.uppercased())
//        }
//        dropDown.selectedIndex = 0
//        dropDown.text = tokens[0].symbol
//        dropDown.didSelect{(selectedText , index ,id) in
//        }
//    }
//
//
//    // MARK: - View Model Methods - Network actions
//    func sendNativeEVM(amountString: String,receiver: String,sender:String) {
//        SVProgressHUD.show()
//        WalletViewModel.shared.sendNativeEVM(amountString: amountString,sender:sender ,receiver: receiver){ result in
//            switch result {
//            case .success(let tokens):
//                print(tokens)
//                SVProgressHUD.dismiss()
//                self.dismiss(animated: true)
//            case .failure(let error):
//                print(error)
//                SVProgressHUD.dismiss()
//            }
//        }
//    }
//
//    // MARK: - Objc Methods
//
//    @objc func handleCloseAction() {
//        animateDismissView()
//    }
//
//    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: view)
//        let isDraggingDown = translation.y > 0
//        let newHeight = currentContainerHeight - translation.y
//        switch gesture.state {
//        case .changed:
//            if newHeight < maximumContainerHeight {
//                containerViewHeightConstraint?.constant = newHeight
//                view.layoutIfNeeded()
//            }
//        case .ended:
//            if newHeight < dismissibleHeight {
//                self.animateDismissView()
//            }
//            else if newHeight < defaultHeight {
//                animateContainerHeight(defaultHeight)
//            }
//            else if newHeight < maximumContainerHeight && isDraggingDown {
//                animateContainerHeight(defaultHeight)
//            }
//            else if newHeight > defaultHeight && !isDraggingDown {
//                animateContainerHeight(maximumContainerHeight)
//            }
//        default:
//            break
//        }
//    }
//
//    @objc func sendBtnTapped() {
//        if (toTextField.text != "" && amountTextField.text != ""){
//            sendNativeEVM(amountString: amountTextField.text!, receiver: toTextField.text!, sender: publicAddress)
//        }
//    }
//
//    func animateContainerHeight(_ height: CGFloat) {
//        UIView.animate(withDuration: 0.4) {
//            self.containerViewHeightConstraint?.constant = height
//            self.view.layoutIfNeeded()
//        }
//        currentContainerHeight = height
//    }
//
//    func animatePresentContainer() {
//        UIView.animate(withDuration: 0.3) {
//            self.containerViewBottomConstraint?.constant = 0
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    func animateShowDimmedView() {
//        dimmedView.alpha = 0
//        UIView.animate(withDuration: 0.4) {
//            self.dimmedView.alpha = self.maxDimmedAlpha
//        }
//    }
//
//    func animateDismissView() {
//        dimmedView.alpha = maxDimmedAlpha
//        UIView.animate(withDuration: 0.4) {
//            self.dimmedView.alpha = 0
//        } completion: { _ in
//            self.dismiss(animated: false)
//        }
//        UIView.animate(withDuration: 0.3) {
//            self.containerViewBottomConstraint?.constant = self.defaultHeight
//            self.view.layoutIfNeeded()
//        }
//    }
//}

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
            static let topTitleValue: CGFloat = 0

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
    private lazy var sendContentView: UIView = {
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
    var publicAddress : String = ""
    var tokensModel = [TokenModel]()
    
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
//        sendContentView.addSubview(qrImageView)
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
            
            ///User Token List View
            sendContentView.topAnchor.constraint(equalTo: contentView.bottomAnchor ,constant: UX.UserTokenView.top),
            sendContentView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor,constant: UX.UserTokenView.common),
            sendContentView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor,constant: -UX.UserTokenView.common),
            sendContentView.heightAnchor.constraint(equalToConstant: 340),
            
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
            sendTitleLabel.topAnchor.constraint(equalTo: actionsView.topAnchor,constant: UX.BalanceLabel.topTitleValue),
            
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
    
    
    @objc func sendBtnTapped (){
        helperMethodToAnimate(view: sendBtnView, button: sendButton)
        UIPasteboard.general.string = self.publicAddress
        SimpleToast().showAlertWithText("Copied!", bottomContainer: view, theme: themeManager!.currentTheme)
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
