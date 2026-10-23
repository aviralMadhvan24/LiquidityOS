import SwiftUI

/// Dedicated screen for Feature 01: Portfolio Stress Testing (Slide 04).
struct StressTestView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @State private var sliderDecline: Double = 15.0
    
    var body: some View {
        let report = viewModel.currentReport
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 6) {
                        Text("PORTFOLIO VALUE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        
                        Text(LOSTheme.formatRupee(viewModel.profile.portfolioValue))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        
                        Text("Total market exposure subject to volatility shock")
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
                    
                    // Stress Selector
                    VStack(alignment: .leading, spacing: 14) {
                        Text("MARKET DECLINE SCENARIO")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.secondary)
                            .tracking(0.8)
                        
                        SegmentedShockPicker(selected: $viewModel.selectedScenario) { level in
                            viewModel.selectScenario(level)
                            sliderDecline = level.percentage
                        }
                        
                        // Fine-tune Slider
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Custom Shock")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)
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
                    
                    // Results Card: Loss & Remaining
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ESTIMATED LOSS")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text("−\(LOSTheme.formatRupee(report.estimatedPortfolioLoss))")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.criticalRed)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("REMAINING VALUE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(.secondary)
                                Text(LOSTheme.formatRupee(report.remainingPortfolioValue))
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.safeGreen)
                            }
                        }
                        
                        // Retained Progress Bar
                        VStack(alignment: .leading, spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LOSTheme.criticalRed.opacity(0.3))
                                        .frame(height: 16)
                                    
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(LOSTheme.safeGreen)
                                        .frame(width: max(0, geo.size.width * CGFloat(report.portfolioRetentionPercent / 100.0)), height: 16)
                                }
                            }
                            .frame(height: 16)
                            
                            HStack {
                                Text("\(String(format: "%.1f%%", report.portfolioRetentionPercent)) of portfolio retained")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.safeGreen)
                                Spacer()
                                Text("\(Int(report.marketDeclinePercent))% drawdown")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
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
                    
                    // Explanatory Note Card
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundStyle(LOSTheme.primary)
                        Text("Simulations reflect instant equity drop. This allows you to evaluate whether your emergency cash prevents you from selling at a market bottom.")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .background(LOSTheme.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Portfolio Stress")
            .background(LOSTheme.background.ignoresSafeArea())
            .onAppear {
                sliderDecline = viewModel.currentDeclinePercentage
            }
        }
    }
}
