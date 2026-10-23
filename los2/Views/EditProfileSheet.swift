import SwiftUI

/// Sheet allowing users to input and tweak their real financial numbers.
struct EditProfileSheet: View {
    @ObservedObject var viewModel: ResilienceViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var portfolioText: String = ""
    @State private var cashText: String = ""
    @State private var incomeText: String = ""
    @State private var expensesText: String = ""
    @State private var billText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Label("Portfolio Value", systemImage: "chart.pie.fill")
                        Spacer()
                        #if os(iOS)
                        TextField("₹", text: $portfolioText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("₹", text: $portfolioText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    HStack {
                        Label("Liquid Cash", systemImage: "banknote.fill")
                        Spacer()
                        #if os(iOS)
                        TextField("₹", text: $cashText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("₹", text: $cashText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                } header: {
                    Text("Assets & Liquidity")
                } footer: {
                    Text("Portfolio includes stocks and mutual funds. Liquid cash includes savings accounts and emergency funds.")
                }
                
                Section {
                    HStack {
                        Label("Monthly Income", systemImage: "arrow.down.left.circle.fill")
                        Spacer()
                        #if os(iOS)
                        TextField("₹", text: $incomeText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("₹", text: $incomeText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                    
                    HStack {
                        Label("Monthly Expenses", systemImage: "arrow.up.right.circle.fill")
                        Spacer()
                        #if os(iOS)
                        TextField("₹", text: $expensesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("₹", text: $expensesText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                } header: {
                    Text("Monthly Cash Flow")
                } footer: {
                    Text("Used to calculate your net cash burn rate (Expenses − Income).")
                }
                
                Section {
                    HStack {
                        Label("Sample Emergency Bill", systemImage: "bolt.shield.fill")
                        Spacer()
                        #if os(iOS)
                        TextField("₹", text: $billText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        #else
                        TextField("₹", text: $billText)
                            .multilineTextAlignment(.trailing)
                        #endif
                    }
                } header: {
                    Text("Stress Test Shock")
                } footer: {
                    Text("A sudden one-time expense such as medical care, car repair, or emergency travel.")
                }
                
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
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
        billText = String(format: "%.0f", viewModel.profile.unexpectedExpense)
    }
    
    private func saveAndDismiss() {
        if let p = Double(portfolioText) { viewModel.profile.portfolioValue = max(0, p) }
        if let c = Double(cashText) { viewModel.profile.liquidCash = max(0, c) }
        if let i = Double(incomeText) { viewModel.profile.monthlyIncome = max(0, i) }
        if let e = Double(expensesText) { viewModel.profile.monthlyExpenses = max(0, e) }
        if let b = Double(billText) { viewModel.profile.unexpectedExpense = max(0, b) }
        dismiss()
    }
}
