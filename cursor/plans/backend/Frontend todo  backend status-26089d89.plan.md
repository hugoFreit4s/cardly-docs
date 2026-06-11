<!-- 26089d89-1757-48f2-92a8-d554abb8e462 -->
---
todos:
  - id: "frontend-todo-md"
    content: "Create cardly-rnative-app/docs/agents/todo.md with blurb + Steps 1–4 + later + emulator base URL risk"
    status: pending
  - id: "backend-todo-status"
    content: "Add status (Step 1–2 DONE) + risk bullets to cardly-backend/docs/agents/todo.md"
    status: pending
  - id: "optional-already-done"
    content: "Optional: link todo.md from cardly-rnative-app/docs/agents/already-done.md"
    status: pending
isProject: false
---
# Frontend todo + backend status flags

## Context

- **Frontend** ([`C:/projects/cardly/cardly-rnative-app`](C:/projects/cardly/cardly-rnative-app)): Expo 54, TS, [`App.tsx`](C:/projects/cardly/cardly-rnative-app/App.tsx) is a static splash (logo + tagline). No navigation, no API calls ([`docs/agents/already-done.md`](C:/projects/cardly/cardly-rnative-app/docs/agents/already-done.md)).
- **Backend** APIs available today: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/logout`, `GET /api/me` ([`AuthController.java`](C:/projects/cardly/cardly-backend/src/main/java/com/cardly/web/AuthController.java), [`MeController.java`](C:/projects/cardly/cardly-backend/src/main/java/com/cardly/web/MeController.java)). DTOs: register `{ name, email, password }`, login `{ email, password }`, response `{ token, expiresAt }` ([`AuthResponse`](C:/projects/cardly/cardly-backend/src/main/java/com/cardly/web/dto/AuthResponse.java)). **No** deck/card HTTP controllers yet—deck CRUD and study flows remain backend work before the app can sync decks.

## 1. Create [`cardly-rnative-app/docs/agents/todo.md`](C:/projects/cardly/cardly-rnative-app/docs/agents/todo.md)

Structure (match backend tone: short product blurb, then numbered steps):

- **Intro:** Same product one-liner as backend (mobile client for Cardly; consumes `cardly-backend`).
- **Step 1 — API layer & config:** Base URL (e.g. `app.config` extra or `.env` + `EXPO_PUBLIC_*`), typed client (`fetch` or axios), attach `Authorization: Bearer <token>` for protected routes, map JSON to TS types aligned with backend DTOs. **Risk:** Android emulator → host machine: use `10.0.2.2` (or documented LAN IP) instead of `localhost` for Spring Boot on the dev PC.
- **Step 2 — Session & token storage:** Persist JWT securely (e.g. `expo-secure-store`), restore session on launch, clear on logout; call `GET /api/me` after login to confirm token and read `id`, `email`, `role`.
- **Step 3 — Navigation & auth UI:** Add a navigation stack (e.g. `@react-navigation/native` + native stack, or Expo Router—pick one and install). Screens: **Login**, **Register** (validate email/password length ≥ 8 per backend), optional **post-auth home** placeholder. Wire register/login to Step 1–2; logout clears token and returns to login.
- **Step 4 — Account reactivation (if/when API supports it):** Backend [`todo.md`](C:/projects/cardly/cardly-backend/docs/agents/todo.md) describes reactivation for soft-deleted users; if the API returns a specific status (e.g. 409) or a dedicated endpoint appears later, handle it in Register. If not implemented yet, **flag** as “blocked on backend contract.”
- **Later (blocked on backend):** Deck list, deck CRUD, card list, study session / SRS UI—only after backend exposes REST for decks/cards.

**Note:** `docs/agents/` is local per repo rules (often not committed); file still created as requested.

## 2. Update [`cardly-backend/docs/agents/todo.md`](C:/projects/cardly/cardly-backend/docs/agents/todo.md)

- Insert a **Status** block **immediately after** the title / product paragraph (before Step 1), e.g.:
  - **Step 1 — Domain layer:** **DONE** (entities, Flyway, repos per spec).
  - **Step 2 — Authentication (JWT):** **DONE** (register, login, logout, JWT, `/api/me`).
- **Risk / follow-up** (short bullets under status):
  - **API surface:** REST for **decks** and **cards** not yet exposed—mobile app cannot implement deck/study features until those endpoints exist.
  - **Reactivation:** Spec in Step 1 (email uniqueness + reactivation); confirm whether **AuthService** fully implements it; if not, frontend should treat reactivation as **pending**.
- Keep existing Step 1–2 **content** as the historical spec (do not delete), so new readers still see the requirements; only add status + risks.

## 3. Optional follow-up (out of scope unless you ask)

- Add a line to [`cardly-rnative-app/docs/agents/already-done.md`](C:/projects/cardly/cardly-rnative-app/docs/agents/already-done.md) pointing to `todo.md` (keeps “read already-done first” accurate). Only if you want this doc sync.

No code changes in `App.tsx` or `package.json` in this plan—only the two markdown files unless you expand scope.
