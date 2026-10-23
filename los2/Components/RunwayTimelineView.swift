import SwiftUI

/// Month-by-month visual runway timeline component.
/// Responsive across screen widths and Dynamic Type settings.
struct RunwayTimelineView: View {
    let startingCash: Double
    let monthlyBurn: Double
    let runwayMonths: Double
    let state: RunwayState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Depletion Timeline", systemImage: "clock.arrow.circlepath")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                Spacer()
                Text(state.rawValue)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)
            }
            
            if state == .cashSurplus {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.up.forward.circle.fill")
                        .font(.title)
                        .foregroundStyle(LOSTheme.safeGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income Exceeds Expenses")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Your cash is accumulating each month instead of burning.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
            } else if state == .breakEven {
                HStack(spacing: 12) {
                    Image(systemName: "equal.circle.fill")
                        .font(.title)
                        .foregroundStyle(LOSTheme.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Zero Monthly Burn")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Cash balances stay steady at current spending behavior.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
            } else if state == .underwater {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title)
                        .foregroundStyle(LOSTheme.criticalRed)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Immediate Cash Deficit")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(LOSTheme.criticalRed)
                        Text("Emergency bill exceeds available cash. Immediate risk of debt or forced asset liquidation.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 8)
            } else {
                // Month-by-month steps up to 6 months
                let displayMonths = min(6, max(1, Int(ceil(runwayMonths))))
                
                VStack(spacing: 10) {
                    HStack(spacing: 6) {
                        ForEach(1...displayMonths, id: \.self) { month in
                            let remaining = max(0, startingCash - (monthlyBurn * Double(month)))
                            let isLast = month == displayMonths
                            
                            VStack(spacing: 6) {
                                Text("M\(month)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundStyle(isLast ? LOSTheme.criticalRed : Color.primary)
                                
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(0.06))
                                        .frame(height: 50)
                                    
                                    let heightRatio = startingCash > 0 ? max(0.05, remaining / startingCash) : 0.05
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(
                                            isLast ? LOSTheme.criticalRed :
                                            (remaining < monthlyBurn ? LOSTheme.warningAmber : LOSTheme.primary)
                                        )
                                        .frame(height: 50 * heightRatio)
                                }
                                
                                Text(LOSTheme.formatRupeeCompact(remaining))
                                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    
                    HStack {
                        Text("Burn Rate: \(LOSTheme.formatRupee(monthlyBurn))/mo")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Spacer()
                        Text("Estimated: \(String(format: "%.1f", runwayMonths)) Mos")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(runwayMonths < 3.0 ? LOSTheme.criticalRed : LOSTheme.safeGreen)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(16)
        .background(LOSTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(LOSTheme.cardBorder, lineWidth: 1)
        )
    }
    
    private var statusColor: Color {
        switch state {
        case .exhausting:
            return runwayMonths < 3.0 ? LOSTheme.criticalRed : LOSTheme.warningAmber
        case .breakEven:
            return LOSTheme.primary
        case .cashSurplus:
            return LOSTheme.safeGreen
        case .underwater:
            return LOSTheme.criticalRed
        }
    }
}
