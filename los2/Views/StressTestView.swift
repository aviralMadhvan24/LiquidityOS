import SwiftUI

/// Feature 01 & 04: Upgraded Stress Test Screen.
/// Supports Mode A (Portfolio-Wide shock) and Mode B (Granular Individual Stock shock),
/// calculating loss contributions, top contributors, and cascading impact on cash runway.
struct StressTestView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @State private var sliderDecline: Double = 15.0
    
    var report: ResilienceReport {
        viewModel.currentReport
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Mode A vs Mode B Segmented Switcher
                    VStack(alignment: .leading, spacing: 8) {
                        Text("STRESS TEST ENGINE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        Picker("Stress Mode", selection: $viewModel.stressTestMode) {
                            Text("Mode A: Portfolio-Wide").tag(0)
                            Text("Mode B: Stock-by-Stock").tag(1)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // MARK: - Hero Portfolio Overview Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("TOTAL PORTFOLIO VALUE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text(LOSTheme.formatRupee(viewModel.profile.portfolioValue))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(viewModel.stressTestMode == 0 ? "SHOCK LEVEL" : "EFFECTIVE SHOCK")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                Text("−\(String(format: "%.1f%%", report.marketDeclinePercent))")
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundStyle(LOSTheme.criticalRed)
                            }
                        }
                        
                        // Retained Progress Bar
                        VStack(alignment: .leading, spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(LOSTheme.criticalRed.opacity(0.25))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(LOSTheme.safeGreen)
                                        .frame(width: max(0, geo.size.width * CGFloat(report.portfolioRetentionPercent / 100.0)), height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            HStack {
                                Text("\(String(format: "%.1f%%", report.portfolioRetentionPercent)) retained")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.safeGreen)
                                Spacer()
                                Text("Loss: −\(LOSTheme.formatRupee(report.estimatedPortfolioLoss))")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.criticalRed)
                            }
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
                    
                    // MARK: - Mode A Controls (Portfolio-Wide)
                    if viewModel.stressTestMode == 0 {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("PORTFOLIO-WIDE DRAWDOWN SCENARIO")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            
                            SegmentedShockPicker(selected: $viewModel.selectedScenario) { level in
                                viewModel.selectScenario(level)
                                sliderDecline = level.percentage
                            }
                            
                            // Fine-tune Slider
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Custom Market Shock")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                    Text("\(Int(sliderDecline))%")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundStyle(LOSTheme.criticalRed)
                                }
                                
                                Slider(value: $sliderDecline, in: 1...60, step: 1) {
                                    Text("Market Decline")
                                }
                                .tint(LOSTheme.criticalRed)
                                .onChange(of: sliderDecline) { val in
                                    viewModel.setCustomDecline(val)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .padding(18)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(LOSTheme.cardBorder, lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Mode B Controls (Individual Stock Shocks)
                    if viewModel.stressTestMode == 1 {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("INDIVIDUAL STOCK SHOCKS")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Spacer()
                                Button("Reset All") {
                                    viewModel.resetIndividualStockDeclines()
                                }
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(LOSTheme.primary)
                            }
                            
                            // Top Loss Contributor Highlight Card
                            if let top = viewModel.individualLossBreakdown.first, top.simulatedLoss > 0 {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(LOSTheme.warningAmber)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("TOP LOSS CONTRIBUTOR: \(top.holding.ticker)")
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.primary)
                                        Text("\(String(format: "%.1f%%", top.lossContributionPercent)) of total loss (−\(LOSTheme.formatRupee(top.simulatedLoss))) driven by \(top.holding.companyName)")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(12)
                                .background(LOSTheme.warningAmber.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            // Holdings List with Per-Stock Sliders
                            if viewModel.profile.activeHoldings.isEmpty {
                                Text("No holdings available. Add stocks in Portfolio Management to run individual stress tests.")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.vertical, 8)
                            } else {
                                ForEach(viewModel.individualLossBreakdown) { item in
                                    IndividualStockShockCard(
                                        item: item,
                                        onShockChange: { newDecline in
                                            viewModel.setIndividualStockDecline(ticker: item.holding.ticker, percentage: newDecline)
                                        }
                                    )
                                }
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
                    }
                    
                    // MARK: - Cascading Liquidity Impact Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("CASCADING LIQUIDITY & RUNWAY IMPACT")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            MetricBox(
                                title: "REMAINING CASH",
                                value: LOSTheme.formatRupee(report.remainingCashAfterEmergency),
                                subtitle: "After unexpected bill",
                                isNegative: report.remainingCashAfterEmergency < 0
                            )
                            
                            MetricBox(
                                title: "NET MONTHLY BURN",
                                value: "\(LOSTheme.formatRupee(report.monthlyNetBurn))/mo",
                                subtitle: "Outflow vs income",
                                isNegative: false
                            )
                            
                            MetricBox(
                                title: "CASH RUNWAY",
                                value: report.runwayState == .cashSurplus ? "Surplus" : "\(String(format: "%.1f", report.runwayMonths)) mos",
                                subtitle: "Before forced liquidation",
                                isNegative: report.runwayMonths < 3.0
                            )
                            
                            MetricBox(
                                title: "RESILIENCE SCORE",
                                value: "\(report.resilienceScore)/100",
                                subtitle: report.resilienceBand.rawValue,
                                isNegative: report.resilienceScore < 50
                            )
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
                    
                    // MARK: - Educational Insight Note
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundStyle(LOSTheme.primary)
                        Text(viewModel.stressTestMode == 0
                             ? "Mode A shocks the entire portfolio uniformly. Use this for broad macroeconomic downturns."
                             : "Mode B allows applying asymmetric shocks to individual holdings, reflecting earnings misses or sector headwinds.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.secondary)
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(LOSTheme.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Stress Test")
            .background(LOSTheme.background.ignoresSafeArea())
            .onAppear {
                sliderDecline = viewModel.currentDeclinePercentage
            }
        }
    }
}

/// Row Card for Granular Mode B Stock Shock
private struct IndividualStockShockCard: View {
    let item: ResilienceViewModel.IndividualStockLossItem
    let onShockChange: (Double) -> Void
    
    @State private var localDecline: Double = 15.0
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(item.holding.ticker)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                        Text(String(format: "%.1f%% alloc", item.holding.portfolioWeightPercent))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                    Text(item.holding.companyName)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("−\(LOSTheme.formatRupee(item.simulatedLoss))")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(LOSTheme.criticalRed)
                    Text("\(String(format: "%.1f%%", item.lossContributionPercent)) of total loss")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                }
            }
            
            // Per-Stock Shock Slider
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Shock")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    Text("−\(Int(localDecline))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundStyle(LOSTheme.criticalRed)
                }
                
                Slider(value: $localDecline, in: 0...60, step: 5)
                    .tint(LOSTheme.criticalRed)
                    .onChange(of: localDecline) { val in
                        onShockChange(val)
                    }
            }
            
            // Simulated Remaining Value
            HStack {
                Text("Remaining: \(LOSTheme.formatRupee(item.simulatedRemainingValue))")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondary)
                Spacer()
                Text("Pre-shock: \(LOSTheme.formatRupee(item.holding.currentValue))")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary.opacity(0.8))
            }
        }
        .padding(12)
        .background(LOSTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            localDecline = item.assumedDecline
        }
    }
}

/// Compact Metric Box for Grid Display
private struct MetricBox: View {
    let title: String
    let value: String
    let subtitle: String
    let isNegative: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .tracking(0.6)
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(isNegative ? LOSTheme.criticalRed : Color.primary)
            Text(subtitle)
                .font(.system(size: 10))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(LOSTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
