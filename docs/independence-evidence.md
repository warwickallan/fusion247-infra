# Yoga-Independence Evidence

**Date:** 2026-07-22

The cloud engine room runs **entirely on `fusion247-core`** and has **no runtime dependency on the Yoga**. The Yoga is an admin/console only (Claude/Larry, Git working copy, Tailscale admin).

## Evidence
1. **VPS reboot recovery (no Yoga involvement):** `fusion247-core` was rebooted and **every service auto-recovered in ~40s** — Tailscale reconnected, all 10 containers came back (Coolify, Redis, Directus, Neo4j, LightRAG), health checks green, **Neo4j data survived** (11 nodes), Directus reconnected to managed Supabase. The Yoga only observed via SSH; it played no part in recovery.
2. **Restart policies:** every service is `restart: unless-stopped`; `tailscaled` is `enabled` at boot. Recovery is automatic.
3. **Reachability is tailnet-wide, not Yoga-bound:** services are reached at `100.101.240.85:<port>` from any tailnet device (S21, Surface, Yoga). The Yoga being off/asleep/rebooting does not affect them.
4. **Direction of dependency:** only **Yoga → cloud** (admin). There is no **cloud → Yoga** runtime call. Closing Claude Desktop or rebooting the Yoga cannot stop cloud services.

## What still (intentionally) lives on the Yoga
The existing **local bridges** remain on the Yoga until Larry-coordinated cutover: the Telegram capture-gateway, Tower watchers, and the local Directus. These are unchanged by this infra work and are **not** part of the cloud engine room yet (see `implementation-status.md`).

## Not performed here (avoids disruption)
- Rebooting the Yoga (brief: do not reboot the Yoga; and it would kill the admin session).
- Stopping the local Directus / gateway (Larry-coordinated cutover, not infra scope).
