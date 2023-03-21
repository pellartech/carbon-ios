// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import UIKit

class HomeLogoHeaderCell: UICollectionViewCell, ReusableCell,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate, UITableViewDataSource{
    private struct UX {
        struct StatsView {
            static let constant: CGFloat = 10
            static let topConstant: CGFloat = 20
            static let viewHeight: CGFloat = 85.2
            static let radius: CGFloat = 15
            static let shadowRadius: CGFloat = 4
            static let shadowOffset = CGSize(width: 0, height: 2)
            static let shadowOpacity: Float = 1
            static let alpha: CGFloat = 0.3

        }
        
        struct DataView {
            static let constant: CGFloat = 20
            static let topConstant: CGFloat = 20
            static let viewHeight: CGFloat = 85.2
            static let leadingConstant: CGFloat = 10
            static let trailingConstant: CGFloat = -20
            static let radius: CGFloat = 15
            static let alpha: CGFloat = 0.3

        }
        struct ComingSoonView {
            static let constant: CGFloat = 10
            static let viewHeight: CGFloat = 140
            static let trailingConstant: CGFloat = -10
            static let radius: CGFloat = 15
            static let alpha: CGFloat = 0.3

        }
        
        struct StatsTitleLabel {
            static let font: CGFloat = 10
            static let centerYAnchor: CGFloat = -30
            static let width: CGFloat = 100
            static let height: CGFloat = 50
        }
        struct CardTitleLabel {
            static let font: CGFloat = 13
            static let centerYAnchor: CGFloat = -25
            static let width: CGFloat = 120
            static let height: CGFloat = 50
            static let YAnchor: CGFloat = -45
        }
        struct CollectionView {
            static let leadingAnchor: CGFloat = 35
            static let topAnchor: CGFloat = 20
            static let width: CGFloat = -30
            static let leading: CGFloat = 10
            static let widthAnchor: CGFloat = -10

        }
    }
    

    // MARK: - UI Elements
    
