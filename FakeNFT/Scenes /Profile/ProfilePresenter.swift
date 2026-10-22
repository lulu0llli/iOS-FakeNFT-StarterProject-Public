import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Свойства
    weak var view: ProfileViewProtocol?
    
    // В будущем здесь будет NetworkClient
    // private let networkClient: NetworkClient

    init() {}
    
    // MARK: - ProfilePresenterProtocol
    func viewDidLoad() {
        loadProfile()
    }
    
    func didTapMyNFTs() {
        print("Нажата кнопка Мои NFT")
        // Здесь будет навигация на экран Мои NFT
    }
    
    func didTapFavorites() {
        print("Нажата кнопка Избранные NFT")
        // Здесь будет навигация на экран Избранные NFT
    }
    
    func didTapWebsite(urlString: String?) {
        print("Нажата ссылка на сайт: \(urlString ?? "нет ссылки")")
        // Здесь будет открытие WKWebView
    }
    
    // MARK: - Private Methods
    private func loadProfile() {
        view?.showLoading()
        
        // Имитация сетевого запроса (пока используем мок)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.view?.hideLoading()
            
            // Моковые данные (потом заменим на запрос к FakeNFT)
            let mockProfile = Profile(
                id: "1",
                name: "Ульяна",
                description: "Начинающий iOS-разработчик. Люблю писать чистый код и решать сложные задачи.",
                website: "https://github.com/lulu0llli",
                avatar: "",
                nfts: [],
                likes: []
            )
            self?.view?.showProfile(mockProfile)
        }
    }
}
