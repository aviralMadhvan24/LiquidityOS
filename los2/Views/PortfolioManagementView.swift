import SwiftUI

/// Feature 02: Portfolio Holdings Management View.
/// Displays total market value, invested capital, unrealized P/L, asset allocation weights,
/// explicit market data freshness badges, and supports full CRUD with live quote refresh.
struct PortfolioManagementView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAddSheet: Bool = false
    @State private var editingHolding: PortfolioHolding? = nil
    
    var totalInvested: Double {
        viewModel.profile.activeHoldings.reduce(0.0) { $0 + $1.investedValue }
    }
    
    var totalMarketValue: Double {
        viewModel.profile.portfolioValue
    }
    
    var totalUnrealizedPnL: Double {
        totalMarketValue - totalInvested
    }
    
    var totalUnrealizedPnLPercent: Double {
        guard totalInvested > 0 else { return 0.0 }
        return (totalUnrealizedPnL / totalInvested) * 100.0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // MARK: - Header Valuation Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("TOTAL PORTFOLIO VALUE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text(LOSTheme.formatRupee(totalMarketValue))
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                            }
                            Spacer()
                            
                            // Freshness Indicator Capsule
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(viewModel.marketDataFreshnessSummary.color)
                                    .frame(width: 7, height: 7)
                                Text(viewModel.marketDataFreshnessSummary.displayName)
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(viewModel.marketDataFreshnessSummary.color)
                            }
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(viewModel.marketDataFreshnessSummary.color.opacity(0.12))
                            .clipShape(Capsule())
                        }
                        
                        Divider()
                            .overlay(LOSTheme.cardBorder)
                        
                        // Invested vs Unrealized P/L
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("INVESTED CAPITAL")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                Text(LOSTheme.formatRupee(totalInvested))
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 3) {
                                Text("UNREALIZED P/L")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                HStack(spacing: 4) {
                                    Image(systemName: totalUnrealizedPnL >= 0 ? "arrow.up.right" : "arrow.down.right")
                                        .font(.system(size: 11, weight: .bold))
                                    Text("\(LOSTheme.formatRupee(abs(totalUnrealizedPnL))) (\(String(format: "%+.1f%%", totalUnrealizedPnLPercent)))")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundStyle(totalUnrealizedPnL >= 0 ? LOSTheme.safeGreen : LOSTheme.criticalRed)
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
                    
                    // MARK: - Action Buttons (Refresh & Add)
                    HStack(spacing: 12) {
                        Button {
                            Task {
                                await viewModel.refreshMarketPrices()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if viewModel.isRefreshingMarketData {
                                    ProgressView()
                                        .tint(LOSTheme.primary)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                Text(viewModel.isRefreshingMarketData ? "Refreshing..." : "Refresh Quotes")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(LOSTheme.cardBackground)
                            .foregroundStyle(LOSTheme.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(LOSTheme.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(viewModel.isRefreshingMarketData)
                        
                        Button {
                            showingAddSheet = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Add Holding")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 11)
                            .background(LOSTheme.primary)
                            .foregroundStyle(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Status banner if any
                    if let msg = viewModel.marketDataMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(LOSTheme.primary)
                            Text(msg)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Holdings List Header
                    HStack {
                        Text("EQUITY HOLDINGS (\(viewModel.profile.activeHoldings.count))")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        Spacer()
                        Text("Swipe to edit/delete")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                    
                    if viewModel.profile.activeHoldings.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.secondary.opacity(0.5))
                            Text("No Holdings in Portfolio")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text("Add your Indian stock holdings (NSE/BSE) to run realistic stress simulations and track liquidity health.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                            Button {
                                showingAddSheet = true
                            } label: {
                                Text("Add First Holding")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(LOSTheme.primary)
                                    .foregroundStyle(Color.black)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(viewModel.profile.activeHoldings) { holding in
                                HoldingRowCard(
                                    holding: holding,
                                    onEdit: {
                                        editingHolding = holding
                                    },
                                    onDelete: {
                                        viewModel.deleteHolding(id: holding.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Notice on Market Data Compliance
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.secondary)
                            Text("DATA INTEGRITY NOTICE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                        }
                        Text("Quotes are fetched via the configured backend adapter (Yahoo Finance NSE 15-min delayed or demo simulation). All delayed and mock prices are strictly labelled to ensure transparency.")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.secondary)
                            .lineSpacing(2)
                    }
                    .padding(14)
                    .background(LOSTheme.cardBackground.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Portfolio Holdings")
            .navigationBarTitleDisplayMode(.inline)
            .background(LOSTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                HoldingEditorSheet(viewModel: viewModel)
            }
            .sheet(item: $editingHolding) { holding in
                HoldingEditorSheet(viewModel: viewModel, existingHolding: holding)
            }
        }
    }
}

/// Card view for an individual holding row
private struct HoldingRowCard: View {
    let holding: PortfolioHolding
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(holding.ticker)
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                        
                        Text(holding.freshness.displayName)
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(holding.freshness.color.opacity(0.12))
                            .foregroundStyle(holding.freshness.color)
                            .clipShape(Capsule())
                    }
                    
                    Text(holding.companyName)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text(LOSTheme.formatRupee(holding.currentValue))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 3) {
                        Image(systemName: holding.unrealizedPnL >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text("\(LOSTheme.formatRupee(abs(holding.unrealizedPnL))) (\(String(format: "%+.1f%%", holding.unrealizedPnLPercent)))")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(holding.unrealizedPnL >= 0 ? LOSTheme.safeGreen : LOSTheme.criticalRed)
                }
            }
            
            Divider()
                .overlay(LOSTheme.cardBorder.opacity(0.5))
            
            // Sub-details: Shares, Avg, Current Price, Weight
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("QUANTITY & AVG")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                    Text("\(holding.shares) @ \(LOSTheme.formatRupee(holding.averageBuyPrice))")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 2) {
                    Text("CURRENT PRICE")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                    Text(LOSTheme.formatRupee(holding.currentPrice))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("WEIGHT")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.secondary)
                    Text(String(format: "%.1f%%", holding.portfolioWeightPercent))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(LOSTheme.primary)
                }
                
                // Action Menu
                Menu {
                    Button(action: onEdit) {
                        Label("Edit Holding", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Remove Holding", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                        .padding(.leading, 8)
                        .padding(.vertical, 4)
                }
            }
        }
        .padding(14)
        .background(LOSTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(LOSTheme.cardBorder, lineWidth: 1)
        )
    }
}
