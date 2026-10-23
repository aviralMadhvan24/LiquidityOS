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
                                .bold()
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
                                .bold()
                                .foregroundStyle(LOSTheme.criticalRed)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(.rect(cornerRadius: LOSTheme.radiusLarge))
                    .overlay(
                        RoundedRectangle(cornerRadius: LOSTheme.radiusLarge)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Cash Runway")
            .background(LOSTheme.background.ignoresSafeArea())
        }
    }
}
