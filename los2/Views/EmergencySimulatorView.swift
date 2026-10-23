import SwiftUI

/// Dedicated screen for Feature 02: Emergency Expense Simulator (Slide 05).
struct EmergencySimulatorView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @State private var billSlider: Double = 50_000
    
    var body: some View {
        let report = viewModel.currentReport
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("AVAILABLE CASH")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        Text(LOSTheme.formatRupee(viewModel.profile.liquidCash))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        
                        Text("Instant bank balance available before shocks")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Unexpected Bill Adjuster
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("UNEXPECTED EXPENSE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            Text("−\(LOSTheme.formatRupee(billSlider))")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(LOSTheme.criticalRed)
                        }
                        
                        // Presets
                        HStack(spacing: 8) {
                            ForEach([25_000.0, 50_000.0, 75_000.0, 100_000.0], id: \.self) { amount in
                                let isSelected = abs(billSlider - amount) < 1.0
                                Button {
                                    billSlider = amount
                                    viewModel.profile.unexpectedExpense = amount
                                } label: {
                                    Text(LOSTheme.formatRupeeCompact(amount))
                                        .font(.system(size: 12, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? LOSTheme.criticalRed.opacity(0.18) : Color.primary.opacity(0.04))
                                        .foregroundStyle(isSelected ? LOSTheme.criticalRed : Color.secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Slider
                        Slider(
                            value: $billSlider,
                            in: 5_000...max(150_000, viewModel.profile.liquidCash * 1.5),
                            step: 5_000
                        ) {
                            Text("Expense Slider")
                        }
                        .tint(LOSTheme.criticalRed)
                        .onChange(of: billSlider) { val in
                            viewModel.profile.unexpectedExpense = val
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Before vs After Breakdown
                    VStack(alignment: .leading, spacing: 14) {
                        Text("CASH BEFORE vs AFTER")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Before")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                                Text(LOSTheme.formatRupee(report.initialCash))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.title3)
                                .foregroundStyle(Color.secondary)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("After")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                                Text(LOSTheme.formatRupee(report.remainingCashAfterEmergency))
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(report.remainingCashAfterEmergency < 0 ? LOSTheme.criticalRed : LOSTheme.warningAmber)
                            }
                        }
                        
                        // Percentage Drained Indicator
                        VStack(alignment: .leading, spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(0.08))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(report.emergencyCashUsedPercent > 75 ? LOSTheme.criticalRed : LOSTheme.warningAmber)
                                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(report.emergencyCashUsedPercent / 100.0))), height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            Text("\(String(format: "%.1f%%", report.emergencyCashUsedPercent)) of liquid cash used in one event")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(report.emergencyCashUsedPercent > 75 ? LOSTheme.criticalRed : LOSTheme.warningAmber)
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Final Impact Pill
                    HStack(spacing: 12) {
                        Image(systemName: "hourglass")
                            .font(.title2)
                            .foregroundStyle(LOSTheme.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Next: Does this affect your runway?")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Remaining ₹\(Int(report.remainingCashAfterEmergency)) provides ~\(String(format: "%.1f", report.runwayMonths)) months of survival at your current burn rate.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    .padding(14)
                    .background(LOSTheme.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Emergency Shock")
            .background(LOSTheme.background.ignoresSafeArea())
            .onAppear {
                billSlider = viewModel.profile.unexpectedExpense
            }
        }
    }
}
