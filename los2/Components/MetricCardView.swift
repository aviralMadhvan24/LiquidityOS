import SwiftUI

/// Reusable fintech card for individual resilience indicators.
struct MetricCardView: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    var badgeText: String? = nil
    var badgeColor: Color = LOSTheme.primary
    var iconName: String? = nil
    var isNegative: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(badgeColor)
                        .frame(width: 26, height: 26)
                        .background(badgeColor.opacity(0.12))
                        .clipShape(Circle())
                }
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                if let badge = badgeText {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(badgeColor.opacity(0.15))
                        .foregroundStyle(badgeColor)
                        .clipShape(Capsule())
                }
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(isNegative ? LOSTheme.criticalRed : Color.primary)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(isNegative ? LOSTheme.criticalRed.opacity(0.85) : Color.secondary)
                    .lineLimit(1)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LOSTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(LOSTheme.cardBorder, lineWidth: 1)
        )
    }
}
