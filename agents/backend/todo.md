# Cardly backend — planned steps

**Cardly** is a spaced-repetition flashcard product. This repository is the **backend**: a **Spring Boot** REST API for user accounts, card scheduling (difficulty levels and review intervals), and future client apps—including a dedicated **Superadmin** front-end and a regular user app.

### Status

| Step | State |
|------|--------|
| **Step 1 — Domain layer** | **DONE** — JPA entities, Flyway migrations, repositories per spec below. |
| **Step 2 — Authentication (JWT)** | **DONE** — Register, login, logout, JWT issuance, `GET /api/me`. |
| **Step 3 — MVP: decks & cards REST** | **DONE** — `GET /api/decks`, `POST /api/decks`, `GET /api/decks/{deckId}/cards`, `POST /api/decks/{deckId}/cards`. |

**Risks / follow-up**

- **Coordination:** Implement Step 3 **before or in lockstep** with the mobile `docs/agents/todo.md` in **`cardly-rnative-app`**. Both todos share the same JSON contract (paths, field names, ISO-8601 instants).
- **REST surface (legacy note):** Until Step 3 ships, the app cannot load decks/cards from the API.
- **Reactivation:** Step 1 below requires **unique email** (including soft-deleted rows) and **reactivation** instead of a duplicate registration. Confirm **`AuthService`** (and related flows) fully implement that contract; until then, clients should treat **reactivation** as **pending** if the API does not return a documented status or body.

---

## Step 1 — Domain layer (entities, migrations, repositories)

Deliverables:

- **JPA `@Entity` classes** (and enums / value objects as needed).
- **Flyway** migrations that create and evolve the schema.
- **Spring Data JPA repositories** for each aggregate root as appropriate.

**Identifiers:** In **PostgreSQL**, primary keys use **`serial4`** (integer identity columns). In the **Java** model, the agent may use `Integer`, `Long`, or another compatible type, but IDs must map to those integer PKs consistently.

**Every entity** includes **`createdAt`**, **`updatedAt`**, and **`deletedAt`** for **soft delete** (null `deletedAt` = active).

**Soft delete — user cascade:** When a **user** is soft-deleted, **all of that user’s decks and cards** must be soft-deleted in the **same transaction**, so there are no active decks or cards left pointing at a deleted user.

### User

- **Relationship:** owns many **decks** (`User` 1 — * `Deck`).
- **Fields:** `name`; `email` (stored **lowercase** and **normalized**); `password` (hashed only, never plaintext); **role** — `USER` or `SUPERADMIN` (two front-ends).
- **Email uniqueness and reactivation:** An email may exist **only once** in the system (including soft-deleted rows). If someone registers an email that already belongs to a **soft-deleted** account, the flow must **not** create a duplicate row: the client should support **account reactivation** (e.g. confirm identity with **password**) and restore the existing row (clear `deletedAt`, update fields as needed). Design registration and auth accordingly.

### Deck

- **Relationship:** belongs to one **user**; has many **cards** (`Deck` 1 — * `Card`).
- **Fields:** `name`; **`position`** (ordering among that user’s decks, e.g. integer for sort order); **`subject`** (theme/category — e.g. sciences, math, geography) so cards inherit grouping by deck.

### Card

- **Relationship:** belongs to one **deck**.
- **Content:** `question`; `answer`.
- **Scheduling / difficulty:** Behavior must match `docs/agents/card-difficulty-level-rules.md`. Persist at least:
  - **`difficultyLevel`:** `none` (before first answer), then `easy`, `medium`, `hard`.
  - **`dueAt`:** instant when the card may be answered (**on or after** only, never before).
  - **`rightStreak`** and **`wrongStreak`** (non-negative integers, consecutive).
  - **`scheduledInterval`:** an **enum** for the current day-bucket from the rules (only the predefined values apply: **1**, **2**, **3**, **5**, **7**, **9** days). Store it in the DB in a stable way (e.g. enum name as string).

Implement associations, indexes (**unique `email`**), and validation as appropriate.

---

## Step 2 — Authentication (JWT)

Implement **register**, **login**, and **logout** using **JWT** (issue signed tokens on login/register as appropriate; validate on protected routes; document or implement token invalidation strategy for logout if using blocklist/short TTL).

