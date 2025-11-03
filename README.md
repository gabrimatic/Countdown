# Countdown

A minimalist iOS countdown application built with SwiftUI. Track important dates with beautiful design, widget support, and full offline functionality.

![iOS Version](https://img.shields.io/badge/iOS-16.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- 📱 **Create & Manage Countdowns** - Add unlimited countdowns with title, date, and notes
- 🎯 **Smart Status Labels** - See whether events are today, upcoming, or overdue with relative formatting
- 📊 **Widget Bundle** - Small, Medium, and Large widget sizes with live updates
- 🌐 **5 Languages** - English, German, Turkish, Spanish, and Farsi (with RTL support)
- 🎨 **Modern Design** - Beautiful card-based interface with Liquid Glass effects
- 🔒 **Privacy-First** - All data stored locally on your device
- ♿ **Fully Accessible** - VoiceOver support and accessibility settings

## Quick Start

### Prerequisites
- Xcode 15+
- iOS 16.0+

### Setup

1. **Clone & Open**
   ```bash
   git clone https://github.com/gabrimatic/countdown.git
   cd countdown
   open Countdown.xcodeproj
   ```

2. **Configure Bundle Identifiers** (for device deployment)
   - Select **Countdown** target → **Signing & Capabilities**
   - Update bundle identifiers if needed:
     - App: `info.gabrimatic.Countdown`
     - Widget: `info.gabrimatic.Countdown.widget`

3. **Build & Run**
   ```bash
   ⌘R  # in Xcode, or use command line:
   xcodebuild -scheme Countdown -destination 'platform=iOS Simulator,name=iPhone 15' build
   ```

4. **Add Widget**
   - Long-press Home Screen → "+" → Search "Countdown"
   - Choose size and add
   - Widget syncs automatically with app

## Architecture

**MVVM Pattern** with clean separation:
- **Models** - Data structures with business logic
- **Services** - State management & persistence
- **Views** - SwiftUI components (presentation only)

**Data Storage** - UserDefaults via app group (no cloud needed)

## Build Commands

```bash
# Build app
xcodebuild -scheme Countdown -destination 'platform=iOS Simulator,name=iPhone 15' build

# Build widget
xcodebuild -scheme CountdownWidget -destination 'platform=iOS Simulator,name=iPhone 15' build

# Clean
xcodebuild clean
```

## Project Structure

```
Countdown/
├── Models/              # Data structures
├── Services/            # State management & persistence
├── Views/               # UI components
├── Utilities/           # Helpers & design system
└── Resources/           # Assets, localization
CountdownWidget/         # Widget extension
```

**Total:** 17 Swift files, ~1,085 lines of code

## Key Technologies

- **SwiftUI** - Modern declarative UI
- **WidgetKit** - Home screen widgets
- **UserDefaults** - Local data persistence
- **Localization** - 5 languages with RTL support

## Customization

### App Group ID
Edit `Utilities/SharedCountdownRepository.swift`:
```swift
let appGroupID = "group.info.gabrimatic.countdown"
```

### Theme
Settings automatically persist in the app:
- System (follows device)
- Light mode
- Dark mode

### Languages
Automatic device language detection. Currently supports:
- 🇬🇧 English
- 🇩🇪 German
- 🇹🇷 Turkish
- 🇪🇸 Spanish
- 🇮🇷 Farsi (RTL)

## Troubleshooting

### Widget not updating
- Verify app group ID matches in both targets
- Clean build: `xcodebuild clean`
- Force restart simulator: `xcrun simctl shutdown all && xcrun simctl erase all`

### Bundle identifier errors
- Check both targets have correct identifiers:
  - App: `info.gabrimatic.Countdown`
  - Widget: `info.gabrimatic.Countdown.widget`

### Localization not working
- Rebuild project: `xcodebuild clean && xcodebuild build`
- Verify `.lproj` folders added to both targets

## Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes and test
4. Commit: `git commit -m "feat: description"`
5. Push and open Pull Request

**Code style:**
- 4 spaces indentation
- camelCase for functions/properties, PascalCase for types
- Localize all user-facing strings with `NSLocalizedString()`

## License

MIT License - See LICENSE file

## Attribution

**Developer**: [gabrimatic.info](https://gabrimatic.info)

---

**Built with:** SwiftUI + WidgetKit | **iOS 16.0+** | **November 2025**
