# Cardly mobile — planned steps (agents)

> **Leia primeiro:** `docs/agents/already-done.md` neste repositório.  
> **Backend irmão:** `cardly-backend` — o MVP abaixo depende do **Step 3** em `cardly-backend/docs/agents/todo.md` (rotas REST de decks e cards).

**Cardly** é o app React Native (Expo). Este ficheiro define o **MVP seguinte:** o utilizador autenticado **vê os seus assuntos** (modelados como **decks**, cada um com campo **`subject`**) e **abre um deck para ver os cartões** dentro dele.

### Status

| Step | State |
|------|--------|
| **Auth, tema, Home mínima** | **DONE** — ver `already-done.md`. |
| **MVP — biblioteca: decks e cartões** | **TODO** — secção abaixo. |

**Bloqueio:** Sem as rotas `GET/POST` descritas no backend Step 3, use apenas **mocks temporários** ou implemente a UI com **estados vazio / erro** até a API existir.

---

## MVP — biblioteca (assuntos / decks e cartões)

### Contrato da API (alinhado ao backend Step 3)

- **Base URL:** já configurada via `EXPO_PUBLIC_API_BASE_URL` → `getApiBaseUrl()` / `apiRequest` em `src/api/client.ts`.
- **Auth:** enviar **`Authorization: Bearer <token>`** em todos os pedidos (usar `token` de `useAuth()`).
- **Rotas esperadas:**
  - `GET /api/decks` → array de `{ id, name, position, subject, createdAt, updatedAt, cardCount? }`
  - `GET /api/decks/{deckId}/cards` → array de cartões com `id`, `deckId`, `question`, `answer`, `difficultyLevel`, `dueAt`, `rightStreak`, `wrongStreak`, `scheduledInterval`, `createdAt`, `updatedAt`
  - `POST /api/decks` corpo `{ name, subject, position? }` — para criar deck vazio (testes e demo)
  - `POST /api/decks/{deckId}/cards` corpo `{ question, answer }` — para criar cartão (testes e demo)

Se o backend devolver nomes de campos diferentes ao implementar, **atualizar os tipos TypeScript** e este ficheiro para bater certo.

### Entregáveis no código (ordem sugerida)

1. **Tipos e cliente HTTP**
   - Estender `src/api/types.ts` (ou módulo dedicado) com tipos para **Deck**, **Card** e bodies de criação.
   - Criar `src/api/decksApi.ts` (ou nome equivalente) com funções que chamam `apiRequest` e recebem `token: string | null` (como `authApi.ts`).
   - Tratar erros com mensagens amigáveis em **pt-BR** (reutilizar padrão das outras screens).

2. **Navegação**
   - Estender `AppStackParamList` em `src/navigation/AppStack.tsx`: pelo menos **`DeckDetail`** com parâmetro `{ deckId: number }` (ou `string` se normalizarem ids — manter consistência com JSON do backend).
   - Registar os novos ecrãs no stack; cabeçalhos alinhados ao estilo existente (DM Sans, cores do tema).

3. **Ecrãs**
   - **Lista de decks** (substituir ou evoluir a Home): mostrar **subject** e **name** (ou só subject se for o foco do produto); indicar **`cardCount`** se existir; pull-to-refresh opcional; estado de carregamento e erro.
   - **Detalhe do deck:** após toque, navegar para `DeckDetail`; `GET /api/decks/{id}/cards`; lista simples (pergunta como título / resumo; resposta expansível ou segundo texto — MVP pode ser só duas linhas).
   - Textos de UI em **pt-BR**; sem comentários no código (regra do projeto).

4. **Fluxo opcional para demo**
   - Se o backend expuser `POST`, adicionar UI mínima (FAB ou botão “Novo deck” / “Novo cartão”) **ou** documentar no commit que a criação é só via API manual até haver UI — preferível incluir um fluxo mínimo para não depender de Postman.

5. **Documentação**
   - Após concluir, atualizar **`docs/agents/already-done.md`** com os novos ficheiros, rotas usadas e ecrãs.

### Critérios de aceitação (MVP)

- Utilizador logado vê a **lista dos seus decks** carregada da API.
- Ao selecionar um deck, vê a **lista de cartões** desse deck.
- Logout continua a funcionar; token inválido deve falhar com tratamento claro (ex. mensagem + eventual redirect já tratado pelo `AuthContext` em `getMe`).

### Não incluir neste MVP

- Sessão de estudo / SRS / responder cartões com regras de `card-difficulty-level-rules.md`.
- Paginação complexa, offline-first, analytics.
- Edição/remoção de decks e cartões (pode ficar para um passo seguinte, a menos que o backend já entregue — neste MVP o foco é **leitura + criação mínima** conforme Step 3 do backend).
