import Foundation

/// Represents the user's base financial reality across all three financial silos:
/// 1. Investments (Portfolio & optional individual holdings)
/// 2. Liquid Savings (Cash)
/// 3. Cash Flow (Monthly Income & Fixed Expenses)
struct FinancialProfile: Equatable, Codable {
    var portfolioValue: Double
    var liquidCash: Double
    var monthlyIncome: Double
    var monthlyExpenses: Double
    var unexpectedExpense: Double
    var holdings: [PortfolioHolding]?
    
    /// Default values based directly on the illustrative hackathon pitch deck:
    /// - Portfolio: ₹5,00,000
    /// - Liquid Cash: ₹80,000
    /// - Monthly Income: ₹10,000
    /// - Monthly Expenses: ₹20,000
    /// - Emergency Bill: ₹50,000
    static let pitchDeckSample = FinancialProfile(
        portfolioValue: 500_000,
        liquidCash: 80_000,
        monthlyIncome: 10_000,
        monthlyExpenses: 20_000,
        unexpectedExpense: 50_000,
        holdings: PortfolioHolding.pitchDeckHoldings
    )
    
    /// Monthly burn rate without any shocks: Expenses minus Income
    var baselineNetCashBurn: Double {
        return monthlyExpenses - monthlyIncome
    }
    
    /// Returns either user-defined holdings or sensible default holdings matching total portfolio value
    var activeHoldings: [PortfolioHolding] {
        if let h = holdings, !h.isEmpty {
            return h
        }
        return PortfolioHolding.pitchDeckHoldings
    }
    
    // Explicit Codable implementation to guarantee backwards compatibility
    enum CodingKeys: String, CodingKey {
        case portfolioValue, liquidCash, monthlyIncome, monthlyExpenses, unexpectedExpense, holdings
    }
    
    init(portfolioValue: Double, liquidCash: Double, monthlyIncome: Double, monthlyExpenses: Double, unexpectedExpense: Double, holdings: [PortfolioHolding]? = nil) {
        self.portfolioValue = portfolioValue
        self.liquidCash = liquidCash
        self.monthlyIncome = monthlyIncome
        self.monthlyExpenses = monthlyExpenses
        self.unexpectedExpense = unexpectedExpense
        self.holdings = holdings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.portfolioValue = try container.decode(Double.self, forKey: .portfolioValue)
        self.liquidCash = try container.decode(Double.self, forKey: .liquidCash)
        self.monthlyIncome = try container.decode(Double.self, forKey: .monthlyIncome)
        self.monthlyExpenses = try container.decode(Double.self, forKey: .monthlyExpenses)
        self.unexpectedExpense = try container.decode(Double.self, forKey: .unexpectedExpense)
        self.holdings = try container.decodeIfPresent([PortfolioHolding].self, forKey: .holdings) ?? PortfolioHolding.pitchDeckHoldings
    }
}
