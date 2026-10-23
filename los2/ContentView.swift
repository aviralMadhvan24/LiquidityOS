import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @StateObject private var viewModel = ResilienceViewModel()
    @StateObject private var concallViewModel = ConcallViewModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        Group {
            if isLoggedIn {
                TabView(selection: $selectedTab) {
                    DashboardView(viewModel: viewModel)
                        .tabItem {
                            Label("Overview", systemImage: "chart.bar.xaxis")
                        }
                        .tag(0)
                    
                    StressTestView(viewModel: viewModel)
                        .tabItem {
                            Label("Stress Test", systemImage: "chart.line.downtrend.xyaxis")
                        }
                        .tag(1)
                    
                    EmergencySimulatorView(viewModel: viewModel)
                        .tabItem {
                            Label("Emergency", systemImage: "bolt.shield.fill")
                        }
                        .tag(2)
                    
                    RunwayView(viewModel: viewModel)
                        .tabItem {
                            Label("Runway", systemImage: "hourglass")
                        }
                        .tag(3)
                    
                    ScenarioCompareView(viewModel: viewModel)
                        .tabItem {
                            Label("Compare", systemImage: "rectangle.split.3x1")
                        }
                        .tag(4)
                    
                    ConcallDashboardView(
                        viewModel: concallViewModel,
                        resilienceViewModel: viewModel
                    )
                    .tabItem {
                        Label("Concall", systemImage: "waveform.badge.magnifyingglass")
                    }
                    .tag(5)
                }
                .tint(LOSTheme.primary)
                .transition(.opacity)
            } else {
                LoginView()
                    .transition(.opacity)
            }
        }
    }
}
