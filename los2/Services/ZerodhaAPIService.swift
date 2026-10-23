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
    
    private func endpoint(_ path: String) -> URL {
        let base = ConcallAPIService.shared.baseURLString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let sub = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(base)/\(sub)") ?? URL(string: "http://localhost:3000/\(sub)")!
    }
    
    func fetchStatus() async throws -> ZerodhaStatusResponse {
        let url = endpoint("api/zerodha/status")
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ZerodhaStatusResponse.self, from: data)
    }
    
    func getLoginURL() async throws -> URL {
        let url = endpoint("api/zerodha/login-url")
        var request = URLRequest(url: url)
        request.timeoutInterval = 5.0
        
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
        let url = endpoint("api/zerodha/demo-connect")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 5.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            struct Err: Codable { let message: String? }
            let err = try? JSONDecoder().decode(Err.self, from: data)
            let msg = err?.message ?? "Backend returned HTTP \((response as? HTTPURLResponse)?.statusCode ?? 500). Ensure backend server is running with latest code."
            throw NSError(domain: "Zerodha", code: 500, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        
        return try await fetchPortfolio()
    }
    
    func fetchPortfolio() async throws -> ZerodhaPortfolioResponse {
        let url = endpoint("api/zerodha/portfolio")
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            struct Err: Codable { let message: String? }
            let err = try? JSONDecoder().decode(Err.self, from: data)
            let msg = err?.message ?? "Failed to fetch portfolio from backend."
            throw NSError(domain: "Zerodha", code: 500, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        return try JSONDecoder().decode(ZerodhaPortfolioResponse.self, from: data)
    }
    
    func disconnect() async throws {
        let url = endpoint("api/zerodha/disconnect")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 4.0
        _ = try? await URLSession.shared.data(for: request)
    }
}
