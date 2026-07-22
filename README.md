# fusion247-infra

Infrastructure-as-documentation for the **Fusion247 cloud engine room**.

## Architecture (settled)

- **Yoga (Lenovo C930, `warwick-yoga`)** — operations centre & local bridge. Claude/Larry/Codex
  workstation, Git working copy, Tailscale admin, recovery console. **Not** the production engine room.
- **Hetzner CX33 (`fusion247-core`)** — the cloud engine room. Hosts Coolify, Directus, Redis,
  Unified Gateway + cloud-portable Telegram listeners, Neo4j (derived), LightRAG (retrieval),
  monitoring, scheduled workers.
- **Managed Supabase** — canonical operational database (not migrated, not self-hosted).
- **GitHub** — canonical code / infra / MyPKA history.
- **Managed Honcho Cloud** — selective conversational memory (subordinate to MyPKA, never canonical).
- External model/embedding APIs only — **no local LLM inference** on the CX33.

## Guardrails

- Target cost **£10–£15/month** initially (excludes existing ChatGPT/Claude subscriptions).
- No secrets in Git (this repo is **public**). Secrets live only in Coolify env / protected stores.
- No public administration surface — access is private via Tailscale.
- No self-hosted Supabase; no removable-disk runtime dependency.

## Docs

| Doc | Purpose |
|---|---|
| `docs/implementation-status.md` | Live status: phase, gate, blocker, next action, cost |
| `docs/service-classification.md` | Cloud runtime vs local bridge vs external managed |
| `docs/architecture.md` | Architecture decision record |

Working branch: **`infra/hetzner-engine-room`** (do not work directly on `main`).
