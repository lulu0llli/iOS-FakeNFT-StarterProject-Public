import UIKit
import Kingfisher

final class EditProfileViewController: UIViewController {
    
    // MARK: - Свойства
    var onProfileUpdated: ((Profile) -> Void)?
    private var profile: Profile
    private var hasUnsavedChanges = false
    
    // MARK: - UI Элементы
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var avatarWrapperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var cameraIconView: UIImageView = {
        let imageView = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        imageView.image = UIImage(systemName: "camera.fill", withConfiguration: config)
        imageView.tintColor = UIColor(named: "YPBlack") ?? .black
        imageView.backgroundColor = UIColor(named: "YPBackground") ?? .systemGray6
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 11.28
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameTitleLabel: UILabel = createTitleLabel(text: "Имя")
    private lazy var descriptionTitleLabel: UILabel = createTitleLabel(text: "Описание")
    private lazy var websiteTitleLabel: UILabel = createTitleLabel(text: "Сайт")
    
    private lazy var nameTextField: UITextField = {
        let textField = createTextField(placeholder: "Введите имя")
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var websiteTextField: UITextField = {
        let textField = createTextField(placeholder: "Введите ссылку")
        textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "YPBackground") ?? .systemGray6
        textView.layer.cornerRadius = 12
        textView.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        textView.textColor = UIColor(named: "YPBlack") ?? .black
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "SFProText-Bold", size: 17) ?? .systemFont(ofSize: 17, weight: .bold)
        button.backgroundColor = UIColor(named: "YPBlack") ?? .black
        button.layer.cornerRadius = 16
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        return button
    }()
    
