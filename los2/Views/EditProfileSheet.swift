import SwiftUI

/// Feature 05: Enhanced Financial Profile Editor Sheet.
/// Allows users to view, validate, and update all dimensions of their real financial reality:
/// income, living expenses, debt/EMI commitments, liquid cash, desired safety reserve, and equity assets.
struct EditProfileSheet: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var portfolioText: String = ""
    @State private var cashText: String = ""
    @State private var incomeText: String = ""
    @State private var expensesText: String = ""
    @State private var debtText: String = ""
    @State private var reserveFloorText: String = ""
    @State private var billText: String = ""
    
    @State private var validationError: String? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                // Validation error callout
                if let err = validationError {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(LOSTheme.criticalRed)
                            Text(err)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(LOSTheme.criticalRed)
                        }
                    }
                }
                
                // Section 1: Assets & Liquid Cash
                Section {
                    HStack {
                        Label("Liquid Cash", systemImage: "banknote.fill")
                        Spacer()
                        TextField("₹", text: $cashText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Label("Safety Floor", systemImage: "shield.fill")
                        Spacer()
                        TextField("₹", text: $reserveFloorText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Label("Portfolio Value", systemImage: "chart.pie.fill")
                        Spacer()
                        TextField("₹", text: $portfolioText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Assets & Reserves")
                } footer: {
                    Text("Liquid cash includes savings and instant bank deposits. The safety floor is the minimum balance you protect.")
                }
                
                // Section 2: Cash Flow (Earnings & Outflows)
                Section {
                    HStack {
                        Label("Monthly Income", systemImage: "arrow.down.left.circle.fill")
                        Spacer()
                        TextField("₹", text: $incomeText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Label("Living Expenses", systemImage: "arrow.up.right.circle.fill")
                        Spacer()
                        TextField("₹", text: $expensesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Label("Debt & EMI Payments", systemImage: "creditcard.fill")
                        Spacer()
                        TextField("₹", text: $debtText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Monthly Cash Flow & Commitments")
                } footer: {
                    Text("Living expenses plus debt commitments determine your total monthly burn rate.")
                }
                
                // Section 3: Stress Testing Emergency Bill
                Section {
                    HStack {
                        Label("Emergency Bill", systemImage: "bolt.shield.fill")
                        Spacer()
                        TextField("₹", text: $billText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Stress Shock Baseline")
                } footer: {
                    Text("Default baseline expense applied to simulate liquidity shock waves.")
                }
                
                // Section 4: Broker Integration Shortcut
                Section {
                    Button {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.isShowingZerodhaSheet = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundStyle(Color(red: 1.0, green: 0.34, blue: 0.13))
                            Text(viewModel.isZerodhaConnected ? "Manage Zerodha Kite Sync" : "Connect Zerodha Kite Account")
                                .foregroundStyle(Color.primary)
                            Spacer()
                            if viewModel.isZerodhaConnected {
                                Text("Synced")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(LOSTheme.safeGreen)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Broker Integration")
                } footer: {
                    Text("Sync real-time equity holdings and cash margins directly from your Zerodha account.")
                }
                
                // Section 5: Reset Actions
                Section {
                    Button(role: .none) {
                        viewModel.resetToDefaults()
                        loadValuesFromProfile()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset to Pitch Deck Example")
                        }
                        .foregroundStyle(LOSTheme.primary)
                    }
                }
            }
            .navigationTitle("Edit Finances")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        validateAndSave()
                    }
                    .fontWeight(.bold)
                    .foregroundStyle(LOSTheme.primary)
                }
            }
            .onAppear {
                loadValuesFromProfile()
            }
        }
    }
    
    private func loadValuesFromProfile() {
        portfolioText = String(format: "%.0f", viewModel.profile.portfolioValue)
        cashText = String(format: "%.0f", viewModel.profile.liquidCash)
        incomeText = String(format: "%.0f", viewModel.profile.monthlyIncome)
        expensesText = String(format: "%.0f", viewModel.profile.monthlyExpenses)
        debtText = String(format: "%.0f", viewModel.profile.monthlyDebtPayments)
        reserveFloorText = String(format: "%.0f", viewModel.profile.minimumCashReserve)
        billText = String(format: "%.0f", viewModel.profile.unexpectedExpense)
    }
    
    private func validateAndSave() {
        guard let p = Double(portfolioText.trimmingCharacters(in: .whitespacesAndNewlines)), p >= 0 else {
            validationError = "Please enter a valid positive number for Portfolio Value."
            return
        }
        guard let c = Double(cashText.trimmingCharacters(in: .whitespacesAndNewlines)), c >= 0 else {
            validationError = "Please enter a valid positive number for Liquid Cash."
            return
        }
        guard let i = Double(incomeText.trimmingCharacters(in: .whitespacesAndNewlines)), i >= 0 else {
            validationError = "Please enter a valid positive number for Monthly Income."
            return
        }
        guard let e = Double(expensesText.trimmingCharacters(in: .whitespacesAndNewlines)), e >= 0 else {
            validationError = "Please enter a valid positive number for Monthly Expenses."
            return
        }
        guard let d = Double(debtText.trimmingCharacters(in: .whitespacesAndNewlines)), d >= 0 else {
            validationError = "Please enter a valid positive number for Debt/EMI Payments."
            return
        }
        guard let rf = Double(reserveFloorText.trimmingCharacters(in: .whitespacesAndNewlines)), rf >= 0 else {
            validationError = "Please enter a valid positive number for Safety Reserve Floor."
            return
        }
        guard let b = Double(billText.trimmingCharacters(in: .whitespacesAndNewlines)), b >= 0 else {
            validationError = "Please enter a valid positive number for Emergency Bill."
            return
        }
        
        // Update profile
        viewModel.profile.portfolioValue = p
        viewModel.profile.liquidCash = c
        viewModel.profile.monthlyIncome = i
        viewModel.profile.monthlyExpenses = e
        viewModel.profile.monthlyDebtPayments = d
        viewModel.profile.minimumCashReserve = rf
        viewModel.profile.unexpectedExpense = b
        
        dismiss()
    }
}
