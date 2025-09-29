# Implementation Status & Next Steps

This document tracks how the current Flutter codebase maps to the requirements in the Finans Koçu PRD. Use it as a living
checklist when turning the scaffolded application into a production-ready product.

## Legend

- ✅ Implemented in the repository (UI flows, providers, localization, or data models exist).
- ⚠️ Partially implemented (structure exists but requires service wiring, data sources, or additional UX polish).
- ⏳ Not yet implemented (requires new code or external services).

## 1. Navigation & Global Shell

| Feature | Status | Notes |
| --- | --- | --- |
| Reorderable bottom navigation with FAB | ✅ | `NavigationProvider` persists order locally; sync hook placeholders exposed in `FinanceProvider`. |
| Animated side drawer + AI popover | ✅ | Drawer animation + AI quick actions available via `ShellScaffold`. |
| Profile slide-over panel | ⚠️ | Panel UI scaffolded; authentication wiring and profile content require Supabase Auth hookup. |
| Global status badges (sync/offline/trial) | ⚠️ | `FinanceProvider` emits status models; visuals connected but backend data uses mock values. |

## 2. Core Screens

| Screen | Status | Notes |
| --- | --- | --- |
| Dashboard | ⚠️ | Summary cards, quick actions, and filters exist; connect to real transaction aggregates. |
| Accounts & Cards | ⚠️ | CRUD forms wired to in-memory Hive boxes. Supabase sync + soft delete restoration pending. |
| Income & Expense | ⚠️ | Tables with undo/redo journaling implemented. OCR import currently feeds mock parsed rows. |
| Analytics | ⚠️ | Charts, gated tables, and export buttons ready. Connect to live data + watermark utility. |
| Net P&L | ⚠️ | Net trend chart scaffolded using provider metrics; needs verified calculations per currency. |
| Categories | ⚠️ | Drag-and-drop lists + AI suggestions UI in place; integrate real AI recommendation service. |
| Admin Panel | ⏳ | Navigation route exists but content is placeholder cards. Populate with Stripe/iyzico forms. |

## 3. Data & Services

| Area | Status | Notes |
| --- | --- | --- |
| Hive persistence | ✅ | Boxes for accounts, transactions, categories, settings, and undo journal registered in `AppBootstrap`. |
| Supabase integration | ⚠️ | `SupabaseService` boots client from `--dart-define`; sync/resolvers require implementation. |
| OCR/import pipeline | ⚠️ | Import wizard, field mapping, and confidence markers shipped. Hook in real OCR engine (e.g., Google ML Kit) and Supabase Function fallback. |
| AI assistant | ⚠️ | Popover + fullscreen chat UI and command router created. Model invocation stubs expect encrypted API keys. |
| Notifications | ⏳ | Reminder scheduling not yet implemented; integrate Firebase Messaging / local notifications. |

## 4. Theming & Localization

- ✅ Fifteen JSON translation files align with PRD strings.
- ⚠️ Theme palette tokens defined in `AppTheme`; audit chart palettes for accessibility once real charts wired.
- ✅ Quick theme switch & dark/light/system toggle via `ThemeProvider`.

## 5. Security & Compliance

- ⚠️ AES encryption wrapper prepared for settings (see `LocalStorageService`). Encrypt Supabase API keys before sync.
- ⏳ Watermark utility for exports to CSV/XLSX not yet coded; placeholder button is present in analytics export sheet.
- ⏳ KVKK/GDPR data deletion/export endpoints not scaffolded.

## 6. Testing & Tooling

- ⚠️ Analyzer/test commands configured in `analysis_options.yaml`; add widget, provider, and integration tests as functionality becomes concrete.
- ⏳ CI workflows not yet authored. Consider GitHub Actions for lint + unit tests.

## 7. Recommended Next Steps

1. **Supabase Wiring** – Implement repositories syncing Hive boxes with Supabase tables (accounts/transactions/categories/settings).
2. **Authentication Flow** – Build sign-in/up screens and integrate with profile panel; store Supabase session securely.
3. **OCR Backend** – Connect to Supabase Functions or on-device OCR; map parsed entities into import review sheet.
4. **AI Engine** – Integrate chosen LLM API, enforce plan-based rate limits, and persist generated category rules.
5. **Notifications & Schedulers** – Add scheduled reminders and background sync triggers for bills and statements.
6. **Export Watermark** – Create utility injecting sentinel columns and metadata before saving CSV/PNG exports.
7. **Testing & QA** – Author unit tests for rule engine, statement period calculator, undo/redo stack, and widget tests for nav reorder and analytics gating.

Keep this document updated as milestones are completed to maintain alignment with the comprehensive PRD.
