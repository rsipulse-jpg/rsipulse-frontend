# RSI Pulse – To-Do List

## ✅ Completed
- Domain + Gmail setup (rsipulse.com, Google Form waitlist).
- Backend live on Render:
  - `/health`, `/scan`, `/scan?test=1`, `/symbols`.
- Mobile app:
  - Free Tab scanner with Demo/Live toggle.
  - Connected to backend.
  - Running on iOS simulator.
- UI polish:
  - Candidate cards, badges, shimmer loaders, error/empty states.
- Navigation:
  - Free Tab + Pro Tab (locked upsell).
- Persistence:
  - Save last scan results with SharedPreferences.
  - Show cached results on app start.
  - Display last scan timestamp.
- QA polish:
  - Tap = copy pair to clipboard.
  - Long-press = open Binance app/browser.
  - Improved error handling and shimmer effect.

---

## 🔜 Next Steps (Part V)
1. **IAP Scaffolding**
   - Lock Pro tab behind mock paywall.
   - Add dev bypass flag.
   - Prepare for real in-app purchases.

2. **Backend Enhancements**
   - Add RSI(6) / RSI(12) turning-up logic.
   - Configurable thresholds via query params.
   - Prepare support for `mode=deluxe`.

3. **Release Prep**
   - Ensure consistent bundle identifier (iOS + Android).
   - Android keystore / iOS provisioning profiles.
   - Write README for GitHub contributors (dev vs. prod setup).

---

## 📝 Future Ideas
- Android build & emulator setup.
- TestFlight distribution for real iPhone testing.
- Landing page polish (replace Google Form redirect).
- Monetization setup (tiers: Free, $1, $5.99).
