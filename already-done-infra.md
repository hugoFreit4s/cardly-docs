# Cardly — infra handoff (AWS deploy in progress)

Last updated: 2026-06-16 (session 2). Use this file to continue deployment support without re-discovering context.

## Goal

Deploy Cardly on the **same EC2 instance as Sisges**, with:
- frontend container (nginx) on host port `3000`
- backend container (Spring Boot) on host port `8082` (8080 was taken by Sisges)
- RDS PostgreSQL for Cardly database
- Host nginx + Let's Encrypt on the **same EC2 as Sisges** (Sisges does **not** use CloudFront)
- Domain `cardly.hugodefreitas.com.br`

## Repos and artifacts

| Item | Location / value |
|------|------------------|
| Docker Hub user | `hugodfreitas` |
| Backend image | `hugodfreitas/cardly-backend:v12` |
| Frontend image | `hugodfreitas/cardly-frontend:v12` |
| Frontend build API URL | `https://cardly.hugodefreitas.com.br` (expects host nginx `/api` → backend `:8082`) |
| SSH key (local) | `C:\Users\ugo\.ssh\sisges-sboot-app-kp.pem` |
| Nginx vhost template | `cardly-docs/deploy/cardly-nginx.conf` |
| Create DB script | `cardly-docs/deploy/create-cardly-db.sh` |
| Compose (prod) | repo root `docker-compose.hub.yml` |
| Env template | repo root `.env.prod.example` |
| Publish scripts | `scripts/docker-hub-publish.ps1`, `scripts/docker-hub-publish.sh` |
| Deploy guide | `cardly-docs/deploy/aws-cardly-v8.md` |

Images were published successfully from local machine (2026-06-15).

## EC2 instance (shared with Sisges)

| Field | Value |
|-------|--------|
| Public IP | `3.130.71.191` |
| Hostname (internal) | `ip-172-31-38-26` |
| SSH user | `ubuntu` |
| Deploy directory | `/opt/cardly` |
| SSH note | `scp`/`ssh` require `-i <path-to-ec2-key.pem>` (permission denied without key) |

### Port allocation on this host

| Service | Container | Host port |
|---------|-----------|-----------|
| Sisges backend | `sisges-deploy-backend-1` | `8080` |
| Sisges frontend | `sisges-deploy-frontend-1` | `3001` |
| Cardly backend | `cardly-backend-1` | `8082` → container `8080` |
| Cardly frontend | `cardly-frontend-1` | `3000` → container `80` |

Cardly `docker-compose.hub.yml` on EC2 was edited so backend maps `8082:8080` (not `8080:8080`).

## RDS

| Field | Value |
|-------|--------|
| Endpoint | `cardly.clwi8c0q49pk.us-east-2.rds.amazonaws.com` |
| Port | `5432` |
| Database | `cardly` |
| Master username | `postgres` |
| Master password | stored in `/opt/cardly/.env.prod` on EC2 (also known to user) |

**RESOLVED (2026-06-16):** RDS SG fixed. Database `cardly` was missing on RDS — created with `deploy/create-cardly-db.sh`. Backend now starts and `/api/dashboard` returns `403` without token (expected).

## Runtime config on EC2 (`/opt/cardly/.env.prod`)

User created this file with values below. If missing, recreate on EC2:

```env
DOCKERHUB_USER=hugodfreitas
TAG=v8

SPRING_DATASOURCE_URL=jdbc:postgresql://cardly.clwi8c0q49pk.us-east-2.rds.amazonaws.com:5432/cardly
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=<see .env.prod on EC2 or user>

CARDLY_JWT_SECRET=iN+OHxyW/2saSw5kak6VG9CFlatYzKnWzCAqsILLONFsenRa3XS9gJAgQkGPMKF2
CARDLY_JWT_EXPIRATION_SECONDS=3600
CARDLY_GOOGLE_CLIENT_ID=
CARDLY_CORS_ALLOWED_ORIGINS=https://cardly.hugodefreitas.com.br
```

## What was completed

1. Docker images built and pushed to Docker Hub (`v8`).
2. Files copied to EC2 (`docker-compose.hub.yml`, `.env.prod`) — after fixing SSH key on `scp`.
3. `docker pull` for both images succeeded (individual `docker pull` worked when `docker compose pull` hit intermittent CloudFront DNS timeouts).
4. Cardly stack started after port change to `8082`:

```text
cardly-backend-1    hugodfreitas/cardly-backend:v8    Up    0.0.0.0:8082->8080/tcp
cardly-frontend-1   hugodfreitas/cardly-frontend:v8   Up    0.0.0.0:3000->80/tcp
```

5. **Host nginx vhost** installed on EC2 (`/etc/nginx/sites-available/cardly`, enabled, reloaded). Mirrors Sisges pattern: `/` → `:3000`, `/api` → `:8082`.
6. **Frontend health** confirmed: `curl -I http://127.0.0.1:3000` → `200`; via nginx `Host: cardly.hugodefreitas.com.br` → `200`; external `http://3.130.71.191` with Host header → `200`.

