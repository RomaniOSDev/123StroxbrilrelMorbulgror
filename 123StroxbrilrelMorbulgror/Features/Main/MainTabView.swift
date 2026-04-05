import SwiftUI

enum MainTab: Int, CaseIterable {
    case home = 0
    case explore = 1
    case activities = 2
    case profile = 3

    var title: String {
        switch self {
        case .home: return "Home"
        case .explore: return "Explore"
        case .activities: return "Activities"
        case .profile: return "Profile"
        }
    }

    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .explore: return "globe.europe.africa.fill"
        case .activities: return "square.grid.2x2.fill"
        case .profile: return "person.crop.circle"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var progress: ReferenceProgressStore
    @State private var tab: MainTab = .home

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(MainTab.home.title, systemImage: MainTab.home.symbol)
            }
            .tag(MainTab.home)

            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label(MainTab.explore.title, systemImage: MainTab.explore.symbol)
            }
            .tag(MainTab.explore)

            NavigationStack {
                ActivitiesHomeView()
            }
            .tabItem {
                Label(MainTab.activities.title, systemImage: MainTab.activities.symbol)
            }
            .tag(MainTab.activities)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(MainTab.profile.title, systemImage: MainTab.profile.symbol)
            }
            .tag(MainTab.profile)
        }
        .tint(Color.appPrimary)
        .toolbarBackground(Color.appBackground, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            ReferenceTabChrome.apply()
        }
        .environment(\.selectMainTab, { newTab in
            tab = newTab
        })
    }
}
