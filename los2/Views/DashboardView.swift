import SwiftUI
import Charts

/// Main Hero Dashboard screen transformed into an interactive Financial Command Center.
/// Displays baseline financial resilience score upfront without requiring stress test selection,
/// provides a prominent "Edit Finances" action, tappable financial summary cards, dynamic "What Needs Attention?" alerts,
/// and quick-action module hubs.
struct DashboardView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    
    @State private var isPreviewingShock: Bool = false
    @State private var isShowingStressSheet: Bool = false
    @State private var isShowingEmergencySheet: Bool = false
    @State private var isShowingRunwaySheet: Bool = false
    
    var baselineReport: ExplainableResilienceReport {
        viewModel.baselineScoreReport
    }
    
    var activeReport: ResilienceReport {
        viewModel.currentReport
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Top Header with Greeting & Prominent "Edit Finances" Button
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Good morning")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.secondary)
                            Text("Financial Command")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        
                        // Prominent "Edit Finances" Action Button
                        Button {
                            viewModel.isShowingEditSheet = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Edit Finances")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(LOSTheme.primary)
                            .foregroundStyle(Color.black)
                            .clipShape(Capsule())
                            .shadow(color: LOSTheme.primary.opacity(0.3), radius: 4, y: 2)
                        }
                        
                        // Zerodha Kite Connection Icon Button
                        Button {
                            viewModel.isShowingZerodhaSheet = true
                        } label: {
                            Image(systemName: viewModel.isZerodhaConnected ? "checkmark.circle.fill" : "link")
                                .font(.system(size: 14, weight: .bold))
                                .padding(8)
                                .background(Color(red: 1.0, green: 0.34, blue: 0.13).opacity(0.12))
                                .foregroundStyle(Color(red: 1.0, green: 0.34, blue: 0.13))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // MARK: - Empty State (If Profile Unconfigured)
                    if viewModel.isProfileIncomplete && viewModel.profile.portfolioValue == 0 && viewModel.profile.liquidCash == 0 {
                        VStack(spacing: 12) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.system(size: 38))
                                .foregroundStyle(LOSTheme.primary)
                            Text("Setup Your Financial Snapshot")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                            Text("Add your bank cash, expenses, and investments to calculate your personalized Resilience Score.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            Button {
                                viewModel.isShowingEditSheet = true
                            } label: {
                                Text("Enter Finances")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 9)
                                    .background(LOSTheme.primary)
                                    .foregroundStyle(Color.black)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(22)
                        .frame(maxWidth: .infinity)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Hero Financial Resilience Score Card (Baseline Front & Center)
                    VStack(spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("FINANCIAL RESILIENCE SCORE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text(isPreviewingShock ? "Under −\(Int(viewModel.currentDeclinePercentage))% Shock" : "Baseline Financial Posture")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                            }
                            Spacer()
                            
                            // Shock Preview Toggle Pill
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                    isPreviewingShock.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: isPreviewingShock ? "waveform.path.badge.minus" : "shield.fill")
                                        .font(.system(size: 10, weight: .bold))
                                    Text(isPreviewingShock ? "Viewing Shock" : "Test Shock")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(isPreviewingShock ? LOSTheme.criticalRed.opacity(0.15) : Color.primary.opacity(0.06))
                                .foregroundStyle(isPreviewingShock ? LOSTheme.criticalRed : Color.secondary)
                                .clipShape(Capsule())
                            }
                        }
                        
                        // Display Active or Baseline Score
                        let displayedScore = isPreviewingShock ? activeReport.resilienceScore : baselineReport.totalScore
                        let displayedBand = isPreviewingShock ? activeReport.resilienceBand : baselineReport.band
                        
                        ResilienceGaugeView(
                            score: displayedScore,
                            band: displayedBand,
                            headline: isPreviewingShock ? activeReport.summaryHeadline : "Baseline Liquidity Buffer"
                        )
                        
                        // Provisional notice if data is missing
                        if let notice = viewModel.provisionalScoreNotice {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(LOSTheme.warningAmber)
                                Text(notice)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(LOSTheme.warningAmber)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(LOSTheme.warningAmber.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        Divider()
                            .overlay(LOSTheme.cardBorder)
                        
                        // 5-Pillar Score Preview: Sleek segmented bar + summary
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                ForEach(baselineReport.pillars) { p in
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(p.statusColor)
                                    }
                                    .frame(height: 5)
                                }
                            }
                            
                            HStack {
                                Text("\(baselineReport.pillars.count) Resilience Pillars Evaluated")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                Spacer()
                                Button {
                                    viewModel.isShowingScoreBreakdownSheet = true
                                } label: {
                                    HStack(spacing: 3) {
                                        Text("Score Breakdown")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 9, weight: .bold))
                                    }
                                    .foregroundStyle(LOSTheme.primary)
                                }
                            }
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - "What Needs Attention?" Actionable Section
                    if !viewModel.attentionItems.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "bell.badge.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(LOSTheme.warningAmber)
                                Text("WHAT NEEDS ATTENTION")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(viewModel.attentionItems) { item in
                                    AttentionCard(item: item) {
                                        handleAttentionAction(item.targetAction)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Interactive Financial Metrics Grid (Tappable Cards)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("FINANCIAL POSITION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            // 1. Portfolio Value (Tappable -> Opens Portfolio)
                            InteractiveMetricCard(
                                title: "PORTFOLIO VALUE",
                                value: LOSTheme.formatRupee(viewModel.profile.portfolioValue),
                                subtitle: "\(viewModel.profile.activeHoldings.count) active holdings",
                                badgeText: "Holdings",
                                badgeColor: LOSTheme.primary,
                                iconName: "chart.pie.fill",
                                isNegative: false
                            ) {
                                viewModel.isShowingPortfolioSheet = true
                            }
                            
                            // 2. Liquid Cash (Tappable -> Opens Emergency Shock Simulator)
                            InteractiveMetricCard(
                                title: "LIQUID SAVINGS",
                                value: LOSTheme.formatRupee(viewModel.profile.liquidCash),
                                subtitle: "Instant buffer",
                                badgeText: "Simulate",
                                badgeColor: LOSTheme.safeGreen,
                                iconName: "banknote.fill",
                                isNegative: false
                            ) {
                                isShowingEmergencySheet = true
                            }
                            
                            // 3. Monthly Income vs Outflows (Tappable -> Opens Edit Finances)
                            let netBurn = viewModel.profile.baselineNetCashBurn
                            InteractiveMetricCard(
                                title: "MONTHLY NET BURN",
                                value: "\(LOSTheme.formatRupee(max(0, netBurn)))/mo",
                                subtitle: "Outflows \(LOSTheme.formatRupeeCompact(viewModel.profile.totalMonthlyOutflows)) vs \(LOSTheme.formatRupeeCompact(viewModel.profile.monthlyIncome))",
                                badgeText: netBurn <= 0 ? "Surplus" : "Drain",
                                badgeColor: netBurn <= 0 ? LOSTheme.safeGreen : LOSTheme.warningAmber,
                                iconName: "flame.fill",
                                isNegative: false
                            ) {
                                viewModel.isShowingEditSheet = true
                            }
                            
                            // 4. Cash Runway (Tappable -> Opens Runway View)
                            InteractiveMetricCard(
                                title: "CASH RUNWAY",
                                value: activeReport.runwayState == .cashSurplus ? "Surplus" : "\(String(format: "%.1f", activeReport.runwayMonths)) mos",
                                subtitle: "Under baseline burn",
                                badgeText: activeReport.runwayMonths < 3.0 ? "Tight" : "Stable",
                                badgeColor: activeReport.runwayMonths < 3.0 ? LOSTheme.criticalRed : LOSTheme.safeGreen,
                                iconName: "hourglass.bottomhalf.filled",
                                isNegative: activeReport.runwayMonths < 3.0
                            ) {
                                isShowingRunwaySheet = true
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Mini Stress Scenario Curve Visualization
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("PORTFOLIO VOLATILITY EXPOSURE")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            Button("Full Stress Test >") {
                                isShowingStressSheet = true
                            }
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(LOSTheme.primary)
                        }
                        .padding(.horizontal)
                        
                        // Mini Chart
                        VStack(alignment: .leading, spacing: 8) {
                            let points = ResilienceEngine.calculateDeclineCurve(portfolioValue: viewModel.profile.portfolioValue)
                            
                            Chart(points) { pt in
                                LineMark(
                                    x: .value("Decline %", pt.declinePercent),
                                    y: .value("Value", pt.remainingPortfolio)
                                )
                                .foregroundStyle(LOSTheme.primary)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Decline %", pt.declinePercent),
                                    y: .value("Value", pt.remainingPortfolio)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [LOSTheme.primary.opacity(0.2), Color.clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                            .frame(height: 100)
                            .chartXAxis {
                                AxisMarks(values: [0, 20, 40, 60]) { val in
                                    if let num = val.as(Int.self) {
                                        AxisValueLabel {
                                            Text("−\(num)%").font(.system(size: 9))
                                        }
                                    }
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading) { val in
                                    if let num = val.as(Double.self) {
                                        AxisValueLabel {
                                            Text(LOSTheme.formatRupeeCompact(num)).font(.system(size: 9))
                                        }
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Portfolio retention under simulated 0% to 60% drawdown.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.secondary)
                                Spacer()
                            }
                        }
                        .padding(14)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(LOSTheme.cardBorder, lineWidth: 1))
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Quick-Action Resilience Command Bar
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("QUICK COMMANDS")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CommandHubPill(title: "Edit Finances", icon: "pencil.line", color: LOSTheme.primary) {
                                    viewModel.isShowingEditSheet = true
                                }
                                CommandHubPill(title: "Stress Test", icon: "chart.line.downtrend.xyaxis", color: LOSTheme.criticalRed) {
                                    isShowingStressSheet = true
                                }
                                CommandHubPill(title: "Simulate Shock", icon: "bolt.shield.fill", color: LOSTheme.warningAmber) {
                                    isShowingEmergencySheet = true
                                }
                                CommandHubPill(title: "Cash Runway", icon: "hourglass", color: LOSTheme.safeGreen) {
                                    isShowingRunwaySheet = true
                                }
                                CommandHubPill(title: "Portfolio", icon: "chart.pie.fill", color: LOSTheme.primary) {
                                    viewModel.isShowingPortfolioSheet = true
                                }
                                CommandHubPill(title: "Reverse Stress", icon: "gauge.with.needle.fill", color: LOSTheme.warningAmber) {
                                    viewModel.isShowingReverseStressSheet = true
                                }
                                CommandHubPill(title: "AI Recovery", icon: "wand.and.stars", color: LOSTheme.safeGreen) {
                                    viewModel.isShowingRecoverySheet = true
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .background(LOSTheme.background.ignoresSafeArea())
            // Sheet presentations
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
            .sheet(isPresented: $isShowingStressSheet) {
                StressTestView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingEmergencySheet) {
                EmergencySimulatorView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingRunwaySheet) {
                RunwayView(viewModel: viewModel)
            }
        }
    }
    
    private func handleAttentionAction(_ target: ResilienceViewModel.AttentionActionTarget) {
        switch target {
        case .editFinances:
            viewModel.isShowingEditSheet = true
        case .emergencySimulator:
            isShowingEmergencySheet = true
        case .stressTest:
            isShowingStressSheet = true
        case .portfolioHoldings:
            viewModel.isShowingPortfolioSheet = true
        case .runway:
            isShowingRunwaySheet = true
        }
    }
}

/// Dynamic card for items in "What Needs Attention?"
private struct AttentionCard: View {
    let item: ResilienceViewModel.AttentionItem
    let onAction: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: item.iconName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(item.severityColor)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .lineLimit(2)
                Text(item.message)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 6)
            
            Button(action: onAction) {
                Text(item.actionLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(item.severityColor.opacity(0.15))
                    .foregroundStyle(item.severityColor)
                    .clipShape(Capsule())
            }
            .layoutPriority(1)
        }
        .padding(12)
        .background(LOSTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(item.severityColor.opacity(0.25), lineWidth: 1)
        )
    }
}

/// Interactive Tappable Metric Card
private struct InteractiveMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let badgeText: String
    let badgeColor: Color
    let iconName: String
    let isNegative: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(badgeColor.opacity(0.12))
                            .frame(width: 26, height: 26)
                        Image(systemName: iconName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(badgeColor)
                    }
                    Spacer(minLength: 2)
                    Text(badgeText)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(badgeColor.opacity(0.12))
                        .foregroundStyle(badgeColor)
                        .clipShape(Capsule())
                        .layoutPriority(1)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .tracking(0.6)
                        .lineLimit(1)
                    Text(value)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(isNegative ? LOSTheme.criticalRed : Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.70)
                    Text(subtitle)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(LOSTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(LOSTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Pill Button for Quick Command Bar
private struct CommandHubPill: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(LOSTheme.cardBackground)
            .foregroundStyle(Color.primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
