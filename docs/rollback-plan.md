# Rollback Plan / Position

**As of 2026-07-22 (session banked).**

## Current rollback position: SAFE — nothing to roll back
No live product cutover was performed. All existing Yoga services (local Directus, capture-gateway/Telegram, Tower watchers) run **unchanged**. The cloud engine room is **additive** and isolated:
- Cloud Directus is a **second read instance** on the ops Supabase (same version, no migrations, no flows) — removing it changes nothing on the source.
- Neo4j / LightRAG hold only **derived/rebuildable** data.
- No Telegram poller was moved (no duplicate-poller risk).

## To fully undo the cloud engine room
1. In Coolify, stop/delete the apps (Directus, Neo4j, LightRAG) + Redis. Nothing on the ops Supabase or the Yoga is affected.
2. To stop billing entirely: delete `fusion247-core` in Hetzner (server ID 154049483) + its firewall. Managed Supabase/GitHub/Honcho are external and untouched.
3. Remove the tailnet node in the Tailscale admin console.

## Per-service rollback
- **Directus (cloud):** delete the Coolify app; local Directus already serves prod. No data change.
- **Neo4j / LightRAG:** delete apps; rebuild from `scripts/neo4j/acceptance.cypher` / re-ingest if needed.
- **Firewall/SSH:** Hetzner console is the always-available recovery path if tailnet SSH is lost.

## Pending cutovers (Larry-owned) — rollback defined at cutover time
Telegram single-poller migration and Directus production cutover are **not started**; their rollback (keep local poller/Directus running, one active instance) will be defined when Larry performs them.
