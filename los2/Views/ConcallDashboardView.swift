import SwiftUI

/// Main Hub for Feature: AI Concall Intelligence.
struct ConcallDashboardView: View {
    @ObservedObject var viewModel: ConcallViewModel
    @ObservedObject var resilienceViewModel: ResilienceViewModel
    
    @State private var isShowingHistory: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header & Backend Health Status Pill
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AI Earnings Call Insights")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.secondary)
                            Text("Concall Intelligence")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        
                        // Server Status Indicator
                        serverStatusBadge
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    // Quick Action Card: Upload / Paste or Try Sample
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("ANALYZE EARNINGS CALL")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text("Extract business risks & guidance from transcript")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.secondary)
                            }
                            Spacer()
                        }
                        
                        HStack(spacing: 10) {
                            Button {
                                viewModel.resetUploadForm()
                                viewModel.isShowingUploadSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Transcript")
                                        .fontWeight(.bold)
                                }
                                .font(.system(size: 14))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(LOSTheme.primary)
                                .foregroundStyle(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                viewModel.loadSampleRelianceConcall()
                            } label: {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Load Sample")
                                        .fontWeight(.semibold)
                                }
                                .font(.system(size: 14))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.primary.opacity(0.06))
                                .foregroundStyle(Color.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
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
                    
                    // Company Selector: User's Existing Portfolio Holdings
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("YOUR PORTFOLIO COMPANIES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            Text("\(resilienceViewModel.profile.activeHoldings.count) holdings")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.secondary)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(resilienceViewModel.profile.activeHoldings) { holding in
                                    let isSelected = viewModel.selectedHolding?.id == holding.id || viewModel.tickerInput == holding.ticker
                                    Button {
                                        viewModel.selectHolding(holding)
                                        // If already analyzed, load it
                                        if let found = viewModel.savedAnalyses.first(where: { $0.metadata.ticker == holding.ticker }) {
                                            viewModel.currentAnalysis = found
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack {
                                                Text(holding.ticker)
                                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                                Spacer()
                                                Text("\(String(format: "%.0f%%", holding.portfolioWeightPercent))")
                                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                                    .foregroundStyle(LOSTheme.primary)
                                            }
                                            
                                            Text(holding.companyName)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundStyle(Color.primary)
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Text(LOSTheme.formatRupee(holding.currentValue))
                                                .font(.system(size: 11))
                                                .foregroundStyle(Color.secondary)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.85)
                                        }
                                        .frame(width: 145, alignment: .leading)
                                        .padding(12)
                                        .background(isSelected ? LOSTheme.primary.opacity(0.14) : Color.primary.opacity(0.04))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isSelected ? LOSTheme.primary : Color.clear, lineWidth: 1.5)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(LOSTheme.cardBorder, lineWidth: 1))
                    .padding(.horizontal)
                    
                    // Latest / Active Analysis Hero Card
                    if let analysis = viewModel.currentAnalysis {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack {
                                        Text(analysis.metadata.companyName)
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                        Text("(\(analysis.metadata.ticker))")
                                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                                            .foregroundStyle(LOSTheme.primary)
                                    }
                                    Text("\(analysis.metadata.quarter) \(analysis.metadata.fiscalYear) Concall Summary")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.secondary)
                                }
                                Spacer()
                                NavigationLink {
                                    ConcallDetailView(
                                        analysis: analysis,
                                        resilienceViewModel: resilienceViewModel
                                    )
                                } label: {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            
                            Text(analysis.executiveSummary)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.primary)
                                .lineLimit(3)
                                .lineSpacing(2)
                            
                            // Key metrics pills
                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(LOSTheme.criticalRed)
                                    Text("\(analysis.risks.count) Business Risks")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right.circle.fill")
                                        .font(.system(size: 11))
                                        .foregroundStyle(LOSTheme.safeGreen)
                                    Text("\(analysis.positives.count) Positives")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                
                                Spacer()
                                
                                Text("\(analysis.findings.count) Quotes")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Divider()
                            
                            HStack(spacing: 12) {
                                NavigationLink {
                                    ConcallDetailView(
                                        analysis: analysis,
                                        resilienceViewModel: resilienceViewModel
                                    )
                                } label: {
                                    Text("View Full Analysis")
                                        .font(.system(size: 13, weight: .bold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(LOSTheme.primary.opacity(0.12))
                                        .foregroundStyle(LOSTheme.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                
                                Button {
                                    viewModel.isShowingStressBridge = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "bolt.shield.fill")
                                        Text("Stress Test")
                                    }
                                    .font(.system(size: 13, weight: .bold))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(LOSTheme.warningAmber.opacity(0.15))
                                    .foregroundStyle(LOSTheme.warningAmber)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(18)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(LOSTheme.cardBorder, lineWidth: 1))
                        .padding(.horizontal)
                    }
                    
                    // Saved Analyses History List
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("SAVED ANALYSES")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            NavigationLink("See All (\(viewModel.savedAnalyses.count))") {
                                ConcallHistoryView(
                                    viewModel: viewModel,
                                    resilienceViewModel: resilienceViewModel
                                )
                            }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(LOSTheme.primary)
                        }
                        
                        ForEach(viewModel.savedAnalyses.prefix(3)) { item in
                            NavigationLink {
                                ConcallDetailView(
                                    analysis: item,
                                    resilienceViewModel: resilienceViewModel
                                )
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(item.metadata.companyName)
                                                .font(.system(size: 14, weight: .bold))
                                            Text("(\(item.metadata.ticker))")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundStyle(LOSTheme.primary)
                                        }
                                        Text("\(item.metadata.quarter) \(item.metadata.fiscalYear) • \(item.findings.count) insights")
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundStyle(Color.secondary)
                                }
                                .padding(12)
                                .background(Color.primary.opacity(0.03))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(LOSTheme.cardBorder, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .background(LOSTheme.background.ignoresSafeArea())
            .sheet(isPresented: $viewModel.isShowingUploadSheet) {
                ConcallUploadSheet(
                    viewModel: viewModel,
                    portfolioValue: resilienceViewModel.profile.portfolioValue
                )
            }
            .sheet(isPresented: $viewModel.isShowingStressBridge) {
                if let analysis = viewModel.currentAnalysis {
                    ConcallStressBridgeSheet(
                        analysis: analysis,
                        resilienceViewModel: resilienceViewModel
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private var serverStatusBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(statusIndicatorColor)
                .frame(width: 7, height: 7)
            Text(statusIndicatorText)
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(statusIndicatorColor.opacity(0.12))
        .foregroundStyle(statusIndicatorColor)
        .clipShape(Capsule())
    }
    
    private var statusIndicatorColor: Color {
        switch viewModel.serverStatus {
        case .online(_, let llmReady):
            return llmReady ? LOSTheme.safeGreen : LOSTheme.warningAmber
        case .offline:
            return Color.secondary
        case .checking:
            return LOSTheme.primary
        }
    }
    
    private var statusIndicatorText: String {
        switch viewModel.serverStatus {
        case .online(let provider, let llmReady):
            return llmReady ? provider : "Setup LLM Key"
        case .offline:
            return "Local Ready"
        case .checking:
            return "Connecting..."
        }
    }
}
