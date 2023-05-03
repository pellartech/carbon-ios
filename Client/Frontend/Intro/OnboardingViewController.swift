import UIKit

protocol OnboardingProtocol {
    func nextButtonTapped()
    func doneButtonTapped()
}

protocol IntroOnboardingProtocol {
    func moveToNextScreen(index:Int)
    func moveToNextScreenManually(index:Int)
    func closeOnboardingScreen()
}

class OnboardingViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OnboardingProtocol, UIScrollViewDelegate {
    
    private lazy var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor =  Utilities().hexStringToUIColor(hex: "#1E1E1E")
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.delegate = self
        collectionView.bounces = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.isPagingEnabled = true
        collectionView.register(OnboardingWelcomeCollectionCell.self, forCellWithReuseIdentifier: "OnboardingWelcomeCollectionCell")
        collectionView.register(OnboardingCollectionCell.self, forCellWithReuseIdentifier: "OnboardingCollectionCell")
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    var delegate: IntroOnboardingProtocol?
    
    var onboardingModel = [OnboardingModel(title: "Privacy", image: "ic_privacy",descrp: "Saves data be downloading ad-blocking filterins only when you’re connected to WI-FI. When toggled on, this setting may affect the quality of ad blocking."),OnboardingModel(title: "Speed!", image: "ic_speed",descrp:"Like VPN, AdBlock etc.ing ad-blocking filterins only when you’re connected to WI-FI. When toggled on, this setting may affect the quality of ad blocking."),OnboardingModel(title: "Rewards", image: "ic_rewards",descrp:"Saves data be downloading ad-blocking filterins only when you’re connected to WI-FI. When toggled on, this setting may affect the quality of ad blocking.")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        collectionView.reloadData()
    }
    
    func setupView() {
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1 + self.onboardingModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingWelcomeCollectionCell", for: indexPath) as! OnboardingWelcomeCollectionCell
            cell.delegate = self
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionCell", for: indexPath) as! OnboardingCollectionCell
            cell.setUI(data: onboardingModel[indexPath.row - 1],index:indexPath.row )
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return  CGSize(width: view.frame.width, height: view.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func nextButtonTapped() {
        scrollToNextItem()
    }
    
    func doneButtonTapped() {
        delegate?.closeOnboardingScreen()
    }
    func scrollToNextItem(){
        let cellSize = collectionView.frame.size
        let contentOffset = collectionView.contentOffset
        if collectionView.contentSize.width >= collectionView.contentOffset.x + cellSize.width
        {
            let r = CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height)
            collectionView.scrollRectToVisible(r, animated: true);
            for cell in collectionView.visibleCells {
                let indexPath = collectionView.indexPath(for: cell)
                delegate?.moveToNextScreen(index: indexPath!.row)
            }
        }
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        delegate?.moveToNextScreenManually(index: indexPath.row)
    }
}
class OnboardingWelcomeCollectionCell: UICollectionViewCell {
    
    private struct UX {
        struct LayerView {
            static let leading: CGFloat = -30
            static let top: CGFloat = 2
            static let height: CGFloat = 120
            static let width: CGFloat = 2.2
        }
        struct LayerSubView {
            static let leading: CGFloat = -70
            static let top: CGFloat = 3
            static let height: CGFloat = 120
            static let width: CGFloat = 2.2
        }
        struct LogoView {
            static let centerY: CGFloat = -130
            static let height: CGFloat = 95
            static let width: CGFloat = 95
        }
        struct CarbonImageView {
            static let top: CGFloat = 22
            static let height: CGFloat = 48
            static let width: CGFloat = 200
        }
        struct MoreThanLabel {
            static let top: CGFloat = 5
            static let height: CGFloat = 15
            static let width: CGFloat = 230
        }
        
        struct StartButtonView {
            static let bottom: CGFloat = -100
            static let width: CGFloat = 190
            static let height: CGFloat = 60
        }
        struct PrivacyLabel {
            static let bottom: CGFloat = -20
            static let width: CGFloat = 250
            static let height: CGFloat = 17
        }
    }
    
