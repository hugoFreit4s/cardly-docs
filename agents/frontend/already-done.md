> **Instrução para agentes:** leia este arquivo antes de qualquer ação neste repositório.
> **Disciplina / relatório ABNT:** veja também `requisitos-academicos.md` nesta pasta.
> **Roadmap técnico:** veja `todo.md` nesta pasta (API, sessão JWT, navegação, auth UI, bloqueios no backend).

# Cardly — aplicativo mobile

Esta pasta contém o cliente mobile **Cardly**: um app de estudo com flashcards inspirado no Anki (assuntos, flashcards por assunto, revisão espaçada e analytics estão no roadmap).

## O que já existe

- **React Native** via **Expo SDK 54** e **TypeScript** (modo `strict` ativado). O projeto foi alinhado ao SDK 54 para coincidir com **Expo Go**; na prática o desenvolvimento atual usa **emulador Android** (AVD no **Android Studio**) + Metro no terminal.
- **Nome do projeto**: **Cardly** — em `app.json` (`name`: “Cardly”, `slug`: `cardly`).
- **Configuração Expo:** `app.config.ts` expõe `extra.apiBaseUrl` a partir de **`EXPO_PUBLIC_API_BASE_URL`** (definir num ficheiro **`.env`** na raiz do projeto, não versionado). Há **`.env.example`** na raiz com valor de exemplo para o emulador Android.
- **API (Spring em `localhost`):** no **emulador Android**, `localhost` aponta para o próprio emulador. Para alcançar o **Spring Boot** na máquina anfitriã, use **`http://10.0.2.2:8080`** (porta padrão do backend local, ajustar se mudares). Num **telefone físico** na mesma rede Wi‑Fi, usa o **IP LAN** do PC (ex.: `http://192.168.x.x:8080`).
- **Cliente HTTP:** `src/api/client.ts` (`fetch`), rotas em `src/api/authApi.ts` — `POST /api/auth/login`, `POST /api/auth/register`, `GET /api/me`, `POST /api/auth/logout`. Rotas de decks/cards em `src/api/decksApi.ts` — `GET /api/decks`, `GET /api/decks/{id}/cards`, `POST /api/decks`, `POST /api/decks/{id}/cards`. Tipos alinhados ao backend em `src/api/types.ts` (inclui `Deck`, `Card`, `CreateDeckBody`, `CreateCardBody`).
- **Sessão JWT:** token em **`expo-secure-store`** (`src/auth/AuthContext.tsx`). Ao abrir a app, restaura o token e valida com **`GET /api/me`**. Logout limpa o armazenamento e chama o endpoint de logout (no backend, `/api/auth/**` é público; o importante é limpar o token localmente).
- **Navegação:** `@react-navigation/native` + **`@react-navigation/native-stack`**, `react-native-screens`, **`react-native-gesture-handler`** (import no topo de `index.ts`). `src/navigation/RootNavigator.tsx` alterna stack de autenticação e stack pós-login. `AppStack` inclui rotas `Decks` (lista de assuntos) e `DeckDetail` (cartões de um deck).
- **Ecrãs:** **Entrar**, **Criar conta** (validação: e-mail e senha ≥ 8 caracteres), **perfil** (Home) com e-mail, papel (`USER` / `SUPERADMIN`) e **Sair**. **Meus Assuntos** (`DecksScreen`) lista decks do utilizador com pull-to-refresh, estados de loading/erro/vazio, e FAB "Novo Assunto" para criar decks. **Detalhe do Deck** (`DeckDetailScreen`) lista cartões com pergunta visível e resposta expansível ao toque, FAB "Novo Cartão" para criar cards. Textos de UI em **pt-BR**.
- **Reativação de conta:** o backend **reativa** utilizadores com *soft delete* no mesmo **`POST /api/auth/register`** (mesmo e-mail); não há fluxo HTTP separado na API — a app informa o utilizador no ecrã de registo; conflito **409** continua possível se o e-mail já estiver ativo.
- **Entrada**: `index.ts` → `App.tsx` (`GestureHandlerRootView`, `SafeAreaProvider`, `AuthProvider`, `NavigationContainer`).
- **UI base**: tema em `src/theme/` (`colors`, `typography` com **DM Sans** via `@expo-google-fonts/dm-sans` + `expo-font`), logo vetorial em `src/components/CardlyLogo.tsx` (**`react-native-svg`**), cópia estática em `assets/cardly-logo.svg`; splash alinhado a `colors.background` em `app.json`.
- **Repositório**: `cardly-rnative-app` (GitHub: `hugoFreit4s/cardly-rnative-app`), ramos **Main** e **Developer**.
- **Regra Cursor**: `.cursor/rules/read-already-done.mdc` — sem comentários no código; sem emojis em mensagens de commit.
- **Backend irmão** (`cardly-backend`): **Spring Boot 3.5**, **Java 21**, **PostgreSQL** na base **`cardly`** (utilizador `postgres`, senha `admin`, `localhost:5432`), **Flyway** em `db/migration`. **Não** usar a base **`sisges`**.

## Como executar

Neste diretório:

```bash
npm install   # se necessário
```

Cria um ficheiro **`.env`** (podes copiar de `.env.example`) com `EXPO_PUBLIC_API_BASE_URL` apontando para o backend (ex. `http://10.0.2.2:8080` no emulador Android). Garante que o **PostgreSQL** e o **`cardly-backend`** estão a correr.

```bash
npm start     # Metro; depois tecla "a" para abrir no Android emulador
npm run android
npm run ios     # macOS para build iOS nativo
npm run web     # pré-visualização web opcional
```

**Android (fluxo usado):** ligar o **AVD** no Android Studio (**Device Manager**), depois `npm start` e **`a`**, ou `npm run android`. Garantir que `adb devices` lista o emulador.

## Desenvolvimento

Com **Metro** e o **emulador** a correr, alterações em `.tsx` / `.ts` / estilos recarregam com **Fast Refresh** — não é preciso reiniciar o emulador nem o Expo a cada gravação. Se algo ficar desincronizado: recarregar na app (`r` no terminal do Expo) ou `npx expo start -c` para limpar cache do Metro. Só após mudanças nativas ou plugins que exigem rebuild é que voltar a correr `npx expo run:android` (ou equivalente).

## Ainda não implementado

Sessão de estudo (responder cartões com SRS), analytics e restante do produto — depende de APIs adicionais no `cardly-backend` (ver `todo.md` nesta pasta).
