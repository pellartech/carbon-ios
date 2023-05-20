//
//  ReceiveViewController.swift
//  Client
//
//  Created by Ashok on 03/05/23.
//

import Foundation
import UIKit
import ParticleAuthService
import ParticleNetworkBase
import RxSwift
import ParticleConnect
import ConnectCommon
import Common
import Shared

class ReceiveViewController: UIViewController {
    // MARK: - UI Constants
    private struct UX {
        struct TopBarView {
            static let corner: CGFloat = 2
            static let width: CGFloat = 76
            static let height: CGFloat = 4
            static let top: CGFloat = 15
        }
        struct ContainerView {
            static let corner: CGFloat = 16
            static let spacing: CGFloat = 12
            static let common: CGFloat = 10
     

        }

        struct TitleLabel{
            static let font: CGFloat = 15
        }
        struct AddressLabel{
            static let font: CGFloat = 15
            static let width: CGFloat = 250
            static let height: CGFloat = 30
        }

        struct QRCodeView {
            static let top: CGFloat = 170
            static let width: CGFloat = 200
            static let height: CGFloat = 200
        }
        
        struct ContainerStackView {
            static let top: CGFloat = 36
            static let leading: CGFloat = 40
            static let trailing: CGFloat = -40
            static let bottom: CGFloat = -20
        }
    }
    
    // MARK: - UI Elements
    ///UIView
    lazy var topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#6C6C6C")
        view.layer.cornerRadius = UX.TopBarView.corner
        view.clipsToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: UX.TopBarView.width, height:  UX.TopBarView.height)
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius =  UX.ContainerView.corner
        view.clipsToBounds = true
        return view
    }()
    
    lazy var dimmedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.alpha = maxDimmedAlpha
        return view
    }()
    
    ///UILabel
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "RECEIVE"
        label.font = .boldSystemFont(ofSize:  UX.TitleLabel.font)
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        return label
    }()
    
    var dummyLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: UX.TitleLabel.font)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 3
        label.font = .boldSystemFont(ofSize: UX.AddressLabel.font)
        label.frame  = CGRect(x: 0, y: 0, width: UX.AddressLabel.width, height: UX.AddressLabel.height)
        return label
    }()
    
    ///UIImageView
    private lazy var qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.frame = CGRect(x: 0, y: 0, width: UX.QRCodeView.width, height: UX.QRCodeView.height)
        return imageView
    }()
    
    ///UIStackView
    lazy var contentStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [titleLabel,addressLabel, dummyLabel,spacer])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = UX.ContainerView.spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - UI Properties
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    let defaultHeight: CGFloat = 400
    let maxDimmedAlpha: CGFloat = 0.6
    let dismissibleHeight: CGFloat = 300
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    var currentContainerHeight: CGFloat = 400
    
    let bag = DisposeBag()
    var single: Single<Account?>?
    var data: [ConnectWalletModel] = []
    var address = ""
    
    // MARK: - View Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        addBlurEffect()
        addTapGesture()
        setupPanGesture()
        setUpViewContraint()
        settingUpUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()
    }
    
    // MARK: - UI Methods
    func applyTheme() {
        view.backgroundColor = .clear
        let themeManager :  ThemeManager?
        themeManager =  AppContainer.shared.resolve()
        let theme = themeManager?.currentTheme
        containerView.backgroundColor = theme?.colors.layer1
        dimmedView.backgroundColor = .clear
    }
    
    func addBlurEffect(){
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.95
        view.addSubview(blurEffectView)
    }
    
    func addTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    func settingUpUI(){
        if let _ = data.first(where: { $0.walletType == .particle }) {
            accountModel[0].isConnected = true
        }
        if let _ = data.first(where: { $0.walletType == .metaMask }) {
            accountModel[1].isConnected = true
        }
        qrImageView.image = generateQRcode(value: self.address)
        addressLabel.text = "Public address: \(self.address)"
    }
    
    func setUpViewContraint() {
        view.addSubview(containerView)
        
        containerView.addSubview(topBarView)
        containerView.addSubview(contentStackView)
        containerView.addSubview(qrImageView)
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: containerView.topAnchor,constant: UX.TopBarView.top),
            topBarView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: UX.TopBarView.height),
            topBarView.widthAnchor.constraint(equalToConstant: UX.TopBarView.width),
            
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: UX.ContainerView.common),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -UX.ContainerView.common),
            
            qrImageView.topAnchor.constraint(equalTo: containerView.topAnchor,constant:  UX.QRCodeView.top),
            qrImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            qrImageView.widthAnchor.constraint(equalToConstant: UX.QRCodeView.width),
            qrImageView.heightAnchor.constraint(equalToConstant: UX.QRCodeView.height),
            
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UX.ContainerStackView.top),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: UX.ContainerStackView.bottom),
            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UX.ContainerStackView.leading),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: UX.ContainerStackView.trailing),
        ])
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    // MARK: - Objc Methodss
    @objc func handleCloseAction() {
        animateDismissView()
    }
    
    
    // MARK: - Helper Methods - Generate QR code
    func generateQRcode(value:String) -> UIImage?{
        let data = value.data(using: String.Encoding.isoLatin1)
        if let filter = CIFilter(name: "CIQRCodeGenerator"){
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            let transform = CGAffineTransform(scaleX: 200, y: 200)
            if let output = filter.outputImage?.transformed(by: transform){
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    // MARK: - Objc Methods
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let isDraggingDown = translation.y > 0
        let newHeight = currentContainerHeight - translation.y
        switch gesture.state {
        case .changed:
            if newHeight < maximumContainerHeight {
                containerViewHeightConstraint?.constant = newHeight
                view.layoutIfNeeded()
            }
        case .ended:
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            self.containerViewHeightConstraint?.constant = height
            self.view.layoutIfNeeded()
        }
        currentContainerHeight = height
    }
    
    func animatePresentContainer() {
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }
    
    func animateDismissView() {
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false)
        }
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            self.view.layoutIfNeeded()
        }
    }
}