    // 🔥 Лоадер (по макету 82x82, фон #F7F7F8, радиус 8)
    private lazy var loadingContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YPBackground") ?? .systemGray6
        view.layer.cornerRadius = 8
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor(named: "YPBlack") ?? .black
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Init
    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupNavigationBar()
        setupViews()
        setupConstraints()
        fillFields()
        setupKeyboardDismissGesture()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(didTapBackButton)
        )
        backButton.tintColor = UIColor(named: "YPBlack") ?? .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        view.addSubview(saveButton)
        
        // Добавляем лоадер
        view.addSubview(loadingContainerView)
        loadingContainerView.addSubview(activityIndicator)
        
        avatarContainerView.addSubview(avatarImageView)
        avatarContainerView.addSubview(cameraIconView)
        avatarWrapperView.addSubview(avatarContainerView)
        
        contentStackView.addArrangedSubview(avatarWrapperView)
        contentStackView.setCustomSpacing(24, after: avatarWrapperView)
        
        contentStackView.addArrangedSubview(nameTitleLabel)
        contentStackView.setCustomSpacing(8, after: nameTitleLabel)
        contentStackView.addArrangedSubview(nameTextField)
        contentStackView.setCustomSpacing(24, after: nameTextField)
        
        contentStackView.addArrangedSubview(descriptionTitleLabel)
        contentStackView.setCustomSpacing(8, after: descriptionTitleLabel)
        contentStackView.addArrangedSubview(descriptionTextView)
        contentStackView.setCustomSpacing(24, after: descriptionTextView)
        
        contentStackView.addArrangedSubview(websiteTitleLabel)
        contentStackView.setCustomSpacing(8, after: websiteTitleLabel)
        contentStackView.addArrangedSubview(websiteTextField)
        
        contentStackView.setCustomSpacing(100, after: websiteTextField)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 80),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            avatarWrapperView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            avatarContainerView.centerXAnchor.constraint(equalTo: avatarWrapperView.centerXAnchor),
            avatarContainerView.topAnchor.constraint(equalTo: avatarWrapperView.topAnchor),
            avatarContainerView.bottomAnchor.constraint(equalTo: avatarWrapperView.bottomAnchor),
            avatarContainerView.widthAnchor.constraint(equalToConstant: 72.56),
            avatarContainerView.heightAnchor.constraint(equalToConstant: 70),
            
            avatarImageView.topAnchor.constraint(equalTo: avatarContainerView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainerView.leadingAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            cameraIconView.trailingAnchor.constraint(equalTo: avatarContainerView.trailingAnchor),
            cameraIconView.bottomAnchor.constraint(equalTo: avatarContainerView.bottomAnchor),
            cameraIconView.widthAnchor.constraint(equalToConstant: 22.56),
            cameraIconView.heightAnchor.constraint(equalToConstant: 22.56),
            
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            websiteTextField.heightAnchor.constraint(equalToConstant: 44),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 132),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Констрейнты для лоадера
            loadingContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingContainerView.widthAnchor.constraint(equalToConstant: 82),
            loadingContainerView.heightAnchor.constraint(equalToConstant: 82),
            
            activityIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingContainerView.centerYAnchor)
        ])
    }
    
    private func fillFields() {
        nameTextField.text = profile.name
        descriptionTextView.text = profile.description
        websiteTextField.text = profile.website
        
        if let url = URL(string: profile.avatar) {
            avatarImageView.kf.setImage(with: url)
        }
    }
    
    // MARK: - Отслеживание изменений
    @objc private func textDidChange() {
        checkForChanges()
    }
    
    private func checkForChanges() {
        let isNameChanged = nameTextField.text != profile.name
        let isWebsiteChanged = websiteTextField.text != profile.website
        let isDescriptionChanged = descriptionTextView.text != profile.description
        
        hasUnsavedChanges = isNameChanged || isWebsiteChanged || isDescriptionChanged
        
        UIView.animate(withDuration: 0.2) {
            self.saveButton.isHidden = !self.hasUnsavedChanges
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Сохранение
    @objc private func didTapSave() {
        // Прячем клавиатуру и кнопку
        view.endEditing(true)
        saveButton.isHidden = true
        
        // Показываем лоадер
        loadingContainerView.isHidden = false
        activityIndicator.startAnimating()
        
        // Имитация сетевого запроса (1.5 секунды)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            let newName = self.nameTextField.text ?? ""
            let newDescription = self.descriptionTextView.text ?? ""
            let newWebsite = self.websiteTextField.text ?? ""
            
            let finalName = newName.isEmpty ? self.profile.name : newName
            let finalDescription = newDescription.isEmpty ? self.profile.description : newDescription
            let finalWebsite = newWebsite.isEmpty ? self.profile.website : newWebsite
            
            let updatedProfile = Profile(
                id: self.profile.id,
                name: finalName,
                description: finalDescription,
                website: finalWebsite,
                avatar: self.profile.avatar,
                nfts: self.profile.nfts,
                likes: self.profile.likes
            )
            
            // Останавливаем лоадер
            self.activityIndicator.stopAnimating()
            self.loadingContainerView.isHidden = true
            
            // Возвращаем данные и закрываем экран
            self.onProfileUpdated?(updatedProfile)
            self.navigateBack()
        }
    }
    
    // MARK: - Выход с проверкой
    @objc private func didTapBackButton() {
        if hasUnsavedChanges {
            showExitAlert()
        } else {
            navigateBack()
        }
    }
    
    private func showExitAlert() {
        let alert = UIAlertController(
            title: "Уверены,\nчто хотите выйти?",
            message: nil,
            preferredStyle: .alert
        )
        
        let stayAction = UIAlertAction(title: "Остаться", style: .cancel)
        
        let exitAction = UIAlertAction(title: "Выйти", style: .default) { [weak self] _ in
            self?.navigateBack()
        }
        
        alert.addAction(stayAction)
        alert.addAction(exitAction)
        
        present(alert, animated: true)
    }
    
    private func navigateBack() {
        if let navController = navigationController, navController.viewControllers.first != self {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - Клавиатура
    private func setupKeyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    // MARK: - Helpers
    private func createTitleLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "SFProText-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(named: "YPBlack") ?? .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor(named: "YPBackground") ?? .systemGray6
        textField.layer.cornerRadius = 12
        textField.font = UIFont(name: "SFProText-Regular", size: 17) ?? .systemFont(ofSize: 17)
        textField.textColor = UIColor(named: "YPBlack") ?? .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
}

// MARK: - UITextViewDelegate
extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        checkForChanges()
    }
}
