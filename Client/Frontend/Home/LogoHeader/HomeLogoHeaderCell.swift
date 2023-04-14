// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Shared
import UIKit

protocol FeatureCardProtocol{
    func cardItemTapped(data: FeatureModel,isLongPress: Bool)
}
class HomeLogoHeaderCell: UICollectionViewCell, ReusableCell,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate{
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
            static let featureViewHeight: CGFloat = 144
            static let stackViewHeight: CGFloat = 174
            static let trailingConstant: CGFloat = -10
            static let radius: CGFloat = 15
            static let alpha: CGFloat = 0.3
            static let viewMoreBottom: CGFloat = -12
            static let viewMoreWidth: CGFloat = 100
            static let viewMoreHeight: CGFloat = 24
            static let viewMoreRadius: CGFloat = 12

        }
        struct StatsTitleLabel {
            static let font: CGFloat = 10
            static let centerYAnchor: CGFloat = -30
            static let width: CGFloat = 100
            static let height: CGFloat = 50
        }
        struct CardTitleLabel {
            static let width: CGFloat = 98
            static let height: CGFloat = 18
            static let YAnchor: CGFloat = -45
            static let font : CGFloat = 13
            static let viewMoreFont : CGFloat = 10
            static let viewMoreYAnchor: CGFloat = -50
        }
        struct CollectionView {
            static let leadingAnchor: CGFloat = 30
            static let topAnchor: CGFloat = 10
            static let trailingAnchor: CGFloat = -30
            static let leading: CGFloat = 10
            static let widthAnchor: CGFloat = -10
            static let featuretopAnchor: CGFloat = 5

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
    
    private lazy var stackView : UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.clear
        view.layer.cornerRadius = UX.ComingSoonView.radius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    private lazy var featureView : UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.black.withAlphaComponent(UX.ComingSoonView.alpha)
        view.layer.cornerRadius = UX.ComingSoonView.radius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    } ()
    
    ///UIButton
    private lazy var viewMoreBtn : UIButton = {
        let button = UIButton()
        button.isUserInteractionEnabled = true
        button.layer.cornerRadius = UX.ComingSoonView.viewMoreRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("VIEW MORE", for: .normal)
        button.setTitleColor(wallpaperManager.currentWallpaper.textColor, for: .normal)
        button.titleLabel?.font =   UIFont.boldSystemFont(ofSize: UX.CardTitleLabel.viewMoreFont)
        return button
    } ()
    
    ///UILabel
    private lazy var statsTitleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontForContentSizeCategory = true
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.StatsTitleLabel.font)
        label.text = "Your Carbon Stats"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
 
    private lazy var cardTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.CardTitleLabel.font)
        label.text = "COMING SOON"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var featureCardTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.CardTitleLabel.font)
        label.text = "FEATURED"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var viewMoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = wallpaperManager.currentWallpaper.textColor
        label.font = UIFont.boldSystemFont(ofSize: UX.CardTitleLabel.viewMoreFont)
        label.text = "VIEW MORE"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isUserInteractionEnabled = false
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
    
    private lazy var featureCollectionView : UICollectionView = {
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
    
    
    // MARK: - Variables
    private  var dataModel = [DataModel(title: "Data Saved", value: "0B"),DataModel(title: "Tracker & Ads Blocked", value: "0"),DataModel(title: "Searches", value: "0")]
    
    private var statsModel = [StatsModel(title: "Wallet", icon:"ic_wallet"),StatsModel(title: "Staking", icon: "ic_stacking"),StatsModel(title: "Swap", icon: "ic_swap"),StatsModel(title: "Bridge", icon: "ic_bridge")]
    
    private  var earnedModel = [DataModel(title: "Earned Today", value: "0"),DataModel(title: "Earned Total", value: "0")]
    
    private var featuredModel = [FeatureModel(title: "ChatGPT", icon:"ic_chatGPT",color: UIColor(red: 18, green: 163, blue: 127, alpha: 1),url: "https://chat.openai.com"),FeatureModel(title: "OpenSea", icon: "ic_openSea",color: UIColor(red: 32, green: 129, blue: 226, alpha: 1),url: "https://opensea.io"),FeatureModel(title: "Curate", icon: "ic_curate",color: UIColor(red: 0, green: 0, blue: 0, alpha: 1),url: "https://curate.style"),FeatureModel(title: "Binance", icon: "ic_binance",color: UIColor(red: 0, green: 0, blue: 0, alpha: 1),url: "https://www.binance.com")]
    private var viewMoredata = FeatureModel(title: "View more", icon: "", color: UIColor.clear, url: "https://carbon.website/app-store/")

    private var wallpaperManager =  WallpaperManager()
   
    var delegate: FeatureCardProtocol?
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(adcountTriggers), name:Notification.Name("AdblockCountNotification"), object: nil)
        var blockedCount = getNumberOfLifetimeTrackersBlocked()
        dataModel[1].value = "\(blockedCount)"
        dataModel[0].value = "\((5/3) * blockedCount)KB"
    }
    
    private func getNumberOfLifetimeTrackersBlocked(userDefaults: UserDefaults = UserDefaults.standard) -> Int {
        return  UserDefaults.standard.integer(forKey: BrowserViewController.userDefaultsTrackersBlockedKey)
    }

    @objc func adcountTriggers(notification : Notification){
        var blockedCount = getNumberOfLifetimeTrackersBlocked()
        dataModel[1].value = "\(blockedCount)"
        dataModel[0].value = "\((5/3) * blockedCount)KB"
        self.tableView.reloadData()
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
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
        featureView.addSubview(featureCardTitleLabel)
        featureView.addSubview(featureCollectionView)
        stackView.addSubview(featureView)
        stackView.addSubview(viewMoreBtn)

        contentView.addSubview(statsView)
        contentView.addSubview(dataView)
        contentView.addSubview(comingSoonView)
        contentView.addSubview(stackView)
        

        NSLayoutConstraint.activate([
            statsTitleLabel.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            statsTitleLabel.centerYAnchor.constraint(equalTo: statsView.centerYAnchor, constant: UX.StatsTitleLabel.centerYAnchor),
            statsTitleLabel.widthAnchor.constraint(equalToConstant: UX.StatsTitleLabel.width),
            statsTitleLabel.heightAnchor.constraint(equalToConstant: UX.StatsTitleLabel.height),
            
            statsView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.StatsView.topConstant),
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
            
            stackView.topAnchor.constraint(equalTo: comingSoonView.bottomAnchor,constant: UX.ComingSoonView.constant),
            stackView.widthAnchor.constraint(equalToConstant: contentView.frame.width - UX.DataView.constant),
            stackView.heightAnchor.constraint(equalToConstant: UX.ComingSoonView.stackViewHeight),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            featureView.topAnchor.constraint(equalTo: comingSoonView.bottomAnchor,constant: UX.ComingSoonView.constant),
            featureView.widthAnchor.constraint(equalToConstant: contentView.frame.width - UX.DataView.constant),
            featureView.heightAnchor.constraint(equalToConstant: UX.ComingSoonView.featureViewHeight),
            featureView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            viewMoreBtn.topAnchor.constraint(equalTo: featureView.bottomAnchor,constant: UX.ComingSoonView.viewMoreBottom),
            viewMoreBtn.centerXAnchor.constraint(equalTo: featureView.centerXAnchor),
            viewMoreBtn.widthAnchor.constraint(equalToConstant: UX.ComingSoonView.viewMoreWidth),
            viewMoreBtn.heightAnchor.constraint(equalToConstant: UX.ComingSoonView.viewMoreHeight),
            
            tableView.leadingAnchor.constraint(equalTo: dataView.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: dataView.topAnchor),
            tableView.widthAnchor.constraint(equalTo: dataView.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: dataView.heightAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: comingSoonView.leadingAnchor,constant: UX.CollectionView.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: comingSoonView.topAnchor,constant: UX.CollectionView.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: comingSoonView.trailingAnchor,constant: UX.CollectionView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: comingSoonView.heightAnchor),
            
            statsCollectionView.leadingAnchor.constraint(equalTo: statsView.leadingAnchor,constant: UX.CollectionView.leading),
            statsCollectionView.topAnchor.constraint(equalTo: statsView.topAnchor),
            statsCollectionView.widthAnchor.constraint(equalTo: statsView.widthAnchor,constant: UX.CollectionView.widthAnchor),
            statsCollectionView.heightAnchor.constraint(equalTo: statsView.heightAnchor),
            
            featureCollectionView.leadingAnchor.constraint(equalTo: featureView.leadingAnchor,constant: UX.CollectionView.leadingAnchor),
            featureCollectionView.topAnchor.constraint(equalTo: featureView.topAnchor,constant: UX.CollectionView.featuretopAnchor),
            featureCollectionView.trailingAnchor.constraint(equalTo: featureView.trailingAnchor,constant:UX.CollectionView.trailingAnchor),
            featureCollectionView.heightAnchor.constraint(equalTo: featureView.heightAnchor),
            
            cardTitleLabel.centerXAnchor.constraint(equalTo: comingSoonView.centerXAnchor),
            cardTitleLabel.centerYAnchor.constraint(equalTo: comingSoonView.centerYAnchor,constant: UX.CardTitleLabel.YAnchor),
            
            featureCardTitleLabel.centerXAnchor.constraint(equalTo: featureView.centerXAnchor),
            featureCardTitleLabel.centerYAnchor.constraint(equalTo: featureView.centerYAnchor,constant: UX.CardTitleLabel.viewMoreYAnchor),
        ])
        setupGradiantLayerToView()
        setupLongGestureRecognizerOnCollection()
        viewMoreBtn.addTarget(self, action: #selector(self.viewMoreTap(sender:)), for: .touchUpInside)
    }
    @objc func viewMoreTap(sender: UIButton) {
        delegate?.cardItemTapped(data: viewMoredata,isLongPress: false)
    }
    
    func setupGradiantLayerToView() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 141.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 6.0/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom, colorTop]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = 12
        gradientLayer.frame = CGRect(x: featureView.frame.origin.x, y: featureView.frame.origin.y, width: 100, height: 24)
        viewMoreBtn.layer.insertSublayer(gradientLayer, at:0)
    }
    func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        featureCollectionView.addGestureRecognizer(longPressedGesture)
    }
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {return}
        let p = gestureRecognizer.location(in: featureCollectionView)
        if let indexPath = featureCollectionView.indexPathForItem(at: p) {
            delegate?.cardItemTapped(data: featuredModel[indexPath.row],isLongPress: true)
        }
    }
    
