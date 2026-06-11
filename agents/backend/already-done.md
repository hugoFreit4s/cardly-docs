> **Instrução para agentes:** leia este arquivo antes de qualquer ação neste repositório.
> **Disciplina / relatório ABNT:** veja também `requisitos-academicos.md` nesta pasta.

# Cardly — API backend

Serviço **Spring Boot** para o app **Cardly** (REST, persistência e analytics no roadmap).

## O que já existe

- **Spring Boot** `3.5.0`, **Maven** (`mvnw` / `mvnw.cmd`), **Java 21**.
- **Coordenadas**: `com.cardly` / `cardly-backend`.
- **Repositório**: GitHub `hugoFreit4s/cardly-backend`, ramos **Main** e **Developer**.
- **Dependências principais**:
  - `spring-boot-starter-web`, `spring-boot-starter-validation`
  - `spring-boot-starter-data-jpa`
  - `spring-boot-starter-security`
  - **JJWT** `0.12.5` (tokens assinados)
  - **PostgreSQL** (driver `runtime`)
  - **Flyway** (`flyway-core` + `flyway-database-postgresql`)
  - **H2** (`test`) — só para testes automatizados
- **Domínio JPA** (`com.cardly.domain`): `User`, `Deck`, `Card`; enums com sufixo **`ENUM`**: `UserRoleENUM`, `DifficultyLevelENUM`, `ScheduledIntervalENUM`; colunas de auditoria e soft delete (`createdAt`, `updatedAt`, `deletedAt`) na entidade base.
- **Migrações**: `src/main/resources/db/migration/` — `V1__baseline.sql`, **`V2__init_schema.sql`** (tabelas `users`, `decks`, `cards`, índices e restrições).
- **Repositórios**: `UserRepository`, `DeckRepository`, `CardRepository` (consultas por email e exclusão lógica onde aplicável).
- **Serviços**: `UserService.softDeleteUser` — em uma transação, soft delete do usuário e cascata para decks e cards ativos; `AuthService` (registro, login, reativação de conta soft-deleted pelo mesmo email); `JwtService` (emissão e validação JWT HS256).
- **Segurança**: estado sem sessão; filtro JWT; rotas públicas `/api/auth/**` e `/error`; demais rotas autenticadas; `GET /api/me` com Bearer token.
- **API REST**:
  - **Auth**: `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/logout` (204; logout stateless — cliente descarta o token).
  - **Me**: `GET /api/me` — retorna o usuário autenticado via Bearer token.
  - **Decks**: `GET /api/decks` (lista decks do usuário, ordenados por `position` e `id`; inclui `cardCount`), `POST /api/decks` (cria deck; body: `name`, `subject`, `position` opcional).
  - **Cards**: `GET /api/decks/{deckId}/cards` (lista cards do deck, se pertence ao usuário), `POST /api/decks/{deckId}/cards` (cria card; body: `question`, `answer`; defaults: `difficultyLevel=NONE`, streaks=0, sem `dueAt`/`scheduledInterval`).
  - DTOs com validação; `ApiExceptionHandler` para erros de validação; 404 se deck não existe ou pertence a outro usuário.
- **Configuração JWT**: `cardly.jwt.secret` e `cardly.jwt.expiration-seconds` em `application.properties` (e equivalente no perfil `test`).
- **Testes unitários (Mockito)**: `AuthServiceTest`, `UserServiceTest`, `DeckServiceTest`, `CardServiceTest`, `EmailNormalizerTest` — sem subir contexto Spring para esses casos.
- **Dados (perfil default)** — em `application.properties`:
  - URL: `jdbc:postgresql://localhost:5432/cardly`
  - Usuário / senha: `postgres` / `admin`
  - Usar **somente** a base **`cardly`**. **Nunca** apontar para **`sisges`**.
  - `spring.jpa.hibernate.ddl-auto=validate`, Flyway em `classpath:db/migration`, `baseline-on-migrate=true`
- **Classe principal**: `com.cardly.CardlyBackendApplication` (exclui `UserDetailsServiceAutoConfiguration` padrão; JWT em vez de usuário gerado pelo Boot).
- **App mobile**: UI inicial com tema (cores, DM Sans), logo SVG e regras Cursor (sem comentários no código; sem emojis em commits) no repositório `cardly-rnative-app`; desenvolvimento em **Expo SDK 54** com **emulador Android** + Metro (Fast Refresh).

## Pré-requisito para rodar (perfil default)

- **PostgreSQL** em execução, com o banco **`cardly`** criado (`CREATE DATABASE cardly;` se ainda não existir).

## Como executar

```bash
.\mvnw.cmd spring-boot:run    # Windows
./mvnw spring-boot:run        # Linux / macOS
```

## Testes

Perfil **`test`** (`@ActiveProfiles("test")` em `CardlyBackendApplicationTests`): **H2** em memória, **Flyway desligado** — não exige Postgres.

```bash
.\mvnw.cmd test
```

## Ainda não implementado

Regras de negócio de revisão espaçada (aplicar `card-difficulty-level-rules.md` em endpoints de resposta), estatísticas, integração completa com o app mobile e demais funcionalidades fora do escopo atual.
