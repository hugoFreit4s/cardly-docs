# Google SSO — Cardly

O login com Google exige um **OAuth 2.0 Client ID (Web)** no Google Cloud. O backend e o frontend usam o **mesmo** Client ID.

## 1) Criar credencial no Google Cloud

1. Acesse [Google Cloud Console](https://console.cloud.google.com/apis/credentials).
2. Crie ou selecione um projeto.
3. Se for a primeira vez, configure a **OAuth consent screen**:
   - **User type:** **External** (Cardly é app público; qualquer conta Google pode entrar).
   - Preencha nome do app, e-mail de suporte e domínio autorizado (`hugodefreitas.com.br`).
   - Em **Test users**, não é necessário enquanto o app estiver em modo *Testing* — adicione seu e-mail se quiser testar antes de publicar.
4. **APIs & Services → Credentials → Create credentials → OAuth client ID**.
5. Tipo: **Web application**.
5. Configure:

| Campo | Valor |
|-------|--------|
| **Authorized JavaScript origins** | `https://cardly.hugodefreitas.com.br` |
| | `http://localhost:8081` (dev Expo web, opcional) |
| **Authorized redirect URIs** | `https://cardly.hugodefreitas.com.br` |
| | `http://localhost:8081` (opcional) |

6. Copie o **Client ID** (formato `....apps.googleusercontent.com`).

## 2) Configurar produção (EC2)

Em `/opt/cardly/.env.prod`:

```bash
CARDLY_GOOGLE_CLIENT_ID=SEU_CLIENT_ID.apps.googleusercontent.com
```

Reinicie o stack:

```bash
cd /opt/cardly
docker compose -f docker-compose.hub.yml --env-file .env.prod up -d
```

O frontend busca o Client ID em tempo de execução via `GET /api/auth/config`, então **não é obrigatório** rebuild da imagem frontend só por mudar o ID — basta atualizar o backend.

Para build local com botão visível sem depender da API:

```bash
EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID=SEU_CLIENT_ID.apps.googleusercontent.com
```

## 3) Desenvolvimento local

**Backend** (`cardly-backend/.env` ou variáveis de ambiente):

```bash
CARDLY_GOOGLE_CLIENT_ID=SEU_CLIENT_ID.apps.googleusercontent.com
```

**App** (`cardly-rnative-app/.env`):

```bash
EXPO_PUBLIC_API_BASE_URL=http://localhost:8080
EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID=SEU_CLIENT_ID.apps.googleusercontent.com
```

Inclua `http://localhost:8081` (ou a porta do Expo web) nas origens autorizadas no Google Console.

## 4) Verificar

1. `curl https://cardly.hugodefreitas.com.br/api/auth/config`  
   Deve retornar `{"googleAuthEnabled":true,"googleWebClientId":"..."}`.
2. Abra a tela de login — o botão **Entrar com Google** deve aparecer.
3. Após login, o backend valida o `id_token` contra o mesmo Client ID.

## 5) Mobile (Android / iOS)

Para apps nativos, crie clientes OAuth separados (Android / iOS) no mesmo projeto Google e defina:

- `EXPO_PUBLIC_GOOGLE_ANDROID_CLIENT_ID`
- `EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID`
- ou `EXPO_PUBLIC_GOOGLE_EXPO_CLIENT_ID` (Expo Go)

Na web em produção, apenas o **Web Client ID** no backend é suficiente.
