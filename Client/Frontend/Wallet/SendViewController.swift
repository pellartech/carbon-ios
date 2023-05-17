//
//  SendViewController.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//

import Foundation
import UIKit
import SVProgressHUD
import ParticleWalletAPI
import iOSDropDown
import ParticleAuthService
import ParticleNetworkBase
import RxSwift
import ConnectCommon
import ParticleConnect
import Common
import Shared

class SendViewController: UIViewController {
    
    // MARK: - UI Constants
    private struct UX {
        struct DropDown {
            static let width: CGFloat = 120
            static let height: CGFloat = 200
            static let top: CGFloat = 20
            static let widthC: CGFloat = 120
            static let heightC: CGFloat = 40
        }
        
        struct TitleLabel{
            static let font: CGFloat = 25
            static let holder: CGFloat = 15
            static let top: CGFloat = 20
            static let height: CGFloat = 50

        }
        struct TokenLabel{
            static let font: CGFloat = 20
        }
        struct ToLabel{
            static let top: CGFloat = 30
            static let leading: CGFloat = 20
        }
        struct AmountLabel{
            static let top: CGFloat = 100
            static let leading: CGFloat = 20
        }
        struct ButtonView {
            static let corner: CGFloat = 15
            static let font: CGFloat = 14
            static let top: CGFloat = 80
            static let height: CGFloat = 50
            static let width: CGFloat = 163
        }
        struct TextField {
            static let common: CGFloat = 20
    
        }
    }

