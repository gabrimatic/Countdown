import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass")
                .font(.system(size: 48, weight: .regular))
                .foregroundStyle(.secondary)
            Text(NSLocalizedString("countdown.list.empty.title", comment: "Empty state title"))
                .font(.title3.bold())
            Text(NSLocalizedString("countdown.list.empty.message", comment: "Empty state message"))
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyStateView()
    }
}
