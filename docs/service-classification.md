# Service Classification — DRAFT (Phase 0)

Observed read-only on the Yoga 2026-07-22. All current services run from `C:\Fusion247PKA`
(secrets in `C:\.fusion247\*.env`). This is a first draft; each row is confirmed/refined before its
migration phase. **Nothing has been stopped, moved or modified.**

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
