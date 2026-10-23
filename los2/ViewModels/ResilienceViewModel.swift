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
    
    // UI sheet states
    @Published var isShowingEditSheet: Bool = false
    @Published var isShowingZerodhaSheet: Bool = false
    
    // Broker Sync State (Zerodha Kite)
    @Published var isZerodhaConnected: Bool = false
    @Published var zerodhaUser: ZerodhaUser? = nil
    @Published var lastZerodhaSyncDate: Date? = nil
    
    init() {
        if let saved = ResilienceViewModel.loadFromUserDefaults() {
            self.profile = saved
        } else {
            self.profile = .pitchDeckSample
        }
        
        loadZerodhaSession()
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
    
    // MARK: - Zerodha Kite Sync
    func syncWithZerodha(portfolioValue: Double, cashBalance: Double?, holdings: [PortfolioHolding], user: ZerodhaUser?) {
        profile.portfolioValue = portfolioValue
        if let cash = cashBalance, cash > 0 {
            profile.liquidCash = cash
        }
        if !holdings.isEmpty {
            profile.holdings = holdings
        }
        self.zerodhaUser = user
        self.isZerodhaConnected = true
        self.lastZerodhaSyncDate = Date()
        saveZerodhaSession()
    }
    
    func disconnectZerodha() {
        isZerodhaConnected = false
        zerodhaUser = nil
        lastZerodhaSyncDate = nil
        UserDefaults.standard.removeObject(forKey: zerodhaStorageKey)
        Task {
            try? await ZerodhaAPIService.shared.disconnect()
        }
    }
    
    private let zerodhaStorageKey = "LiquidityOS_ZerodhaUser_v1"
    
    private func saveZerodhaSession() {
        if let user = zerodhaUser, let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: zerodhaStorageKey)
        }
    }
    
    private func loadZerodhaSession() {
        guard let data = UserDefaults.standard.data(forKey: zerodhaStorageKey),
              let decoded = try? JSONDecoder().decode(ZerodhaUser.self, from: data) else {
            return
        }
        self.zerodhaUser = decoded
        self.isZerodhaConnected = true
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
