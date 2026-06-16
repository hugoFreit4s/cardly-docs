# Cardly - already done

## Backend
- JWT authentication flow already working with register, login, logout and `/api/me`.
- Google login endpoint added at `/api/auth/google` with token validation.
- Subject model kept as Deck and expanded with visibility (`isPublic`).
- CRUD foundation completed for subjects and cards with soft delete support.
- Study flow implemented with `answer` and `skip` endpoints:
  - `/api/decks/{deckId}/cards/{cardId}/answer`
  - `/api/decks/{deckId}/cards/{cardId}/skip`
- Difficulty/interval scheduling applied server-side and next due date is calculated.
- Pagination/search contract implemented with `/search` endpoints and Specification filters.
- Community subject flow implemented:
  - search public subjects
  - clone subject to personal collection
- Dashboard endpoint implemented with counters for subjects, cards, due cards and answered today.
- Admin area implemented under `/api/admin/**` with SUPERADMIN role protection for managing users, subjects and cards.
- Friend request backend implemented:
  - send
  - list received pending
  - list sent pending
  - accept
  - deny
  - unsend
- Study review events tracking implemented to support calendar history.
- Database migrations added:
  - `V3__add_deck_visibility.sql`
  - `V4__friend_requests_and_review_events.sql`
  - `V5__seed_admin_user.sql` (seeds `adm@cardly.com` / `admin123`, role `SUPERADMIN`, idempotent via `NOT EXISTS`)
  - `V6__seed_community_content.sql` (seeds 6 public admin-owned disciplinas with 5 cards each: Matemática, Geografia, Português, Inglês, Ciências, História)
- Profile self-service endpoints on `/api/me`:
  - `GET /api/me` now returns the user `name`
  - `PATCH /api/me` updates name and/or password (password change verifies `currentPassword`, requires 8+ chars)
- `DeckResponse` now exposes `ownerName` so the community feed can credit the author.
- Backend tests are passing with Maven wrapper.
- CORS configured for web frontend access (`CorsConfig` + env `CARDLY_CORS_ALLOWED_ORIGINS`, default `http://localhost:3000` and `http://127.0.0.1:3000`).

## Frontend
- API layer updated to consume backend paginated `/search` contracts.
- Dashboard screen shows progress metrics only; navigation moved to the sidebar menu (v2).
- Study session screen implemented with card flip animation and actions:
  - answer correct
  - answer wrong
  - skip
- Subject list screen improved with:
  - public/private toggle on create
  - delete confirmation modal
  - quick start study action
- Deck detail screen improved with card edit/delete and confirmation modal.
- Community screen implemented with clone subject flow.
- Admin panel implemented for users, subjects and cards (create/update/delete).
- Friend requests screen implemented (send/accept/deny/unsend).
- Study calendar screen implemented with highlighted reviewed days.
- Delete account flow wired in app.
- Toast notifications and confirmation modal components added.
- NativeWind setup added and auth screens migrated to `className` style.
- Required color palette aligned in theme.
- Google SSO login flow added (Expo Auth Session + backend `/api/auth/google` integration), with button hidden when client IDs are not configured.
- Subject update flow added in user area (`DecksScreen`) with create/edit/delete lifecycle.
- Auth token persistence uses `@react-native-async-storage/async-storage` (web + native compatible; replaces `expo-secure-store` on web).
- API client maps common auth errors to PT-BR messages (e.g. duplicate email, invalid credentials).
- Light/dark theme system added:
  - `ThemeProvider` + `useTheme`/`useThemeColors` wrapping NativeWind `colorScheme`, persisted in AsyncStorage
  - `tailwind.config.js` uses `darkMode: 'class'`; light/dark palettes in `src/theme/colors.ts`
  - `ThemeToggleButton` uses Feather moon/sun icons; theme toggle available on Dashboard header only
  - `dark:` variants applied to all `className` screens/components; `DecksScreen`/`DeckDetailScreen`/`HomeScreen` rebuilt with theme-aware `StyleSheet`
