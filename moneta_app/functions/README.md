# Firebase Functions for Moneta

Functions:
- processSmsMessage (callable): Parses an SMS text, categorizes, and writes to Firestore under the signed-in user's `transactions`.
- generateSummary (callable): Fetches transactions in a date range and calls Gemini to generate a summary.

Setup:
1. Install deps:
   - In `moneta_app/functions` run `npm install`.
2. Secrets / env:
   - Production: store Gemini key as secret
     - `firebase functions:secrets:set GEMINI_API_KEY`
   - Local emulator: copy `.env.local.sample` to `.env.local` and set `GEMINI_API_KEY=...`
3. Build & Deploy:
   - `npm run build`
   - `firebase deploy --only functions`