// MARK: - UICollectionView Delegate & DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case statsCollectionView:
            return  earnedModel.count
        case featureCollectionView:
            return featuredModel.count
        default:
            return statsModel.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case statsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatsCollectionCell", for: indexPath) as! StatsCollectionCell
            cell.setUI(data: earnedModel[indexPath.row])
            return cell
        case featureCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComingSoonCollectionCell", for: indexPath) as! ComingSoonCollectionCell
            cell.setUIFeature(data: featuredModel[indexPath.row],index: indexPath.row)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ComingSoonCollectionCell", for: indexPath) as! ComingSoonCollectionCell
            cell.setUI(data: statsModel[indexPath.row],index: indexPath.row)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView == statsCollectionView ? CGSize(width:(collectionView.frame.width/2) - 5, height: 50) : CGSize(width: 56, height: 68)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == statsCollectionView ? 10 : 20
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == featureCollectionView{
            delegate?.cardItemTapped(data: featuredModel[indexPath.row],isLongPress: false)
        }
    }

// MARK: - UITableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataTableCell", for: indexPath) as! DataTableCell
        cell.setUI(data: dataModel[indexPath.row])
        cell.selectionStyle = .none
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
            static let width: CGFloat = 56
            static let height: CGFloat = 56
            
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
            static let height: CGFloat = 15
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
    func setUIFeature(data : FeatureModel,index : Int){
        iconImageView.image = UIImage(named: data.icon!)
        titleLabel.text = data.title
        iconImageView.widthAnchor.constraint(equalToConstant: UX.Icon.width).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: UX.Icon.height).isActive = true
        iconImageView.backgroundColor = data.color!
        iconView.backgroundColor = data.color!
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
            setUIForImage(width:  UX.Icon.width3, height: UX.Icon.height3)
        case 3:
            setUIForImage(width:UX.Icon.width4, height:  UX.Icon.height4)
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

class FeatureModel {
    var title: String?
    var icon: String?
    var color: UIColor?
    var url : String?
    init(title: String?,icon: String?,color: UIColor,url:String?){
        self.title = title
        self.icon = icon
        self.color = color
        self.url = url
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
