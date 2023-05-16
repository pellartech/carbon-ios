//
//  TokensTVCell.swift
//  Client
//
//  Created by Ashok on 14/05/23.
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

class TokensTVCell: UITableViewCell {
    
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
            static let valueWidth: CGFloat = 150
            static let valueHeight: CGFloat = 30
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
    private lazy var valueLabel : UILabel = {
        let label = UILabel()
        label.textColor =  UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var valueAtLabel : UILabel = {
        let label = UILabel()
        label.textColor = Utilities().hexStringToUIColor(hex: "#818181")
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.fontAt)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    private var wallpaperManager =  WallpaperManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        iconView.addSubview(iconImageView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(valueAtLabel)
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
            
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Value.top),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
            valueLabel.widthAnchor.constraint(equalToConstant: UX.Value.valueWidth),
            valueLabel.heightAnchor.constraint(equalToConstant: UX.Value.valueHeight),

            valueAtLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor,constant: UX.Value.topAt),
            valueAtLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.trailing),
        ]
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(token : TokenModel){
        let value = toEther(wei: token.amount)
        titleLabel.text = token.tokenInfo.name
        valueLabel.text = "\(value) \(token.tokenInfo.symbol)"
        if #available(iOS 15.0, *) {
            valueAtLabel.text = value.formatted(.currency(code: "USD"))
        }
        
        if (token.tokenInfo.logoURI != ""){
            iconImageView.sd_setImage(with: URL(string: token.imageUrl)!)
        }else{
            var defaultImage = ""
            switch token.tokenInfo.symbol {
            case "ETH":
                defaultImage = "ic_eth"
                iconImageView.image = UIImage(named: defaultImage)
            case "USDC":
                defaultImage = "ic_usdc"
                iconImageView.image = UIImage(named: defaultImage)
            case "USDT":
                defaultImage = "ic_usdt"
                iconImageView.image = UIImage(named: defaultImage)
            case "WETH":
                defaultImage = "ic_weth"
                iconImageView.image = UIImage(named: defaultImage)
            default: break
            }
        }
    }
    
    
    func toEther(wei: BInt) -> Decimal {
        let etherInWei = pow(Decimal(10), 18)
        if let decimalWei = Decimal(string: wei.description){
            return decimalWei / etherInWei
        }else{
            return Decimal()
        }
    }
    
}


