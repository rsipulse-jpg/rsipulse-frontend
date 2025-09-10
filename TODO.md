# RSI Pulse – To-Do List (Updated after Phase II)

## ✅ Completed
- Backend Free & Premium modes implemented in `app.py`.
- Frontend updated with Demo toggle, Free/Premium selector, and Scan Now button.
- pubspec.yaml updated with `http` and `shared_preferences` dependencies.
- iOS simulator issues resolved (device targeting by UDID and name).
- Backend Base URL field removed from UI and code.
- Introduced `--dart-define` for backend URL switching (local vs. remote).
- Snapshot PDF created for archiving Phase II.
- Git workflow updated: commit & push new `api.dart`.

## ⏳ Pending
- Result persistence (reload last scan on app start).
- IAP scaffolding (lock Premium mode behind paywall).
- QA polish (skeleton loader/shimmer, tap-to-open Binance pair or copy symbol).
- Deluxe mode design (configurable triggers, background scans, saved setups).
- Release prep (bundle identifier consistency, TestFlight, Android keystore).

## 📌 Next Step
Move to **Phase III**: start with result persistence + basic QA polish before IAP scaffolding.
