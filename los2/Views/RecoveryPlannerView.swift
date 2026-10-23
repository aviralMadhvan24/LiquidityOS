import SwiftUI

/// Feature 05: AI Recovery Planner View.
/// Evaluates post-shock cash depletion and calculates deterministic recovery blueprints (Conservative, Balanced, Aggressive)
/// enhanced with AI strategic rationale and trade-off analysis.
struct RecoveryPlannerView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTierIndex: Int = 1 // Default to Balanced (index 1)
    
    var response: RecoveryPlanResponse? {
        viewModel.recoveryPlanResponse
    }
    
    var baseline: RecoveryBaseline? {
        viewModel.recoveryBaseline
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Header Baseline Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("RECOVERY BASELINE")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text("Post-Shock Deficit")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                            }
                            Spacer()
                            
                            if let res = response {
                                HStack(spacing: 4) {
                                    Image(systemName: res.aiGenerated ? "sparkles" : "shield.checkerboard")
                                        .font(.system(size: 10, weight: .bold))
                                    Text(res.aiProvider)
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                }
                                .padding(.horizontal, 9)
                                .padding(.vertical, 5)
                                .background(LOSTheme.primary.opacity(0.12))
                                .foregroundStyle(LOSTheme.primary)
                                .clipShape(Capsule())
                            }
                        }
                        
                        Divider()
                            .overlay(LOSTheme.cardBorder)
                        
                        // Baseline metrics
                        HStack(spacing: 12) {
                            BaselineMetric(
                                title: "POST-SHOCK CASH",
                                value: LOSTheme.formatRupee(baseline?.immediatePostShockCash ?? viewModel.currentReport.remainingCashAfterEmergency),
                                isAlert: (baseline?.immediatePostShockCash ?? 0) < 20_000
                            )
                            
                            Spacer()
                            
                            BaselineMetric(
                                title: "NET MONTHLY BURN",
                                value: "\(LOSTheme.formatRupee(baseline?.baselineNetBurn ?? viewModel.currentReport.monthlyNetBurn))/mo",
                                isAlert: false
                            )
                            
                            Spacer()
                            
                            BaselineMetric(
                                title: "CURRENT RUNWAY",
                                value: String(format: "%.1f mos", baseline?.baselineRunwayMonths ?? viewModel.currentReport.runwayMonths),
                                isAlert: (baseline?.baselineRunwayMonths ?? 5.0) < 3.0
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
                    
                    // MARK: - Goal Customizer & Refresh Action
                    VStack(alignment: .leading, spacing: 10) {
                        Text("RECOVERY OBJECTIVE")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        HStack {
                            Image(systemName: "target")
                                .foregroundStyle(LOSTheme.primary)
                            TextField("Enter recovery priority...", text: $viewModel.recoveryUserGoals)
                                .font(.system(size: 13))
                        }
                        .padding(10)
                        .background(LOSTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Button {
                            Task {
                                await viewModel.fetchRecoveryPlans()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                if viewModel.isGeneratingRecoveryPlan {
                                    ProgressView()
                                        .tint(.black)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                Text(viewModel.isGeneratingRecoveryPlan ? "Synthesizing Blueprint..." : "Generate AI Recovery Blueprint")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(LOSTheme.primary)
                            .foregroundStyle(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .disabled(viewModel.isGeneratingRecoveryPlan)
                    }
                    .padding(16)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Plan Selector Tabs
                    if let plans = response?.plans, !plans.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("SELECT RECOVERY STRATEGY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                                .padding(.horizontal)
                            
                            // Strategy Switcher
                            HStack(spacing: 8) {
                                ForEach(Array(plans.enumerated()), id: \.element.id) { index, plan in
                                    let isSelected = selectedTierIndex == index
                                    Button {
                                        selectedTierIndex = index
                                    } label: {
                                        VStack(spacing: 4) {
                                            Text(plan.tier)
                                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                            Text("+\(String(format: "%.1f", plan.runwayExtensionMonths)) mo")
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .foregroundStyle(isSelected ? LOSTheme.safeGreen : Color.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(isSelected ? LOSTheme.cardBackground : LOSTheme.cardBackground.opacity(0.5))
                                        .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(isSelected ? LOSTheme.primary : Color.clear, lineWidth: 1.5)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Active Plan Details
                            let activePlan = plans[min(selectedTierIndex, plans.count - 1)]
                            PlanDetailCard(plan: activePlan)
                                .padding(.horizontal)
                        }
                        
                        // MARK: - AI Executive Summary & Risk Advisory
                        if let res = response {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundStyle(LOSTheme.primary)
                                    Text("AI STRATEGIC NARRATIVE")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.secondary)
                                        .tracking(0.8)
                                }
                                
                                Text(res.summary)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.primary)
                                    .lineSpacing(3)
                                
                                if let advisory = res.riskAdvisory {
                                    Divider()
                                        .overlay(LOSTheme.cardBorder)
                                    
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "shield.lefthalf.filled")
                                            .font(.system(size: 12))
                                            .foregroundStyle(LOSTheme.warningAmber)
                                            .padding(.top, 2)
                                        Text(advisory)
                                            .font(.system(size: 11))
                                            .foregroundStyle(Color.secondary)
                                            .lineSpacing(2)
                                    }
                                }
                            }
                            .padding(16)
                            .background(LOSTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(LOSTheme.cardBorder, lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .padding(.bottom, 24)
                        }
                    } else if !viewModel.isGeneratingRecoveryPlan {
                        VStack(spacing: 12) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.secondary.opacity(0.6))
                            Text("No Active Recovery Plan")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Text("Tap 'Generate AI Recovery Blueprint' above to calculate personalized emergency repair strategies.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        .padding(36)
                        .frame(maxWidth: .infinity)
                        .background(LOSTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("AI Recovery Planner")
            .navigationBarTitleDisplayMode(.inline)
            .background(LOSTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .task {
                if response == nil {
                    await viewModel.fetchRecoveryPlans()
                }
            }
        }
    }
}

/// Baseline metric sub-item
private struct BaselineMetric: View {
    let title: String
    let value: String
    let isAlert: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(isAlert ? LOSTheme.criticalRed : Color.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

/// Detailed Card for the Selected Recovery Plan
private struct PlanDetailCard: View {
    let plan: RecoveryPlanOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(plan.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Text(plan.description)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                
                Text(plan.tier.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LOSTheme.primary.opacity(0.12))
                    .foregroundStyle(LOSTheme.primary)
                    .clipShape(Capsule())
            }
            
            Divider()
                .overlay(LOSTheme.cardBorder)
            
            // 4 Core Financial Metrics
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 10) {
                MetricPill(
                    label: "MONTHLY SAVINGS",
                    value: "+\(LOSTheme.formatRupee(plan.monthlyExpenseReduction))/mo",
                    highlightColor: LOSTheme.safeGreen
                )
                
                MetricPill(
                    label: "NEW NET BURN",
                    value: "\(LOSTheme.formatRupee(plan.newNetBurn))/mo",
                    highlightColor: plan.newNetBurn == 0 ? LOSTheme.safeGreen : LOSTheme.warningAmber
                )
                
                MetricPill(
                    label: "NEW CASH RUNWAY",
                    value: String(format: "%.1f mos", plan.newRunwayMonths),
                    badge: "+\(String(format: "%.1f", plan.runwayExtensionMonths)) mo",
                    highlightColor: LOSTheme.safeGreen
                )
                
                MetricPill(
                    label: "REBUILD EMERGENCY FUND",
                    value: plan.monthsToRebuildEmergencyFund >= 99 ? "N/A" : "\(plan.monthsToRebuildEmergencyFund) Months",
                    highlightColor: LOSTheme.primary
                )
            }
            
            // Action Steps
            VStack(alignment: .leading, spacing: 8) {
                Text("RECOMMENDED ACTIONS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .tracking(0.8)
                
                ForEach(plan.actionSteps, id: \.self) { step in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(LOSTheme.safeGreen)
                            .padding(.top, 2)
                        Text(step)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .padding(.top, 4)
            
            // Trade-offs & Behavioral Feasibility
            VStack(alignment: .leading, spacing: 4) {
                Text("STRATEGIC TRADE-OFFS")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .tracking(0.8)
                Text(plan.tradeOffs)
                    .font(.system(size: 12))
                    .foregroundStyle(Color.secondary)
                    .lineSpacing(2)
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
    }
}

private struct MetricPill: View {
    let label: String
    let value: String
    var badge: String? = nil
    let highlightColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            HStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(highlightColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                if let b = badge {
                    Text(b)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(highlightColor.opacity(0.12))
                        .foregroundStyle(highlightColor)
                        .clipShape(Capsule())
                        .layoutPriority(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(LOSTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
