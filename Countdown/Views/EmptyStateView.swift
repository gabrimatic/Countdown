import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hourglass")
                .font(.system(size: 48, weight: .regular))
                .foregroundStyle(.secondary)
            Text("No countdowns yet")
                .font(.title3.bold())
            Text("Tap the plus button to add your first countdown. Keep everything offline and up to date automatically.")
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
