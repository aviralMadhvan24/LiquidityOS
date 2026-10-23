import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Design system constants and styling for LiquidityOS.
enum LOSTheme {
    // Primary brand accents
    static let primary = Color(red: 0.12, green: 0.53, blue: 0.90) // Electric Indigo / Blue
    static let accentGradient = LinearGradient(
        colors: [Color(red: 0.22, green: 0.45, blue: 0.98), Color(red: 0.12, green: 0.75, blue: 0.95)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Status colors
    static let safeGreen = Color(red: 0.18, green: 0.80, blue: 0.44)
    static let warningAmber = Color(red: 0.98, green: 0.65, blue: 0.15)
    static let criticalRed = Color(red: 0.94, green: 0.28, blue: 0.32)
    static let purpleAccent = Color(red: 0.62, green: 0.36, blue: 0.95)
    
    // Background and Card styling (Universal for iOS & macOS)
    #if os(iOS) || os(tvOS) || os(visionOS)
    static let background = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    #elseif os(macOS)
    static let background = Color(nsColor: .windowBackgroundColor)
    static let cardBackground = Color(nsColor: .controlBackgroundColor)
    #else
    static let background = Color.gray.opacity(0.1)
    static let cardBackground = Color.white
    #endif
    
    static let cardBorder = Color.primary.opacity(0.08)
    
    // Currency Formatter
    static func formatRupee(_ value: Double, showSign: Bool = false) -> String {
        let absValue = abs(value)
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        
        let formatted = formatter.string(from: NSNumber(value: absValue)) ?? "₹\(Int(absValue))"
        if value < 0 {
            return "−\(formatted)"
        } else if showSign && value > 0 {
            return "+\(formatted)"
        }
        return formatted
    }
    
    // Compact formatting (e.g. ₹5.0L, ₹80k)
    static func formatRupeeCompact(_ value: Double) -> String {
        let absVal = abs(value)
        let prefix = value < 0 ? "−₹" : "₹"
        if absVal >= 10_000_000 {
            return String(format: "%@%.1f Cr", prefix, absVal / 10_000_000)
        } else if absVal >= 100_000 {
            return String(format: "%@%.1f L", prefix, absVal / 100_000)
        } else if absVal >= 1_000 {
            return String(format: "%@%.0f k", prefix, absVal / 1_000)
        } else {
            return String(format: "%@%.0f", prefix, absVal)
        }
    }
}
