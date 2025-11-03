import SwiftUI

/// Provides Liquid Glass material settings with iOS 26 support and graceful fallbacks.
/// Based on Apple's iOS 26 Liquid Glass design language.
enum GlassSettings {

    /// Returns the appropriate surface material based on iOS version and accessibility settings
    /// - Parameters:
    ///   - reduceTransparency: Whether the user has enabled Reduce Transparency
    ///   - contrast: The color scheme contrast level
    /// - Returns: A ShapeStyle material appropriate for the surface background
    static func surfaceMaterial(
        reduceTransparency: Bool,
        contrast: ColorSchemeContrast
    ) -> AnyShapeStyle {
        // Respect accessibility settings first
        if reduceTransparency || contrast == .increased {
            return AnyShapeStyle(.regularMaterial)
        }

        // On iOS 26+, system automatically uses Liquid Glass for materials
        // On iOS 16-25, use ultraThinMaterial as fallback
        return AnyShapeStyle(.ultraThinMaterial)
    }

    /// Returns the appropriate chrome material for top/bottom overlays
    /// - Parameters:
    ///   - reduceTransparency: Whether the user has enabled Reduce Transparency
    ///   - contrast: The color scheme contrast level
    /// - Returns: A ShapeStyle material appropriate for chrome elements
    static func chromeMaterial(
        reduceTransparency: Bool,
        contrast: ColorSchemeContrast
    ) -> AnyShapeStyle {
        // Respect accessibility settings first
        if reduceTransparency || contrast == .increased {
            return AnyShapeStyle(.thickMaterial)
        }

        // On iOS 26+, system automatically uses Liquid Glass for materials
        // On iOS 16-25, use thinMaterial as fallback
        return AnyShapeStyle(.thinMaterial)
    }

    /// Returns a card material for countdown cards and other UI elements
    /// - Parameters:
    ///   - reduceTransparency: Whether the user has enabled Reduce Transparency
    ///   - contrast: The color scheme contrast level
    /// - Returns: A ShapeStyle material appropriate for cards
    static func cardMaterial(
        reduceTransparency: Bool,
        contrast: ColorSchemeContrast
    ) -> AnyShapeStyle {
        // Respect accessibility settings first
        if reduceTransparency || contrast == .increased {
            return AnyShapeStyle(.regularMaterial)
        }

        // On iOS 26+, system automatically uses Liquid Glass for materials
        // On iOS 16-25, use ultraThinMaterial as fallback
        return AnyShapeStyle(.ultraThinMaterial)
    }
}
