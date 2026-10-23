import SwiftUI

/// Main Hero Dashboard screen reproducing Slide 07 from the pitch deck.
struct DashboardView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    
    var body: some View {
        let report = viewModel.currentReport
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Greeting
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good morning")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("Resilience Overview")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Button {
                            viewModel.isShowingEditSheet = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(10)
                                .background(LOSTheme.cardBackground)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(LOSTheme.cardBorder, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // Stress-Test Selector Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("STRESS-TEST SELECTOR")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                            Spacer()
                            Text("\(Int(viewModel.currentDeclinePercentage))% Shock Active")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundStyle(report.resilienceBand.color)
                        }
                        
                        SegmentedShockPicker(selected: $viewModel.selectedScenario) { level in
                            viewModel.selectScenario(level)
                        }
                    }
                    .padding(14)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // Hero Resilience Gauge
                    VStack(spacing: 8) {
                        ResilienceGaugeView(
                            score: report.resilienceScore,
                            band: report.resilienceBand,
                            headline: report.summaryHeadline
                        )
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // 4 Core Financial Metrics Grid
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        // 1. Portfolio Value & Loss
                        MetricCardView(
                            title: "PORTFOLIO VALUE",
                            value: LOSTheme.formatRupee(viewModel.profile.portfolioValue),
                            subtitle: "\(LOSTheme.formatRupee(report.estimatedPortfolioLoss)) loss",
                            badgeText: "−\(Int(report.marketDeclinePercent))%",
                            badgeColor: LOSTheme.criticalRed,
                            iconName: "chart.pie.fill",
                            isNegative: false
                        )
                        
                        // 2. Est. Portfolio Loss
                        MetricCardView(
                            title: "EST. LOSS (\(Int(report.marketDeclinePercent))%)",
                            value: "−\(LOSTheme.formatRupee(report.estimatedPortfolioLoss))",
                            subtitle: "\(String(format: "%.0f%%", report.portfolioRetentionPercent)) retained",
                            badgeText: "Shock",
                            badgeColor: LOSTheme.criticalRed,
                            iconName: "chart.line.downtrend.xyaxis",
                            isNegative: true
                        )
                        
                        // 3. Liquid Cash
                        MetricCardView(
                            title: "LIQUID CASH",
                            value: LOSTheme.formatRupee(viewModel.profile.liquidCash),
                            subtitle: "Pre-emergency",
                            badgeText: "Ready",
                            badgeColor: LOSTheme.safeGreen,
                            iconName: "banknote.fill",
                            isNegative: false
                        )
                        
                        // 4. Cash After Emergency
                        MetricCardView(
                            title: "AFTER EMERGENCY",
                            value: LOSTheme.formatRupee(report.remainingCashAfterEmergency),
                            subtitle: "After \(LOSTheme.formatRupee(viewModel.profile.unexpectedExpense)) bill",
                            badgeText: "\(String(format: "%.0f%%", report.emergencyCashUsedPercent)) used",
                            badgeColor: report.remainingCashAfterEmergency < 0 ? LOSTheme.criticalRed : LOSTheme.warningAmber,
                            iconName: "cross.case.fill",
                            isNegative: report.remainingCashAfterEmergency < 0
                        )
                        
                        // 5. Net Cash Burn
                        MetricCardView(
                            title: "NET CASH BURN",
                            value: "\(LOSTheme.formatRupee(report.monthlyNetBurn))/mo",
                            subtitle: "Spend \(LOSTheme.formatRupee(report.monthlyExpenses)) vs \(LOSTheme.formatRupee(report.monthlyIncome))",
                            badgeText: report.monthlyNetBurn == 0 ? "Break Even" : "Drain",
                            badgeColor: report.monthlyNetBurn == 0 ? LOSTheme.safeGreen : LOSTheme.warningAmber,
                            iconName: "flame.fill",
                            isNegative: false
                        )
                        
                        // 6. Cash Runway
                        MetricCardView(
                            title: "CASH RUNWAY",
                            value: report.runwayState == .cashSurplus ? "Surplus" : "\(String(format: "%.1f", report.runwayMonths)) mos",
                            subtitle: "Under \(LOSTheme.formatRupee(report.monthlyNetBurn))/mo burn",
                            badgeText: report.runwayMonths < 3.0 ? "Tight" : "Stable",
                            badgeColor: report.runwayMonths < 3.0 ? LOSTheme.criticalRed : LOSTheme.safeGreen,
                            iconName: "hourglass.bottomhalf.filled",
                            isNegative: report.runwayMonths < 3.0
                        )
                    }
                    .padding(.horizontal)
                    
                    // Plain-English Resilience Summary Banner (Slide 07 Bottom)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundStyle(report.resilienceBand.color)
                            Text("RESILIENCE SUMMARY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .tracking(0.8)
                        }
                        
                        Text(report.summaryVerdict)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineSpacing(3)
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        ForEach(report.recommendations, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(LOSTheme.primary)
                                    .padding(.top, 2)
                                Text(tip)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(report.resilienceBand.color.opacity(0.3), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .background(LOSTheme.background.ignoresSafeArea())
            .sheet(isPresented: $viewModel.isShowingEditSheet) {
                EditProfileSheet(viewModel: viewModel)
            }
        }
    }
}