    // MARK: - UI Elements
    private lazy var sendBtnView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = UX.ButtonView.corner
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    ///UILabel
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SEND"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: UX.TitleLabel.font)
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        return label
    }()
    
    var tokenLabel: UILabel = {
        let label = UILabel()
        label.text = "ETH"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: UX.TokenLabel.font)
        label.textColor = UIColor.white
        return label
    }()
    
    var toLabel: UILabel = {
        let label = UILabel()
        label.text = "To"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize:  UX.TokenLabel.font)
        label.textColor = UIColor.white
        return label
    }()
    var amountLabel: UILabel = {
        let label = UILabel()
        label.text = "Amount"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize:  UX.TokenLabel.font)
        label.textColor = UIColor.white
        return label
    }()
    
    ///DropDown
    var dropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.backgroundColor = UIColor.clear
        dropDown.rowBackgroundColor = Utilities().hexStringToUIColor(hex: "#5B5B65")
        dropDown.textColor =  Utilities().hexStringToUIColor(hex: "#FF581A")
        dropDown.itemsColor = UIColor.white
        dropDown.tintColor = Utilities().hexStringToUIColor(hex: "#FF581A")
        dropDown.itemsTintColor =  Utilities().hexStringToUIColor(hex: "#FF581A")
        dropDown.selectedRowColor = Utilities().hexStringToUIColor(hex: "#5B5B65")
        dropDown.borderColor = Utilities().hexStringToUIColor(hex: "#5B5B65")
        dropDown.arrowColor = UIColor.clear
        dropDown.isSearchEnable = false
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        dropDown.font = .boldSystemFont(ofSize:  UX.TokenLabel.font)
        dropDown.frame = CGRect(x: 0, y: 0, width: UX.DropDown.width, height: UX.DropDown.height)
        dropDown.textAlignment = .center
        dropDown.borderWidth = 1
        dropDown.layer.cornerRadius = 20
        return dropDown
    }()
    
    
    ///UITextField
    lazy var toTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: UX.TitleLabel.font)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UX.TitleLabel.holder)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Enter receiver address", attributes:attributes)
        return textField
    }()
    
    ///UIButton
    private lazy var sendButton : UIButton = {
        let button = UIButton()
        button.setTitle("SEND", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.sendBtnTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
        button.isUserInteractionEnabled = true
        return button
    }()
    
    ///UITextField
    lazy var amountTextField:UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.numbersAndPunctuation
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: UX.TitleLabel.font)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.gray,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: UX.TitleLabel.holder)
        ]
        textField.attributedPlaceholder = NSAttributedString(string: "Enter amount", attributes:attributes)
        return textField
    }()
    
    // MARK: - UI Properties
    var tokens = [TokenModel]()
    var publicAddress = String()
    let bag = DisposeBag()
    var adapter: ConnectAdapter!
    let viewModel = WalletViewModel()
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        setUpView()
        setUpViewContraint()
        setUpDropDownValue()
    }
    
    // MARK: - UI Methods
    
    func applyTheme() {
        let themeManager :  ThemeManager?
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    func setUpView(){
        view.addSubview(titleLabel)
        view.addSubview(dropDown)
        view.addSubview(toLabel)
        view.addSubview(amountLabel)
        view.addSubview(toTextField)
        view.addSubview(amountTextField)
        view.addSubview(sendBtnView)
        view.addSubview(sendButton)
    }
    
    func setUpViewContraint(){
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.TitleLabel.top),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.TitleLabel.height),
            
            dropDown.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: UX.DropDown.top),
            dropDown.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dropDown.heightAnchor.constraint(equalToConstant:  UX.DropDown.heightC),
            dropDown.widthAnchor.constraint(equalToConstant: UX.DropDown.widthC),
            
            
            toLabel.topAnchor.constraint(equalTo: dropDown.bottomAnchor,constant: UX.ToLabel.top),
            toLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant:  UX.ToLabel.leading),
            
            toTextField.topAnchor.constraint(equalTo: toLabel.bottomAnchor,constant: UX.TextField.common),
            toTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.TextField.common),
            toTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.TextField.common),
            
            amountLabel.topAnchor.constraint(equalTo: toLabel.bottomAnchor,constant: UX.AmountLabel.top),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.AmountLabel.leading),
            
            amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor,constant: UX.TextField.common),
            amountTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.TextField.common),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.TextField.common),
            
            sendBtnView.topAnchor.constraint(equalTo: amountTextField.bottomAnchor,constant: UX.ButtonView.top),
            sendBtnView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendBtnView.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            sendBtnView.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
            
            sendButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor,constant: UX.ButtonView.top),
            sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            sendButton.heightAnchor.constraint(equalToConstant: UX.ButtonView.height),
            
        ])
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUpDropDownValue(){
        for token in tokens {
            dropDown.optionArray.append(token.symbol)
        }
        dropDown.selectedIndex = 0
        dropDown.text = tokens[0].symbol
        dropDown.didSelect{(selectedText , index ,id) in
        }
    }
    // MARK: - Objc Methods - Button actions
    @objc func sendBtnTapped() {
        if (toTextField.text != "" && amountTextField.text != ""){
            switch dropDown.text{
            case  "ETH": sendNativeEVM(amountString: amountTextField.text!, receiver: toTextField.text!, sender: publicAddress)
            default : sendNativeEVM(amountString: amountTextField.text!, receiver: toTextField.text!, sender: publicAddress)
            }
        }
    }
    
    // MARK: - View Model Methods - Network actions
    func sendNativeEVM(amountString: String,receiver: String,sender:String) {
        SVProgressHUD.show()
        self.viewModel.sendNativeEVM(amountString: amountString,sender:sender ,receiver: receiver){ result in
            switch result {
            case .success(let tokens):
                print(tokens)
                SVProgressHUD.dismiss()
                self.dismiss(animated: true)
            case .failure(let error):
                print(error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func sendERC20Token(amountString: String,receiver: String,sender:String) {
        SVProgressHUD.show()
        let filterToken = tokens.filter {
            $0.tokenInfo.name == self.dropDown.text!
        }
        self.viewModel.sendERC20Token(amountString: amountString,sender: sender, receiver: receiver, filterToken: filterToken[0]){ result in
            switch result {
            case .success(let tokens):
                print(tokens)
                SVProgressHUD.dismiss()
                self.dismiss(animated: true)
            case .failure(let error):
                print(error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
}
