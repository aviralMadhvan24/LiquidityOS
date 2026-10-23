import SwiftUI

/// Animated circular gauge visualizing the 0-100 Resilience Score.
/// Designed for responsive scaling across small, regular, and Max iPhone viewports.
struct ResilienceGaugeView: View {
    let score: Int
    let band: ResilienceBand
    let headline: String
    
    @State private var animatedScore: Double = 0
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Background Track
                Circle()
                    .trim(from: 0.15, to: 0.85)
                    .stroke(
                        Color.primary.opacity(0.08),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                
                // Active Colored Arc
                Circle()
                    .trim(from: 0.15, to: 0.15 + (0.70 * (animatedScore / 100.0)))
                    .stroke(
                        gradientForBand(band),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.75), value: animatedScore)
                
                // Score Labels
                VStack(spacing: 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(Int(animatedScore))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                            .minimumScaleFactor(0.8)
                        
                        Text("/ 100")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.secondary)
                    }
                    
                    // Band Status Pill
                    Text(band.rawValue)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(band.color.opacity(0.15))
                        .foregroundStyle(band.color)
                        .clipShape(Capsule())
                }
            }
            .frame(width: 200, height: 175)
            
            // Subtitle status line
            Text(headline)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 4)
        .onAppear {
            animatedScore = Double(score)
        }
        .onChange(of: score) { newScore in
            animatedScore = Double(newScore)
        }
    }
    
    private func gradientForBand(_ band: ResilienceBand) -> LinearGradient {
        switch band {
        case .critical:
            return LinearGradient(
                colors: [Color.red, Color.orange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .moderate:
            return LinearGradient(
                colors: [Color.orange, Color.yellow],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .healthy, .bulletproof:
            return LinearGradient(
                colors: [LOSTheme.safeGreen, Color.cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
