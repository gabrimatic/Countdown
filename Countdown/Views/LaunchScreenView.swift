import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background color matching AccentColor
            Color.accentColor
                .ignoresSafeArea()

            // App icon in the center
            Image("LaunchImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .cornerRadius(30)
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}
