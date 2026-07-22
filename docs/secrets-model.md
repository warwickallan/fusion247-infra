# Secrets Model (locations only — no values)

**Rule:** no secrets in Git (repo is public). Values live only in Coolify and in `C:\.fusion247\*.env` on the Yoga.

## Where each secret lives
| Secret | Location | Notes |
|---|---|---|
| Hetzner API token | `C:\.fusion247\hetzner.env` | Read&Write, project Fusion247 |
| Coolify API token | `C:\.fusion247\coolify.env` | root scope |
| Neo4j password | `C:\.fusion247\neo4j.env` + Coolify env | `NEO4J_AUTH` |
| LightRAG server key | `C:\.fusion247\lightrag.env` + Coolify env | `X-API-Key` for the API |
| **OpenAI API key** | **Coolify env only** | project "Fusion247 LightRAG"; per Warwick, not stored locally |
| Honcho API key | `C:\.fusion247\honcho.env` | managed Honcho Cloud |
| Redis password | Coolify (managed db) | auto-generated |
| Directus KEY/SECRET/DB | Coolify env (staging) | sourced from local Directus `.env` |
| Backup passphrase | `C:\.fusion247\backup-key.env` | encrypts recovery bundle |
| SSH private key | `~/.ssh/hetzner_fusion247_ed25519` | never committed |

## Guards in place
- `.gitignore` blocks `*.env`, `*.key`, `id_*`, `*token*`, `*secret*`, backups, bundles.
- Every commit runs a secret-pattern scan before committing.
- Directus/LightRAG logs are redacted (`sk-***`) when surfaced.
- Coolify + services are private (tailnet-only, Hetzner firewall) — no public secret exposure surface.
