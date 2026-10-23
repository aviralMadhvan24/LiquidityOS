import Foundation

struct ZerodhaUser: Codable, Equatable {
    let userId: String
    let userName: String
    let broker: String
    let isDemo: Bool?
}

struct ZerodhaStatusResponse: Codable {
    let success: Bool
    let isConfigured: Bool
    let isConnected: Bool
    let user: ZerodhaUser?
}

struct ZerodhaHoldingItem: Codable, Identifiable {
    let id: String
    let companyName: String
    let ticker: String
    let sector: String
    let currentValue: Double
    let shares: Int?
    let averageBuyPrice: Double?
    let pnl: Double?
    let portfolioWeightPercent: Double
}

struct ZerodhaPortfolioResponse: Codable {
    let success: Bool
    let connected: Bool
    let broker: String
    let user: ZerodhaUser?
    let totalPortfolioValue: Double
    let availableCash: Double
    let holdingsCount: Int
    let holdings: [ZerodhaHoldingItem]
}

final class ZerodhaAPIService {
    static let shared = ZerodhaAPIService()
    
    private var baseURL: URL {
        ConcallAPIService.shared.baseURL
    }
    
    func fetchStatus() async throws -> ZerodhaStatusResponse {
        let url = baseURL.appendingPathComponent("api/zerodha/status")
        var request = URLRequest(url: url)
        request.timeoutInterval = 4.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ZerodhaStatusResponse.self, from: data)
    }
    
    func getLoginURL() async throws -> URL {
        let url = baseURL.appendingPathComponent("api/zerodha/login-url")
        var request = URLRequest(url: url)
        request.timeoutInterval = 4.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            struct Err: Codable { let message: String? }
            let err = try? JSONDecoder().decode(Err.self, from: data)
            throw NSError(domain: "Zerodha", code: 400, userInfo: [NSLocalizedDescriptionKey: err?.message ?? "Kite credentials not set in backend/.env"])
        }
        
        struct LoginRes: Codable {
            let success: Bool
            let loginUrl: String
        }
        let res = try JSONDecoder().decode(LoginRes.self, from: data)
        guard let targetURL = URL(string: res.loginUrl) else {
            throw URLError(.badURL)
        }
        return targetURL
    }
    
    func connectDemo() async throws -> ZerodhaPortfolioResponse {
        let url = baseURL.appendingPathComponent("api/zerodha/demo-connect")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 4.0
        
        _ = try await URLSession.shared.data(for: request)
        return try await fetchPortfolio()
    }
    
    func fetchPortfolio() async throws -> ZerodhaPortfolioResponse {
        let url = baseURL.appendingPathComponent("api/zerodha/portfolio")
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ZerodhaPortfolioResponse.self, from: data)
    }
    
    func disconnect() async throws {
        let url = baseURL.appendingPathComponent("api/zerodha/disconnect")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 4.0
        _ = try? await URLSession.shared.data(for: request)
    }
}
