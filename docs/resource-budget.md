# Resource Budget — fusion247-core (CX33, 8 GB RAM / 4 vCPU / 80 GB)

**Updated:** 2026-07-22 · Starting targets; tune by measurement (Phase 5).

## RAM allocation (target)
| Component | RAM cap | Notes |
|---|---|---|
| Ubuntu + Docker + Coolify | ~1.5–2.0 GB | measured Coolify idle ≈ 1.3 GB |
| Directus | 768 MB | `mem_limit`, connects to managed Supabase |
| Redis | 256 MB | `maxmemory 256mb`, `allkeys-lru` |
| Gateways / listeners (combined) | 512 MB | Telegram + Unified Gateway |
| Neo4j (container total) | ~2.0 GB | heap + pagecache tuned under this |
| LightRAG | ~1.0 GB | sequential ingestion only |
| Monitoring + aux workers | 512 MB | |
| Filesystem cache / burst headroom | remainder | keep idle < 75% |

Sum of caps ≈ 5.5–6.0 GB app + ~2 GB host → fits 8 GB **only if not all peak at once**.
LightRAG + Neo4j heavy ops must not run concurrently at full tilt (sequential queues).

## Acceptance thresholds (Phase 5)
- Idle host memory **< 75%**; peak ordinary retrieval **< 90%**.
- No OOM-killed services; no sustained heavy swap.
- Directus stays responsive during one controlled LightRAG ingestion.
- Neo4j query stays responsive; disk **< 70%** at handover.

If tuning can't meet these: do **not** auto-upgrade — show measured failure + exact CX43 cost delta, stop at a human gate.

## Enforcement (per service)
`mem_limit`, health checks, `restart: unless-stopped`, log rotation (`max-size`/`max-file`),
sequential queues for ingestion, disk/memory alerts (monitoring phase).
