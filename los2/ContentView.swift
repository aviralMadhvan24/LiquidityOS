import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @StateObject private var viewModel = ResilienceViewModel()
    @StateObject private var concallViewModel = ConcallViewModel()
    @State private var selectedTab: AppTab = .overview
    
    var body: some View {
        Group {
            if isLoggedIn {
                TabView(selection: $selectedTab) {
                    DashboardView(viewModel: viewModel)
                        .tabItem {
                            Label(AppTab.overview.rawValue, systemImage: AppTab.overview.iconName)
                        }
                        .tag(AppTab.overview)
                    
                    StressTestView(viewModel: viewModel)
                        .tabItem {
                            Label(AppTab.stressTest.rawValue, systemImage: AppTab.stressTest.iconName)
                        }
                        .tag(AppTab.stressTest)
                    
                    EmergencySimulatorView(viewModel: viewModel)
                        .tabItem {
                            Label(AppTab.emergency.rawValue, systemImage: AppTab.emergency.iconName)
                        }
                        .tag(AppTab.emergency)
                    
                    RunwayView(viewModel: viewModel)
                        .tabItem {
                            Label(AppTab.runway.rawValue, systemImage: AppTab.runway.iconName)
                        }
                        .tag(AppTab.runway)
                    
                    ConcallDashboardView(
                        viewModel: concallViewModel,
                        resilienceViewModel: viewModel
                    )
                    .tabItem {
                        Label(AppTab.concall.rawValue, systemImage: AppTab.concall.iconName)
                    }
                    .tag(AppTab.concall)
                }
                .tint(LOSTheme.primary)
                .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: isLoggedIn)
    }
}
