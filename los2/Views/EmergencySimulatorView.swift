import SwiftUI

/// Feature 02: Redesigned Emergency Expense Simulator.
/// Simulates realistic emergency shocks (medical, vehicle, family, job gap), supports one-time vs recurring drains,
/// evaluates minimum reserve breaches, and calculates funding shortfalls with a full before-and-after comparison.
struct EmergencySimulatorView: View {
    @ObservedObject var viewModel: ResilienceViewModel
    
    var sim: EmergencySimulationResult {
        viewModel.emergencySimulationResult
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - Hero Before vs After Financial Comparison Card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("EMERGENCY SHOCK IMPACT")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.8)
                                Text(sim.severityRating.uppercased())
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundStyle(sim.statusColor)
                            }
                            Spacer()
                            
                            // Category Icon Capsule
                            HStack(spacing: 6) {
                                Image(systemName: viewModel.emergencyScenario.category.iconName)
                                    .font(.system(size: 12, weight: .bold))
                                Text(viewModel.emergencyScenario.category.rawValue)
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(sim.statusColor.opacity(0.12))
                            .foregroundStyle(sim.statusColor)
                            .clipShape(Capsule())
                        }
                        
                        Text(sim.summaryHeadline)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Divider()
                            .overlay(LOSTheme.cardBorder)
                        
                        // Before vs After Cash & Runway Comparison
                        HStack(spacing: 12) {
                            // BEFORE
                            VStack(alignment: .leading, spacing: 4) {
                                Text("BEFORE SHOCK")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.6)
                                Text(LOSTheme.formatRupee(sim.preShockCash))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.70)
                                Text("Runway: \(String(format: "%.1f", sim.preShockRunwayMonths)) mos")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer(minLength: 4)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundStyle(sim.statusColor)
                                .layoutPriority(1)
                            
                            Spacer(minLength: 4)
                            
                            // AFTER
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("AFTER SHOCK")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.secondary)
                                    .tracking(0.6)
                                Text(LOSTheme.formatRupee(sim.postShockCash))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(sim.isShortfall ? LOSTheme.criticalRed : Color.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.70)
                                Text("Runway: \(String(format: "%.1f", sim.postShockRunwayMonths)) mos")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(sim.postShockRunwayMonths < 3.0 ? LOSTheme.criticalRed : LOSTheme.safeGreen)
                                    .lineLimit(1)
                            }
                        }
                        
                        // Cash Drained Progress Bar
                        VStack(alignment: .leading, spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(0.08))
                                        .frame(height: 10)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(sim.statusColor)
                                        .frame(width: max(0, min(geo.size.width, geo.size.width * CGFloat(sim.cashDrainedPercentage / 100.0))), height: 10)
                                }
                            }
                            .frame(height: 10)
                            
                            HStack {
                                Text("\(Int(sim.cashDrainedPercentage))% of liquid cash consumed")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(sim.statusColor)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                Spacer()
                                Text("Total Drain: −\(LOSTheme.formatRupee(sim.totalEmergencyDrain))")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.criticalRed)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                    }
                    .padding(18)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(sim.statusColor.opacity(0.35), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Funding Shortfall Warning (If Cash Insufficient)
                    if sim.isShortfall {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .font(.title2)
                                .foregroundStyle(LOSTheme.criticalRed)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("FUNDING SHORTFALL: \(LOSTheme.formatRupee(sim.fundingShortfall))")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundStyle(LOSTheme.criticalRed)
                                    .minimumScaleFactor(0.85)
                                    .lineLimit(1)
                                Text("Liquid cash (\(LOSTheme.formatRupeeCompact(sim.preShockCash))) cannot cover this \(LOSTheme.formatRupeeCompact(sim.totalEmergencyDrain)) shock. Requires \(LOSTheme.formatRupee(sim.fundingShortfall)) from debt or emergency borrowing.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.secondary)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(14)
                        .background(LOSTheme.criticalRed.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(LOSTheme.criticalRed.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // MARK: - Minimum Cash Reserve Status Card
                    HStack(spacing: 12) {
                        Image(systemName: sim.isReserveBreached ? "shield.slash.fill" : "shield.checkerboard")
                            .font(.title2)
                            .foregroundStyle(sim.isReserveBreached ? LOSTheme.warningAmber : LOSTheme.safeGreen)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(sim.isReserveBreached ? "SAFETY FLOOR BREACHED" : "SAFETY FLOOR INTACT")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundStyle(sim.isReserveBreached ? LOSTheme.warningAmber : LOSTheme.safeGreen)
                                Spacer()
                                Text("Floor: \(LOSTheme.formatRupee(sim.minimumReserveTarget))")
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            if sim.isReserveBreached {
                                Text("Remaining liquid cash (\(LOSTheme.formatRupeeCompact(sim.postShockCash))) drops \(LOSTheme.formatRupeeCompact(sim.reserveBreachAmount)) below your \(LOSTheme.formatRupeeCompact(sim.minimumReserveTarget)) safety floor.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            } else {
                                Text("Remaining liquid cash (\(LOSTheme.formatRupeeCompact(sim.postShockCash))) safely preserves your \(LOSTheme.formatRupeeCompact(sim.minimumReserveTarget)) safety floor.")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(14)
                    .background(LOSTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(sim.isReserveBreached ? LOSTheme.warningAmber.opacity(0.3) : LOSTheme.cardBorder, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    
                    // MARK: - Emergency Category Presets
                    VStack(alignment: .leading, spacing: 10) {
                        Text("EMERGENCY CATEGORY")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(EmergencyCategory.allCases) { cat in
                                    let isSelected = viewModel.emergencyScenario.category == cat
                                    Button {
                                        viewModel.emergencyScenario.category = cat
                                        viewModel.emergencyScenario.amount = cat.defaultAmount
                                        viewModel.profile.unexpectedExpense = viewModel.emergencyScenario.totalEmergencyDrain
                                    } label: {
                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Image(systemName: cat.iconName)
                                                    .font(.system(size: 14, weight: .bold))
                                                Spacer()
                                                if isSelected {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 12))
                                                }
                                            }
                                            
                                            Text(cat.rawValue)
                                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                            
                                            Text(LOSTheme.formatRupeeCompact(cat.defaultAmount))
                                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                                .foregroundStyle(isSelected ? Color.black : Color.secondary)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 145, alignment: .leading)
                                        .padding(12)
                                        .background(isSelected ? LOSTheme.primary : LOSTheme.cardBackground)
                                        .foregroundStyle(isSelected ? Color.black : Color.primary)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(isSelected ? Color.clear : LOSTheme.cardBorder, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // MARK: - Expense Frequency & Configuration
                    VStack(alignment: .leading, spacing: 16) {
                        Text("FREQUENCY & DURATION")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                            .tracking(0.8)
                        
                        Picker("Expense Type", selection: $viewModel.emergencyScenario.expenseType) {
                            ForEach(EmergencyExpenseType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: viewModel.emergencyScenario.expenseType) { _ in
                            viewModel.profile.unexpectedExpense = viewModel.emergencyScenario.totalEmergencyDrain
                        }
                        
                        if viewModel.emergencyScenario.expenseType == .recurring {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Recurring Duration")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.secondary)
                                    Spacer()
                                    Text("\(viewModel.emergencyScenario.recurringMonths) Months (\(LOSTheme.formatRupee(viewModel.emergencyScenario.amount))/mo)")
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundStyle(LOSTheme.primary)
                                }
                                
                                Stepper(
                                    value: $viewModel.emergencyScenario.recurringMonths,
                                    in: 2...12
                                ) {
                                    Text("Duration: \(viewModel.emergencyScenario.recurringMonths) months")
                                        .font(.system(size: 12))
                                }
                                .onChange(of: viewModel.emergencyScenario.recurringMonths) { _ in
                                    viewModel.profile.unexpectedExpense = viewModel.emergencyScenario.totalEmergencyDrain
                                }
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
                    
                    // MARK: - Amount Adjuster (Slider + Quick Pills)
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("AMOUNT")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondary)
                                .tracking(0.8)
                            Spacer()
                            Text(LOSTheme.formatRupee(viewModel.emergencyScenario.amount))
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(LOSTheme.criticalRed)
                        }
                        
                        // Preset Pills
                        HStack(spacing: 8) {
                            ForEach([25_000.0, 50_000.0, 100_000.0, 150_000.0], id: \.self) { val in
                                let isSel = abs(viewModel.emergencyScenario.amount - val) < 1.0
                                Button {
                                    viewModel.emergencyScenario.amount = val
                                    viewModel.profile.unexpectedExpense = viewModel.emergencyScenario.totalEmergencyDrain
                                } label: {
                                    Text(LOSTheme.formatRupeeCompact(val))
                                        .font(.system(size: 12, weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(isSel ? LOSTheme.criticalRed.opacity(0.18) : Color.primary.opacity(0.04))
                                        .foregroundStyle(isSel ? LOSTheme.criticalRed : Color.secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Fine-tune Slider
                        Slider(
                            value: $viewModel.emergencyScenario.amount,
                            in: 5_000...max(250_000, viewModel.profile.liquidCash * 2.0),
                            step: 5_000
                        )
                        .tint(LOSTheme.criticalRed)
                        .onChange(of: viewModel.emergencyScenario.amount) { _ in
                            viewModel.profile.unexpectedExpense = viewModel.emergencyScenario.totalEmergencyDrain
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
            .navigationTitle("Emergency Simulator")
            .background(LOSTheme.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Reset") {
                        viewModel.resetEmergencyScenario()
                        viewModel.profile.unexpectedExpense = viewModel.emergencyScenario.totalEmergencyDrain
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LOSTheme.primary)
                }
            }
            .onAppear {
                viewModel.emergencyScenario.amount = viewModel.profile.unexpectedExpense
            }
        }
    }
}
