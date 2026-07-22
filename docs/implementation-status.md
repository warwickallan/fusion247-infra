# Implementation Status

**Updated:** 2026-07-22 · **Branch:** `infra/hetzner-engine-room`

| Field | Value |
|---|---|
| **Status** | ✅ Engine room live; **handover-quality correction pass applied** (PR #1 review) |
| **Deployed & proven** | Coolify + **Redis, Directus (staging), Neo4j, LightRAG** live; **Honcho + LightRAG pilots PASSED**; **reboot + redeploy persistence PASSED** |
| **Acceptance** | **13 of 15** proofs (1,2,3,6,7,8,9,10,11,12,13,14,15). Remaining **4 & 5** (Telegram input→receipt→record) depend on the Telegram gateway migration = **Larry-owned**. |
| **Blocker** | None (infra). Prod cutover blocker noted: Directus `DB_SSL__REJECT_UNAUTHORIZED=false` is **staging-only**. |
| **Cost** | ~€10.69/mo net (~£9–£11) infra + LightRAG pilot **$0.04** + Honcho on $100 credit → within £10–15. |
| **Resource use** | ~2.2–2.4 GB RAM of 7.6; disk ~5%; swap unused. |

## Deployed services (fusion247-core) — as-built
Definitions: `compose/core.compose.yaml` (Redis, Directus) · `compose/knowledge.compose.yaml` (Neo4j, LightRAG). Secrets in Coolify/off-repo only.

| Service | Coolify UUID | Image | As-built status |
|---|---|---|---|
| Redis | `s4mlb36rih6gil5pmzm31dj4` | redis:7.2 | ✅ healthy; managed db, auth, private net. Not yet wired to Directus. |
| Directus (staging) | `ljiw2zciyel9a8gxiu9dvqz7` | directus/directus:11.17.4 | ✅ healthy; reads **ops** Supabase (`directus_sys,asdair,cockpit`); tailnet `:8055`; **cache/rate-limiter OFF**; `DB_SSL__REJECT_UNAUTHORIZED=false` **(staging-only — PROD CUTOVER BLOCKER)**; cockpit ext not built in. |
| Neo4j | `akdzfjqdpt8ivip4z202dz41` | neo4j:5.26-community | ✅ healthy; **acceptance loaded (11 nodes, 4-hop proven)**; **named volume `neo4j-data`→`/data`**; data **survives redeploy** (proven). Tailnet `:7474`/`:7687`. |
| LightRAG | `g327xy3z5zv3qzrf75htbkse` | ghcr.io/hkuds/lightrag@sha256:de09cd75… (v1.5.4) | ✅ pilot PASSED; **named volume `lightrag-data`→`/app/data/rag_storage`**; index **survives redeploy** (proven); **TOKEN_SECRET set** (no guest-mode); per-role OpenAI models; OpenAI key Coolify-only. Tailnet `:9621`. |

## Correction pass (2026-07-22, PR #1 review) — completed
- **Backup security:** `scripts/backup.sh` hardened (`umask 077`, protected temp staging, `-pass env:`, verify-before-success, `chmod 600`, cleanup trap, shreds legacy plaintext dirs). Re-ran backup + **restore rehearsal** (64 tables/3 apps; persistent-volume defs captured).
- **Persistence:** named volumes for Neo4j + LightRAG; **controlled redeploy proved** Neo4j nodes + LightRAG index survive; both health OK; Directus stayed healthy.
- **Service security:** LightRAG `TOKEN_SECRET` set in Coolify only.
- **As-built reproducibility:** `core.compose.yaml` + `knowledge.compose.yaml` reconciled to live; rebuild-runbook reconstructs the live deployment incl. volumes.
- **Docs reconciled:** access-model (tailnet-only SSH), service-classification (as-built section added), kernel/reboot + Neo4j status corrected.
- **Independence proof:** see `independence-evidence.md` (Yoga-off-tailnet check from S21).

## ⛔ Explicitly NOT started (coordinate with Larry)
Unified Gateway / **Telegram single-poller migration** · **Directus cockpit extension + production cutover** — affect live routing, MyPKA, Obsidian, Telegram, product model.

## 👤 Larry-owned follow-on work (not infra)
Telegram single-poller migration · Directus cockpit ext + prod cutover · ObsidiWikAi production integration · Neo4j ontology + governed graph writes · LightRAG production ingestion behaviour · managed Honcho integration into Larry context · n8n architecture decision + visual-routing build.

## Server record — `fusion247-core`
| Field | Value |
|---|---|
| Server ID | 154049483 |
| Public IPv4 | 178.104.171.240 · Tailnet | 100.101.240.85 |
| Type / OS | CX33 (4 vCPU / 8 GB / 80 GB) · Ubuntu 24.04 |
| Region | Nuremberg (nbg1) · Backups | Hetzner auto (10–14 UTC) |
| Kernel / reboot | Rebooted 2026-07-22; running `6.8.0-117`; `reboot-required` **cleared** (pending update was tools-level). |
| SSH | key `hetzner_fusion247_ed25519`; **tailnet-only** (public 22 removed). |
| Firewall | Hetzner id 11352036 — inbound 41641/udp + icmp only. |

## History (Phases 0–3)
- **Phase 0** — orientation: repo bootstrapped, services inventoried/classified.
- **Phase 1** — Hetzner account/project/token, ED25519 key, CX33 created (Nuremberg, backups), cost approved.
- **Phase 2** — key SSH, Europe/London, updates, 2 GB swap, Tailscale joined + verified, `access-model.md`.
- **Phase 3** — Coolify installed; Fusion247 project + Prod/Staging; private via Tailscale + firewall; SSH tailnet-only. Deploys: Redis, Directus, Neo4j, LightRAG; Honcho + LightRAG pilots.

## Guardrails in force
- Target £10–£15/mo. No secrets in Git (public repo) — Coolify + `C:\.fusion247\*.env` only.
- `C:\Fusion247PKA` + existing Yoga services read-only until an approved (Larry-coordinated) cutover.
- No public admin surface; private via Tailscale + Hetzner firewall.
