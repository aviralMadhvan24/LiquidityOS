import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ResilienceViewModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
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
        }
        .tint(LOSTheme.primary)
    }
}
