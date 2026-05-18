# ConnectX — Real-Time Chat Application 🌐

ConnectX is a premium, production-grade real-time messaging application built with **Flutter** and **Firebase Realtime Database**. Adhering to the principles of **Clean Layered Architecture**, reactive stream programming, and strict **Separation of Concerns (SoC)**, it delivers a seamless, high-performance, and secure communication experience.

---

## ✨ Outstanding Features

*   💬 **Real-Time One-to-One Messaging**: Instantaneous delivery and synchronization of chronological message threads using deterministic alphabetical room sharding (`uid1_uid2`).
*   🟢 **Online/Offline Presence Tracking**: WebSocket heartbeat tracking using server-side `.onDisconnect()` hooks to capture unexpected app closures or dead batteries instantly, showing active status and accurate last-seen timestamps.
*   ✍️ **Dynamic Typing Indicators**: Debounced state broadcasts writing to the user’s `typingTo` node in real-time, displaying floating dot animations dynamically on peer screens.
*   🔐 **Secure Firebase Authentication**: Full support for signup, email/password login, logout, and automatic session persistence across restarts.
*   🎨 **Premium obsidian Glassmorphic UI**: Beautiful dark obsidian HSL palette, asymmetric message bubble designs, smooth micro-animations, and full responsive support across mobile and web viewports.
*   ⚡ **Zero-Leak Stream Synchronization**: Active stream listeners are cleanly torn down during widget disposal to prevent duplicate subscriptions and memory leaks.
*   🛡️ **Hardened Database Rules**: Locked parameters restricting access to authenticated users and private room channels.

---

## 📐 Architecture & Clean Design Pattern

ConnectX strictly isolates business concerns to guarantee scalability and ease of maintenance:

```
    [Presentation UI]          ───>   [State Management]         ───>   [Centralized Service]
  (Screens & Widgets)                  (ChangeNotifier)                (Firebase API wrapper)
  login_screen.dart                     auth_provider.dart               firebase_service.dart
  register_screen.dart
```

1.  **Presentation Layer (`lib/screens` & `lib/widgets`)**: Standard stateless and stateful widgets rendering the visual state. Absolutely zero Firebase imports or database references are placed here.
2.  **State Management Layer (`lib/providers`)**: Handles UI actions, manages state properties (like `isLoading` and `error`), and dispatches updates via `notifyListeners()`.
3.  **Domain/Entity Layer (`lib/models`)**: Type-safe serializations (`UserModel` & `MessageModel`) ensuring strict validation.
4.  **Infrastructure Layer (`lib/services`)**: Centralized wrapper managing low-level authentication and Realtime Database WebSockets.

---

## 📂 Folder Structure

```
C:\Users\DELL\ConnectX
├── android/app
│   └── google-services.json    # Android firebase credentials configuration
├── assets/                     # Graphic branding assets
├── database.rules.json         # Firebase security rules parameters
├── lib/
│   ├── constants/              # Theme and color specifications
│   ├── models/                 # Pure type-safe Dart entities
│   ├── providers/              # Observer controllers (State management)
│   ├── screens/                # Responsive visual panels
│   ├── services/               # Firebase network and mock engines
│   ├── utils/                  # Routers and shared helper configs
│   ├── widgets/                # Reusable modular UI components
│   ├── firebase_options.dart   # Aligned FlutterFire configuration
│   └── main.dart               # Entrypoint core initialization
└── pubspec.yaml                # Package and SDK constraints
```

---

## ⚙️ Prerequisites & Setup Guide

### 1. Requirements
*   **Flutter SDK**: `^3.11.5`
*   **Dart SDK**: `^3.0.0`
*   **Firebase Account**: Firebase Realtime Database and Authentication enabled.

### 2. Configuration Settings

#### A. Place Google Services (Android)
Download your `google-services.json` from the Firebase Developer Console and place it exactly at:
```bash
android/app/google-services.json
```

#### B. Setup Security Parameters
Copy the paths defined inside `database.rules.json` and paste them directly into the "Rules" tab of your Realtime Database console:
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "chat_rooms": {
      "$roomId": {
        ".read": "auth != null && $roomId.contains(auth.uid)",
        ".write": "auth != null && $roomId.contains(auth.uid)"
      }
    }
  }
}
```

### 3. Launching the Application
Execute these terminal commands to resolve dependencies and launch:

```bash
# Resolve and download plugins
flutter pub get

# Compile and launch the app in debug mode (Chrome, Android, or Edge)
flutter run -d chrome
```
