# Implementation Status

**Updated:** 2026-07-22 · **Branch:** `infra/hetzner-engine-room`

| Field | Value |
|---|---|
| **Status** | ✅ **Infra follow-on complete** (2026-07-22): Neo4j acceptance, backups+restore, reboot/recovery, independence, docs, handover PR |
| **Deployed & proven** | Coolify + **Redis, Directus (staging), Neo4j, LightRAG** live; **Honcho + LightRAG pilots PASSED**; **VPS reboot auto-recovery PASSED** |
| **Acceptance** | **13 of 15 proofs** met (1,2,3,6,7,8,9,10,11,12,13,14,15). Remaining **4 & 5** (Telegram input+receipt+record) depend on the Telegram gateway migration = **Larry-owned**. |

## Infra follow-on session (2026-07-22) — completed
1. ✅ **Neo4j acceptance** — idempotent dataset (`scripts/neo4j/acceptance.cypher`); real **4-hop** query proven; 860 MiB.
2. ✅ **Backups + restore rehearsal** — encrypted Coolify-config bundle → Yoga; non-destructive restore verified (64 tables/3 apps/86 env-vars).
3. ✅ **VPS reboot + auto-recovery** — all services back in ~40s, Neo4j data survived, no manual steps (`independence-evidence.md`).
4. ✅ **Yoga-independence evidence** — cloud recovered with zero Yoga involvement.
5. ✅ **Docs + handover PR** — rebuild-runbook, rollback-plan, secrets-model, cost-model, independence-evidence.
6. ✅ **Larry handover** — `larry-handover.md`.
| **Current blocker** | None |
| **Recurring-cost estimate** | ~€10.69/mo net (~£9–£11) infra + trivial API (LightRAG pilot = **$0.04**) + Honcho on $100 credit → within £10–15 target |
| **VPS resource use** | ~2.4 GB RAM used of 7.6 (Coolify + 4 services); disk ~5%; swap unused |

## ⛔ Explicitly NOT started (owner decision — coordinate with Larry)
Do **not** begin these on an infra-only resume; they affect live routing, MyPKA, Obsidian, Telegram and the product operating model:
- Unified Gateway / **Telegram single-poller migration**
- **Directus cockpit extension + production cutover**

## ▶ Next resumed INFRA session — complete ONLY these
1. **Neo4j acceptance dataset** + real multi-hop query proof (with persistent volume first).
2. **Backups** + non-destructive **restore rehearsal**.
3. **VPS reboot** + automatic-recovery test (GATE 6 before reboot).
4. Final **Yoga-independence evidence**.
5. **Infrastructure docs + handover PR** (do not merge without Warwick's QA).
6. **Concise Larry handover**: live services + private access routes; deploy/health checks; where secrets live (no values); resource limits + measured usage; backup/recovery process; incomplete product cutovers; exact rollback position.

## 👤 Larry-owned follow-on work (not infra)
- Unified Gateway / Telegram single-poller migration
- Directus cockpit extension + production cutover
- ObsidiWikAi production integration
- Neo4j ontology + governed graph writes
- LightRAG production ingestion behaviour
- Managed Honcho integration into Larry context
- n8n architecture decision + any later visual-routing build

## Deployed services (fusion247-core)
| Service | Coolify UUID | Image | Status |
|---|---|---|---|
| Redis | `s4mlb36rih6gil5pmzm31dj4` | redis:7.2 | ✅ healthy (private net, auth). Password held in Coolify only. |
| Directus (staging) | `ljiw2zciyel9a8gxiu9dvqz7` | directus/directus:11.17.4 | ✅ healthy; reads **ops** Supabase (`directus_sys,asdair,cockpit`); tailnet-only `http://100.101.240.85:8055`. Cache/rate-limiter off for now; cockpit extension not yet built in. |
| Neo4j | `akdzfjqdpt8ivip4z202dz41` | neo4j:5.26-community | ✅ healthy; Cypher over Bolt OK; tailnet-only `http://100.101.240.85:7474` (browser) + 7687 (bolt). Heap 1G / pagecache 512M. Creds off-repo. **TODO: persistent volume before real ingestion; acceptance dataset (Karpathy packet) pending.** |
| LightRAG | `g327xy3z5zv3qzrf75htbkse` | ghcr.io/hkuds/lightrag v1.5.4 (digest pinned) | ✅ **pilot PASSED** — per-role OpenAI models; ingested 1 packet (23 entities/25 relations); semantic + multi-hop queries answered **with provenance**; Directus stayed healthy. Tailnet-only :9621. OpenAI key in Coolify only. See `lightrag-pilot.md`. |

### Directus staging notes
- Vanilla directus:11.17.4 (no flows exist in DB → zero duplicate-processing risk; verified `directus_flows=0`).
- Real data present: `asdair.regulars`=91, orders=2, products=11.
- Local Directus left running untouched (both share the ops DB; safe — same version, no migrations).
- **Next:** build cockpit Vue extension into a custom image (needs Fusion247PKA / GATE 3B), then production cutover (GATE 4 for prod secrets).

## Server record — `fusion247-core`
| Field | Value |
|---|---|
| Server ID | 154049483 |
| Public IPv4 | 178.104.171.240 |
| IPv6 | 2a01:4f8:1c16:d697::/64 |
| Type / OS | CX33 (4 vCPU / 8 GB / 80 GB) · Ubuntu 24.04 |
| Region | Nuremberg (nbg1), DE |
| Backups | Enabled (window 10–14 UTC) |
| SSH key | `yoga-fusion247-core` (ED25519), private key local-only on Yoga |
| Created | 2026-07-22 17:40 UTC |
| Monthly max | ≈ €10.69 net |

## Completed
- **Phase 0** — Orientation: repo bootstrapped, services inventoried & classified, docs committed.
- **Phase 1** — Hetzner: account (Warwick), project `Fusion247`, R/W API token (secured off-repo),
  ED25519 key generated + registered, **CX33 `fusion247-core` created in Nuremberg with backups**,
  cost approved (~£9–£11/mo).
- **Phase 2** — Secure access: key SSH proven; timezone Europe/London; security updates applied
  (kernel reboot pending → deferred to Phase 13 gate); 2 GB swap @ swappiness 10; **Tailscale joined**
  (`100.101.240.85`), verified Yoga↔server (ping + tailnet key-SSH); Tailscale SSH intercept disabled;
  `access-model.md` written.
- **Phase 3 (partial)** — Coolify 4.1.2 installed (Docker 29.6.2); admin registered (Warwick);
  reachable **private over tailnet, blocked publicly** (Hetzner firewall). **Fusion247 project** +
  Production/Staging environments created via API; localhost target usable (`host.docker.internal`).
  **SSH hardened to tailnet-only** (public 22 removed from firewall). Coolify API token secured off-repo.
  Remaining: connect GitHub (GATE 3B), log rotation.

## Guardrails in force
- Target £10–£15/month total. Infra ~£10.69/mo net; Honcho + LightRAG meters still to come (each ≤£2, gated).
- No secrets committed (public repo). API token + env secrets live only under `C:\.fusion247\`.
- `C:\Fusion247PKA` and existing services remain read-only until an approved cutover.
- No public admin surface; access will be private via Tailscale (Phase 2).

## Next: Phase 2 — Secure initial access
Prove SSH key login → set timezone → apply security updates → configure modest swap → install Tailscale →
**GATE 2 (authorise `fusion247-core` on the tailnet)** → write `docs/access-model.md`.
