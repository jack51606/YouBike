import UIKit

@MainActor
public final class MainController: UIViewController {
    
    private let navigationBar = UIView()
    private var viewControllers: [UIViewController] = []
    private var selectedIndex = 2 {
        didSet {
            show(viewControllers[selectedIndex], sender: self)
            menuButtonTapped()
        }
    }
    
    private let menuView = UIView()
    private let menuButton = UIButton()
    private var menuCollectionView: UICollectionView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        additionalSafeAreaInsets.top = 72.0
        
        viewControllers = [UIViewController(), UIViewController(), StationInformationViewController(), UIViewController(), UIViewController()]
        show(viewControllers[selectedIndex], sender: self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setNavigationBar()
        setMenuView()
    }
    
    public override func show(_ vc: UIViewController, sender: Any?) {
        
        for child in children {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        
        addChild(vc)
        vc.view.frame = view.frame
        view.insertSubview(vc.view, at: 0)
        vc.didMove(toParent: self)
    }
    
    private func setNavigationBar() {
        
        // Navigation Bar
        let topInset = view.window?.safeAreaInsets.top ?? 0.0
        
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: topInset),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: 72.0)
        ])
        
        // Logo
        let logoImageView = UIImageView(image: UIImage(named: "UbikeLogo"))
        logoImageView.contentMode = .scaleAspectFit
        navigationBar.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 32.0),
            logoImageView.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 65.0)
        ])
        
        // Menu Button
        var menuButtonConfiguration = UIButton.Configuration.plain()
        menuButtonConfiguration.baseBackgroundColor = .clear
        menuButton.configuration = menuButtonConfiguration
        menuButton.configurationUpdateHandler = { button in
            if button.state == .normal {
                button.configuration?.image = UIImage(named: "BurgerBar")
            } else if button.state == .selected {
                button.configuration?.image = UIImage(named: "Xmark")
            }
        }
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        navigationBar.addSubview(menuButton)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuButton.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor, constant: -24.0),
            menuButton.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 24.0)
        ])
        
        // Separator
        let separator = UIView()
        separator.backgroundColor = UIColor(hex: "#EBEBEB")
        navigationBar.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separator.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: navigationBar.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    private func setMenuView() {
        
        // Menu View
        menuView.backgroundColor = .tintColor
        
        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Menu CollectionView
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .sidebarPlain)
        listConfiguration.backgroundColor = .clear
        listConfiguration.showsSeparators = false
        let layout = UICollectionViewCompositionalLayout.list(using: listConfiguration)
        
        menuCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        menuCollectionView.dataSource = self
        menuCollectionView.delegate = self
        menuCollectionView.register(UICollectionViewListCell.self, forCellWithReuseIdentifier: UICollectionViewListCell.self.description())
        menuCollectionView.contentInset.top = 16.0
        menuCollectionView.backgroundColor = .clear
        
        menuView.addSubview(menuCollectionView)
        menuCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuCollectionView.topAnchor.constraint(equalTo: menuView.topAnchor),
            menuCollectionView.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            menuCollectionView.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            menuCollectionView.trailingAnchor.constraint(equalTo: menuView.trailingAnchor)
        ])
        
        // Login Button
        let loginButton = UIButton()
        loginButton.setTitle("登入", for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16.0)
        loginButton.setTitleColor(.tintColor, for: .normal)
        loginButton.backgroundColor = .white
        loginButton.layer.cornerRadius = 20.0
        menuView.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.bottomAnchor.constraint(equalTo: menuView.bottomAnchor, constant: -72.0),
            loginButton.leadingAnchor.constraint(equalTo: menuView.leadingAnchor, constant: 40.0),
            loginButton.widthAnchor.constraint(equalToConstant: 80.0),
            loginButton.heightAnchor.constraint(equalToConstant: 40.0)
        ])
        
        menuView.alpha = 0
    }
    
    @objc private func menuButtonTapped() {
        
        menuButton.isSelected.toggle()
        UIView.animate(withDuration: 0.2) {
            self.menuView.alpha = self.menuButton.isSelected ? 1 : 0
        }
    }
}

extension MainController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewListCell.self.description(), for: indexPath) as! UICollectionViewListCell
        
        var configuration: LabelConfiguration
        if let cellConfiguration = cell.contentConfiguration as? LabelConfiguration {
            configuration = cellConfiguration
        } else {
            configuration = LabelConfiguration()
        }
        
        configuration.height = 60.0
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        configuration.label.font = .systemFont(ofSize: 18.0, weight: .medium)
        configuration.label.textColor = indexPath.row == selectedIndex ? UIColor(hex: "#677510")! : .white
        
        switch indexPath.row {
        case 0:
            configuration.label.text = "使 用 說 明"
        case 1:
            configuration.label.text = "收 費 方 式"
        case 2:
            configuration.label.text = "站 點 資 訊"
        case 3:
            configuration.label.text = "最 新 消 息"
        case 4:
            configuration.label.text = "活 動 專 區"
        default:
            break
        }
        
        cell.contentConfiguration = configuration
        cell.backgroundConfiguration?.backgroundColor = .tintColor
        
        return cell
    }
}

extension MainController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard indexPath.row != selectedIndex else { return }
        
        selectedIndex = indexPath.row
        collectionView.reloadData()
    }
}
