import UIKit

@MainActor
public final class StationInformationViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let searchField = TextField()
    private let tableHeader = UIView()
    private var stationCollectionView: UICollectionView!
    private let autoCompleteView: PaddingLabel = {
        let label = PaddingLabel()
        label.padding = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
        label.backgroundColor = UIColor(hex: "#F6F6F6")
        label.layer.cornerRadius = 8.0
        label.layer.cornerCurve = .continuous
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 16.0)
        label.textColor = .black
        return label
    }()
    
    private var allStations: [Station] = []
    private var stations: [Station] = [] {
        didSet {
            stationCollectionView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleLabel()
        setSearchField()
        setTableHeader()
        setCollectionView()
        setAutoCompleteView()
        
        Task {
            allStations = await NetworkAPI.shared.fetchData()
            stations = allStations
        }
        
        // 點擊空白處時取消鍵盤
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setTitleLabel() {
        
        titleLabel.font = .systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = .tintColor
        titleLabel.text = "站 點 資 訊"
        
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32.0),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0)
        ])
    }
    
    private func setSearchField() {
        
        searchField.delegate = self
        searchField.backgroundColor = UIColor(hex: "#F6F6F6")
        searchField.layer.cornerRadius = 8.0
        searchField.layer.cornerCurve = .continuous
        searchField.font = .systemFont(ofSize: 16.0)
        searchField.textColor = .black
        let magnifyingGlass = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        magnifyingGlass.tintColor = .placeholderText
        let iconContainer = UIView()
        iconContainer.addSubview(magnifyingGlass)
        magnifyingGlass.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            magnifyingGlass.topAnchor.constraint(equalTo: iconContainer.topAnchor),
            magnifyingGlass.bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor),
            magnifyingGlass.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor),
            magnifyingGlass.trailingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: -16.0)
        ])
        searchField.rightView = iconContainer
        searchField.rightViewMode = .always
        searchField.attributedPlaceholder = NSAttributedString(string: "搜尋站點", attributes: [.foregroundColor: UIColor(hex: "#AEAEAE")!])
        searchField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24.0),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            searchField.heightAnchor.constraint(equalToConstant: 44.0)
        ])
    }
    
    private func setTableHeader() {
        
        tableHeader.backgroundColor = .tintColor
        tableHeader.layer.cornerRadius = 8.0
        tableHeader.layer.cornerCurve = .continuous
        tableHeader.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let stationConfiguration = StationConfiguration()
        stationConfiguration.countyLabel.font = .systemFont(ofSize: 16, weight: .medium)
        stationConfiguration.countyLabel.textColor = .white
        stationConfiguration.countyLabel.text = "縣市"
        stationConfiguration.districtLabel.font = .systemFont(ofSize: 16, weight: .medium)
        stationConfiguration.districtLabel.textColor = .white
        stationConfiguration.districtLabel.text = "區域"
        stationConfiguration.stationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        stationConfiguration.stationLabel.textColor = .white
        stationConfiguration.stationLabel.text = "站點名稱"
        let contentView = StationContentView(configuration: stationConfiguration)
        tableHeader.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: tableHeader.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: tableHeader.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: tableHeader.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: tableHeader.trailingAnchor)
        ])
        
        view.addSubview(tableHeader)
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableHeader.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 24.0),
            tableHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            tableHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            tableHeader.heightAnchor.constraint(equalToConstant: 72.0)
        ])
    }
    
    private func setCollectionView() {
        
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
        listConfiguration.backgroundColor = .clear
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        stationCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        stationCollectionView.dataSource = self
        stationCollectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.self.description())
        stationCollectionView.layer.cornerRadius = 8.0
        stationCollectionView.layer.cornerCurve = .continuous
        stationCollectionView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        stationCollectionView.layer.borderWidth = 0.5
        stationCollectionView.layer.borderColor = UIColor.placeholderText.cgColor
        
        view.insertSubview(stationCollectionView, belowSubview: tableHeader)
        stationCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stationCollectionView.topAnchor.constraint(equalTo: tableHeader.bottomAnchor, constant: -0.5),
            stationCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -56.0),
            stationCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            stationCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0)
        ])
    }
    
    private func setAutoCompleteView() {
        
        view.addSubview(autoCompleteView)
        autoCompleteView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            autoCompleteView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8.0),
            autoCompleteView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            autoCompleteView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            autoCompleteView.heightAnchor.constraint(equalToConstant: 44.0)
        ])
        
        autoCompleteView.alpha = 0
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.isEmpty {
            stations = allStations
            autoCompleteView.alpha = 0
        } else {
            stations = allStations.filter({ $0.sarea.contains(text) || $0.sna.contains(text) })
            autoCompleteView.text = text
            autoCompleteView.alpha = 1
        }
        
        if !stations.isEmpty {
            stationCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
}

extension StationInformationViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        autoCompleteView.alpha = 0
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let text = textField.text, !text.isEmpty {
            autoCompleteView.alpha = 1
        }
        
        return true
    }
}

extension StationInformationViewController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stations.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.self.description(), for: indexPath) as! UICollectionViewListCell
        
        let station = stations[indexPath.row]
        
        var configuration: StationConfiguration
        if let cellConfiguration = cell.contentConfiguration as? StationConfiguration {
            configuration = cellConfiguration
        } else {
            configuration = StationConfiguration()
        }
        
        configuration.countyLabel.font = .systemFont(ofSize: 14.0)
        configuration.countyLabel.textColor = .black
        configuration.countyLabel.text = "台北市"
        configuration.districtLabel.font = .systemFont(ofSize: 14.0)
        configuration.districtLabel.textColor = .black
        configuration.districtLabel.text = station.sarea
        configuration.stationLabel.font = .systemFont(ofSize: 14.0)
        configuration.stationLabel.textColor = .black
        configuration.stationLabel.text = station.sna.removingPrefix("YouBike2.0_")
        
        cell.contentConfiguration = configuration
        cell.backgroundConfiguration?.backgroundColor = indexPath.row % 2 == 0 ? .clear : UIColor(hex: "#F6F6F6")
        
        return cell
    }
}
