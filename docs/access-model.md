# Access Model — fusion247-core

**Updated:** 2026-07-22

## Principle
No general public administration surface. All admin UIs reachable **privately over Tailscale** only.
Tailscale Funnel is **not** enabled. Public exposure is limited to what the app genuinely needs
(e.g. Telegram webhooks/polling are outbound; no inbound public admin).

## Network identities
| Host | Public IPv4 | Tailnet IPv4 |
|---|---|---|
| fusion247-core (server) | 178.104.171.240 | **100.101.240.85** |
| warwick-yoga (ops) | — | 100.80.175.41 |
| warwicks-s21-ultra (phone) | — | 100.97.23.28 |

Tailnet: `warwickjunior2011@`. `tailscaled` is **enabled at boot** (survives reboot).

## Access matrix (target)
| Surface | Exposure | How |
|---|---|---|
| **SSH** | **private (tailnet-only)** | ED25519 key from Yoga over tailnet `100.101.240.85`. **Public port 22 removed from the Hetzner firewall** — no public SSH. Tailscale SSH intercept disabled (plain key auth). |
| **Coolify** | private | bound behind Tailscale; reached via tailnet IP / MagicDNS |
| **Directus** | private | via Tailscale only (mobile S21/Surface use tailnet) |
| **Neo4j browser/Bolt** | private | Docker network + Tailscale only; no public Bolt |
| **LightRAG API** | private | Docker private network + controlled gateway only |
| **Redis** | private | Docker private network + auth; never public |

## Recovery paths (keep ≥1 independent)
1. **Hetzner Cloud console** (VNC/rescue) — always available, independent of Tailscale. **Primary fallback** now that SSH is tailnet-only.
2. **Key SSH over tailnet** `100.101.240.85`.

## Hardening applied (as-built)
- ✅ **Public SSH removed** — Hetzner firewall (id 11352036) inbound = `41641/udp` (Tailscale) + `icmp` only; **no public 22**. SSH is tailnet-only; Hetzner console is the out-of-band fallback.
- ✅ Server created **key-only** (no root password set); Coolify/services private (tailnet + firewall).
- ✅ Firewall applied **before** Coolify exposed :8000 — admin never publicly reachable.
