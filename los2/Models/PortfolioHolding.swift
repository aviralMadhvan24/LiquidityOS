import Foundation

/// Represents a company holding within the user's investment portfolio.
struct PortfolioHolding: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var companyName: String
    var ticker: String
    var sector: String
    var currentValue: Double
    var portfolioWeightPercent: Double
    var shares: Int?
    var averageBuyPrice: Double?
    
    /// Default holdings representing the ₹5,00,000 portfolio from the pitch deck.
    static let pitchDeckHoldings: [PortfolioHolding] = [
        PortfolioHolding(
            id: UUID(),
            companyName: "Reliance Industries",
            ticker: "RELIANCE",
            sector: "Energy & Telecom",
            currentValue: 175_000,
            portfolioWeightPercent: 35.0,
            shares: 60,
            averageBuyPrice: 2850
        ),
        PortfolioHolding(
            id: UUID(),
            companyName: "Tata Consultancy Services",
            ticker: "TCS",
            sector: "Information Technology",
            currentValue: 150_000,
            portfolioWeightPercent: 30.0,
            shares: 38,
            averageBuyPrice: 3800
        ),
        PortfolioHolding(
            id: UUID(),
            companyName: "HDFC Bank",
            ticker: "HDFCBANK",
            sector: "Financial Services",
            currentValue: 100_000,
            portfolioWeightPercent: 20.0,
            shares: 62,
            averageBuyPrice: 1550
        ),
        PortfolioHolding(
            id: UUID(),
            companyName: "Infosys",
            ticker: "INFY",
            sector: "Information Technology",
            currentValue: 75_000,
            portfolioWeightPercent: 15.0,
            shares: 42,
            averageBuyPrice: 1720
        )
    ]
}
