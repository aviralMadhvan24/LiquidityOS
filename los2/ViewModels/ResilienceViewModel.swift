import Foundation
import SwiftUI
import Combine

/// Item wrapper for scenario comparison to avoid tuple keypath issues in ForEach.
struct ScenarioComparisonItem: Identifiable {
    var id: String { scenario.rawValue }
    let scenario: StressScenarioLevel
    let report: ResilienceReport
}

/// Main ViewModel managing the state of financial profiles, stress simulations, and real-time reports.
final class ResilienceViewModel: ObservableObject {
    @Published var profile: FinancialProfile {
        didSet {
            saveToUserDefaults()
        }
    }
    
    @Published var selectedScenario: StressScenarioLevel = .stress
    @Published var customDeclinePercentage: Double = 15.0
    @Published var isUsingCustomDecline: Bool = false
    
    // UI sheet state
    @Published var isShowingEditSheet: Bool = false
    
    init() {
        if let saved = ResilienceViewModel.loadFromUserDefaults() {
            self.profile = saved
        } else {
            self.profile = .pitchDeckSample
        }
    }
    
    var currentDeclinePercentage: Double {
        if isUsingCustomDecline {
            return customDeclinePercentage
        }
        return selectedScenario.percentage
    }
    
    /// Live recalculated report whenever profile or decline changes.
    var currentReport: ResilienceReport {
        ResilienceEngine.analyze(profile: profile, declinePercent: currentDeclinePercentage)
    }
    
    /// Reports for all three standard scenarios (Mild, Stress, Severe) for side-by-side comparison.
    var scenarioComparisons: [ScenarioComparisonItem] {
        StressScenarioLevel.allCases.map { level in
            ScenarioComparisonItem(
                scenario: level,
                report: ResilienceEngine.analyze(profile: profile, declinePercent: level.percentage)
            )
        }
    }
    
    func selectScenario(_ scenario: StressScenarioLevel) {
        isUsingCustomDecline = false
        selectedScenario = scenario
        customDeclinePercentage = scenario.percentage
    }
    
    func setCustomDecline(_ value: Double) {
        isUsingCustomDecline = true
        customDeclinePercentage = value
    }
    
    func resetToDefaults() {
        profile = .pitchDeckSample
        selectedScenario = .stress
        customDeclinePercentage = 15.0
        isUsingCustomDecline = false
    }
    
    // MARK: - Persistence
    private static let storageKey = "LiquidityOS_FinancialProfile_v1"
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }
    
    private static func loadFromUserDefaults() -> FinancialProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(FinancialProfile.self, from: data) else {
            return nil
        }
        return decoded
    }
}
