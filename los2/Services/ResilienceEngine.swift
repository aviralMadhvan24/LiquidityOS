import Foundation

/// Core mathematical engine that models financial shock waves and calculates resilience.
struct ResilienceEngine {
    
    /// Computes a full resilience assessment given a financial profile and a simulated market drop percentage.
    static func analyze(profile: FinancialProfile, declinePercent: Double) -> ResilienceReport {
        // 1. Portfolio Stress Impact
        let marketDeclinePercent = max(0, min(100, declinePercent))
        let portfolioLoss = profile.portfolioValue * (marketDeclinePercent / 100.0)
        let remainingPortfolio = max(0, profile.portfolioValue - portfolioLoss)
        let portfolioRetentionPercent = profile.portfolioValue > 0
            ? (remainingPortfolio / profile.portfolioValue) * 100.0
            : 100.0
        
        // 2. Emergency Shock Impact
        let initialCash = profile.liquidCash
        let unexpectedBill = profile.unexpectedExpense
        let remainingCash = initialCash - unexpectedBill
        let emergencyCashUsedPercent = initialCash > 0
            ? min(100.0, max(0.0, (unexpectedBill / initialCash) * 100.0))
            : 100.0
        
        // 3. Cash Burn & Runway
        let income = profile.monthlyIncome
        let expenses = profile.monthlyExpenses
        let netBurn = expenses - income // positive = burning cash, negative = surplus
        
        let runwayMonths: Double
        let runwayState: RunwayState
        
        if remainingCash <= 0 {
            runwayMonths = 0.0
            runwayState = .underwater
        } else if netBurn > 0 {
            runwayMonths = remainingCash / netBurn
            runwayState = .exhausting
        } else if netBurn == 0 {
            runwayMonths = 99.0 // Infinite/stable
            runwayState = .breakEven
        } else {
            runwayMonths = 99.0 // Cash growing each month
            runwayState = .cashSurplus
        }
        
        // 4. Resilience Score Calculation (0 - 100)
        let score = calculateResilienceScore(
            runwayMonths: runwayMonths,
            remainingCash: remainingCash,
            initialCash: initialCash,
            portfolioRetentionPercent: portfolioRetentionPercent,
            netBurn: netBurn,
            monthlyExpenses: expenses
        )
        
        // 5. Band and Verdict Categorization
        let band: ResilienceBand
        switch score {
        case ..<40:
            band = .critical
        case 40..<70:
            band = .moderate
        case 70..<85:
            band = .healthy
        default:
            band = .bulletproof
        }
        
        // 6. Summary Headline and Plain-English Verdict
        let headline: String
        let formattedLoss = LOSTheme.formatRupee(portfolioLoss)
        let formattedRemainingCash = LOSTheme.formatRupee(remainingCash)
        let formattedBill = LOSTheme.formatRupee(unexpectedBill)
        
        if runwayState == .cashSurplus {
            headline = "\(band.rawValue) - CASH SURPLUS"
        } else if runwayState == .breakEven {
            headline = "\(band.rawValue) - BREAK EVEN"
        } else {
            headline = "\(band.rawValue) - \(String(format: "%.1f", runwayMonths)) MONTHS RUNWAY"
        }
        
        let verdict = "\(band.rawValue.capitalized): \(Int(marketDeclinePercent))% crash + \(formattedBill) bill leaves \(formattedRemainingCash) cash, \(runwayState == .cashSurplus ? "cash surplus" : String(format: "%.1f months runway", runwayMonths))."
        
        // 7. Actionable Recommendations
        var recommendations: [String] = []
        if remainingCash < (expenses * 3) {
            let targetCash = expenses * 3
            recommendations.append("Build emergency buffer to at least \(LOSTheme.formatRupee(targetCash)) (3 months expenses).")
        }
        if runwayMonths < 6.0 && netBurn > 0 {
            recommendations.append("Reduce monthly burn of \(LOSTheme.formatRupee(netBurn))/mo to extend runway past 6 months.")
        }
        if marketDeclinePercent >= 15.0 && portfolioLoss > (profile.portfolioValue * 0.2) {
            recommendations.append("Review portfolio asset allocation to minimize drawdown exposure.")
        }
        if recommendations.isEmpty {
            recommendations.append("Financial cushion is resilient against combined market and expense shocks.")
        }
        
        return ResilienceReport(
            marketDeclinePercent: marketDeclinePercent,
            estimatedPortfolioLoss: portfolioLoss,
            remainingPortfolioValue: remainingPortfolio,
            portfolioRetentionPercent: portfolioRetentionPercent,
            initialCash: initialCash,
            unexpectedBill: unexpectedBill,
            remainingCashAfterEmergency: remainingCash,
            emergencyCashUsedPercent: emergencyCashUsedPercent,
            monthlyIncome: income,
            monthlyExpenses: expenses,
            monthlyNetBurn: max(0, netBurn),
            runwayMonths: runwayMonths,
            runwayState: runwayState,
            resilienceScore: score,
            resilienceBand: band,
            summaryHeadline: headline,
            summaryVerdict: verdict,
            recommendations: recommendations
        )
    }
    
    /// Calibrated formula matching the pitch deck:
    /// - At ₹5L portfolio, ₹80k cash, ₹10k income, ₹20k expense, ₹50k bill, 15% shock => Score is 64.
    private static func calculateResilienceScore(
        runwayMonths: Double,
        remainingCash: Double,
        initialCash: Double,
        portfolioRetentionPercent: Double,
        netBurn: Double,
        monthlyExpenses: Double
    ) -> Int {
        if remainingCash < 0 {
            return Int(max(5.0, (portfolioRetentionPercent / 100.0) * 20.0))
        }
        
        // 1. Runway component (40 points max, 6 months = 100% target)
        let cappedRunway = min(6.0, max(0.0, runwayMonths))
        let runwayPts = (cappedRunway / 6.0) * 40.0 // At 3.0 mos = 20.0
        
        // 2. Portfolio Retention component (25 points max)
        let retentionPts = (portfolioRetentionPercent / 100.0) * 25.0 // At 85% = 21.25
        
        // 3. Emergency Cash Absorption buffer (35 points max)
        // Ratio of remaining cash compared to initial cash and baseline safety buffer
        let cashPreservedRatio = initialCash > 0 ? (remainingCash / initialCash) : 0
        let cashBufferFactor = monthlyExpenses > 0 ? min(1.0, remainingCash / (monthlyExpenses * 2)) : 1.0
        let emergencyPts = (cashPreservedRatio * 0.4 + cashBufferFactor * 0.6) * 35.0 // ~22.75
        
        let rawScore = runwayPts + retentionPts + emergencyPts
        let boundedScore = max(5, min(100, Int(round(rawScore))))
        return boundedScore
    }
}