7. **RDS security group** fixed — EC2 can reach PostgreSQL.
8. **Database `cardly`** created on RDS (`CREATE DATABASE cardly`).
9. **Backend healthy** — `curl -I http://127.0.0.1:8082/api/dashboard` → `403` (service up).
10. **TLS** — Certbot succeeded for `cardly.hugodefreitas.com.br` (expires 2026-09-14).

## What was NOT completed (next steps)

1. **End-to-end smoke test** — login, dashboard, friends flow over `https://cardly.hugodefreitas.com.br`.

### Architecture note (corrected)

Sisges production uses **host nginx (80/443) + Let's Encrypt**, proxying to Docker on custom ports. Cardly should follow the same model on the shared EC2. CloudFront is **not** required and was the wrong target in the earlier plan.

## Known issues and workarounds

### Docker Hub pull timeouts

`docker compose pull` sometimes fails with:

```text
lookup production.cloudfront.docker.com: i/o timeout
```

Workaround that worked:

```bash
docker pull hugodfreitas/cardly-backend:v8
docker pull hugodfreitas/cardly-frontend:v8
docker compose -f docker-compose.hub.yml --env-file .env.prod up -d
```

Internet/DNS on EC2 is OK (`curl google.com`, `curl hub.docker.com`, `nslookup production.cloudfront.docker.com` all worked when tested).

### Port 8080 conflict

Sisges uses `8080`. Cardly backend must stay on host port **8082**.

### `docker compose -f` log command failed once

User saw: `unknown shorthand flag: 'f' in -f` (likely typo or compose plugin quirk on slow terminal).

**Prefer direct commands on slow EC2:**

```bash
docker ps
docker logs --tail 80 cardly-backend-1
docker logs --tail 40 cardly-frontend-1
```

Or legacy: `docker-compose -f docker-compose.hub.yml logs --tail 80 backend`

## Next commands for the user (copy-paste, one at a time)

SSH:

```bash
ssh -i <ec2-key.pem> ubuntu@3.130.71.191
cd /opt/cardly
```

Verify containers:

```bash
docker ps
```

Health checks (use short timeouts on slow terminal):

```bash
curl -I --max-time 8 http://127.0.0.1:3000
curl -I --max-time 8 http://127.0.0.1:8082/api/dashboard
```

Expected for API: `401` or `403` without token is OK (service up). `Connection refused` or hang → check backend logs and RDS SG.

Backend logs:

```bash
docker logs --tail 80 cardly-backend-1
```

If DB connection errors, fix RDS SG then:

```bash
docker restart cardly-backend-1
sleep 15
docker logs --tail 80 cardly-backend-1
```

Restart full stack if needed:

```bash
cd /opt/cardly
docker compose -f docker-compose.hub.yml --env-file .env.prod down
docker compose -f docker-compose.hub.yml --env-file .env.prod up -d
docker ps
```

## Host nginx + DNS + TLS (in progress)

Nginx vhost is already on EC2. Template in repo: `cardly-docs/deploy/cardly-nginx.conf`.

| Path | Upstream |
|------|----------|
| `/` | `http://127.0.0.1:3000` (Cardly frontend container) |
| `/api` | `http://127.0.0.1:8082` (Cardly backend container) |

### DNS (your registrar / Route53)

Add an **A record**:

```text
cardly.hugodefreitas.com.br  →  3.130.71.191
```

### TLS (after DNS resolves)

On EC2:

```bash
sudo certbot --nginx -d cardly.hugodefreitas.com.br
```

Certbot will extend the vhost with HTTPS (same as Sisges).

Frontend image was built with `EXPO_PUBLIC_API_BASE_URL=https://cardly.hugodefreitas.com.br`, so same-origin `/api` routing via nginx is correct.

## External smoke test (optional, before DNS)

From user machine (if EC2 SG allows):

```powershell
curl -I http://3.130.71.191:3000
curl -I http://3.130.71.191:8082/api/dashboard
```

## Local republish (if env/API URL changes)

```powershell
cd C:\projects\cardly
$env:DOCKERHUB_USER='hugodfreitas'
$env:TAG='v8'
$env:EXPO_PUBLIC_API_BASE_URL='https://cardly.hugodefreitas.com.br'
.\scripts\docker-hub-publish.ps1
```

Then on EC2: `docker pull ...` and `docker compose ... up -d`.

## Related docs

- Feature completion log: `cardly-docs/already-done.md` (v8 app changes)
- Deploy guide: `cardly-docs/deploy/aws-cardly-v8.md`
- Removed: `cardly-docs/deploy/deploy-setup.md` (credentials moved to EC2 `.env.prod` only)

## Open questions for user (when resuming)

1. Manual app smoke test: register/login, dashboard, friends on `https://cardly.hugodefreitas.com.br`.
2. If a partial CloudFront distribution was created earlier, it can be deleted (not needed).
