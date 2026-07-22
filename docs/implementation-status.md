# Implementation Status

**Updated:** 2026-07-22 · **Branch:** `infra/hetzner-engine-room`

| Field | Value |
|---|---|
| **Current phase** | Phase 0 → Phase 1 boundary |
| **Current human gate** | **GATE 1A — Hetzner account** (pending) |
| **Current blocker** | None |
| **Next automatic action** | On GATE 1A completion: create `Fusion247` project, stage CX33 config, generate ED25519 SSH key, present GATE 1B (server cost) |
| **Recurring-cost estimate** | £0 (nothing chargeable created yet) |
| **VPS resource use** | n/a (no server yet) |

## Completed — Phase 0 (Reset & Orientation)
- ✅ Read Yoga preflight report (REDUCED-SCOPE GO; 12 GB soldered RAM is the limiter → cloud engine room chosen).
- ✅ Confirmed **no** production Docker/Coolify on the Yoga; nothing to stop, nothing removed.
- ✅ Confirmed repo: `C:\fusion247-infra` (was empty) + remote `github.com/warwickallan/fusion247-infra` (empty, **public**).
- ✅ Initialised git; baseline on `main`; created working branch `infra/hetzner-engine-room`.
- ✅ Inventoried running Fusion247 processes & ports (see `service-classification.md`).
- ✅ Identified local **Directus 11.17.4** (port 8074).
- ✅ Identified Telegram listener = capture-gateway (single bot token, authorised-user gate, worker-id dedupe).
- ✅ Identified Tower watcher deps (Supabase `pg` + local fs → local bridge).
- ✅ First service-classification draft written.

## Guardrails in force
- Target £10–£15/month. No chargeable resource without a shown cost breakdown + explicit approval.
- No secrets committed (public repo). Secrets stay in `C:\.fusion247\*.env` / Coolify only.
- `C:\Fusion247PKA`, existing Directus/gateway/Tower, Supabase schemas = **read-only** until an approved cutover.
- No public admin surface; access private via Tailscale.

## Next: Phase 1 — Hetzner account & server creation
Navigate Warwick to Hetzner Cloud, present GATE 1A (account), then stage CX33 and present GATE 1B (cost) **before** creating anything chargeable.
