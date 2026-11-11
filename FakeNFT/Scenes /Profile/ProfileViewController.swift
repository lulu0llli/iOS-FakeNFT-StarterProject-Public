import UIKit
import ProgressHUD

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    
    private let presenter: ProfilePresenterProtocol
    
    private var currentProfile: Profile?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileMenuCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var headerView = ProfileHeaderView()
    private let menuItems = ["Мои NFT", "Избранные NFT"]
    
    private enum Constants {
        static let menuRowHeight: CGFloat = 54
    }
    
    // MARK: - Init
    init(presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupViews()
        setupConstraints()
        presenter.viewDidLoad()
    }
    
    private func setupNavigationBar() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        let editImage = UIImage(systemName: "square.and.pencil", withConfiguration: config)
        
        let editButton = UIBarButtonItem(
            image: editImage,
            style: .plain,
            target: self,
            action: #selector(didTapEditButton)
        )
        editButton.tintColor = UIColor(named: "YPBlack") ?? .black
        navigationItem.rightBarButtonItem = editButton
    }
    
    @objc private func didTapEditButton() {
        presenter.didTapEdit()
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateHeaderLayout() {
        guard let header = tableView.tableHeaderView else { return }
        let size = header.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if header.frame.height != size.height {
            header.frame.size.height = size.height
            tableView.tableHeaderView = header
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeaderLayout()
    }
    
    func showLoading() { DispatchQueue.main.async { ProgressHUD.show() } }
    func hideLoading() { DispatchQueue.main.async { ProgressHUD.dismiss() } }
    
    func showProfile(_ profile: Profile) {
        DispatchQueue.main.async {
            self.currentProfile = profile
            self.headerView.configure(with: profile)
            self.updateHeaderLayout()
            self.tableView.reloadData()
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ОК", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func showEditScreen(with profile: Profile) {
        let editVC = EditProfileViewController(profile: profile)
        editVC.hidesBottomBarWhenPushed = true
        editVC.onProfileUpdated = { [weak self] updatedProfile in
            self?.presenter.updateProfile(with: updatedProfile)
        }
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func navigateToMyNFTs() {
        let myNFTVC = MyNFTViewController()
        myNFTVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(myNFTVC, animated: true)
    }
    
    func navigateToFavorites() {
        let favoritesVC = FavoriteNFTViewController()
        favoritesVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(favoritesVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if indexPath.row == 0 {
            let count = currentProfile?.nfts.count ?? 0
            content.text = "\(NSLocalizedString("Profile.myNFTs", comment: "")) (\(count))"
        } else {
            let count = currentProfile?.likes.count ?? 0
            content.text = "\(NSLocalizedString("Profile.favoriteNFTs", comment: "")) (\(count))"
        }
        
        content.textProperties.font = UIFont(name: "SFProText-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        content.textProperties.color = UIColor(named: "YPBlack") ?? .black
        cell.contentConfiguration = content
        
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronImageView.tintColor = UIColor(named: "YPBlack") ?? .black
        cell.accessoryView = chevronImageView
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.menuRowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            presenter.didTapMyNFTs()
        } else {
            presenter.didTapFavorites()
        }
    }
}
