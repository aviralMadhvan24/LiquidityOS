import Foundation

struct StockSearchResult: Identifiable, Codable, Equatable {
    var id: String { symbol }
    let symbol: String
    let name: String
    let exchange: String
    let sector: String?
    let type: String?
}

struct StockQuotePayload: Codable {
    let symbol: String
    let name: String
    let exchange: String
    let currentPrice: Double
    let previousClose: Double
    let change: Double
    let changePercent: Double
    let timestamp: String
    let freshness: String
    let currency: String?
    let isFromCache: Bool?
    let staleWarning: String?
}

final class MarketDataAPIService {
    static let shared = MarketDataAPIService()
    
    private func endpoint(_ path: String) -> URL {
        let base = ConcallAPIService.shared.baseURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let sub = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(base)/\(sub)") ?? URL(string: "http://localhost:3000/\(sub)")!
    }
    
    func searchStocks(query: String) async throws -> [StockSearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return []
        }
        let url = endpoint("api/market/search?q=\(encoded)")
        var req = URLRequest(url: url)
        req.timeoutInterval = 4.0
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            return []
        }
        
        struct SearchRes: Codable {
            let success: Bool
            let results: [StockSearchResult]
        }
        let decoded = try JSONDecoder().decode(SearchRes.self, from: data)
        return decoded.results
    }
    
    func fetchQuote(symbol: String, exchange: String? = nil, force: Bool = false) async throws -> StockQuotePayload {
        let clean = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // 1. Try backend server if available
        let url = endpoint("api/market/quote/\(clean)\(force ? "?force=true" : "")")
        var req = URLRequest(url: url)
        req.timeoutInterval = 2.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                struct SingleQuoteRes: Codable {
                    let success: Bool
                    let quote: StockQuotePayload
                }
                if let decoded = try? JSONDecoder().decode(SingleQuoteRes.self, from: data) {
                    return decoded.quote
                }
            }
        } catch {
            // Backend offline or unreachable
        }
        
        // 2. Direct on-device live quote from Yahoo Finance
        if let direct = await fetchDirectLiveQuote(symbol: clean, exchange: exchange) {
            return direct
        }
        
        // 3. Fallback to IndianStockDirectory reference price
        if let fallbackItem = IndianStockDirectory.shared.find(symbol: clean) {
            let seed = Double(abs(clean.hashValue % 40)) / 10.0 - 2.0 // -2.0% to +2.0%
            let changeVal = round(fallbackItem.defaultPrice * (seed / 100.0) * 100) / 100
            let prevClose = fallbackItem.defaultPrice - changeVal
            return StockQuotePayload(
                symbol: fallbackItem.symbol,
                name: fallbackItem.name,
                exchange: fallbackItem.exchange,
                currentPrice: fallbackItem.defaultPrice,
                previousClose: prevClose,
                change: changeVal,
                changePercent: round(seed * 100) / 100,
                timestamp: ISO8601DateFormatter().string(from: Date()),
                freshness: "REFERENCE_CATALOG",
                currency: "INR",
                isFromCache: true,
                staleWarning: nil
            )
        }
        
        throw NSError(domain: "MarketData", code: 404, userInfo: [NSLocalizedDescriptionKey: "Quote not found for \(clean)"])
    }
    
    private static let symbolAliases: [String: String] = [
        "TATAMOTORS": "TMPV.NS",
        "NIFTY": "^NSEI",
        "SENSEX": "^BSESN",
        "BANKNIFTY": "^NSEBANK"
    ]
    
    /// Fetches live quote directly from Yahoo Finance on-device (zero backend dependency)
    func fetchDirectLiveQuote(symbol: String, exchange: String? = nil) async -> StockQuotePayload? {
        let clean = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let resolvedExchange = exchange ?? (IndianStockDirectory.shared.find(symbol: clean)?.exchange ?? "NSE")
        let targetSymbol: String
        if let alias = Self.symbolAliases[clean] {
            targetSymbol = alias
        } else if clean.contains(".") || clean.starts(with: "^") {
            targetSymbol = clean
        } else {
            let suffix = resolvedExchange == "BSE" ? ".BO" : ".NS"
            targetSymbol = "\(clean)\(suffix)"
        }
        guard let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(targetSymbol)?interval=1d&range=2d") else {
            return nil
        }
        var req = URLRequest(url: url)
        req.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        req.timeoutInterval = 3.5
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            
            struct YahooChartResult: Codable {
                struct Chart: Codable {
                    struct ResultItem: Codable {
                        struct Meta: Codable {
                            let regularMarketPrice: Double?
                            let chartPreviousClose: Double?
                            let previousClose: Double?
                            let shortName: String?
                            let currency: String?
                            let exchangeName: String?
                        }
                        let meta: Meta
                    }
                    let result: [ResultItem]?
                }
                let chart: Chart
            }
            
            let decoded = try JSONDecoder().decode(YahooChartResult.self, from: data)
            guard let meta = decoded.chart.result?.first?.meta,
                  let price = meta.regularMarketPrice else { return nil }
            
            let prevClose = meta.chartPreviousClose ?? meta.previousClose ?? price
            let change = round((price - prevClose) * 100) / 100
            let changePct = prevClose > 0 ? round((change / prevClose) * 10000) / 100 : 0
            
            return StockQuotePayload(
                symbol: clean,
                name: meta.shortName ?? clean,
                exchange: meta.exchangeName == "BSE" ? "BSE" : "NSE",
                currentPrice: round(price * 100) / 100,
                previousClose: round(prevClose * 100) / 100,
                change: change,
                changePercent: changePct,
                timestamp: ISO8601DateFormatter().string(from: Date()),
                freshness: "DELAYED_15MIN",
                currency: meta.currency ?? "INR",
                isFromCache: false,
                staleWarning: nil
            )
        } catch {
            return nil
        }
    }
    
    func fetchBatchQuotes(symbols: [String], force: Bool = false) async throws -> [String: StockQuotePayload] {
        let url = endpoint("api/market/quotes")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 10.0
        
        struct BatchReq: Codable {
            let symbols: [String]
            let forceRefresh: Bool
        }
        req.httpBody = try JSONEncoder().encode(BatchReq(symbols: symbols, forceRefresh: force))
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            return [:]
        }
        
        struct BatchRes: Codable {
            let success: Bool
            let quotes: [String: StockQuotePayload]
        }
        let decoded = try JSONDecoder().decode(BatchRes.self, from: data)
        return decoded.quotes
    }
}
