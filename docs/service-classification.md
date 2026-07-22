# Service Classification

## Current (as-built) — cloud engine room, 2026-07-22
What is **actually deployed** on `fusion247-core` (cloud runtime, Class A) vs. what remains a **Yoga-local bridge** (Class B) or **external managed** (Class C). This supersedes the Phase 0 draft below for current state.

| Service | Class | Where it runs now | Notes |
|---|---|---|---|
| Directus (staging) | A | **cloud** (Coolify) | reads ops Supabase; local Directus still runs (not cut over) |
| Redis | A | **cloud** | deployed; not yet wired to Directus |
| Neo4j | A | **cloud** | derived graph; named volume; acceptance loaded |
| LightRAG | A | **cloud** | retrieval; named volume; pilot passed |
| Capture/Unified Gateway (Telegram) | B→A | **Yoga (unchanged)** | migration is **Larry-owned**; single-poller cutover pending |
| Tower loop / Tower watch | B | **Yoga (unchanged)** | reads local session files → stays local bridge |
| Contract-apply / YouTube capture | TBD | **Yoga (unchanged)** | classify at cutover |
| Managed Supabase / GitHub / Honcho / Telegram / OpenAI | C | external | canonical / managed |

> The cloud services are **additive**; no Yoga service was stopped or moved. Cutovers are Larry-owned.

---

## Historical baseline — DRAFT (Phase 0)

Observed read-only on the Yoga 2026-07-22 (kept as the Phase 0 inventory). All current services run from `C:\Fusion247PKA`
(secrets in `C:\.fusion247\*.env`). This was the first draft; **nothing was stopped, moved or modified** at Phase 0.

## Legend
- **A = Cloud Runtime** (target: CX33) · **B = Local Bridge** (stays on Yoga) · **C = External Managed**

## Current running processes

| Service | Path / entry | Port | Class | Notes / migration | Duplicate risk |
|---|---|---|---|---|---|
| **Directus (local)** | `wp-d-proof/directus/cli.js start` (**v11.17.4**) | 8074 | A | Rebuild pinned image → Coolify; keep Directus auth; exclude retired `mypka-cockpit` path. Connects to managed Supabase. | Low (schema in Supabase) |
| **Capture / Unified Gateway** | `fusion-capture-gateway/src/live/liveRunner.js` | — | A | Telegram **long-poll** listener. Env keys: `TELEGRAM_BOT_TOKEN`, `AUTHORISED_TELEGRAM_USER_ID`, `WORKER_ID`, `DATABASE_URL`, `DATABASE_SSL_CA_FILE`, `CLICKUP_TOKEN`. | **HIGH — never run two pollers on one bot token.** Cut over singly. |
| **Tower loop watcher** | `control-plane/tower-loop/watcher.mjs` | — | **B** | Uses `pg` (Supabase) **and local fs** (reads local session state). Stays a tiny Yoga-local bridge. | Medium — single instance |
| **Tower watch** | `bin/tower-watch.js` | — | B | Tower audit; reads local Claude turns → Supabase; silent on Telegram. | Single instance |
| **Contract apply** | `control-plane/wp-d-proof/apply-contract-command.mjs --watch=15` | — | A? | Control-plane worker; confirm local deps before classifying. | TBD |
| **YouTube capture (TubeAIR)** | `hub/youtube/watch-captures.mjs --watch=30` | — | A | Cloud-portable capture stage; confirm local file deps. | TBD |
| **Tower mergeCheck (PR #58)** | `C:\Fusion247PKA-tower/…/tower-loop/mergeCheck.mjs` | — | B | **Live Codex QA / merge activity — DO NOT DISTURB.** Invokes local Codex; stays local. | N/A (deliberate invocation) |

## External managed (Class C)
Managed Supabase (canonical DB) · GitHub · managed Honcho Cloud · Telegram · OpenAI/Anthropic/embedding APIs.

## Open confirmations before migration
- Directus cockpit extension build source (Phase 6).
- Full local-dependency check for Contract-apply and YouTube capture (are they truly cloud-portable?).
- Gateway cursor/offset persistence & receipt path (Phase 7 single-poller cutover).
