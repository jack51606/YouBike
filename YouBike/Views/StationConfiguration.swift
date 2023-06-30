import UIKit

struct StationConfiguration: UIContentConfiguration {
    
    public let countyLabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    public let districtLabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    public let stationLabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    public var contentInsets: NSDirectionalEdgeInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    public var height: CGFloat = 72
    
    public func makeContentView() -> UIView & UIContentView {
        
        return StationContentView(configuration: self)
    }
    
    public func updated(for state: UIConfigurationState) -> StationConfiguration {
        
        return self
    }
}

final class StationContentView: UIView, UIContentView {
    
    public var configuration: UIContentConfiguration {
        didSet {
            updateContents()
        }
    }
    private let container = UIView()
    private var topConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    
    public init(configuration: StationConfiguration) {
        
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = container.topAnchor.constraint(equalTo: topAnchor)
        bottomConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        leadingConstraint = container.leadingAnchor.constraint(equalTo: leadingAnchor)
        trailingConstraint = container.trailingAnchor.constraint(equalTo: trailingAnchor)
        heightConstraint = container.heightAnchor.constraint(equalToConstant: configuration.height)
        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            leadingConstraint,
            trailingConstraint,
            heightConstraint
        ])
        
        container.addSubview(configuration.countyLabel)
        configuration.countyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            configuration.countyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            configuration.countyLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            configuration.countyLabel.widthAnchor.constraint(equalToConstant: 80.0)
        ])
        
        container.addSubview(configuration.districtLabel)
        configuration.districtLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            configuration.districtLabel.leadingAnchor.constraint(equalTo: configuration.countyLabel.trailingAnchor),
            configuration.districtLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            configuration.districtLabel.widthAnchor.constraint(equalToConstant: 80.0)
        ])
        
        container.addSubview(configuration.stationLabel)
        configuration.stationLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            configuration.stationLabel.leadingAnchor.constraint(equalTo: configuration.districtLabel.trailingAnchor),
            configuration.stationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            configuration.stationLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func updateContents() {
        guard let configuration = configuration as? LabelConfiguration else { return }
        
        topConstraint.constant = configuration.contentInsets.top
        bottomConstraint.constant = -configuration.contentInsets.bottom
        leadingConstraint.constant = configuration.contentInsets.leading
        trailingConstraint.constant = -configuration.contentInsets.trailing
        heightConstraint.constant = configuration.height
    }
}
