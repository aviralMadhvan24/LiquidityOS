import SwiftUI

/// Detailed view showing all structured findings, quotations, and guidance from a concall.
struct ConcallDetailView: View {
    let analysis: ConcallAnalysis
    @ObservedObject var resilienceViewModel: ResilienceViewModel
    @State private var selectedFilter: FindingClassification? = nil
    @State private var isShowingStressBridge: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Information Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(analysis.metadata.quarter) \(analysis.metadata.fiscalYear) EARNINGS CALL")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            
                            Text(analysis.metadata.companyName)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Text(analysis.metadata.ticker)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(LOSTheme.primary.opacity(0.12))
                            .foregroundStyle(LOSTheme.primary)
                            .clipShape(Capsule())
                    }
                    
                    if let source = analysis.metadata.transcriptSource {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text.magnifyingglass")
                                .font(.system(size: 11))
                            Text("Source: \(source)")
                                .font(.system(size: 11))
                        }
                        .foregroundStyle(Color.secondary)
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
                
                // Portfolio Connection Banner & Stress Button
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Portfolio Connection", systemImage: "briefcase.fill")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(LOSTheme.primary)
                        Spacer()
                    }
                    
                    Text(analysis.portfolioConnection.holdingSummary)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    
                    Text(analysis.portfolioConnection.potentialExposureExplanation)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.secondary)
                        .lineSpacing(2)
                    
                    Button {
                        isShowingStressBridge = true
                    } label: {
                        HStack {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                            Text("Stress Test Portfolio Under These Risks")
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 13))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .background(LOSTheme.primary)
                        .foregroundStyle(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 4)
                }
                .padding(16)
                .background(LOSTheme.primary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Executive Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("EXECUTIVE SUMMARY")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .tracking(0.8)
                    
                    Text(analysis.executiveSummary)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.primary)
                        .lineSpacing(3)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(LOSTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(LOSTheme.cardBorder, lineWidth: 1))
                .padding(.horizontal)
                
                // Financial & Guidance Commentary Cards
                VStack(alignment: .leading, spacing: 12) {
                    Text("FINANCIAL COMMENTARY & GUIDANCE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                        .tracking(0.8)
                    
                    VStack(spacing: 10) {
                        commentaryRow(title: "Revenue Commentary", content: analysis.financialPerformance.revenueCommentary, icon: "indianrupeesign.circle")
                        commentaryRow(title: "Profit Commentary", content: analysis.financialPerformance.profitCommentary, icon: "chart.bar.fill")
                        commentaryRow(title: "Margin Pressure", content: analysis.financialPerformance.marginPressure, icon: "gauge.with.needle", isWarning: true)
                        commentaryRow(title: "Costs & Debt", content: analysis.financialPerformance.risingCostsOrDebt, icon: "creditcard.fill")
                        commentaryRow(title: "Growth Guidance", content: analysis.growthAndGuidance.growthGuidance, icon: "arrow.up.right.circle")
                        commentaryRow(title: "Guidance Comparison", content: analysis.growthAndGuidance.guidanceComparison, icon: "clock.arrow.2.circlepath")
                    }
                }
                .padding(18)
                .background(LOSTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(LOSTheme.cardBorder, lineWidth: 1))
                .padding(.horizontal)
                
                // Findings & Supporting Quotations Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("EVIDENCE-BACKED FINDINGS")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        Spacer()
                        Text("\(analysis.findings.count) items")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.secondary)
                    }
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            filterChip(title: "All (\(analysis.findings.count))", isSelected: selectedFilter == nil) {
                                selectedFilter = nil
                            }
                            ForEach(FindingClassification.allCases) { cat in
                                let count = analysis.findings.filter { $0.classification == cat }.count
                                if count > 0 {
                                    filterChip(title: "\(cat.displayName) (\(count))", isSelected: selectedFilter == cat) {
                                        selectedFilter = cat
                                    }
                                }
                            }
                        }
                    }
                    
                    // Filtered Finding Cards
                    let filtered = analysis.findings.filter { item in
                        guard let f = selectedFilter else { return true }
                        return item.classification == f
                    }
                    
                    ForEach(filtered) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label(item.classification.displayName, systemImage: item.classification.iconName)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(item.classification.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(item.classification.color.opacity(0.12))
                                    .clipShape(Capsule())
                                Spacer()
                                Text(item.location)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Text(item.topic)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.primary)
                            
                            Text(item.explanation)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.secondary)
                            
                            // Verbatim Quote Block
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "quote.opening")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color.secondary)
                                    .padding(.top, 2)
                                Text(item.exactQuote)
                                    .font(.system(size: 12, weight: .medium, design: .serif))
                                    .italic()
                                    .foregroundStyle(Color.primary)
                            }
                            .padding(10)
                            .background(Color.primary.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(14)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(item.classification.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                
                // Key Management Statements
                if !analysis.managementStatements.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("KEY MANAGEMENT STATEMENTS")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        ForEach(analysis.managementStatements) { stmt in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(stmt.speaker)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(LOSTheme.primary)
                                
                                Text("\"\(stmt.quote)\"")
                                    .font(.system(size: 13, design: .serif))
                                    .italic()
                                
                                HStack {
                                    Text(stmt.context)
                                        .font(.system(size: 11))
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                    Text(stmt.location)
                                        .font(.system(size: 10))
                                        .foregroundStyle(Color.secondary)
                                }
                            }
                            .padding(12)
                            .background(Color.primary.opacity(0.03))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(LOSTheme.cardBorder, lineWidth: 1))
                    .padding(.horizontal)
                }
                
                // Key Uncertainties
                if !analysis.keyUncertainties.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Topics Requiring Further Investigation", systemImage: "questionmark.circle.fill")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(LOSTheme.warningAmber)
                        
                        ForEach(analysis.keyUncertainties, id: \.self) { item in
                            HStack(alignment: .top, spacing: 6) {
                                Image(systemName: "circle.fill")
                                    .font(.system(size: 4))
                                    .foregroundStyle(LOSTheme.warningAmber)
                                    .padding(.top, 6)
                                Text(item)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(LOSTheme.cardBorder, lineWidth: 1))
                    .padding(.horizontal)
                }
                
                // Bottom Disclaimer
                Text(analysis.portfolioConnection.disclaimer)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle(analysis.metadata.ticker)
        .navigationBarTitleDisplayMode(.inline)
        .background(LOSTheme.background.ignoresSafeArea())
        .sheet(isPresented: $isShowingStressBridge) {
            ConcallStressBridgeSheet(
                analysis: analysis,
                resilienceViewModel: resilienceViewModel
            )
        }
    }
    
    @ViewBuilder
    private func commentaryRow(title: String, content: String, icon: String, isWarning: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(isWarning ? LOSTheme.warningAmber : LOSTheme.primary)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            Text(content)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(content.contains("Not mentioned") ? Color.secondary.opacity(0.7) : Color.primary)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? LOSTheme.primary : Color.primary.opacity(0.06))
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
