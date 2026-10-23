import Foundation
import SwiftUI
import Combine

/// Item wrapper for scenario comparison to avoid tuple keypath issues in ForEach.
struct ScenarioComparisonItem: Identifiable {
    var id: String { scenario.rawValue }
    let scenario: StressScenarioLevel
    let report: ResilienceReport
}

/// Main ViewModel managing financial profiles, live market data, granular stress tests, reverse stress, and AI recovery planning.
@MainActor
final class ResilienceViewModel: ObservableObject {
    @Published var profile: FinancialProfile {
        didSet {
            saveToUserDefaults()
        }
    }
    
    // MARK: - Stress Test State (Mode A vs Mode B)
    @Published var stressTestMode: Int = 0 // 0 = Mode A (Portfolio-Wide), 1 = Mode B (Individual Stock)
    @Published var selectedScenario: StressScenarioLevel = .stress
    @Published var customDeclinePercentage: Double = 15.0
    @Published var isUsingCustomDecline: Bool = false
    @Published var stockDeclineOverrides: [String: Double] = [:] // ticker -> decline %
    
    // MARK: - Reverse Stress Testing State
    @Published var reverseStressAssumption = ReverseStressAssumption()
    
    // MARK: - AI Recovery Planner State
    @Published var recoveryPlanResponse: RecoveryPlanResponse? = nil
    @Published var recoveryBaseline: RecoveryBaseline? = nil
    @Published var isGeneratingRecoveryPlan: Bool = false
    @Published var recoveryUserGoals: String = "Protect cash runway & avoid forced stock liquidation"
    
    // MARK: - Market Data Sync State
    @Published var isRefreshingMarketData: Bool = false
    @Published var marketDataMessage: String? = nil
    @Published var marketDataFreshnessSummary: MarketDataFreshness = .demoData
    
