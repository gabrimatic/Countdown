import SwiftUI

/// Provides a shared Liquid Glass backdrop that stays respectful of accessibility settings.
struct GlassChrome<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.colorScheme) private var colorScheme

    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            backgroundLayer
            content
        }
        .overlay(alignment: .top, content: topChrome)
    }

    private var backgroundLayer: some View {
        Group {
            if reduceTransparency || colorSchemeContrast == .increased {
                Color(.systemBackground)
            } else {
                Rectangle()
                    .fill(
                        GlassSettings.surfaceMaterial(
                            reduceTransparency: reduceTransparency,
                            contrast: colorSchemeContrast
                        )
                    )
                    .overlay(ambientTint)
            }
        }
        .ignoresSafeArea()
    }

    private var ambientTint: some View {
        LinearGradient(
            colors: ambientPalette,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.12)
    }

    private var ambientPalette: [Color] {
        if colorScheme == .dark {
            return [Color.accentColor.opacity(0.28), Color.white.opacity(0.05)]
        } else {
            return [Color.white.opacity(0.4), Color.accentColor.opacity(0.18)]
        }
    }

    private func topChrome() -> some View {
        Rectangle()
            .fill(
                GlassSettings.chromeMaterial(
                    reduceTransparency: reduceTransparency,
                    contrast: colorSchemeContrast
                )
            )
            .overlay(
                Divider()
                    .opacity(colorSchemeContrast == .increased ? 0.4 : 0.18),
                alignment: .bottom
            )
            .frame(height: 12)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
