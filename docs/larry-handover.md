# Larry Handover — Fusion247 Cloud Engine Room

**From:** infrastructure session 2026-07-22 · **To:** Larry (product/cutover work)
**Repo:** `warwickallan/fusion247-infra` @ `infra/hetzner-engine-room` · live state in `implementation-status.md`.

## 1. Live services + private access routes
Host **`fusion247-core`** (Hetzner CX33, Nuremberg). Tailnet **`100.101.240.85`** (tailnet `warwickjunior2011@`). **All private** — public admin blocked by Hetzner firewall; SSH is tailnet-only (`~/.ssh/hetzner_fusion247_ed25519`).

| Service | Access (tailnet only) | Notes |
|---|---|---|
| Coolify | `http://100.101.240.85:8000` | deploy/health/logs/restart/env |
| Directus (staging) | `http://100.101.240.85:8055` | reads **ops** Supabase `directus_sys,asdair,cockpit`; standard UI (no cockpit ext yet) |
| Neo4j | `http://100.101.240.85:7474` (browser), `:7687` (bolt) | derived graph; acceptance data loaded |
| LightRAG | `http://100.101.240.85:9621` | per-role OpenAI models; `X-API-Key` auth |
| Redis | internal Docker net | cache/queue |

## 2. Deployment + health checks
- **Deploy/manage** via Coolify (UI or API token in `C:\.fusion247\coolify.env`). Apps are docker-image type; Redis is a managed db.
- **Health:** Redis `redis-cli -a $REDIS_PASSWORD ping`→PONG; Directus `GET /server/health`→200; LightRAG `GET /health`→200; Neo4j `cypher-shell … "MATCH (n) RETURN count(n)"`.
- Verified auto-recovery after a VPS reboot (~40s, no manual steps) — see `independence-evidence.md`.

## 3. Secrets (locations only — see `secrets-model.md`)
Never in Git. In **Coolify** + `C:\.fusion247\*.env` on the Yoga. **OpenAI key is in Coolify only** (project "Fusion247 LightRAG"). Backup bundle encrypted; passphrase in `C:\.fusion247\backup-key.env`.

## 4. Resource limits + measured usage (CX33 = 8 GB / 4 vCPU / 80 GB)
- Caps: Directus 768M, Redis 256M, Neo4j heap 1G/pagecache 512M, LightRAG concurrency `MAX_ASYNC_LLM=4` (per-role 2). Budgets in `resource-budget.md`.
- **Measured:** idle with all services ≈ **2.3–2.4 GB / 7.6 GB** used; disk ~5%; swap unused. Comfortable headroom.

## 5. Backup / recovery
- Hetzner automatic backups (server level) + **encrypted Coolify-config bundle** (`scripts/backup.sh`), pulled to `C:\.fusion247\backups\`. **Restore rehearsal passed** (64 tables/3 apps/86 env-vars into throwaway pg, non-destructive).
- Full rebuild steps: `rebuild-runbook.md`. Neo4j/LightRAG are rebuildable (Cypher script / re-ingest).

## 6. Incomplete product cutovers (NOT started — Larry-owned, coordinate)
These affect live routing, MyPKA, Obsidian, Telegram, product operating model:
- **Unified Gateway / Telegram single-poller migration** — never run two pollers on one bot token; cut over singly (deploy cloud with polling off → prove → stop local → enable cloud → prove one instance + one receipt + no dup → keep rollback).
- **Directus cockpit extension + production cutover** — build cockpit Vue ext from private `Fusion247PKA` into a custom image (needs GitHub gate 3B), prod secrets (gate 4), then cutover.
- **ObsidiWikAi production integration**, **Neo4j ontology + governed graph writes**, **LightRAG production ingestion behaviour**, **managed Honcho integration into Larry context**, **n8n architecture decision + visual routing**.

## 7. Exact rollback position
**SAFE — nothing to roll back.** No live cutover done; all Yoga services run unchanged; cloud is additive/isolated. Full undo + per-service rollback in `rollback-plan.md`. Hetzner console is the always-available recovery path.