    private lazy var layerView: UIView = {
        let view = UIView()
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#1E1E1E")
        view.layer.cornerRadius = contentView.frame.width + 60
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var layerSubView: UIView = {
        let view = UIView()
        view.backgroundColor = Utilities().hexStringToUIColor(hex: "#FF6D24")
        view.layer.cornerRadius = contentView.frame.width + 40
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    
    private lazy var moreThanLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = " MORE THAN A BROWSER"
        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        let myAttribute = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10) ]
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Utilities().hexStringToUIColor(hex: "#808080"), range: range)
        attributedString.addAttributes(myAttribute, range: range)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(4.5), range: range)
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var moreThanLabe: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = " MORE THAN A BROWSER"
        let attributedString = NSMutableAttributedString(string: label.text ?? "")
        let myAttribute = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10) ]
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: Utilities().hexStringToUIColor(hex: "#808080"), range: range)
        attributedString.addAttributes(myAttribute, range: range)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: CGFloat(4.5), range: range)
        label.attributedText = attributedString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var startButtonView: GradientView = {
        let view = GradientView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var startGradientView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        return view
    }()
    
    private lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10)
        label.textAlignment = .center
        label.text = "Privacy Policy, Terms of Usage"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(privacyLabelTapped))
        label.addGestureRecognizer(tap)
        return label
    }()
    
    private lazy var startLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "START"
        label.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    var delegate : OnboardingProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(layerSubView)
        contentView.addSubview(layerView)
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(carbonImageView)
        contentView.addSubview(moreThanLabel)
        contentView.addSubview(startButtonView)
        contentView.addSubview(startGradientView)
        contentView.addSubview(startLabel)
        contentView.addSubview(privacyLabel)
        
        contentView.setGradientBackground2()
        layerSubView.setGradientBackground3()
        
        NSLayoutConstraint.activate([
            layerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.LayerView.leading),
            layerView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.LayerView.top),
            layerView.widthAnchor.constraint(equalToConstant: contentView.frame.width * UX.LayerView.width),
            layerView.heightAnchor.constraint(equalToConstant: contentView.frame.height + UX.LayerView.height),
            
            layerSubView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: UX.LayerSubView.leading),
            layerSubView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.LayerSubView.top),
            layerSubView.widthAnchor.constraint(equalToConstant: contentView.frame.width * UX.LayerSubView.width),
            layerSubView.heightAnchor.constraint(equalToConstant: contentView.frame.height + UX.LayerSubView.height),
            
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor,constant: UX.LogoView.centerY),
            logoImageView.widthAnchor.constraint(equalToConstant:  UX.LogoView.width),
            logoImageView.heightAnchor.constraint(equalToConstant:  UX.LogoView.height),
            
            carbonImageView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor,constant: UX.CarbonImageView.top),
            carbonImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            carbonImageView.widthAnchor.constraint(equalToConstant: UX.CarbonImageView.width),
            carbonImageView.heightAnchor.constraint(equalToConstant: UX.CarbonImageView.height),
            
            moreThanLabel.topAnchor.constraint(equalTo: carbonImageView.bottomAnchor,constant: UX.MoreThanLabel.top),
            moreThanLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            moreThanLabel.widthAnchor.constraint(equalToConstant: UX.MoreThanLabel.width),
            moreThanLabel.heightAnchor.constraint(equalToConstant: UX.MoreThanLabel.height),
            
            startButtonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.StartButtonView.bottom),
            startButtonView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            startButtonView.widthAnchor.constraint(equalToConstant: UX.StartButtonView.width),
            startButtonView.heightAnchor.constraint(equalToConstant: UX.StartButtonView.height),
            startGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.StartButtonView.bottom),
            startGradientView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            startGradientView.widthAnchor.constraint(equalToConstant: UX.StartButtonView.width),
            startGradientView.heightAnchor.constraint(equalToConstant: UX.StartButtonView.height),
            
            startLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.StartButtonView.bottom),
            startLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            startLabel.widthAnchor.constraint(equalToConstant: UX.StartButtonView.width),
            startLabel.heightAnchor.constraint(equalToConstant: UX.StartButtonView.height),
            
            privacyLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            privacyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.PrivacyLabel.bottom),
            privacyLabel.widthAnchor.constraint(equalToConstant: UX.PrivacyLabel.width),
            privacyLabel.heightAnchor.constraint(equalToConstant: UX.PrivacyLabel.height),
        ])
    }
    @objc func privacyLabelTapped(sender:UILabel) {
        guard let url = URL(string: "https://carbon.website/privacy-policy/") else { return }
        UIApplication.shared.open(url)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func nextLabelTapped(sender: UILabel){
        delegate?.nextButtonTapped()
    }
}

