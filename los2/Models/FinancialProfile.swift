import Foundation

/// Represents the user's base financial reality across all three financial silos:
/// 1. Investments (Portfolio)
/// 2. Liquid Savings (Cash)
/// 3. Cash Flow (Monthly Income & Fixed Expenses)
struct FinancialProfile: Equatable, Codable {
    var portfolioValue: Double
    var liquidCash: Double
    var monthlyIncome: Double
    var monthlyExpenses: Double
    var unexpectedExpense: Double
    
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
        unexpectedExpense: 50_000
    )
    
    /// Monthly burn rate without any shocks: Expenses minus Income
    var baselineNetCashBurn: Double {
        return monthlyExpenses - monthlyIncome
    }
}