    // MARK: - UI Sheet States
    @Published var isShowingEditSheet: Bool = false
    @Published var isShowingZerodhaSheet: Bool = false
    @Published var isShowingScoreBreakdownSheet: Bool = false
    @Published var isShowingPortfolioSheet: Bool = false
    @Published var isShowingReverseStressSheet: Bool = false
    @Published var isShowingRecoverySheet: Bool = false
    
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
        recalculatePortfolioValueFromHoldings()
    }
    
    // MARK: - Active Drawdown Percent (Mode A)
    var currentDeclinePercentage: Double {
        if isUsingCustomDecline {
            return customDeclinePercentage
        }
        return selectedScenario.percentage
    }
    
    // MARK: - Live Report (Mode A or Mode B)
    var currentReport: ResilienceReport {
        if stressTestMode == 1 {
            // Mode B: Calculate total loss from individual stock shocks
            let totalLoss = totalIndividualStockLoss
            let effectiveDecline = profile.portfolioValue > 0 ? (totalLoss / profile.portfolioValue) * 100.0 : currentDeclinePercentage
            return ResilienceEngine.analyze(profile: profile, declinePercent: effectiveDecline)
        }
        return ResilienceEngine.analyze(profile: profile, declinePercent: currentDeclinePercentage)
    }
    
    // MARK: - Explainable 5-Pillar Score
    var explainableScoreReport: ExplainableResilienceReport {
        let decline = stressTestMode == 1 ? effectiveIndividualDeclinePercent : currentDeclinePercentage
        return ResilienceEngine.calculateExplainableScore(profile: profile, declinePercent: decline)
    }
    
    // MARK: - Mode B: Individual Stock Shock Calculations
    var effectiveIndividualDeclinePercent: Double {
        guard profile.portfolioValue > 0 else { return currentDeclinePercentage }
        return (totalIndividualStockLoss / profile.portfolioValue) * 100.0
    }
    
    var totalIndividualStockLoss: Double {
        profile.activeHoldings.reduce(0.0) { sum, h in
            let decline = stockDeclineOverrides[h.ticker] ?? currentDeclinePercentage
            let loss = h.currentValue * (decline / 100.0)
            return sum + loss
        }
    }
    
    struct IndividualStockLossItem: Identifiable {
        var id: String { holding.ticker }
        let holding: PortfolioHolding
        let assumedDecline: Double
        let simulatedLoss: Double
        let simulatedRemainingValue: Double
        let lossContributionPercent: Double
    }
    
    var individualLossBreakdown: [IndividualStockLossItem] {
        let totalLoss = max(1.0, totalIndividualStockLoss)
        return profile.activeHoldings.map { h in
            let decline = stockDeclineOverrides[h.ticker] ?? currentDeclinePercentage
            let loss = h.currentValue * (decline / 100.0)
            let remaining = max(0, h.currentValue - loss)
            let contribution = (loss / totalLoss) * 100.0
            return IndividualStockLossItem(
                holding: h,
                assumedDecline: decline,
                simulatedLoss: loss,
                simulatedRemainingValue: remaining,
                lossContributionPercent: contribution
            )
        }.sorted { $0.simulatedLoss > $1.simulatedLoss }
    }
    
    func setIndividualStockDecline(ticker: String, percentage: Double) {
        stockDeclineOverrides[ticker] = max(0, min(100, percentage))
    }
    
    func resetIndividualStockDeclines() {
        stockDeclineOverrides.removeAll()
    }
    
    // MARK: - Reverse Stress Result (Computed Live)
    var reverseStressResult: ReverseStressResult {
        ReverseStressEngine.calculateBreakingPoint(
            profile: profile,
            assumption: reverseStressAssumption
        )
    }
    
    // MARK: - Scenario Comparison Items
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
        resetIndividualStockDeclines()
    }
    
    // MARK: - Portfolio Holdings Management
    func addOrUpdateHolding(
        ticker: String,
        companyName: String,
        shares: Int,
        averageBuyPrice: Double,
        sector: String = "Equity",
        currentPrice: Double? = nil
    ) {
        var list = profile.activeHoldings
        let cleanTicker = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if let existingIndex = list.firstIndex(where: { $0.ticker.uppercased() == cleanTicker }) {
            // Update existing holding
            var existing = list[existingIndex]
            existing.shares = shares
            existing.averageBuyPrice = averageBuyPrice
            if let cp = currentPrice { existing.currentPrice = cp }
            existing.lastUpdated = Date()
            list[existingIndex] = existing
        } else {
            // Add new holding
            let newHolding = PortfolioHolding(
                companyName: companyName,
                ticker: cleanTicker,
                sector: sector,
                shares: shares,
                averageBuyPrice: averageBuyPrice,
                currentPrice: currentPrice ?? averageBuyPrice,
                freshness: .demoData,
                lastUpdated: Date()
            )
            list.append(newHolding)
        }
        
        profile.holdings = list
        recalculatePortfolioValueFromHoldings()
    }
    
    func deleteHolding(id: UUID) {
        var list = profile.activeHoldings
        list.removeAll { $0.id == id }
        profile.holdings = list
        recalculatePortfolioValueFromHoldings()
    }
    
    func recalculatePortfolioValueFromHoldings() {
        let list = profile.activeHoldings
        guard !list.isEmpty else { return }
        
        let totalVal = list.reduce(0.0) { $0 + $1.currentValue }
        profile.portfolioValue = totalVal
        
        // Update weights
        if totalVal > 0 {
            profile.holdings = list.map { h in
                var updated = h
                updated.portfolioWeightPercent = Double(round((h.currentValue / totalVal) * 1000) / 10)
                return updated
            }
        }
    }
    
    // MARK: - Live Market Data Refresh
    func refreshMarketPrices() async {
        isRefreshingMarketData = true
        marketDataMessage = nil
        
        let tickers = profile.activeHoldings.map { $0.ticker }
        do {
            let quotes = try await MarketDataAPIService.shared.fetchBatchQuotes(symbols: tickers, force: true)
            var updatedList = profile.activeHoldings
            var primaryFreshness: MarketDataFreshness = .demoData
            
            for i in 0..<updatedList.count {
                let sym = updatedList[i].ticker
                if let q = quotes[sym] {
                    updatedList[i].currentPrice = q.currentPrice
                    updatedList[i].previousClose = q.previousClose
                    updatedList[i].priceChange = q.change
                    updatedList[i].priceChangePercent = q.changePercent
                    let f = MarketDataFreshness(rawValue: q.freshness) ?? .demoData
                    updatedList[i].freshness = f
                    primaryFreshness = f
                    updatedList[i].lastUpdated = Date()
                    updatedList[i].staleWarning = q.staleWarning
                }
            }
            
            profile.holdings = updatedList
            recalculatePortfolioValueFromHoldings()
            marketDataFreshnessSummary = primaryFreshness
            isRefreshingMarketData = false
            marketDataMessage = "Quotes refreshed (\(primaryFreshness.displayName))."
        } catch {
            isRefreshingMarketData = false
            marketDataMessage = "Refresh failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - AI Recovery Planner
    func fetchRecoveryPlans() async {
        isGeneratingRecoveryPlan = true
        do {
            let res = try await RecoveryAPIService.shared.generateRecoveryPlan(
                profile: profile,
                simulatedLoss: currentReport.estimatedPortfolioLoss,
                incomeLossMonths: reverseStressAssumption.scenarioDurationMonths,
                userGoals: recoveryUserGoals
            )
            recoveryBaseline = res.baseline
            recoveryPlanResponse = res.recovery
            isGeneratingRecoveryPlan = false
        } catch {
            isGeneratingRecoveryPlan = false
        }
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
        recalculatePortfolioValueFromHoldings()
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
