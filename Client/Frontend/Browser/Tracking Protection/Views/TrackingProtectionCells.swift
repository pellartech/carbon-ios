// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Combine
import Shared

class SubtitleCell: UITableViewCell {
    private var wallpaperManager =  WallpaperManager()

    
    convenience init(title: String, subtitle: String, reuseIdentifier: String? = nil, theme :ThemeManager) {
        self.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.text = title
        textLabel?.textColor = wallpaperManager.currentWallpaper.textColor
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        textLabel?.adjustsFontForContentSizeCategory = true
        textLabel?.numberOfLines = 0
        detailTextLabel?.text = subtitle
        detailTextLabel?.textColor = wallpaperManager.currentWallpaper.textColor
        detailTextLabel?.font = UIFont.systemFont(ofSize: 20)
        detailTextLabel?.adjustsFontForContentSizeCategory = true
        backgroundColor = theme.currentTheme.colors.layer4
        selectionStyle = .none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ImageCell: UITableViewCell {
    private var wallpaperManager =  WallpaperManager()

    convenience init(image: UIImage, title: String, reuseIdentifier: String? = nil, theme :ThemeManager) {
        self.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        imageView?.image = image
        textLabel?.text = title
        textLabel?.textColor = wallpaperManager.currentWallpaper.textColor
        textLabel?.numberOfLines = 0
        backgroundColor = theme.currentTheme.colors.layer4
        selectionStyle = .none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SwitchTableViewCell: UITableViewCell {
    
    private var wallpaperManager =  WallpaperManager()

    private lazy var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.tintColor = .darkGray
        toggle.addTarget(self, action: #selector(toggle(sender:)), for: .valueChanged)

        return toggle
    }()

    private var cancellable: AnyCancellable?
    private var subject = PassthroughSubject<Bool, Never>()
    public var valueChanged: AnyPublisher<Bool, Never> { subject.eraseToAnyPublisher() }
    public var isOn: Bool = false {
        didSet { toggle.isOn = isOn }
    }

    convenience init(item: ToggleItem, style: UITableViewCell.CellStyle = .default, reuseIdentifier: String?, theme :ThemeManager) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        toggle.isOn = Settings.getToggle(item.settingsKey)
        toggle.accessibilityIdentifier = "BlockerToggle.\(item.settingsKey.rawValue)"
        toggle.onTintColor = theme.currentTheme.colors.actionPrimary
        textLabel?.text = item.title
        textLabel?.textColor = wallpaperManager.currentWallpaper.textColor
        textLabel?.numberOfLines = 0
        accessoryView = PaddedSwitch(switchView: toggle)
        backgroundColor = theme.currentTheme.colors.layer4
        selectionStyle = .none
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func toggle(sender: UISwitch) {
        subject.send(sender.isOn)
    }
}

//class TrackingHeaderView: UIView {
//    private lazy var faviImageView: AsyncImageView = {
//        let image = AsyncImageView()
//        image.translatesAutoresizingMaskIntoConstraints = false
//        return image
//    }()
//
//    private lazy var domainLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.preferredFont(forTextStyle: .callout)
//        label.textColor = .primaryText
//        label.numberOfLines = 0
//        label.setContentHuggingPriority(.required, for: .horizontal)
//        label.setContentCompressionResistancePriority(.required, for: .horizontal)
//        return label
//    }()
//
//    private lazy var stackView: UIStackView = {
//        let stackView = UIStackView(arrangedSubviews: [faviImageView, domainLabel])
//        stackView.spacing = 8
//        stackView.alignment = .center
//        stackView.axis = .horizontal
//        return stackView
//    }()
//
//    private lazy var separator: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemGray
//        return view
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        commonInit()
//    }
//
//    private func commonInit() {
//        addSubview(separator)
//        addSubview(stackView)
//        backgroundColor = .systemGroupedBackground
//
//        faviImageView.snp.makeConstraints { make in
//            make.width.height.equalTo(40)
//        }
//        separator.snp.makeConstraints { make in
//            make.height.equalTo(0.5)
//            make.bottom.leading.trailing.equalToSuperview()
//        }
//        stackView.snp.makeConstraints { make in
//            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).inset(16)
//            make.leading.bottom.equalToSuperview().inset(16)
//        }
//    }
//
//    var cancellable: AnyCancellable?
//
//    func configure(domain: String, publisher: AnyPublisher<URL?, Never>) {
//        self.domainLabel.text = domain
//        cancellable = publisher
//            .sink { [weak self] url in
//                guard let self = self else { return }
//                guard let url = url else {
//                    self.faviImageView.defaultImage = .defaultFavicon
//                    return
//                }
//                self.faviImageView.load(imageURL: url, defaultImage: .defaultFavicon)
//            }
//    }
//}


public class TooltipTableViewCell: UITableViewCell {

    private lazy var tooltip: TooltipView = {
        let tooltipView = TooltipView()
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        tooltipView.delegate = self
        return tooltipView
    }()

    public weak var delegate: TooltipViewDelegate?

    public convenience init(title: String, body: String, style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = nil) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        tooltip.set(title: title, body: body)
        contentView.addSubview(tooltip)
        NSLayoutConstraint.activate([
            tooltip.topAnchor.constraint(equalTo: contentView.topAnchor),
            tooltip.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tooltip.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tooltip.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TooltipTableViewCell: TooltipViewDelegate {
    public func didTapTooltipDismissButton() {
        delegate?.didTapTooltipDismissButton()
    }
}

public protocol TooltipViewDelegate: AnyObject {
    func didTapTooltipDismissButton()
}

class TooltipView: UIView {

    weak var delegate: TooltipViewDelegate?

    private lazy var gradient: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = .cornerRadius
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.blue.cgColor]
        gradientLayer.startPoint = .startPoint
        gradientLayer.endPoint = .endPoint
        return gradientLayer
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelContainerStackView, dismissButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = .space
        stackView.layoutMargins = UIEdgeInsets(top: .margin, left: .margin, bottom: .margin, right: .margin)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()

    private lazy var labelContainerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = .space
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.blue
        label.numberOfLines = 0
        return label
    }()

    private lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.blue
        label.numberOfLines = 0
        return label
    }()

    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: CGFloat.dismissButtonSize),
            button.heightAnchor.constraint(equalToConstant: CGFloat.dismissButtonSize)
        ])
//        button.setImage(UI, for: .normal)
        button.addTarget(self, action: #selector(didTapTooltipDismissButton), for: .primaryActionTriggered)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupLayout()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradient.frame = bounds
    }

    private func setupLayout() {
        addSubview(mainStackView)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }

    func set(title: String = "", body: String, maxWidth: CGFloat? = nil) {
        titleLabel.text = title
        titleLabel.isHidden = title.isEmpty
        bodyLabel.text = body
        guard let maxWidth = maxWidth else { return }
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let idealSize = body.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil).size
        NSLayoutConstraint.activate([
            labelContainerStackView.widthAnchor.constraint(lessThanOrEqualToConstant: idealSize.width)
            ])
    }

    @objc func didTapTooltipDismissButton() {
        delegate?.didTapTooltipDismissButton()
    }
}

fileprivate extension CGFloat {
    static let space: CGFloat = 12
    static let margin: CGFloat = 16
    static let cornerRadius: CGFloat = 12
    static let dismissButtonSize: CGFloat = 24
}

fileprivate extension CGPoint {
    static let startPoint = CGPoint(x: 0, y: 1)
    static let endPoint = CGPoint(x: 1, y: 1)
}