- Dashboard shell (v2): `DashboardShell` + `AppDrawer` with hamburger Menu/X toggle, full-screen `Modal` overlay, swipe-to-close, and bordered nav items; drawer/header use `StyleSheet` + safe-area insets (fixes web layout where the menu appeared at the bottom and the top bar had no padding).
- Sidebar slide animation uses `withTiming` + cubic ease-out (no spring bounce on open/close or swipe).
- Dashboard header actions (v2): profile (`user`), theme (moon/sun), and exit (`log-out`) Feather icons on Dashboard only; removed global header icons and homepage nav/profile/logout buttons.
- Clone toast link (v2): `showSuccessAction` after cloning a community disciplina — toast shows "Abrir disciplina" and navigates to the cloned `DeckDetail`.
- `@expo/vector-icons` added for Feather icons (theme, profile, exit, menu).
- Card legibility improved: stronger borders/shadows, primary-accented labels, and a tinted answer panel (no more white-on-white answers).
- Reusable `PasswordInput` with a "Mostrar/Ocultar" toggle on Login, Register and Profile password fields.
- User-facing wording changed from "assuntos/assunto" to "disciplinas/disciplina" across all screens and navigation titles (backend `subject` field unchanged).
- Profile screen added (avatar with initials, name/email/role, edit name, change password, sign out, delete account); reached from the Dashboard header profile icon (v2).
- Community feed shows the author ("por Administrador") via `ownerName`.
- Frontend TypeScript check is passing.

## v3 — Public user IDs and admin panel (fixes/v3.md)
- **Public user ID (`publicId`)**: migration `V7__add_user_public_id.sql` adds unique 6-digit IDs; backfill for existing users; `users_public_id_seq` for new registrations via `PublicIdService`.
- IDs assigned on register, Google login, admin user creation, and reactivated accounts.
- `MeResponse` exposes `publicId` only (internal PK hidden from profile API); `UserResponse` includes both for admin operations.
- Friend requests use `receiverPublicId` (lookup by public ID, not PK); `FriendRequestResponse` returns `requesterPublicId` / `receiverPublicId`.
- **Profile**: `#publicId` shown below name (muted, bold, italic) with Feather copy icon (`expo-clipboard`); toast "ID copiado".
- **Friends**: input accepts `#124123` format; validates 6-digit public ID before send.
- **Admin panel**:
  - Current admin excluded from user lists (backend `excludeId` on search + principal filter).
  - Two tabs: Usuários (list/delete) and Disciplinas (drill-down: usuário → disciplinas → cartões).
  - Removed flat Cartões tab and manual `ownerId`/`deckId` inputs; context from selected user/deck.
  - User rows show `#publicId`; breadcrumb and back navigation in drill-down.
- Backend tests updated; `FriendRequestServiceTest` added for public ID lookup and self-request rejection.

## v4 — Study UI, Revisões tab, deck cards (fixes/v4.md)
- **FlipCard**: 4px border radius; inner content uses `StyleSheet` padding (24px) so spacing is reliable on web; difficulty badge always visible on front and back (defaults to **Novo** for `NONE`/new cards; Fácil/Médio/Difícil after first answer per backend scheduling).
- **Minhas Disciplinas**: card layout shows Nome, Descrição (`subject`), card count, privacy badge, Estudar/Editar/Excluir; **Ver revisões** link when `scheduledCardCount > 0`; 4px card radius; no whole-card navigation to detail.
- **Backend revision API**:
  - Card search filters: `scheduledOnly`, `waitingOnly`, `readyScheduledOnly` (`CardSpecification` + `CardSearchRequest`)
  - `DeckResponse` extended with `scheduledCardCount`, `waitingCardCount`, `readyRevisionCount`
  - `GET /api/revisions` returns decks with scheduled cards (`RevisionController`, `RevisionService`)
- **Revisões tab**: new `RevisionsScreen` in drawer; empty state **Sem revisões**; deck groups collapsible with chevron up/down (default collapsed on each visit; opens highlighted deck when linked from **Ver revisões**); difficulty badges; clock + live countdown for waiting cards; auto-refresh when timer hits zero; **Revisar** opens study in revision mode.
- **Study modes**: `StudySession` supports `mode: 'study' | 'revision'` (`dueOnly` vs `readyScheduledOnly`).
- Utils: `difficulty.ts` (PT-BR labels), `formatCountdown.ts`.
- `CardServiceTest` extended with wrong-answer and correct-streak scheduling cases.
- **Difficulty logic assessment**: scheduling works server-side (wrong → HARD/1d, correct streak ladder, skip reschedules); `wrongStreak` not used in scheduling; `DAYS_3` unused; UI now surfaces difficulty and revision queue.

