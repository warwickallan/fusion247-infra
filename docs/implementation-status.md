# Implementation Status

**Updated:** 2026-07-22 · **Branch:** `infra/hetzner-engine-room`

| Field | Value |
|---|---|
| **Current phase** | Multi: Directus/Redis/Neo4j deployed; **Honcho pilot PASSED**; LightRAG + cockpit/prod cutover remain |
| **Current human gate** | None pending (GATE 3B/GitHub only when private repo needed) |
| **Current blocker** | None |
| **Next automatic action** | Inspect managed Supabase **read-only**, then deploy Directus 11.17.4 → Staging |
| **Recurring-cost estimate** | ~€10.69/mo net (~£9–£11) — CX33 + IPv4 + backups |
| **VPS resource use** | ~1.1 GB RAM used of 7.6 (Coolify + Redis); disk ~4%; swap unused |

## Deployed services (fusion247-core)
| Service | Coolify UUID | Image | Status |
|---|---|---|---|
| Redis | `s4mlb36rih6gil5pmzm31dj4` | redis:7.2 | ✅ healthy (private net, auth). Password held in Coolify only. |
| Directus (staging) | `ljiw2zciyel9a8gxiu9dvqz7` | directus/directus:11.17.4 | ✅ healthy; reads **ops** Supabase (`directus_sys,asdair,cockpit`); tailnet-only `http://100.101.240.85:8055`. Cache/rate-limiter off for now; cockpit extension not yet built in. |
| Neo4j | `akdzfjqdpt8ivip4z202dz41` | neo4j:5.26-community | ✅ healthy; Cypher over Bolt OK; tailnet-only `http://100.101.240.85:7474` (browser) + 7687 (bolt). Heap 1G / pagecache 512M. Creds off-repo. **TODO: persistent volume before real ingestion; acceptance dataset (Karpathy packet) pending.** |

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
