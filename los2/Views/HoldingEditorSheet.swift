import SwiftUI

/// Modal sheet for adding a new holding or editing an existing holding with live stock search and valuation.
struct HoldingEditorSheet: View {
    @ObservedObject var viewModel: ResilienceViewModel
    var existingHolding: PortfolioHolding? = nil
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery: String = ""
    @State private var searchResults: [StockSearchResult] = []
    @State private var isSearching: Bool = false
    
    @State private var ticker: String = ""
    @State private var companyName: String = ""
    @State private var sector: String = "Equity"
    @State private var sharesText: String = "10"
    @State private var avgBuyPriceText: String = "1000"
    @State private var currentPrice: Double = 1000.0
    @State private var freshness: MarketDataFreshness = .demoData
    
    var shares: Int {
        Int(sharesText) ?? 1
    }
    
    var avgBuyPrice: Double {
        Double(avgBuyPriceText) ?? 0.0
    }
    
    var investedValue: Double {
        Double(shares) * avgBuyPrice
    }
    
    var marketValue: Double {
        Double(shares) * currentPrice
    }
    
    var unrealizedPnL: Double {
        marketValue - investedValue
    }
    
    var unrealizedPnLPercent: Double {
        guard investedValue > 0 else { return 0 }
        return (unrealizedPnL / investedValue) * 100.0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Stock Search & Selection
                if existingHolding == nil {
                    Section {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.secondary)
                            TextField("Search stock (e.g. RELIANCE, TCS)", text: $searchQuery)
                                .textInputAutocapitalization(.characters)
                                .onChange(of: searchQuery) { _, q in
                                    Task { await performSearch(q) }
                                }
                        }
                        
                        if isSearching {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        } else if !searchResults.isEmpty {
                            ForEach(searchResults) { result in
                                Button {
                                    selectSearchResult(result)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(result.symbol)
                                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                                .foregroundStyle(Color.primary)
                                            Text(result.name)
                                                .font(.system(size: 12))
                                                .foregroundStyle(Color.secondary)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        Text(result.exchange)
                                            .font(.system(size: 11, weight: .semibold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.primary.opacity(0.06))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Search Indian Stocks (NSE/BSE)")
                    }
                }
                
                // Section 2: Selected Stock Details
                Section {
                    HStack {
                        Text("Ticker")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text(ticker.isEmpty ? "Select a stock" : ticker)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(LOSTheme.primary)
                    }
                    
                    HStack {
                        Text("Company Name")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text(companyName.isEmpty ? "—" : companyName)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Market Price")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                        Text(LOSTheme.formatRupee(currentPrice))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                        Text(freshness.displayName)
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(freshness.color.opacity(0.15))
                            .foregroundStyle(freshness.color)
                            .clipShape(Capsule())
                    }
                } header: {
                    Text("Stock Details")
                }
                
                // Section 3: Quantity & Average Purchase Price
                Section {
                    HStack {
                        Label("Quantity (Shares)", systemImage: "number")
                        Spacer()
                        #if os(iOS)
                        TextField("Shares", text: $sharesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("Shares", text: $sharesText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    HStack {
                        Label("Avg Purchase Price", systemImage: "indianrupeesign")
                        Spacer()
                        #if os(iOS)
                        TextField("Price", text: $avgBuyPriceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("Price", text: $avgBuyPriceText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                } header: {
                    Text("Your Investment")
                } footer: {
                    Text("Enter the number of shares owned and your average cost per share.")
                }
                
                // Section 4: Live Calculated Position Valuation
                Section {
                    HStack {
                        Text("Invested Capital")
                        Spacer(minLength: 8)
                        Text(LOSTheme.formatRupee(investedValue))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    HStack {
                        Text("Current Market Value")
                        Spacer(minLength: 8)
                        Text(LOSTheme.formatRupee(marketValue))
                            .bold()
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    HStack {
                        Text("Unrealized Profit / Loss")
                        Spacer(minLength: 8)
                        HStack(spacing: 4) {
                            Text(LOSTheme.formatRupee(unrealizedPnL, showSign: true))
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text("(\(String(format: "%+.1f%%", unrealizedPnLPercent)))")
                                .font(.system(size: 12, weight: .semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                        }
                        .foregroundStyle(unrealizedPnL >= 0 ? LOSTheme.safeGreen : LOSTheme.criticalRed)
                    }
                } header: {
                    Text("Valuation Summary")
                }
            }
            .navigationTitle(existingHolding == nil ? "Add Holding" : "Edit Holding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveHolding()
                    }
                    .bold()
                    .disabled(ticker.isEmpty || shares <= 0 || avgBuyPrice <= 0)
                }
            }
            .onAppear {
                if let h = existingHolding {
                    ticker = h.ticker
                    companyName = h.companyName
                    sector = h.sector
                    sharesText = "\(h.shares)"
                    avgBuyPriceText = String(format: "%.2f", h.averageBuyPrice)
                    currentPrice = h.currentPrice
                    freshness = h.freshness
                } else {
                    // Preselect a default popular stock
                    ticker = "RELIANCE"
                    companyName = "Reliance Industries"
                    sector = "Energy & Telecom"
                    sharesText = "20"
                    avgBuyPriceText = "2850"
                    Task { await fetchCurrentQuote("RELIANCE") }
                }
            }
        }
    }
    
    private func performSearch(_ query: String) async {
        guard query.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2 else {
            searchResults = []
            return
        }
        isSearching = true
        do {
            let res = try await MarketDataAPIService.shared.searchStocks(query: query)
            searchResults = res
            isSearching = false
        } catch {
            isSearching = false
        }
    }
    
    private func selectSearchResult(_ result: StockSearchResult) {
        ticker = result.symbol
        companyName = result.name
        sector = result.sector ?? "Equity"
        searchQuery = ""
        searchResults = []
        Task { await fetchCurrentQuote(result.symbol) }
    }
    
    private func fetchCurrentQuote(_ sym: String) async {
        do {
            let quote = try await MarketDataAPIService.shared.fetchQuote(symbol: sym)
            currentPrice = quote.currentPrice
            if let f = MarketDataFreshness(rawValue: quote.freshness) {
                freshness = f
            }
        } catch {
            // Keep default
        }
    }
    
    private func saveHolding() {
        viewModel.addOrUpdateHolding(
            ticker: ticker,
            companyName: companyName,
            shares: shares,
            averageBuyPrice: avgBuyPrice,
            sector: sector,
            currentPrice: currentPrice
        )
        dismiss()
    }
}