    ///UIView
    private lazy var statsView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent( UX.StatsView.alpha)
        view.layer.cornerRadius = UX.StatsView.radius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private lazy var dataView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(UX.DataView.alpha)
        view.layer.cornerRadius = UX.DataView.radius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private lazy var comingSoonView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(UX.ComingSoonView.alpha)
        view.layer.cornerRadius = UX.ComingSoonView.radius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    
    ///UILabel
    private lazy var statsTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.StatsTitleLabel.font)
        label.text = "Your Carbon Stats"
        label.translatesAutoresizingMaskIntoConstraints = false
        statsView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: statsView.centerYAnchor, constant: UX.StatsTitleLabel.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: UX.StatsTitleLabel.width),
            label.heightAnchor.constraint(equalToConstant: UX.StatsTitleLabel.height)])
        return label
    }()
    
 
    private lazy var cardTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.CardTitleLabel.font)
        label.text = "COMING SOON"
        label.translatesAutoresizingMaskIntoConstraints = false
        statsView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: statsView.centerYAnchor, constant: UX.CardTitleLabel.centerYAnchor),
            label.widthAnchor.constraint(equalToConstant: UX.CardTitleLabel.width),
            label.heightAnchor.constraint(equalToConstant: UX.CardTitleLabel.height)])
        return label
    }()
    
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        tableView.register(DataTableCell.self, forCellReuseIdentifier:"DataTableCell")
        return tableView
    }()
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ComingSoonCollectionCell.self, forCellWithReuseIdentifier: "ComingSoonCollectionCell")
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var statsCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(StatsCollectionCell.self, forCellWithReuseIdentifier: "StatsCollectionCell")
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    

    
    // MARK: - Variables
    private  var dataModel = [DataModel(title: "Data Saved", value: "2MB"),DataModel(title: "Tracker & Ads Blocked", value: "5"),DataModel(title: "Searches", value: "19")]
    
    private var statsModel = [StatsModel(title: "Wallet", icon:"ic_wallet"),StatsModel(title: "Staking", icon: "ic_stacking"),StatsModel(title: "Swap", icon: "ic_swap"),StatsModel(title: "Bridge", icon: "ic_bridge")]
    
    private  var earnedModel = [DataModel(title: "Earned Today", value: "2"),DataModel(title: "Earned Total", value: "10")]
  
    private var wallpaperManager =  WallpaperManager()

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    func setupView() {
        statsView.addSubview(statsTitleLabel)
        statsView.addSubview(statsCollectionView)

        dataView.addSubview(tableView)
        comingSoonView.addSubview(cardTitleLabel)
        comingSoonView.addSubview(collectionView)
        
        contentView.addSubview(statsView)
        contentView.addSubview(dataView)
        contentView.addSubview(comingSoonView)
        
        NSLayoutConstraint.activate([
            statsView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                           constant: UX.StatsView.topConstant),
            statsView.widthAnchor.constraint(equalToConstant: contentView.frame.width/2 -  UX.StatsView.constant),
            statsView.heightAnchor.constraint(equalToConstant: UX.StatsView.viewHeight),
            statsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            dataView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.DataView.topConstant),
            dataView.widthAnchor.constraint(equalToConstant: contentView.frame.width/2 -  UX.DataView.constant),
            dataView.heightAnchor.constraint(equalToConstant: UX.DataView.viewHeight),
            statsView.leadingAnchor.constraint(equalTo: dataView.trailingAnchor , constant: UX.DataView.leadingConstant),
            dataView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: UX.DataView.trailingConstant),
            
            comingSoonView.topAnchor.constraint(equalTo: dataView.bottomAnchor,constant: UX.ComingSoonView.constant),
            comingSoonView.widthAnchor.constraint(equalToConstant: contentView.frame.width - UX.DataView.constant),
            comingSoonView.heightAnchor.constraint(equalToConstant: UX.ComingSoonView.viewHeight),
            comingSoonView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: dataView.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: dataView.topAnchor),
            tableView.widthAnchor.constraint(equalTo: dataView.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: dataView.heightAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: comingSoonView.leadingAnchor,constant: UX.CollectionView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: comingSoonView.topAnchor,constant: UX.CollectionView.topAnchor),
            collectionView.widthAnchor.constraint(equalTo: comingSoonView.widthAnchor,constant: UX.CollectionView.width),
            collectionView.heightAnchor.constraint(equalTo: comingSoonView.heightAnchor),
            
            statsCollectionView.leadingAnchor.constraint(equalTo: statsView.leadingAnchor,constant: UX.CollectionView.leading),
            statsCollectionView.topAnchor.constraint(equalTo: statsView.topAnchor),
            statsCollectionView.widthAnchor.constraint(equalTo: statsView.widthAnchor,constant: UX.CollectionView.widthAnchor),
            statsCollectionView.heightAnchor.constraint(equalTo: statsView.heightAnchor),
            
            cardTitleLabel.centerXAnchor.constraint(equalTo: comingSoonView.centerXAnchor),
            cardTitleLabel.centerYAnchor.constraint(equalTo: comingSoonView.centerYAnchor,constant: UX.CardTitleLabel.YAnchor),
        ])
    }


// MARK: - UICollectionView Delegate & DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == statsCollectionView ? earnedModel.count :statsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == statsCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCollectionCell", for: indexPath) as! StatsCollectionCell
            cell.setUI(data: earnedModel[indexPath.row])
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComingSoonCollectionCell", for: indexPath) as! ComingSoonCollectionCell
            cell.setUI(data: statsModel[indexPath.row],index: indexPath.row)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == statsCollectionView ? CGSize(width:(collectionView.frame.width/2) - 5, height: 50) : CGSize(width: 65, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == statsCollectionView ? 30 : 25
    }


