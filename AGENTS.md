# Repository Guidelines

## Project Structure & Module Organization
The Xcode project lives in `Countdown.xcodeproj`, with app sources under `Countdown/` (SwiftUI entry point in `CountdownApp.swift`, feature folders for Models, Services, Utilities, and Views) and the widget extension inside `CountdownWidget/`. Shared assets reside in `Countdown/Resources/` (including `Assets.xcassets` and Info.plists); place any future shared helpers in `Utilities/SharedCountdownRepository.swift` so the app and widget stay in sync.

## Build, Test, and Development Commands
Open the project with `open Countdown.xcodeproj` for day-to-day development. Use `xcodebuild -scheme Countdown -destination 'platform=iOS Simulator,name=iPhone 15' build` for reproducible builds. Build the widget target with `xcodebuild -scheme CountdownWidget -destination 'platform=iOS Simulator,name=iPhone 15' build` when iterating on timelines. Once XCTest targets exist, run them via `xcodebuild -scheme Countdown -destination 'platform=iOS Simulator,name=iPhone 15' test`.

## Coding Style & Naming Conventions
Follow Swift API Design Guidelines: 4-space indentation, same-line braces, camelCase for functions and properties, and PascalCase for types (`CountdownStore`, `EmptyStateView`). SwiftUI screens live in `Views/` with the `View` suffix; persistency and business logic belong in `Services/` or `Utilities/`. Keep preview data in dedicated extensions like `CountdownStore+Preview.swift` so design and widget previews remain consistent.

## Testing Guidelines
No XCTest bundle ships yet; introduce one named `CountdownTests` that mirrors the folder layout. Organize files by subject (`CountdownStoreTests.swift`, `CountdownWidgetProviderTests.swift`) and prefer method names like `test_whenCountdownIsDueToday_thenStatusMatches()`. Target coverage for persistence, timeline generation, and SwiftUI state updates. Execute tests with the `xcodebuild` command above or ⌘U inside Xcode.

## Commit & Pull Request Guidelines
Commit history favors concise, imperative messages (e.g., `Improve countdown ordering and widget relevance`), so keep summaries short and scoped. Pull requests should describe the change, enumerate testing evidence (simulator device, unit tests, widget previews), and link to related issues. Attach screenshots or short videos for UI adjustments and note any widget timeline effects for reviewers.

## Widget & Configuration Tips
Before running on devices, update bundle identifiers and the shared app group; adjust `SharedCountdownRepository.swift` if your group name changes. When adding shared data or timeline entries, confirm both the app target and widget access the same repository to avoid stale countdowns. Refresh widgets in Xcode's Widget debugger after data model changes to validate timelines.
