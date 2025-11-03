import SwiftUI

struct CountdownRowView: View {
    let item: CountdownItem

    private var subtitle: String {
        CountdownRowView.dateFormatter.string(from: item.date)
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
            VStack {
                if item.daysRemaining > 0 {
                    Text("\(item.clampedDaysRemaining)")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(item.statusDetail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    Text(item.statusLabel)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text(item.statusDetail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(minWidth: 72)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(item.title). \(item.statusDetail)")
        }
        .padding(.vertical, 8)
    }
}

private extension CountdownRowView {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

struct CountdownRowView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        Group {
            CountdownRowView(item: CountdownItem(title: "Launch Day", date: Date().addingTimeInterval(86400 * 12)))
            CountdownRowView(item: CountdownItem(title: "Wedding Anniversary", date: Date().addingTimeInterval(86400)))
            CountdownRowView(item: CountdownItem(title: "Conference Talk", date: Date().addingTimeInterval(-86400 * 2)))
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
