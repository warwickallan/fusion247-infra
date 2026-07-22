# Rebuild Runbook — replacement server recovery

Step-by-step recovery to a fresh server. No hidden manual steps; no memory required.
**Canonical sources:** GitHub `warwickallan/fusion247-infra` + managed Supabase (ops/dev) + this repo's docs.
**Secrets:** never in Git — in Coolify and `C:\.fusion247\*.env` on the Yoga; recovery bundle is encrypted.

## 0. Prerequisites (on the Yoga)
- `C:\.fusion247\*.env` (hetzner, coolify, neo4j, lightrag, honcho, backup-key) — the off-repo secrets.
- Latest encrypted backup bundle in `C:\.fusion247\backups\*.tar.gz.enc`.
- SSH key `~/.ssh/hetzner_fusion247_ed25519` (+ `.pub`).

## 1. Provision server
- Hetzner Cloud → project **Fusion247** → create **CX33**, Ubuntu 24.04, Nuremberg, IPv4, backups on, name `fusion247-core`. (Or via API with the token in `hetzner.env`.)
- Add the SSH public key. Apply the **network firewall** (inbound: 22/tcp SSH *(tighten to tailnet after)*, 41641/udp Tailscale, icmp; deny rest).

## 2. Base hardening
- `timedatectl set-timezone Europe/London`; 2 GB swap @ swappiness 10; `apt-get update && upgrade`.
- Install Tailscale (`curl -fsSL https://tailscale.com/install.sh | sh`), `tailscale up --hostname=fusion247-core`; authorise the node. Then remove public 22 from the firewall (SSH tailnet-only).

## 3. Coolify
- Install: `curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash`.
- **Restore Coolify config** from the encrypted bundle (recovers projects, apps, env vars):
  - Decrypt: `openssl enc -d -aes-256-cbc -pbkdf2 -in <bundle>.tar.gz.enc -out b.tar.gz -pass pass:<BACKUP_PASSPHRASE>` (from `backup-key.env`).
  - Restore `coolify-db.sql` into Coolify's Postgres (stop Coolify, restore, start) — or re-create the apps from the definitions below.

## 4. Redeploy services (Coolify)
All are defined in `compose/` and `implementation-status.md` (images + envs). Re-create in project **Fusion247**:
- **Redis** (managed db) — new password to Coolify.
- **Directus** `directus/directus:11.17.4` — envs from `C:\Fusion247PKA\...\directus\.env` (DB → ops Supabase pooler, `directus_sys,asdair,cockpit`); `CACHE_ENABLED=false` until Redis wired; port 8055; tailnet-only.
- **Neo4j** `neo4j:5.26-community` — heap 1G/pagecache 512M; then load `scripts/neo4j/acceptance.cypher`.
- **LightRAG** `ghcr.io/hkuds/lightrag` (pin digest `sha256:de09cd75…` = v1.5.4) — per-role models; OpenAI key **into Coolify only**; port 9621.

## 5. Verify
- Health: Redis PING, Directus `/server/health` 200, Neo4j Cypher count, LightRAG `/health` 200.
- Reboot once and confirm auto-recovery (see `independence-evidence.md`).
- Take a fresh backup (`scripts/backup.sh`) and pull to the Yoga.
