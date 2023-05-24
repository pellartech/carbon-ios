//  WalletGetStartedViewController.swift
//  Example
//
//  Created by Ashok on 22/05/23.
//

import Foundation
import UIKit
import Common
import Shared

class WalletGetStartedViewController: UIViewController {
    
    // MARK: - UI Constants
    private struct UX {
        
        struct LogoView {
            static let top: CGFloat = 60
            static let width: CGFloat = 220
            static let height: CGFloat = 46
            static let heightBg: CGFloat = 120
            static let top1: CGFloat = 0
            static let imageHeight: CGFloat = 80
            static let widthMiddle: CGFloat = 300
        }
        struct WalletLabel {
            static let font: CGFloat = 20
            static let font1: CGFloat = 28
                    }
        struct Wallet {
            static let top: CGFloat = 15
            static let leading: CGFloat = 2
            static let width: CGFloat = 65
            static let height: CGFloat = 16
            static let width1: CGFloat = 120
            static let height1: CGFloat = 35
            static let leading1: CGFloat = 2
            static let top1: CGFloat = 2
            
        }
        struct LogoImageView {
            static let height: CGFloat = 32
            static let width: CGFloat = 32
            static let height1: CGFloat = 60
            static let width1: CGFloat = 60
            static let leading: CGFloat = -80
            static let carbonLeading: CGFloat = 30
        }
        struct CarbonImageView {
            static let leading: CGFloat = 10
            static let width: CGFloat = 123
            static let height: CGFloat = 30
            static let top: CGFloat = -10
            static let leading1: CGFloat = 20
            static let width1: CGFloat = 137
            static let height1: CGFloat = 33
        }
        
        struct DescriptionLabel {
            static let top: CGFloat = 30
            static let font: CGFloat = 12
            static let width: CGFloat = 290
            static let height: CGFloat = 65
            
        }
        
        struct ButtonView {
            static let top: CGFloat = 50
            static let centerX: CGFloat = 90
            static let height: CGFloat = 50
            static let width: CGFloat = 163
            static let font: CGFloat = 14
            static let corner: CGFloat = 10
            static let leading: CGFloat = 30
        }
        
    }
    // MARK: - UI Elements
    