// MARK: - UITableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataTableCell", for: indexPath) as! DataTableCell
        cell.setUI(data: dataModel[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
}

// MARK: - UITableViewCell
class DataTableCell: UITableViewCell {
    
    private struct UX {
        struct Title {
            static let font: CGFloat = 10
            static let top: CGFloat = 12
            static let leading: CGFloat = 10
            static let height: CGFloat = 10
        }
        struct Value {
            static let font: CGFloat = 10
            static let top: CGFloat = 10
            static let trailing: CGFloat = -15
            static let height: CGFloat = 10
            static let width: CGFloat = 30
        }
    }
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.Title.font)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var valueLabel : UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize:  UX.Value.font)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var wallpaperManager =  WallpaperManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Title.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.Title.leading),
            titleLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width/2),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Title.height),
            
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Value.top),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor,constant: UX.Value.trailing),
            valueLabel.widthAnchor.constraint(equalToConstant: UX.Value.width),
            valueLabel.heightAnchor.constraint(equalToConstant: UX.Value.height)])
    }
    
    func setUI(data : DataModel){
        titleLabel.text = data.title
        valueLabel.text = data.value
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UICollectionViewCell
class ComingSoonCollectionCell: UICollectionViewCell {
    
    private struct UX {
        struct IconView {
            static let top: CGFloat = 10
            static let height: CGFloat = 56
            static let width: CGFloat = 56
        }
        struct Icon {
            static let width1: CGFloat = 30
            static let height1: CGFloat = 35
            
            static let width2: CGFloat = 34
            static let height2: CGFloat = 34

            static let width3: CGFloat = 33
            static let height3: CGFloat = 33
            
            static let width4: CGFloat = 31
            static let height4: CGFloat = 31
        }
        struct Value {
            static let font: CGFloat = 10
            static let top: CGFloat = 10
            static let height: CGFloat = 10
            static let width: CGFloat = 56
        }
    }
    private lazy var iconView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
    }()
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.Value.font)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var wallpaperManager =  WallpaperManager()

    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView.addSubview(iconImageView)
        addSubview(iconView)
        addSubview(titleLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iconView.widthAnchor.constraint(equalToConstant:  UX.IconView.width),
            iconView.heightAnchor.constraint(equalToConstant:   UX.IconView.height),
            iconImageView.centerXAnchor.constraint(equalTo:  iconView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo:  iconView.centerYAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor,constant: UX.Value.top),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: UX.Value.width),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.Value.height)
        ])
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        iconView.setGradientBackground()
    }
    func setUI(data : StatsModel,index : Int){
        iconImageView.image = UIImage(named: data.icon!)
        titleLabel.text = data.title
        switch index {
        case 0:
            setUIForImage(width: UX.Icon.width1, height: UX.Icon.height1)
        case 1:
            setUIForImage(width: UX.Icon.width2, height: UX.Icon.height2)
        case 2:
            setUIForImage(width: UX.Icon.width3, height: UX.Icon.height3)
        case 3:
            setUIForImage(width: UX.Icon.width4, height: UX.Icon.height4)
        default:
            break
        }
    }
    func setUIForImage(width: CGFloat, height: CGFloat){
        iconImageView.widthAnchor.constraint(equalToConstant: width).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
class StatsCollectionCell: UICollectionViewCell {
    
    private struct UX {
        struct Value {
            static let font: CGFloat = 20
            static let top: CGFloat = 10
            static let height: CGFloat = 30
            static let width: CGFloat = 70
        }
        struct ValueTitle {
            static let font: CGFloat = 10
            static let top: CGFloat = -10
            static let height: CGFloat = 50
            static let width: CGFloat = 70
            
        }
    }
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .orange
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: UX.Value.font)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var valueTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.ValueTitle.font)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var wallpaperManager =  WallpaperManager()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(valueLabel)
        addSubview(valueTitleLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.Value.top),
            valueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant:  UX.Value.width),
            valueLabel.heightAnchor.constraint(equalToConstant:  UX.Value.height),
    
            valueTitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor,constant: UX.ValueTitle.top),
            valueTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            valueTitleLabel.widthAnchor.constraint(equalToConstant: UX.ValueTitle.width),
            valueTitleLabel.heightAnchor.constraint(equalToConstant: UX.ValueTitle.height)

        ])
    }
    func setUI(data : DataModel){
        valueLabel.text = data.value
        valueTitleLabel.text = data.title
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Models
class DataModel {
    
    var title: String?
    var value: String?
    
    init(title: String?,value: String?){
        self.title = title
        self.value = value
    }
}

class StatsModel {
    
    var title: String?
    var icon: String?
    
    init(title: String?,icon: String?){
        self.title = title
        self.icon = icon
    }
}

extension UIView{
    func setGradientBackground() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 141.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 6.0/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.frame
        self.layer.insertSublayer(gradientLayer, at:0)
    }
}
