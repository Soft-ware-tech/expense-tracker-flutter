# Expense Tracker

A clean, simple expense tracker built with Flutter and Firebase.

## Features

- Firebase Authentication (email/password sign up & login)
- Add, edit, and delete expenses (title, amount, category, date, optional note)
- Per-user data storage in Cloud Firestore (each user only sees their own expenses)
- Current-month total spend summary
- Expense history list with swipe-to-delete + confirmation
- Filter by category, filter by date, and free-text search
- Monthly / category-wise summary screen with a pie chart and breakdown bars
- Dark / light mode toggle
- Loading, empty, and error states handled throughout
- English / Tamil / Sinhala language support
- **Monthly budget limit with a live progress bar** that turns amber at 80%
  and red once you go over, so overspending is obvious at a glance
- **Export expenses to CSV** (respects whatever filter/search is currently
  active) and share it straight from the device share sheet
- **Receipt photo attachments** — snap a photo or pick one from the gallery
  when adding/editing an expense; it's uploaded to Firebase Storage and shown
  as a thumbnail on the expense

## Tech Stack

- Flutter (Material 3)
- Firebase Auth + Cloud Firestore + Cloud Storage
- Provider for state management
- fl_chart for the summary pie chart
- image_picker for receipt photos, csv + share_plus for CSV export

## Getting Started

1. Clone the repo and install dependencies:
   ```
   flutter pub get
   ```
2. This project already includes `lib/firebase_options.dart` and
   `android/app/google-services.json` for the `expense-tracker-cyphlab`
   Firebase project. If you want to point it at your own Firebase project
   instead, run:
   ```
   flutterfire configure
   ```
3. Deploy the included security rules so users can only read/write their own
   expenses, budget, and receipts:
   ```
   firebase deploy --only firestore:rules,storage:rules
   ```
   **Note:** Firebase Storage (used for receipt photos) requires the project
   to be on the pay-as-you-go **Blaze plan** to create a storage bucket
   (there's still a generous free tier - you won't be billed at this scale).
   If you'd rather not upgrade the plan, everything else in the app works
   fully without it — the receipt-upload feature will just fail gracefully
   with an error snackbar until Storage is enabled.
4. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  models/        # Expense data model
  providers/      # ExpenseProvider, ThemeProvider, LanguageProvider (state mgmt)
  services/       # AuthService, FirestoreService, BudgetService, StorageService
  screens/        # Login, Register, Home, Add/Edit Expense, Summary
  widgets/        # Reusable UI pieces (ExpenseCard, SummaryCard, BudgetProgressCard, GlassContainer)
  utils/          # Categories, localized strings, CSV export helper
```

## AI Tools Used

- **Claude** (Anthropic) — used to review the project against the task
  brief, and to design and implement three additional features: the
  monthly budget limit + progress alert, CSV export, and receipt photo
  attachment via Firebase Storage (including the matching Firestore/Storage
  security rules). All generated code was reviewed, adjusted to match the
  existing app's structure and styling, and tested manually before being
  committed.
- **ChatGPT** (OpenAI) — used while building the base app: generating
  initial boilerplate/screen structure, and helping debug specific Flutter
  and Firebase errors along the way. All suggestions were reviewed and
  adjusted before being used.

## Security

- Every expense document is stamped with the owning user's `userId`, and
  `firestore.rules` enforces that a signed-in user can only read, update, or
  delete their own expenses.
- Each user's monthly budget lives at `budgets/{uid}` — the document ID
  itself is checked against `request.auth.uid`, so a user can never read or
  write another user's budget.
- Receipt photos live at `receipts/{uid}/...` in Firebase Storage;
  `storage.rules` restricts access to that uid's own folder and caps uploads
  at 5 MB, image files only.