    ///UIView
    private lazy var logoView : UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var middleLogoView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var logoBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var startBtnView: GradientView = {
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
    
    private lazy var middleLogoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_carbon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var middleCarbonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_carbon_text")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var walletImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "carbon_wallet")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var walletImageView2: UIImageView = {
        let imageView = UIImageView()
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
    private lazy var middleWalletLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: UX.WalletLabel.font1)
        label.textAlignment = .center
        label.text = "wallet"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = .systemFont(ofSize: UX.DescriptionLabel.font)
        label.textAlignment = .center
        label.text = "Remember that you have to send only Carbon $CSIX (BEP29( on this address. Sending any other token can be a mistake and you can lose all your tokens that you send in this transaction"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 4
        return label
    }()
    
    ///UIButton
    private lazy var startButton : UIButton = {
        let button = UIButton()
        button.setTitle("START", for: .normal)
        button.titleLabel?.font =  UIFont.boldSystemFont(ofSize: UX.ButtonView.font)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.btnIhaveWalletsTapped), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = UX.ButtonView.corner
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
    
    private lazy var contentView : UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()
    
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpViewContraint()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        applyTheme()
    }
    
    func applyTheme() {
        navigationController?.isNavigationBarHidden = true
        let themeManager :  ThemeManager?
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        view.backgroundColor = theme?.colors.layer1
    }
    
    // MARK: - UI Methods
    func setUpView(){        
        view.addSubview(logoBackgroundView)
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        
        logoView.addSubview(logoImageView)
        logoView.addSubview(carbonImageView)
        logoView.addSubview(walletLabel)
        logoBackgroundView.addSubview(logoView)
        middleLogoView.addSubview(middleLogoImageView)
        middleLogoView.addSubview(middleCarbonImageView)
        middleLogoView.addSubview(middleWalletLabel)
        
        contentView.addSubview(walletImageView)
        contentView.addSubview(middleLogoView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(startBtnView)
        contentView.addSubview(startButton)
        contentView.addSubview(walletImageView2)
    }
    
    func setUpViewContraint(){
        NSLayoutConstraint.activate([
            
            ///Scroll
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor,constant: 120),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            ///Top bar
            logoView.topAnchor.constraint(equalTo: view.topAnchor,constant: UX.LogoView.top),
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.widthAnchor.constraint(equalToConstant: UX.LogoView.width),
            logoView.heightAnchor.constraint(equalToConstant: UX.LogoView.height),
            
            logoBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            logoBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoBackgroundView.widthAnchor.constraint(equalTo: view.widthAnchor),
            logoBackgroundView.heightAnchor.constraint(equalToConstant: UX.LogoView.heightBg),
            
            logoImageView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoView.topAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: UX.LogoImageView.width),
            logoImageView.heightAnchor.constraint(equalToConstant: UX.LogoImageView.height),
            
            carbonImageView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor,constant: UX.CarbonImageView.leading),
            carbonImageView.topAnchor.constraint(equalTo: logoView.topAnchor),
            carbonImageView.widthAnchor.constraint(equalToConstant: UX.CarbonImageView.width),
            carbonImageView.heightAnchor.constraint(equalToConstant: UX.CarbonImageView.height),
            
            walletLabel.leadingAnchor.constraint(equalTo: carbonImageView.trailingAnchor,constant: UX.Wallet.leading),
            walletLabel.topAnchor.constraint(equalTo: logoView.topAnchor,constant:  UX.Wallet.top),
            walletLabel.widthAnchor.constraint(equalToConstant: UX.Wallet.width),
            walletLabel.heightAnchor.constraint(equalToConstant: UX.Wallet.height),
            
            ///Wallet Image
            walletImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            walletImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            walletImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            walletImageView.heightAnchor.constraint(equalToConstant: (view.frame.size.height/2) - UX.LogoView.imageHeight),
            
            
            ///Middle LogoView
            middleLogoView.topAnchor.constraint(equalTo: walletImageView.bottomAnchor,constant: UX.LogoView.top1),
            middleLogoView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            middleLogoView.widthAnchor.constraint(equalToConstant: UX.LogoView.widthMiddle),
            middleLogoView.heightAnchor.constraint(equalToConstant: UX.LogoView.height),
            
            middleLogoImageView.topAnchor.constraint(equalTo: middleLogoView.topAnchor),
            middleLogoImageView.centerXAnchor.constraint(equalTo: middleLogoView.centerXAnchor,constant: UX.LogoImageView.leading),
            middleLogoImageView.widthAnchor.constraint(equalToConstant: UX.LogoImageView.width1),
            middleLogoImageView.heightAnchor.constraint(equalToConstant: UX.LogoImageView.height1),
            
            middleCarbonImageView.leadingAnchor.constraint(equalTo: middleLogoImageView.trailingAnchor,constant: UX.CarbonImageView.leading1),
            middleCarbonImageView.topAnchor.constraint(equalTo: middleLogoView.topAnchor,constant: UX.CarbonImageView.top),
            middleCarbonImageView.widthAnchor.constraint(equalToConstant: UX.CarbonImageView.width1),
            middleCarbonImageView.heightAnchor.constraint(equalToConstant: UX.CarbonImageView.height1),
            
            middleWalletLabel.leadingAnchor.constraint(equalTo: middleLogoImageView.trailingAnchor,constant: UX.Wallet.leading1),
            middleWalletLabel.topAnchor.constraint(equalTo: middleCarbonImageView.bottomAnchor,constant:  UX.Wallet.top1),
            middleWalletLabel.widthAnchor.constraint(equalToConstant: UX.Wallet.width1),
            middleWalletLabel.heightAnchor.constraint(equalToConstant: UX.Wallet.height1),
            
            
            ///Description Label
            descriptionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: middleLogoView.bottomAnchor,constant:  UX.DescriptionLabel.top),
            descriptionLabel.widthAnchor.constraint(equalToConstant: UX.DescriptionLabel.width),
            descriptionLabel.heightAnchor.constraint(equalToConstant: UX.DescriptionLabel.height),
            
            
            ///Create button
            startBtnView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant:UX.ButtonView.top),
            startBtnView.widthAnchor.constraint(equalToConstant:  UX.ButtonView.width),
            startBtnView.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            startBtnView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:UX.ButtonView.leading),
            startBtnView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant:-UX.ButtonView.leading),

            startButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: UX.ButtonView.top),
            startButton.widthAnchor.constraint(equalToConstant: UX.ButtonView.width),
            startButton.heightAnchor.constraint(equalToConstant:  UX.ButtonView.height),
            startButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:UX.ButtonView.leading),
            startButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant:-UX.ButtonView.leading),
            
            walletImageView2.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            walletImageView2.topAnchor.constraint(equalTo: startBtnView.bottomAnchor),
            walletImageView2.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            walletImageView2.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
        ])
    }
    
    // MARK: - Objc Methods
    @objc func closeBtnTapped (){
        self.dismiss(animated: true)
    }
    
    @objc func btnIhaveWalletsTapped (){
        let addWalletVC = AddWalletViewController()
        addWalletVC.delegate = self
        self.navigationController?.pushViewController(addWalletVC, animated: true)
    }
}

extension WalletGetStartedViewController : AddWalletProtocol{
    func addWalletDelegate() {
        let walletVC = WalletViewController()
        self.navigationController?.pushViewController(walletVC, animated: true)
    }
}
