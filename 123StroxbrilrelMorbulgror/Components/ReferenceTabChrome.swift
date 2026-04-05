import SwiftUI
import UIKit

enum ReferenceTabChrome {
    static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "AppSurface")

        let normal = UIColor(named: "AppTextSecondary") ?? .secondaryLabel
        let selected = UIColor(named: "AppPrimary") ?? .label

        let stacked = appearance.stackedLayoutAppearance
        stacked.normal.iconColor = normal
        stacked.normal.titleTextAttributes = [.foregroundColor: normal]
        stacked.selected.iconColor = selected
        stacked.selected.titleTextAttributes = [.foregroundColor: selected, .font: UIFont.systemFont(ofSize: 10, weight: .semibold)]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().clipsToBounds = false
        UITabBar.appearance().layer.shadowColor = UIColor.black.cgColor
        UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -6)
        UITabBar.appearance().layer.shadowRadius = 14
        UITabBar.appearance().layer.shadowOpacity = 0.22

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(named: "AppBackground")
        nav.titleTextAttributes = [.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
    }
}
