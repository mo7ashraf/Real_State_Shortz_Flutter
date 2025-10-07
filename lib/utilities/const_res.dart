// Base URL for backend API.
// Defaults to Android emulator host (10.0.2.2). Override at run-time with:
// flutter run --dart-define=BASE_URL=http://<your-machine-ip>:8000/
// Example (real device on same Wi‑Fi):
// flutter run --dart-define=BASE_URL=http://192.168.1.50:8000/
const String baseURL = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://reels.metatry.online/',
  // defaultValue: 'http://192.168.1.13:8000/',
);
const String apiURL = '${baseURL}api/';
const String apiKey = 'retry123';

// Auth provider toggle
// When false, email/password login uses local backend only (no Firebase Auth)
// Set to true to re-enable Firebase email/password authentication
const bool useFirebaseEmailAuth = false;

// If you change this topic you also change backend .env file
String notificationTopic = "shortzz";

String revenueCatAndroidApiKey =
    ""; // disabled in dev // revenueCat android api
String revenueCatAppleApiKey = ""; // disabled in dev // revenueCat apple api
