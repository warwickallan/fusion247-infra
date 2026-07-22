# Honcho Pilot — Acceptance Result

**Date:** 2026-07-22 · **SDK:** honcho-ai v2.2.0 · **Workspace:** `Fusion247` · Managed Honcho Cloud (api.honcho.dev)

## Result: ✅ PASS
Ran `scripts/honcho/honcho_pilot.py` (in an isolated `python:3.12-slim` container on fusion247-core).

1. **Ingest** — 5 *selected* items only (decisions, preferences, a correction, cost target). ~408 chars / ~102 tokens.
2. **Process** — Honcho built the peer representation.
3. **Retrieve (fresh query)** — `peer.chat("...preferences and key Fusion247 decisions?")` returned an accurate synthesis of the ingested facts.
4. **Show context** — see status report; correctly recalled delegation preference, £10–15/mo target, Hetzner CX33/Nuremberg, ops/dev Supabase refs.
5. **Not canonical** — Honcho is a *retrieval/memory* layer, subordinate to MyPKA (Supabase + GitHub remain canonical). The pilot wrote nothing to MyPKA.
6. **Token meter** — this run ingested ~102 tokens (negligible).
7. **Cost** — trivially small against the **$100 free credit** (to be re-confirmed live in the dashboard).
8. **Guardrail** — content policy enforced in the adapter (only decisions/preferences/corrections/summaries; no raw logs, diffs, tool output, sensitive data). Spend targets: alert >£2/mo, stop >£3/mo without approval.

## Content policy (enforced by the adapter)
**Allowed:** synthetic test conversations, agreed architectural decisions, working preferences, explicit corrections, compact accepted summaries, non-sensitive conclusions.
**Excluded:** raw Tower audit history, terminal output, code diffs, health/family/employer info, credentials, raw email, sensitive docs, large assistant responses, status narration.

## Next
- Build a small **usage meter** (log ingested tokens per run into the infra repo or Supabase) and wire the >£2 alert / >£3 stop.
- Do **not** auto-connect every Larry/Tower turn yet — prove selective value first (this pilot is step one).
