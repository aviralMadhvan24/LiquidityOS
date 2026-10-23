# LiquidityOS

> **“Can you withstand the next financial shock?”**  
> Portfolio risk meets personal cash-flow resilience.

LiquidityOS is an iOS application built with SwiftUI that performs interactive financial stress-testing across investments, liquid emergency cash, and monthly burn rate.

---

## 🌟 Why LiquidityOS?

Your money lives in three separate silos:
1. **Investments:** Stocks, mutual funds, and crypto (Zerodha, Groww, Apple Stocks).
2. **Savings:** Liquid cash sitting in bank accounts.
3. **Cash Flow:** Fixed living expenses vs. monthly income.

When financial shocks occur in the real world, they rarely happen one at a time. A market crash combined with an unexpected emergency bill and income disruption forces individuals to sell their crashed investments at a loss. 

LiquidityOS connects all three silos to answer one fundamental question:
> **“If a market crash and an emergency bill hit today, how many months can I survive before running out of cash?”**

---

## 🚀 Key Features

* **Portfolio Stress Testing:** Simulate instant market drops (**Mild 5%**, **Stress 15%**, **Severe 30%**, or custom percentage) to see estimated losses and retained portfolio values.
* **Emergency Expense Simulator:** Dial in unplanned bills (e.g. ₹50,000) and quantify liquid cash depletion instantly.
* **Cash Runway Engine:** Models monthly net burn (`Expenses − Income`) and calculates exact survival runway in months. Intelligently detects break-even and cash surplus states.
* **Unified Resilience Score (0–100):** Real-time weighted resilience metric with a dynamic circular gauge and plain-English verdicts.
* **Multi-Scenario Comparison Matrix:** Side-by-side comparative breakdown of Mild, Stress, and Severe market shocks.
* **100% On-Device & Private:** No sensitive financial data ever leaves your device.

---

## 📱 Tech Stack & Architecture

* **Language:** Swift 5.10+
* **Framework:** SwiftUI
* **Design Pattern:** MVVM (Model-View-ViewModel) + Pure Service Calculation Engine
* **Target Platforms:** iOS 16+ (iPhone & iPad)

### Project Structure

```
los2/
├── MyApp.swift                      // App entry point
├── ContentView.swift                // Tab navigation container
│
├── Models/
│   ├── FinancialProfile.swift       // User's base assets & cash flow
│   ├── StressScenario.swift         // Market shock definitions
│   └── ResilienceReport.swift       // Calculated metrics & resilience band
│
├── Services/
│   └── ResilienceEngine.swift       // Mathematical resilience engine
│
├── ViewModels/
│   └── ResilienceViewModel.swift    // Reactive state management & persistence
│
├── Views/
│   ├── DashboardView.swift          // Resilience Overview dashboard
│   ├── StressTestView.swift         // Portfolio shock slider & breakdown
│   ├── EmergencySimulatorView.swift // Emergency bill impact slider
│   ├── RunwayView.swift             // Monthly burn & depletion timeline
│   ├── ScenarioCompareView.swift    // 3-way side-by-side scenario matrix
│   └── EditProfileSheet.swift       // Finance customizer & pitch preset reset
│
└── Components/
    ├── Theme.swift                  // Indian Rupee currency formatters & design tokens
    ├── ResilienceGaugeView.swift    // Circular animated resilience score gauge
    ├── MetricCardView.swift         // Fintech metric card with badges & status tints
    ├── SegmentedShockPicker.swift   // 3-way shock level selector
    └── RunwayTimelineView.swift     // Visual month-by-month cash trajectory
```

---

## 🛠️ How to Run

1. Open `los2.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g., iPhone 16 Pro).
3. Press `⌘ + R` (Run).
