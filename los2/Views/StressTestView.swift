import SwiftUI
import Charts

/// Feature 01 & 04: Advanced Stress Testing Screen with Native Interactive Swift Charts.
/// Includes Graph A (Before vs After), Graph B (Loss by Scenario), Graph C (Stock Loss Contribution),
/// and Graph D (Continuous Portfolio Decline Curve).
struct StressTestView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @State private var sliderDecline: Double = 15.0
    @State private var selectedGraphTab: Int = 0 // 0 = Before/After, 1 = Scenarios, 2 = Stock Breakdown, 3 = Decline Curve
    
    var report: ResilienceReport {
        viewModel.currentReport
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Stress Test Engine Mode Picker (Mode A vs Mode B)
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("PORTFOLIO EXPOSURE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text(LOSTheme.formatRupee(viewModel.profile.portfolioValue))
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                            }
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 3) {
                                Text(viewModel.stressTestMode == 0 ? "ASSUMED SHOCK" : "EFFECTIVE SHOCK")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                Text("−\(String(format: "%.1f%%", report.marketDeclinePercent))")
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundStyle(LOSTheme.criticalRed)
                            }
                        }
                        
                        // Retained vs Loss Split
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("RETAINED VALUE")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                Text(LOSTheme.formatRupee(report.remainingPortfolioValue))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.safeGreen)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("SIMULATED LOSS")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                Text("−\(LOSTheme.formatRupee(report.estimatedPortfolioLoss))")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
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
                    
                    // MARK: - Interactive Swift Charts Visualizer
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("INTERACTIVE VISUALIZATION")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            Text("Swift Charts")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(LOSTheme.primary)
                        }
                        
                        // Chart Selector Tabs
                        Picker("Chart View", selection: $selectedGraphTab) {
                            Text("Before / After").tag(0)
                            Text("By Scenario").tag(1)
                            Text("Stock Loss").tag(2)
                            Text("Decline Curve").tag(3)
                        }
                        .pickerStyle(.segmented)
                        
                        // Active Chart Container
                        Group {
                            switch selectedGraphTab {
                            case 0:
                                GraphABeforeAfterView(
                                    portfolioValue: viewModel.profile.portfolioValue,
                                    remainingValue: report.remainingPortfolioValue,
                                    loss: report.estimatedPortfolioLoss
                                )
                            case 1:
                                GraphBScenarioComparisonView(
                                    portfolioValue: viewModel.profile.portfolioValue,
                                    activeDecline: report.marketDeclinePercent
                                ) { selectedDecline in
                                    viewModel.setCustomDecline(selectedDecline)
                                    sliderDecline = selectedDecline
                                }
                            case 2:
                                GraphCStockContributionView(
                                    items: viewModel.individualLossBreakdown,
                                    totalLoss: viewModel.totalIndividualStockLoss
                                )
                            default:
                                GraphDDeclineCurveView(
                                    portfolioValue: viewModel.profile.portfolioValue,
                                    currentDecline: report.marketDeclinePercent
                                )
                            }
                        }
                        .frame(height: 220)
                        .padding(.top, 4)
                        
                        // Hypothetical Simulation Notice
                        HStack(spacing: 6) {
                            Image(systemName: "chart.line.uptrend.xyaxis.circle")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.secondary)
                            Text("Hypothetical stress-test simulation based on mathematical drawdown. Not a price forecast.")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.secondary)
                                .lineLimit(1)
                        }
                        .padding(.top, 2)
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Mode A Shock Controls (Portfolio-Wide)
                    if viewModel.stressTestMode == 0 {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("MARKET DECLINE SCENARIO")
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
                                    Text("−\(Int(sliderDecline))%")
                                        .font(.system(size: 14, weight: .bold, design: .monospaced))
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
                    
                    // MARK: - Mode B Shock Controls (Individual Stock Shocks)
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
                    
                    // MARK: - Cascading Liquidity & Runway Impact Card
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

// MARK: - Graph A: Before vs After Bar Chart
private struct GraphABeforeAfterView: View {
    let portfolioValue: Double
    let remainingValue: Double
    let loss: Double
    
    struct ValueBarItem: Identifiable {
        let id: String
        let category: String
        let amount: Double
        let color: Color
    }
    
    var items: [ValueBarItem] {
        [
            ValueBarItem(id: "pre", category: "Pre-Shock", amount: portfolioValue, color: LOSTheme.primary),
            ValueBarItem(id: "rem", category: "Remaining", amount: remainingValue, color: LOSTheme.safeGreen),
            ValueBarItem(id: "loss", category: "Drawdown Loss", amount: loss, color: LOSTheme.criticalRed)
        ]
    }
    
    var body: some View {
        Chart(items) { item in
            BarMark(
                x: .value("Stage", item.category),
                y: .value("Rupees", item.amount)
            )
            .foregroundStyle(item.color)
            .cornerRadius(6)
            .annotation(position: .top) {
                Text(LOSTheme.formatRupeeCompact(item.amount))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(item.color)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(Color.primary.opacity(0.06))
                if let num = value.as(Double.self) {
                    AxisValueLabel {
                        Text(LOSTheme.formatRupeeCompact(num))
                            .font(.system(size: 9))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.system(size: 10, weight: .semibold))
            }
        }
    }
}

// MARK: - Graph B: Loss by Scenario Comparison Bar Chart
private struct GraphBScenarioComparisonView: View {
    let portfolioValue: Double
    let activeDecline: Double
    let onSelectScenario: (Double) -> Void
    
    var points: [ResilienceEngine.ScenarioComparisonPoint] {
        ResilienceEngine.calculateScenarioComparisons(portfolioValue: portfolioValue, activeDecline: activeDecline)
    }
    
    var body: some View {
        Chart(points) { point in
            BarMark(
                x: .value("Scenario", point.scenarioName),
                y: .value("Loss", point.loss)
            )
            .foregroundStyle(point.isSelected ? LOSTheme.criticalRed : LOSTheme.criticalRed.opacity(0.35))
            .cornerRadius(6)
            .annotation(position: .top) {
                Text("−\(LOSTheme.formatRupeeCompact(point.loss))")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(point.isSelected ? LOSTheme.criticalRed : Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine().foregroundStyle(Color.primary.opacity(0.06))
                if let num = value.as(Double.self) {
                    AxisValueLabel {
                        Text(LOSTheme.formatRupeeCompact(num))
                            .font(.system(size: 9))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.system(size: 10, weight: .semibold))
            }
        }
    }
}

// MARK: - Graph C: Individual Stock Loss Contribution Chart
private struct GraphCStockContributionView: View {
    let items: [ResilienceViewModel.IndividualStockLossItem]
    let totalLoss: Double
    
    var body: some View {
        if items.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "chart.pie")
                    .font(.title2)
                    .foregroundStyle(Color.secondary)
                Text("No stock holdings to display.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            Chart(items) { item in
                BarMark(
                    x: .value("Simulated Loss", item.simulatedLoss),
                    y: .value("Stock", item.holding.ticker)
                )
                .foregroundStyle(LOSTheme.criticalRed.opacity(0.85))
                .cornerRadius(4)
                .annotation(position: .trailing) {
                    Text("\(String(format: "%.1f%%", item.lossContributionPercent))")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(LOSTheme.criticalRed)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisGridLine().foregroundStyle(Color.primary.opacity(0.06))
                    if let num = value.as(Double.self) {
                        AxisValueLabel {
                            Text(LOSTheme.formatRupeeCompact(num))
                                .font(.system(size: 9))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
            }
        }
    }
}

// MARK: - Graph D: Continuous Portfolio Decline Curve Area Chart
private struct GraphDDeclineCurveView: View {
    let portfolioValue: Double
    let currentDecline: Double
    
    var curvePoints: [ResilienceEngine.DeclineCurvePoint] {
        ResilienceEngine.calculateDeclineCurve(portfolioValue: portfolioValue)
    }
    
    var activeRemaining: Double {
        max(0, portfolioValue * (1.0 - (currentDecline / 100.0)))
    }
    
    var body: some View {
        Chart {
            // Area Under Curve
            ForEach(curvePoints) { point in
                AreaMark(
                    x: .value("Shock %", point.declinePercent),
                    y: .value("Remaining Value", point.remainingPortfolio)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [LOSTheme.safeGreen.opacity(0.35), LOSTheme.safeGreen.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Continuous Curve Line
            ForEach(curvePoints) { point in
                LineMark(
                    x: .value("Shock %", point.declinePercent),
                    y: .value("Remaining Value", point.remainingPortfolio)
                )
                .foregroundStyle(LOSTheme.safeGreen)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
            }
            
            // Active Shock Vertical Marker Rule
            RuleMark(x: .value("Current Shock", currentDecline))
                .foregroundStyle(LOSTheme.criticalRed)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                .annotation(position: .topLeading) {
                    Text("\(Int(currentDecline))% Shock: \(LOSTheme.formatRupeeCompact(activeRemaining))")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundStyle(LOSTheme.criticalRed)
                        .padding(4)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(LOSTheme.criticalRed.opacity(0.4), lineWidth: 1))
                }
            
            // Active Point Marker
            PointMark(
                x: .value("Current Shock", currentDecline),
                y: .value("Current Remaining", activeRemaining)
            )
            .foregroundStyle(LOSTheme.criticalRed)
            .symbolSize(45)
        }
        .chartXScale(domain: 0...60)
        .chartXAxis {
            AxisMarks(values: [0, 15, 30, 45, 60]) { val in
                AxisGridLine().foregroundStyle(Color.primary.opacity(0.06))
                if let num = val.as(Int.self) {
                    AxisValueLabel {
                        Text("\(num)%")
                            .font(.system(size: 9))
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { val in
                AxisGridLine().foregroundStyle(Color.primary.opacity(0.06))
                if let num = val.as(Double.self) {
                    AxisValueLabel {
                        Text(LOSTheme.formatRupeeCompact(num))
                            .font(.system(size: 9))
                    }
                }
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
