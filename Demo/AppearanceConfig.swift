import UIKit

extension UITabBar {
    static func configureWithOpaqueBackground() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // tabBarAppearance.backgroundColor = .systemGray5
        tabBarAppearance.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1.00)
        
        appearance().standardAppearance = tabBarAppearance
        appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

extension UINavigationBar {
    static func configureWithOpaqueBackground() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        // navigationBarAppearance.backgroundColor = .systemBlue
        navigationBarAppearance.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1.00)
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        appearance().scrollEdgeAppearance = navigationBarAppearance
        appearance().standardAppearance = navigationBarAppearance
    }
}