class OnboardingCollectionCell: UICollectionViewCell {
    
    
    private struct UX {
        struct HeaderView {
            static let top: CGFloat = 45
            static let width: CGFloat = 209
            static let height: CGFloat = 46
        }
        struct LogoView {
            static let height: CGFloat = 46
            static let width: CGFloat = 46
        }
        struct CarbonImageView {
            static let leading: CGFloat = 10
            static let width: CGFloat = 155
            static let height: CGFloat = 40
            
        }
        struct CenterImageView {
            static let centerY: CGFloat = -50
            static let width: CGFloat = 220
            static let height: CGFloat = 220
        }
        struct TitleLabel {
            static let bottom: CGFloat = -200
            static let width: CGFloat = 190
            static let height: CGFloat = 60
        }
        struct DescrpLabel {
            static let top: CGFloat = 5
            static let width: CGFloat = 320
            static let height: CGFloat = 70
        }
        struct NextLabel {
            static let bottom: CGFloat = -50
            static let width: CGFloat = 190
            static let height: CGFloat = 60
        }
    }
    
    
    
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
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
    private lazy var centerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var descrpLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 10
        label.textAlignment = .center
        label.textColor = Utilities().hexStringToUIColor(hex: "#808080")
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nextLabel: GradientLabel = {
        let label = GradientLabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "NEXT"
        label.translatesAutoresizingMaskIntoConstraints = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(nextLabelTapped))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
        return label
    }()
    
    var delegate : OnboardingProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor =  Utilities().hexStringToUIColor(hex: "#1E1E1E")
        contentView.backgroundColor =  Utilities().hexStringToUIColor(hex: "#1E1E1E")
        
        headerView.addSubview(logoImageView)
        headerView.addSubview(carbonImageView)
        contentView.addSubview(headerView)
        
        
        contentView.addSubview(centerImageView)
        contentView.addSubview(descrpLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(nextLabel)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: UX.HeaderView.top),
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalToConstant: UX.HeaderView.width),
            headerView.heightAnchor.constraint(equalToConstant: UX.HeaderView.height),
            
            logoImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: UX.LogoView.width),
            logoImageView.heightAnchor.constraint(equalToConstant: UX.LogoView.height),
            
            carbonImageView.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor,constant: UX.CarbonImageView.leading),
            carbonImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            carbonImageView.widthAnchor.constraint(equalToConstant: UX.CarbonImageView.width),
            carbonImageView.heightAnchor.constraint(equalToConstant: UX.CarbonImageView.height),
            
            centerImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            centerImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor,constant: UX.CenterImageView.centerY),
            centerImageView.widthAnchor.constraint(equalToConstant: UX.CenterImageView.width),
            centerImageView.heightAnchor.constraint(equalToConstant: UX.CenterImageView.height),
            
            
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.TitleLabel.bottom),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: UX.TitleLabel.width),
            titleLabel.heightAnchor.constraint(equalToConstant: UX.TitleLabel.height),
            
            descrpLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,constant:UX.DescrpLabel.top),
            descrpLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            descrpLabel.widthAnchor.constraint(equalToConstant: UX.DescrpLabel.width),
            descrpLabel.heightAnchor.constraint(equalToConstant: UX.DescrpLabel.height),
            
            nextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: UX.NextLabel.bottom),
            nextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nextLabel.widthAnchor.constraint(equalToConstant: UX.NextLabel.width),
            nextLabel.heightAnchor.constraint(equalToConstant: UX.NextLabel.height),
            
        ])
    }
    @objc func nextLabelTapped(sender: UILabel){
        if nextLabel.text == "DONE"{
            delegate?.doneButtonTapped()
        }else{
            delegate?.nextButtonTapped()
        }
    }
    func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        guard let djksf = UIGraphicsGetCurrentContext()else{return UIColor.clear}
        gradientLayer.render(in: djksf)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }
    func setUI(data : OnboardingModel,index:Int){
        nextLabel.text = index == 3 ? "DONE" : "NEXT"
        titleLabel.text = data.title
        descrpLabel.text = data.descrp
        centerImageView.image = UIImage(named: data.image!)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class OnboardingModel {
    
    var title: String?
    var image: String?
    var descrp: String?
    
    init(title: String?,image: String?,descrp: String? ){
        self.title = title
        self.image = image
        self.descrp = descrp
        
    }
}


extension UILabel {
    
    func gradientColor(bounds: CGRect, gradientLayer :CAGradientLayer) -> UIColor? {
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        guard let djksf = UIGraphicsGetCurrentContext()else{return UIColor.clear}
        gradientLayer.render(in: djksf)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIColor(patternImage: image!)
    }
    func getGradientLayer(bounds : CGRect) -> CAGradientLayer{
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }
    
    func setGradient(){
        let gradient = getGradientLayer(bounds: self.bounds)
        self.textColor = gradientColor(bounds: self.bounds, gradientLayer: gradient)
    }
}

class GradientLabel: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTextColor()
    }
    private func updateTextColor() {
        let topColor: UIColor = UIColor(red: 255.0/255.0, green: 50.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        let bottomColor: UIColor = UIColor(red: 255.0/255.0, green: 145.0/255.0, blue: 51.0/255.0, alpha: 1.0)
        let image = UIGraphicsImageRenderer(bounds: bounds).image { context in
            let colors = [topColor.cgColor, bottomColor.cgColor]
            guard let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil) else { return }
            context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: bounds.minX, y: bounds.midY), end: CGPoint(x: bounds.maxX, y: bounds.maxY),options: [])
        }
        textColor = UIColor(patternImage: image)
    }
}

class GradientView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateTextColor()
    }
    private func updateTextColor() {
        let topColor: UIColor = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 6.0/255.0, alpha: 1.0)
        let bottomColor: UIColor = UIColor(red: 255.0/255.0, green: 141.0/255.0, blue: 49.0/255.0, alpha: 1.0)
        let image = UIGraphicsImageRenderer(bounds: bounds).image { context in
            let colors = [topColor.cgColor, bottomColor.cgColor]
            guard let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: nil) else { return }
            context.cgContext.drawLinearGradient(gradient,
                                                 start: CGPoint(x: bounds.minX, y: bounds.midY),
                                                 end: CGPoint(x: bounds.maxX, y: bounds.maxY),
                                                 options: [])
        }
        backgroundColor = UIColor(patternImage: image)
    }
}

class Utilities {
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,blue: CGFloat(rgbValue & 0x0000FF) / 255.0,alpha: CGFloat(1.0)
        )
    }
}
extension UIView{
    func setGradientBackground2() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 141.0/255.0, blue: 49.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 6.0/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorBottom,colorTop]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.frame
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func setGradientBackground3() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 135.0/255.0, blue: 48.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 26.0/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop,colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.frame
        self.layer.insertSublayer(gradientLayer, at:0)
    }
}
