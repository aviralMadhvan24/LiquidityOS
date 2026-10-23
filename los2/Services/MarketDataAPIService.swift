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
    
    func fetchQuote(symbol: String, force: Bool = false) async throws -> StockQuotePayload {
        let clean = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let url = endpoint("api/market/quote/\(clean)\(force ? "?force=true" : "")")
        var req = URLRequest(url: url)
        req.timeoutInterval = 6.0
        
        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            struct Err: Codable { let message: String? }
            let err = try? JSONDecoder().decode(Err.self, from: data)
            throw NSError(domain: "MarketData", code: (response as? HTTPURLResponse)?.statusCode ?? 500, userInfo: [NSLocalizedDescriptionKey: err?.message ?? "Quote fetch failed."])
        }
        
        struct SingleQuoteRes: Codable {
            let success: Bool
            let quote: StockQuotePayload
        }
        let decoded = try JSONDecoder().decode(SingleQuoteRes.self, from: data)
        return decoded.quote
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
