# Architecture Decision Record — Fusion247 Cloud Engine Room

**Status:** Accepted · **Date:** 2026-07-22 · **Supersedes:** Yoga-hosting / Hostinger / CX43 plans

## Decision

| # | Decision |
|---|---|
| 1 | **Yoga is the operations centre & local bridge** — not the production engine room. |
| 2 | **Hetzner CX33 (`fusion247-core`) is the cloud engine room** — Ubuntu 24.04, 4 vCPU / 8 GB / 80 GB. |
| 3 | **Managed Supabase remains canonical** for operational data (not migrated, not self-hosted). |
| 4 | **GitHub remains canonical** for code, infra and MyPKA history. |
| 5 | **Honcho is managed cloud** — selective conversational memory, subordinate to MyPKA, never canonical. |
| 6 | **Neo4j is a derived graph** — rebuildable, not canonical. |
| 7 | **LightRAG is retrieval only** — not canonical. |
| 8 | **No self-hosted Supabase.** |
| 9 | **No local LLM inference on the CX33** — external model/embedding APIs only. |
| 10 | **No removable-disk runtime dependency** — external SSD is backup/cold storage only (USB 3.0, 5 Gbps). |
| 11 | **Privacy:** no public admin surface; access private via Tailscale. |
| 12 | **Spending:** target £10–£15/month; per-component meters and hard gates. |

## Why not host on the Yoga
Preflight (`C:\ClaudeJobs\PREFLIGHT-2026-07-22-Fusion247-Runtime.md`) verdict was REDUCED-SCOPE GO,
limited by **12 GB soldered RAM** and single-machine availability (a Yoga reboot/scan must not take
production down). The CX33 gives dependable daily availability independent of the Yoga.

## Consequences
- The Yoga keeps only genuine **local bridges** (processes that read local Claude/Codex/Obsidian state).
- Everything cloud-portable moves to the CX33 under Coolify + Docker Compose.
- Reconstruction is always possible from GitHub + managed Supabase.
