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
| **SSH** | private (key-based) | ED25519 key from Yoga; works over tailnet `100.101.240.85` and (currently) public IP. Tailscale SSH intercept **disabled** (plain key auth). |
| **Coolify** | private | bound behind Tailscale; reached via tailnet IP / MagicDNS |
| **Directus** | private | via Tailscale only (mobile S21/Surface use tailnet) |
| **Neo4j browser/Bolt** | private | Docker network + Tailscale only; no public Bolt |
| **LightRAG API** | private | Docker private network + controlled gateway only |
| **Redis** | private | Docker private network + auth; never public |

## Recovery paths (keep ≥1 independent)
1. **Hetzner Cloud console** (VNC/rescue) — always available, independent of Tailscale.
2. **Key SSH over tailnet** `100.101.240.85`.
3. Key SSH over public IP (to be restricted to tailnet once Coolify access is proven).

## Pending hardening (apply alongside Phase 3)
- Restrict inbound public SSH (UFW) to tailnet interface once tailnet SSH is proven reliable — keep Hetzner console as fallback.
- Confirm `PasswordAuthentication no` (server was created key-only; no root password set).
- Do **not** firewall before Coolify install completes (avoid self-lockout / proxy conflicts).