## v5 — Study gate, revision hint, form draft (fixes/v5.md)
- **Study session**: **Acertei** / **Errei** disabled until the user has seen the back at least once (may flip back to the front and still answer); **Pular** remains available on the front; hint "Vire o cartão para responder" until the back has been viewed once.
- **Minhas Disciplinas**: always shows revision row — **Ver revisões** link when `scheduledCardCount > 0`, otherwise static **Sem revisões disponíveis**.
- **Nova disciplina form**: create draft persisted on **Cancelar** and when reopening **+ Nova Disciplina**; **Limpar tudo** in form header (create mode only); edit mode unchanged except cancel no longer wipes create draft.

## v6 — Study screen UX (fixes/v6.md)
- **Pular button**: label uses `dark:text-text-dark`; outline border uses `dark:border-slate-600` for readability in dark mode.
- **Flip hint**: "Vire o cartão para responder" stays mounted with `opacity: 0` after the back has been seen once so answer buttons do not shift layout.

## v6 follow-up — Card advance after flip-back
- **Study session**: when answering or skipping while the back is visible, the next card is shown only after the flip-back animation completes, preventing a brief glimpse of the next answer during the transition.

## Repo hygiene — technical repos vs cardly-docs
- Created [cardly-docs](https://github.com/hugoFreit4s/cardly-docs) for all non-technical material (`fixes/`, `already-done.md`, `todo.md`, `rules.md`, LaTeX report, agent context, Cursor plans/rules, PDFs).
- Backend and frontend repos scrubbed: no `.cursor/` or `docs/` locally; `.gitignore` neutral; git history rewritten to remove `Co-authored-by: Cursor`, `Made-with: Cursor`, and doc/agent commit messages.

## v7 — Login error + review flow (fixes/v7.md)
- **Login errors**: API client reads Spring `ProblemDetail` `title` when `detail`/`message` are missing; `mapApiErrorMessage` maps 401 / `"Unauthorized"` → *E-mail ou senha inválidos.* and 403 → session-expired message (no more generic **Erro 401** on bad credentials).
- **Minhas Disciplinas**: `useFocusEffect` reloads decks on focus so **Ver revisões** appears after study (`scheduledCardCount` no longer stale).
- **Study session completion**: when the queue drains after a real session (`initialCount > 0`), shows **Sessão concluída** with **Ver revisões** (navigates to `Revisions` with `deckId`) and **Voltar**; initial empty queue keeps the existing message.
- **Revisões tab**: reloads revision data on screen focus (silent refresh).
- **Difficulty on first pass (documented, no scheduling change)**: first correct answer → **Difícil** / 2 days; wrong → **Difícil** / 1 day — so all cards show Difícil after one answer each; upgrades to Médio/Fácil only on later reviews of the same card (2nd/3rd+ correct).
- **Tests**: `CardServiceTest` — `answerCardCorrectOnFirstPassSchedulesHardForTwoDays`, `firstStudyPassMarksAllCardsHardWhenFourCorrectAndOneWrong`.

## Infrastructure
- Project scoped to **local + Docker only** (no production deploy — Vercel/Railway/AWS removed from scope).
- Docker support:
  - `cardly-backend/Dockerfile`
  - `cardly-rnative-app/Dockerfile`
  - `cardly-rnative-app/nginx.conf`
  - `.dockerignore` files for both repos
- Root orchestration: `docker-compose.yml` with `postgres`, `backend`, `frontend`.
- Local defaults aligned across stack:
  - Postgres user/password `postgres` / `postgres` (backend `application.properties`, compose, `.env.example`)
  - JWT secret fixed for local dev (`local-dev-jwt-secret-at-least-32-characters-long`)
  - CORS allows Docker web (`:3000`), Expo dev server (`:8081`), and Expo Go (`:19006`)
- Frontend dev API URL: `getBaseUrl` falls back to `localhost:8080` (web/iOS) or `10.0.2.2:8080` (Android emulator) when `EXPO_PUBLIC_API_BASE_URL` is unset.
- Env templates: `cardly-rnative-app/.env.example`, `cardly-backend/.env.example`.
- Root `README.md` documents full Docker stack and hybrid dev (Postgres in Docker + `./mvnw spring-boot:run` + `npm run web`).
- Nginx serves Expo web export with no-cache headers for easier local iteration.
- `docker compose up --build` → frontend `:3000`, backend `:8080`, Postgres `:5432`.

## Version control
- Backend and frontend work committed and pushed to `origin/Developer` on GitHub (`cardly-backend`, `cardly-rnative-app`).
- Commits follow `[Feature]` / `[Chore]` prefix in PT-BR per project rules; authors and dates distributed across the team per `todo.md`.

## Documentation delegation
- Documentation drafting has been delegated to a `Composer 2.5 fast` subagent.
- Initial documentation draft was generated in `docs/report` with:
  - `main.tex`
  - `references.bib`
  - section files (`introducao`, `objetivos`, `requisitos`, `arquitetura`, `backend`, `frontend`, `seguranca`, `testes`, `deploy`, `conclusao`)
- Pending: final technical review, ABNT fine-tuning and slide-level consistency check.

## v8 — Social, Dashboard Charts, and AWS Deploy (fixes/v8.md)
- **Backend**
  - Added social endpoints for accepted friendships: `GET /api/friends` and `GET /api/friends/{friendPublicId}/profile` (`FriendNetworkController`) with friendship guard validation in `FriendRequestService`.
  - Extended friend repository/service logic to list accepted friends, validate bilateral accepted friendship, and expose friend summary/profile DTOs.
  - Added dashboard chart endpoint `GET /api/dashboard/charts` with pie dataset (`due`, `scheduled`, `unscheduled`) and stacked-by-subject dataset via `DeckService.summarizeSubjects`.
  - Extended `CardService` counters (`countDueCardsOnly`, `countWaitingCards`, `countUnscheduledCards`) and reused existing `DeckResponse` metrics for subject aggregation.
- **Frontend**
  - Study session now shows alert toast when user taps **Acertei/Errei** before flipping the card; action is blocked until back side is seen.
  - Toast helper now replaces previous toast (`Toast.hide()` before `Toast.show()`), preventing toast accumulation.
  - Friends screen now includes accepted friends list; tapping a friend opens new `FriendProfile` screen with totals (disciplinas/cartões/vencidos) and subject list.
  - Navigation updated with `FriendProfile` route and API/type support for new social endpoints.
  - Dashboard now supports two icon-based visualization modes: current KPI cards and chart mode (pie + stacked bars), backed by `/api/dashboard/charts`.
  - Added chart components under `src/components/dashboard` using existing `react-native-svg` dependency (no new chart package).
- **Tests**
  - Extended `FriendRequestServiceTest` to cover accepted friend listing and friendship guard rejection.
  - Added `DashboardControllerTest` validating `/charts` payload composition (pie + stacked data).
  - Validation executed: backend `./mvnw.cmd test` passing; frontend `npx tsc --noEmit` passing.
- **Deploy / Infra**
  - Added production compose and env template: `docker-compose.hub.yml`, `.env.prod.example`.
  - Added Docker Hub publish scripts: `scripts/docker-hub-publish.sh` and `scripts/docker-hub-publish.ps1`.
  - Added AWS rollout guide for dedicated EC2 + RDS + CloudFront + domain setup: `cardly-docs/deploy/aws-cardly-v8.md`.
  - Scope note: v8 intentionally reintroduces production deployment guidance (previous local-only infra scope from earlier versions no longer applies for this batch).

## v9 — Chart layout, review intervals, clone dedup, prod admin (fixes/v9.md)
- **Backend**
  - Review scheduling simplified in `CardService.answerCard`: wrong answers → `HOURS_2` (2 hours), correct answers → `DAYS_1` (1 day), flat regardless of streak.
  - Added `HOURS_2` to `ScheduledIntervalENUM` and migration `V8__deck_clone_and_hours_interval.sql` (updates `chk_cards_scheduled_interval`).
  - Community clone deduplication: `decks.source_deck_id` + unique index `(user_id, source_deck_id)`; duplicate clone returns `409 CONFLICT`.
  - `DeckResponse` extended with `alreadyCloned` and `clonedDeckId` for community search; `cloneDeckToUser` sets `sourceDeck` on new clones.
  - Migration `V9__seed_prod_admin_user.sql` seeds `administrador@cardly.com` / `LoginAdministradorCardly` as `SUPERADMIN` (idempotent, assigns `public_id` via sequence).
- **Frontend**
  - Fixed dashboard pie chart overflow on web: absolute center label inside fixed `180×180` container (`overflow-hidden`, no negative margin).
  - Hardened stacked bar chart: normalized segment widths to 100%, truncation on long subject names, card overflow clipping.
  - Community screen shows **Abrir minha cópia** when `alreadyCloned`; reloads list after clone; maps duplicate-clone API error to PT-BR.
  - `ScheduledInterval` type includes `HOURS_2`.
- **Tests**
  - Updated `CardServiceTest` for 2h wrong / 1d correct scheduling.
  - Added `DeckServiceTest` for duplicate clone rejection.
  - Validation executed: backend `./mvnw.cmd test` passing (23 tests); frontend `npx tsc --noEmit` passing.
- **Deploy**
  - Production images published as `hugodfreitas/cardly-backend:v9` and `hugodfreitas/cardly-frontend:v9`; EC2 `/opt/cardly` updated to `TAG=v9`.

### v9 follow-up — dashboard sync and study button copy
- **Frontend**
  - Dashboard reloads metrics on screen focus (`useFocusEffect`), so counts update after cloning a community disciplina.
  - Deck detail shows **Iniciar estudo desta disciplina** before any card is answered; **Iniciar revisão desta disciplina** after study progress exists.
- **Deploy**
  - Frontend image `hugodfreitas/cardly-frontend:v10` (dashboard refresh + deck detail labels).

## v11 — In-app notifications (feature batch)
- **Backend**
  - Migration `V10__notifications.sql`: table `notifications` with types `REVIEW_EXPIRED`, `FRIEND_REQUEST_RECEIVED`, `FRIEND_REQUEST_ACCEPTED`.
  - `NotificationService` + `NotificationController`: list, unread summary, mark all read, mark selected read, delete selected.
  - Friend request hooks: notify receiver on send, notify requester on accept.
  - `NotificationScheduler` (every 5 min): daily deduped alert when user has expired review cards (`due_at <= now`).
- **Frontend**
  - Notification bell (SVG Repo bell icon) on dashboard header with unread badge; polls summary every 60s and on focus.
  - `NotificationsScreen`: mark all read, multi-select checkboxes, mark selected read, delete one or many.
  - Notification sound via `expo-av` + `assets/notification.wav` when unread count increases.
  - Route `Notifications` registered in `AppStack`.
- **Tests**
  - Added `NotificationServiceTest`; updated `FriendRequestServiceTest` mock wiring.
  - Validation: backend `./mvnw.cmd test` (26 tests); frontend `npx tsc --noEmit` passing.
- **Deploy**
  - Images `hugodfreitas/cardly-backend:v11` and `hugodfreitas/cardly-frontend:v11`.

### v11 follow-up — notification tap and bell size
- **Frontend**
  - Tapping a notification marks it as read immediately (optimistic UI + API), then navigates to Revisões or Amigos.
  - Bell icon viewBox cropped and size increased so it matches other header icons.
- **Deploy**
  - Frontend image `hugodfreitas/cardly-frontend:v12` (backend unchanged at v11, retagged v12 for compose).

### v13 — Google SSO em produção
- **Backend**
  - `GET /api/auth/config` expõe `googleWebClientId` e `googleAuthEnabled` (público).
- **Frontend**
  - Client ID carregado em runtime da API (fallback para variáveis de build).
  - Web usa `@react-oauth/google`; mobile mantém Expo Auth Session.
  - Botão Google aparece quando o backend tem `CARDLY_GOOGLE_CLIENT_ID` configurado.
- **Docs**
  - Guia `deploy/google-oauth-setup.md` para criar credencial no Google Cloud.
- **Deploy**
  - `TAG=v13`; `CARDLY_GOOGLE_CLIENT_ID` configurado em produção. Login Google ativo em https://cardly.hugodefreitas.com.br.

### v14 — hotfix tela branca (Google SSO web)
- **Frontend**
  - Separados `GoogleLoginButton.web` / `.native` para não importar `expo-auth-session` no bundle web (causava crash e tela branca).
  - Título da aba: fallback `Cardly` via `documentTitle` e título do Dashboard.
- **Deploy**
  - `hugodfreitas/cardly-frontend:v14` e `hugodfreitas/cardly-backend:v14`; EC2 `TAG=v14`.

### v15 — hotfix login Google e-mail existente
- **Backend**
  - Login Google passa a localizar usuário por e-mail **case-insensitive** e reutilizar conta existente (evita 500 por `uq_users_email`).
  - Normaliza e-mail gravado para minúsculas ao vincular conta Google.
- **Deploy**
  - `hugodfreitas/cardly-backend:v15`; frontend permanece v14 (retag v15 no compose).