Enforce **lowercase**, **normalized** emails on write paths and the **email / reactivation** rules from Step 1.

**Order:** Step 1 must provide the **User** persistence (entities, migrations, repositories) before Step 2 can be completed end-to-end.

---

## Step 3 — MVP: user sees assuntos / decks and cards

**Goal:** An authenticated user can **list their decks** (each deck has a **`subject`** string used as grouping/category in the product) and **list the cards inside a chosen deck**. The mobile app (`cardly-rnative-app`) consumes these endpoints using the existing **Bearer JWT**.

**Out of scope for this MVP step:** Spaced-repetition answer flows, analytics, Superadmin-only APIs, pagination (small payloads assumed), bulk operations.

### Security and ownership

- All routes below require **authentication** (same JWT filter as `GET /api/me`).
- Resolve the current user from **`UserPrincipal`** (or equivalent) and **never** return or mutate decks/cards that belong to another user.
- If a deck id does not exist, is soft-deleted, or belongs to another user → respond **404** (avoid leaking existence across users).
- Use existing repositories: `DeckRepository.findByUser_IdAndDeletedAtIsNull`, `CardRepository.findByDeck_IdAndDeletedAtIsNull`, and load deck by id + user check before listing or creating cards.

### API contract (implement exactly enough for the mobile MVP)

Base path prefix: **`/api`**. JSON bodies and responses; dates as **ISO-8601** strings (e.g. `Instant` serialized in UTC).

1. **`GET /api/decks`**  
   - Returns **all active** decks for the authenticated user.  
   - Sort by **`position`** ascending, then **`id`** if needed for stability.  
   - Response: JSON array of objects, each including at least:  
     `id`, `name`, `position`, `subject`, `createdAt`, `updatedAt`  
   - Optional but recommended for UX: **`cardCount`** (count of active cards in that deck).  
   - Do **not** include full card lists in this response (keep payload small).

2. **`GET /api/decks/{deckId}/cards`**  
   - Returns **all active** cards for that deck, only if the deck belongs to the current user.  
   - Suggested order: **`id`** ascending.  
   - Each card object includes at least:  
     `id`, `deckId`, `question`, `answer`,  
     `difficultyLevel` (string enum matching persistence: `NONE`, `EASY`, `MEDIUM`, `HARD`),  
     `dueAt` (nullable instant), `rightStreak`, `wrongStreak`,  
     `scheduledInterval` (nullable string enum: `DAYS_1`, `DAYS_2`, `DAYS_3`, `DAYS_5`, `DAYS_7`, `DAYS_9`),  
     `createdAt`, `updatedAt`.

3. **`POST /api/decks`** (minimal create — so QA and the app are not stuck on empty accounts)  
   - Body (JSON): `name` (required), `subject` (required), `position` (optional; if omitted, default to **end of list**, e.g. max existing position + 1 for that user).  
   - Validate with Bean Validation; **201** with the created deck representation (same shape as list items, including `cardCount` if you added it).

4. **`POST /api/decks/{deckId}/cards`** (minimal create)  
   - Body: `question` (required), `answer` (required).  
   - Set sensible defaults for new cards: **`difficultyLevel` = `NONE`**, **`rightStreak` = 0**, **`wrongStreak` = 0**, **`dueAt` = null**, **`scheduledInterval` = null** (unless product rules require otherwise — SRS application stays out of this MVP).  
   - **201** with the created card object.

### Implementation notes

- Add **`DeckController`** / **`CardController`** (or a single cohesive controller) under `com.cardly.web`, plus **response DTOs** (do not expose JPA entities directly).
- Reuse **`ApiExceptionHandler`** for validation errors; return **403** only if you introduce role checks; default case is **404** for cross-user or missing resources.
- Add **unit or slice tests** where valuable (e.g. service layer: cannot read another user’s deck). Existing style: Mockito tests without full Spring context where possible.
- After shipping, update **`docs/agents/already-done.md`** in this repo to list the new routes and point mobile agents to the finalized contract.

**Sibling repo:** `cardly-rnative-app` — implement the matching client in `docs/agents/todo.md`.
