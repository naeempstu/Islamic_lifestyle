# Islamic Lifestyle 🌙

A modern, minimal, and spiritually calming Islamic lifestyle mobile application built with Flutter & Firebase. Designed for Muslims in Bangladesh and worldwide, supporting both **English** and **বাংলা**.

## Features

| Module | Description |
|---|---|
| **Auth & Onboarding** | Email/Google sign-in, guest mode, smooth onboarding with language selection |
| **Prayer Times** | Accurate 5-waqt times (9 calculation methods), Qibla compass, prayer checklist |
| **Qur'an** | All 114 surahs, Arabic text with translation, audio recitation, bookmarks |
| **Dhikr & Dua** | Morning/evening/after-salah dhikr, tasbih counter with haptic feedback, dua categories |
| **Daily Deen (Habits)** | Daily checklist, Qur'an reading tracker, weekly reflection |
| **Halal Guide** | Halal/Haram food guide, E-number reference, Islamic lifestyle tips |
| **Ramadan Mode** | Sehri/Iftar times, fasting tracker, daily goals, Sadaqah reminder, reflection journal |
| **Settings** | Language (EN/BN), theme (light/dark/system), calculation method, notifications, backup |

## Tech Stack

- **Framework:** Flutter 3.2+ (Dart)
- **State Management:** Provider (ChangeNotifier)
- **Routing:** GoRouter with ShellRoute
- **Backend:** Firebase (Auth, Firestore, Messaging, Storage)
- **Local Storage:** SharedPreferences + Hive
- **Prayer Times:** `adhan` package
- **Location:** `geolocator` + `flutter_compass`
- **Notifications:** `flutter_local_notifications`
- **Audio:** `just_audio`
- **Theme:** Material 3 with custom Islamic color palette

## Getting Started

### Prerequisites
- Flutter SDK >= 3.2.0
- Android Studio / VS Code
- Firebase project (for Auth, Firestore, Messaging)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd Islamic_lifestyle
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase (follow prompts)
   flutterfire configure
   ```
   This will replace `lib/firebase_options.dart` with your actual config.

4. **Add fonts** (place in `assets/fonts/`)
   - Amiri (for Arabic text) — download from Google Fonts
   - NotoSansBengali (for Bangla) — download from Google Fonts

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
├── firebase_options.dart        # Firebase config (auto-generated)
├── core/
│   ├── theme/                   # AppColors, AppTheme (light/dark)
│   ├── constants/               # App constants, asset paths
│   ├── services/                # Auth, Prayer, Location, Notification, Storage
│   ├── providers/               # Theme, Locale, Prayer, Habit providers
│   ├── router/                  # GoRouter configuration
│   └── l10n/                    # Localization (EN/BN)
├── shared/
│   └── widgets/                 # Reusable UI components
└── features/
    ├── onboarding/              # Onboarding flow
    ├── auth/                    # Login & Register
    ├── home/                    # Dashboard & navigation shell
    ├── prayer/                  # Prayer times & Qibla
    ├── quran/                   # Surah list, detail & data
    ├── dhikr/                   # Dhikr, Tasbih, Dua
    ├── habits/                  # Daily Deen routine
    ├── halal/                   # Halal lifestyle guide
    ├── ramadan/                 # Ramadan mode
    └── settings/                # App settings
```

## Color Palette

| Color | Hex | Usage |
|---|---|---|
| Primary Green | `#1B7A4E` | Primary actions, positive states |
| Beige | `#F5F0E8` | Light background |
| Night Blue | `#1A2744` | Dark mode, headers |
| Gold | `#D4A853` | Accents, Ramadan theme |

## Localization

The app supports **English** and **বাংলা (Bangla)** with 80+ localized strings. Language can be changed from:
- Onboarding screen (first launch)
- Settings screen (anytime)

## License

This project is for educational and personal use.

---

*"And whoever holds firmly to Allah has indeed been guided to a straight path."* — Qur'an 3:101
