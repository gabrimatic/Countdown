import SwiftUI

/// A Liquid Glass-enhanced countdown card for displaying countdown information
/// with adaptive glass effects that respect accessibility settings
struct CountdownCard: View {
    let item: CountdownItem

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.colorScheme) private var colorScheme

    private var subtitle: String {
        CountdownCard.dateFormatter.string(from: item.date)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            Spacer()
            countdownBadge
        }
        .padding()
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(borderGradient, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var countdownBadge: some View {
        VStack(spacing: 4) {
            if item.daysRemaining > 0 {
                Text("\(item.clampedDaysRemaining)")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(item.statusDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text(item.statusLabel)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(item.statusDetail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(minWidth: 80)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title). \(item.statusDetail)")
    }

    @ViewBuilder
    private var cardBackground: some View {
        Rectangle()
            .fill(
                GlassSettings.cardMaterial(
                    reduceTransparency: reduceTransparency,
                    contrast: colorSchemeContrast
                )
            )
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(colorScheme == .dark ? 0.15 : 0.4),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private extension CountdownCard {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct CountdownCard_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        VStack(spacing: 16) {
            CountdownCard(item: CountdownItem(title: "Launch Day", date: Date().addingTimeInterval(86400 * 12)))
            CountdownCard(item: CountdownItem(title: "Wedding Anniversary", date: Date().addingTimeInterval(86400)))
            CountdownCard(item: CountdownItem(title: "Conference Talk", date: Date().addingTimeInterval(-86400 * 2)))
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
