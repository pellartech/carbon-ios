//
//  DrawerTVCell.swift
//  Client
//
//  Created by Ashok on 14/05/23.
//

import Foundation
import UIKit

class DrawerTVCell: UITableViewCell {
    
    // MARK: - UI Constants
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
            static let font: CGFloat = 16
            static let top: CGFloat = 10
            static let leading: CGFloat = 80
            static let height: CGFloat = 30
        }
        struct Value {
            static let font: CGFloat = 12
            static let fontAt: CGFloat = 12
            static let top: CGFloat = 20
            static let topAt: CGFloat = 0
            static let trailing: CGFloat = -15
            static let height: CGFloat = 20
            static let width: CGFloat = 50
            static let connectTrailing: CGFloat = -20
            
        }
    }
    // MARK: - UI Elements
    
    ///UIView
    private lazy var iconView: UIView = {
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
        label.font = UIFont.systemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var valueLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .left
        label.numberOfLines = 5
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    ///UIImageView
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
   
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpView()
        setUpViewConstraint()
    }
    
    // MARK: - UI Methods
    func setUpView(){
        iconView.addSubview(iconImageView)
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func setUpViewConstraint(){
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Icon.top),
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Icon.leading),
            iconImageView.widthAnchor.constraint(equalToConstant: UX.Icon.width),
            iconImageView.heightAnchor.constraint(equalToConstant: UX.Icon.height),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Title.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant: UX.Value.topAt),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: UX.Value.connectTrailing),
            
        ]
        )
    }
    
    func setUI(model : ConnectWalletModel){
        titleLabel.text = model.name
        if let imageUrl = URL(string: model.walletType.imageName) {
            iconImageView.sd_setImage(with: imageUrl)
        }
        valueLabel.text = "Public address: \(model.publicAddress)"
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
