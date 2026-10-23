import SwiftUI

/// Dedicated screen for Feature 03: Cash Runway (Slide 06).
struct RunwayView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    
    var body: some View {
        let report = viewModel.currentReport
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Hero Runway Callout
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ESTIMATED CASH RUNWAY")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        
                        HStack(alignment: .firstTextBaseline) {
                            if report.runwayState == .cashSurplus {
                                Text("Surplus")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.safeGreen)
                            } else if report.runwayState == .breakEven {
                                Text("Stable")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.primary)
                            } else {
                                Text("\(String(format: "%.1f", report.runwayMonths))")
                                    .font(.system(size: 42, weight: .bold, design: .rounded))
                                    .foregroundStyle(report.runwayMonths < 3.0 ? LOSTheme.criticalRed : LOSTheme.warningAmber)
                                Text("months")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("Period of survival before all liquid cash is exhausted")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
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
                    
                    // Month by month Timeline
                    RunwayTimelineView(
                        startingCash: report.remainingCashAfterEmergency,
                        monthlyBurn: report.monthlyNetBurn,
                        runwayMonths: report.runwayMonths,
                        state: report.runwayState
                    )
                    .padding(.horizontal)
                    
                    // Cash flow variables
                    VStack(spacing: 12) {
                        HStack {
                            Label("Post-Emergency Cash", systemImage: "banknote")
                            Spacer(minLength: 8)
                            Text(LOSTheme.formatRupee(report.remainingCashAfterEmergency))
                                .fontWeight(.bold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        Divider()
                        HStack {
                            Label("Monthly Living Expenses", systemImage: "arrow.up.right")
                            Spacer(minLength: 8)
                            Text(LOSTheme.formatRupee(report.monthlyExpenses))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        if viewModel.profile.monthlyDebtPayments > 0 {
                            Divider()
                            HStack {
                                Label("Monthly Debt & EMIs", systemImage: "creditcard")
                                Spacer(minLength: 8)
                                Text(LOSTheme.formatRupee(viewModel.profile.monthlyDebtPayments))
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        Divider()
                        HStack {
                            Label("Monthly Income", systemImage: "arrow.down.left")
                            Spacer(minLength: 8)
                            Text(LOSTheme.formatRupee(report.monthlyIncome))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        Divider()
                        HStack {
                            Label("Monthly Cash Burn", systemImage: "flame.fill")
                                .foregroundStyle(LOSTheme.criticalRed)
                            Spacer(minLength: 8)
                            Text("−\(LOSTheme.formatRupee(report.monthlyNetBurn))/mo")
                                .fontWeight(.bold)
                                .foregroundStyle(LOSTheme.criticalRed)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Formula Card (Slide 06 Educational Breakdown)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("HOW RUNWAY IS CALCULATED")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        
                        Text("Runway = Cash / Monthly Net Cash Burn")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(LOSTheme.primary)
                        
                        Text("Net cash burn = Expenses (\(LOSTheme.formatRupee(report.monthlyExpenses))) − Income (\(LOSTheme.formatRupee(report.monthlyIncome))) = \(LOSTheme.formatRupee(report.monthlyNetBurn))")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        
                        if report.monthlyNetBurn > 0 && report.remainingCashAfterEmergency > 0 {
                            Text("Runway = \(LOSTheme.formatRupee(report.remainingCashAfterEmergency)) / \(LOSTheme.formatRupee(report.monthlyNetBurn)) = \(String(format: "%.1f", report.runwayMonths)) months")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Cash Runway")
            .background(LOSTheme.background.ignoresSafeArea())
        }
    }
}
