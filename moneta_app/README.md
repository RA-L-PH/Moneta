# Moneta — Expense Tracker (Flutter + Firebase + Cloud Functions)

Moneta helps you log expenses, see insights, and auto-capture transactions from SMS. It uses Flutter on the frontend and Firebase (Auth, Firestore, Functions) on the backend. A Cloud Function integrates with Gemini to generate spending summaries.

## Features

- Google Sign-In with Firebase Auth
- Real-time transactions in Firestore
- Dashboard with category pie chart and monthly summary
- Transaction history with search/filter basics
- Manual add expense screen
- Android SMS listener forwarding transactional messages to a Cloud Function
- AI Insights screen calling a `generateSummary` Cloud Function (Gemini)

## Setup

1) Flutter packages
- Ensure Flutter SDK is installed
- From the project root:

```
flutter pub get
```

2) Firebase config
- Create a Firebase project
- Enable Authentication (Google) and Firestore
- Add iOS and Android apps and download config files:
	- Android: place `android/app/google-services.json`
	- iOS: place `ios/Runner/GoogleService-Info.plist`
- Add the Google Services Gradle plugins per Firebase docs if not present

3) Cloud Functions
- See `functions/` folder (Node.js). Set environment variables:
	- `GEMINI_API_KEY` — your Gemini API key
- Deploy or run locally with the Firebase CLI.

4) Android permissions
- This app requests SMS read permission (Android) to capture transactional SMS. Grant when prompted.

## Run

Windows PowerShell examples:

```
flutter run
```

Optional: run Functions emulator if developing backend locally.

## Data Model

Firestore:
- `users/{uid}/transactions/{txId}`
	- amount: number
	- description: string
	- category: string
	- date: Timestamp
	- type: 'debit' | 'credit'
	- source: 'manual' | 'sms'

## Security

- Firebase Auth secures per-user data
- Firestore rules should scope reads/writes to `request.auth.uid == resource.data.uid`

## Notes

- SMS collection works only on Android; iOS forbids programmatic SMS access.
- Gemini summaries are generated server-side via Cloud Functions.

## Assets

- Place the Moneta logo at `assets/images/moneta_logo.png`.
- The assets directory is registered in `pubspec.yaml` under `assets:`.
