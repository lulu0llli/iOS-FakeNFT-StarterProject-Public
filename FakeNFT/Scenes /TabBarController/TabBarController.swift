import UIKit

final class TabBarController: UITabBarController {

    var servicesAssembly: ServicesAssembly!

    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
    )
    
    // Добавляем настройку для нашей вкладки Профиля
    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(systemName: "person.crop.circle"),
        tag: 1
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Вкладка Каталог (существующая)
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        catalogController.tabBarItem = catalogTabBarItem

        // 2. Вкладка Профиль (наша новая)
        let profileController = ProfileAssembly.assemble()
        
        // Оборачиваем профиль в UINavigationController,
        // чтобы в будущем можно было переходить на экраны "Мои NFT" и "Избранные"
        let profileNavController = UINavigationController(rootViewController: profileController)
        profileNavController.tabBarItem = profileTabBarItem

        // Добавляем обе вкладки в таббар
        viewControllers = [catalogController, profileNavController]

        view.backgroundColor = .systemBackground
    }
}
