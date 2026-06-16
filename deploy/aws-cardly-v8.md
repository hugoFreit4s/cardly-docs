# Deploy AWS — Cardly (v8)

Este guia segue o **mesmo padrão do Sisges**: EC2 compartilhada, nginx no host (80/443), Let's Encrypt, RDS PostgreSQL.

## 1) Arquitetura alvo

- **DNS**: `cardly.hugodefreitas.com.br` → IP público da EC2 (registro **A**)
- **EC2 (Ubuntu, compartilhada com Sisges)**: host nginx encaminha para containers Docker
  - `cardly-frontend` na porta **3000**
  - `cardly-backend` na porta **8082** (8080 já é do Sisges)
- **RDS PostgreSQL**: banco `cardly`
- **TLS**: Certbot no host (não é necessário CloudFront)

```
Usuário → DNS → EC2 nginx :443
                  ├─ /     → localhost:3000 (frontend)
                  └─ /api  → localhost:8082 (backend)
Backend → RDS PostgreSQL :5432
```

## 2) Preparar imagens no Docker Hub

No host local:

```powershell
cd C:\projects\cardly
$env:DOCKERHUB_USER='hugodfreitas'
$env:TAG='v8'
$env:EXPO_PUBLIC_API_BASE_URL='https://cardly.hugodefreitas.com.br'
.\scripts\docker-hub-publish.ps1
```

O frontend chama `/api/...` na mesma origem; não use subdomínio `api.` a menos que republique a imagem.

## 3) RDS

- Endpoint: `cardly.clwi8c0q49pk.us-east-2.rds.amazonaws.com`
- Banco: `cardly`
- **Security group**: liberar porta `5432` **somente** do security group da EC2 (não `0.0.0.0/0`)

## 4) EC2 — portas no host

| Serviço | Container | Porta host |
|---------|-----------|------------|
| Sisges backend | `sisges-deploy-backend-1` | 8080 |
| Sisges frontend | `sisges-deploy-frontend-1` | 3001 |
| Cardly backend | `cardly-backend-1` | **8082** |
| Cardly frontend | `cardly-frontend-1` | 3000 |

No EC2, `docker-compose.hub.yml` deve mapear `8082:8080` para o backend Cardly.

## 5) Runtime na EC2 (`/opt/cardly`)

Arquivos: `docker-compose.hub.yml`, `.env.prod` (ver `.env.prod.example` no repo).

```bash
cd /opt/cardly
docker pull hugodfreitas/cardly-backend:v8
docker pull hugodfreitas/cardly-frontend:v8
docker compose -f docker-compose.hub.yml --env-file .env.prod up -d
docker ps
```

Health checks locais:

```bash
curl -I http://127.0.0.1:3000
curl -I http://127.0.0.1:8082/api/dashboard   # 401/403 = OK; 502 = backend/RDS
docker logs --tail 80 cardly-backend-1
```

## 6) Nginx no host

Template: `cardly-docs/deploy/cardly-nginx.conf`

```bash
sudo cp cardly-nginx.conf /etc/nginx/sites-available/cardly
sudo ln -sf /etc/nginx/sites-available/cardly /etc/nginx/sites-enabled/cardly
sudo nginx -t && sudo systemctl reload nginx
```

## 7) DNS + TLS

1. Criar registro **A**: `cardly.hugodefreitas.com.br` → IP da EC2 (`3.130.71.191`)
2. Após propagar:

```bash
sudo certbot --nginx -d cardly.hugodefreitas.com.br
```

## 8) Checklist pós-deploy

- `https://cardly.hugodefreitas.com.br` carrega o frontend
- `GET /api/dashboard` responde (401 sem token = serviço no ar)
- Login e dashboard funcionam
- Fluxo de amizade (enviar, aceitar, listar, perfil)

## 9) Estado atual (2026-06-16)

Ver `cardly-docs/already-done-infra.md` para handoff detalhado.

- Containers Cardly: **up**
- Nginx vhost Cardly: **instalado**
- Frontend via nginx: **200 OK**
- Backend: **bloqueado** — RDS SG não permite conexão da EC2
- DNS `cardly.hugodefreitas.com.br`: **pendente**
- TLS Certbot: **pendente** (após DNS)
