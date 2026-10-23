import SwiftUI

/// Main Hero Dashboard screen reproducing Slide 07 from the pitch deck,
/// enhanced with 1-tap navigation to Portfolio Holdings, Reverse Stress, AI Recovery, and Explainable Score Breakdown.
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
                                .foregroundStyle(Color.secondary)
                            Text("Resilience Overview")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        
                        // Zerodha Kite Connection Button
                        Button {
                            viewModel.isShowingZerodhaSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.isZerodhaConnected ? "checkmark.circle.fill" : "link")
                                    .font(.system(size: 11, weight: .bold))
                                Text(viewModel.isZerodhaConnected ? "Kite Synced" : "Connect Zerodha")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color(red: 1.0, green: 0.34, blue: 0.13).opacity(viewModel.isZerodhaConnected ? 0.15 : 0.10))
                            .foregroundStyle(Color(red: 1.0, green: 0.34, blue: 0.13))
                            .clipShape(Capsule())
                        }
                        
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
                                .foregroundStyle(Color.secondary)
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
                    
                    // Hero Resilience Gauge (Tappable for 5-Pillar Score Breakdown)
                    Button {
                        viewModel.isShowingScoreBreakdownSheet = true
                    } label: {
                        VStack(spacing: 8) {
                            ResilienceGaugeView(
                                score: report.resilienceScore,
                                band: report.resilienceBand,
                                headline: report.summaryHeadline
                            )
                            
                            HStack(spacing: 4) {
                                Text("Inspect 5-Pillar Breakdown")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundStyle(LOSTheme.primary)
                            .padding(.top, 2)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(LOSTheme.cardBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                    // MARK: - Advanced Resilience Suite (Quick Access Navigation)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("RESILIENCE SUITE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            Text("3 Upgraded Modules")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // 1. Portfolio Management
                                QuickModuleCard(
                                    title: "Portfolio Holdings",
                                    badgeText: "\(viewModel.profile.activeHoldings.count) Stocks",
                                    detailText: LOSTheme.formatRupee(viewModel.profile.portfolioValue),
                                    icon: "chart.pie.fill",
                                    color: LOSTheme.primary
                                ) {
                                    viewModel.isShowingPortfolioSheet = true
                                }
                                
                                // 2. Reverse Stress Testing
                                let revResult = viewModel.reverseStressResult
                                let revText = revResult.breakingPointDeclinePercent != nil
                                    ? "\(Int(revResult.breakingPointDeclinePercent!))% Crash Limit"
                                    : "Safe > 100%"
                                QuickModuleCard(
                                    title: "Reverse Stress",
                                    badgeText: "Threshold",
                                    detailText: revText,
                                    icon: "gauge.with.needle.fill",
                                    color: LOSTheme.warningAmber
                                ) {
                                    viewModel.isShowingReverseStressSheet = true
                                }
                                
                                // 3. AI Recovery Planner
                                QuickModuleCard(
                                    title: "AI Recovery",
                                    badgeText: "Blueprint",
                                    detailText: "3 Strategic Paths",
                                    icon: "wand.and.stars",
                                    color: LOSTheme.safeGreen
                                ) {
                                    viewModel.isShowingRecoverySheet = true
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
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
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                        }
                        
                        Text(report.summaryVerdict)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.primary)
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
                                    .foregroundStyle(Color.secondary)
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
            .sheet(isPresented: $viewModel.isShowingZerodhaSheet) {
                ZerodhaConnectSheet(resilienceViewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingScoreBreakdownSheet) {
                ResilienceScoreBreakdownSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingPortfolioSheet) {
                PortfolioManagementView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingReverseStressSheet) {
                ReverseStressTestView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isShowingRecoverySheet) {
                RecoveryPlannerView(viewModel: viewModel)
            }
        }
    }
}

/// Compact horizontal card for fast navigation to upgraded modules
private struct QuickModuleCard: View {
    let title: String
    let badgeText: String
    let detailText: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 28, height: 28)
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(color)
                    }
                    Spacer()
                    Text(badgeText)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(color.opacity(0.12))
                        .foregroundStyle(color)
                        .clipShape(Capsule())
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.primary)
                    Text(detailText)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
            }
            .frame(width: 145)
            .padding(12)
            .background(LOSTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LOSTheme.cardBorder, lineWidth: 1)
            )
        }
    }
}
