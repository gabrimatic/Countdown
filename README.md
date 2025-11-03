# Countdown

A minimalist SwiftUI iOS countdown application with WidgetKit support. Track important dates offline, manage multiple countdowns, and surface them on your Home Screen with automatically refreshing widgets.

## Features
- Add, edit, and delete unlimited countdowns
- Day-based countdowns that automatically normalize to midnight and communicate status (today, overdue, upcoming)
- Data persistence via shared `UserDefaults` (no network connection required)
- Widget bundle with small, medium, and large layouts that surface relative timing and completion details
- Automatic widget refresh every day and whenever data changes in the app
- Lightweight SwiftUI interface focused on clarity and typography

## Project Structure
- `Countdown.xcodeproj` – Xcode project with app and widget targets
- `Countdown/` – App sources, models, services, and resources
- `CountdownWidget/` – Widget extension sources and Info.plist

## Getting Started
1. Open `Countdown.xcodeproj` in Xcode 15 or later.
2. Update the bundle identifiers (`com.example.Countdown` and `com.example.Countdown.widget`) to match your team.
3. Configure the app group identifier (`group.com.example.countdown`) in the Signing & Capabilities tab for both the app and widget targets, or change the constant in `SharedCountdownRepository.swift` to match your group.
4. Build and run on an iOS device or simulator (iOS 16+).
5. After adding countdowns, add the widget to your Home Screen to see live updates.

All functionality is available offline; the app stores data locally using shared defaults so the widget can stay in sync automatically. Widgets present rich relative timing strings so you know whether events are upcoming, due today, or already completed at a glance.
