# Rebuild Runbook — replacement server recovery (as-built)

Reconstructs the **accepted live deployment** (2026-07-22), not a hypothetical one. No hidden steps.
**Canonical sources:** GitHub `warwickallan/fusion247-infra` + managed Supabase (ops/dev).
**Secrets:** never in Git — in Coolify + `C:\.fusion247\*.env` on the Yoga; recovery bundle is encrypted.
**As-built definitions:** `compose/core.compose.yaml` (Redis, Directus) + `compose/knowledge.compose.yaml` (Neo4j, LightRAG).

## 0. Prerequisites (on the Yoga)
- `C:\.fusion247\*.env` (hetzner, coolify, neo4j, lightrag, honcho, backup-key). **OpenAI + LightRAG TOKEN_SECRET are Coolify-only** — re-mint if lost.
- Latest encrypted bundle `C:\.fusion247\backups\*.tar.gz.enc` (+ passphrase in `backup-key.env`).
- SSH key `~/.ssh/hetzner_fusion247_ed25519`.

## 1. Provision + harden
- Hetzner → project **Fusion247** → **CX33**, Ubuntu 24.04, Nuremberg, IPv4, backups on, name `fusion247-core`; add SSH public key.
- Network firewall (inbound: **22/tcp**, **41641/udp** Tailscale, **icmp**; deny rest). Timezone Europe/London; 2 GB swap @ swappiness 10; `apt-get update && upgrade`.
- Install Tailscale, `tailscale up --hostname=fusion247-core`, authorise; then **remove public 22** from the firewall (SSH tailnet-only).

## 2. Coolify + restore config
- `curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash`.
- Restore Coolify config DB from the encrypted bundle (recovers projects, apps, env vars **and persistent-volume definitions**): `openssl enc -d -aes-256-cbc -pbkdf2 -in <bundle>.tar.gz.enc -pass env:BPASS | tar xz`; restore `coolify-db.sql` into Coolify's Postgres. (Or re-create apps from §3.)

## 3. Services (Coolify) — as-built
Re-create in project **Fusion247**. Set env values from Coolify/off-repo store (never Git):
- **Redis** — managed db, image `redis:7.2`, `maxmemory 256mb`/`allkeys-lru`, auth, private net.
- **Directus** `directus/directus:11.17.4` — env from `core.compose.yaml`; DB → ops Supabase pooler, `DB_SEARCH_PATH=directus_sys,asdair,cockpit`; **CACHE_ENABLED=false**, `NO_UPDATE_NOTIFIER=1`; `DB_SSL__REJECT_UNAUTHORIZED=false` **(staging only — prod blocker)**; host port 8055; tailnet-only.
- **Neo4j** `neo4j:5.26-community` — heap 1G/pagecache 512M; **persistent storage `neo4j-data` → `/data`**; ports 7474/7687. Then load `scripts/neo4j/acceptance.cypher`.
- **LightRAG** `ghcr.io/hkuds/lightrag@sha256:de09cd75…` (v1.5.4) — per-role models (`knowledge.compose.yaml`); OpenAI key + `TOKEN_SECRET` **into Coolify only**; **persistent storage `lightrag-data` → `/app/data/rag_storage`**; port 9621; then re-ingest packet(s).

### Persistent volumes (Coolify API)
`POST /api/v1/applications/{uuid}/storages` with `{"type":"persistent","name":"<vol>","mount_path":"<path>"}`, then redeploy. Volumes: `neo4j-data`→`/data`, `lightrag-data`→`/app/data/rag_storage`. First redeploy initialises the volume (empty) → reload data → subsequent redeploys persist it (proven).

## 4. Verify
- Health: Redis PING; Directus `/server/health` 200; Neo4j Cypher count; LightRAG `/health` 200.
- **Persistence:** redeploy Neo4j + LightRAG → confirm Neo4j nodes + LightRAG index survive (proven 2026-07-22).
- Reboot once → confirm auto-recovery (`independence-evidence.md`).
- `BPASS=… bash scripts/backup.sh` → pull the encrypted bundle to the Yoga.
