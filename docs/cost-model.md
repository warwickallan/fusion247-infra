# Cost Model

**Target:** £10–15/month total (excludes existing ChatGPT/Claude subscriptions).

## Recurring infrastructure (Hetzner)
| Item | €/mo (net) |
|---|---|
| CX33 server | 8.49 |
| Primary IPv4 | 0.50 |
| Automatic backups (+20%) | 1.70 |
| **Subtotal** | **10.69** |
| VAT (UK — uncertain; DE 19% if applied) | 0–2.03 |
| **≈ GBP monthly max** | **~£9–£11** |

Billing is hourly, invoiced month-end; delete `fusion247-core` to stop.

## Metered API (usage-based, on top)
| Service | Meter | Controls |
|---|---|---|
| **LightRAG / OpenAI** | dedicated project "Fusion247 LightRAG" dashboard = exact £ by model (= by role). Pilot run measured **$0.04** (1 ingest, 23 entities/25 relations, 2 multi-hop queries). | £10 prepaid, **auto-recharge OFF**; alert at projected **£3/mo**, stop non-essential ingestion at **£5**; no full-vault ingestion; don't change embedding model post-index without rebuilding vectors. |
| **Honcho** | managed Honcho Cloud, on **$100 free credit** (pilot ~102 tokens = negligible). | ingest only selected items; alert >£2/mo, stop >£3/mo without approval. |

## Projected total
Infra **~£9–11** + LightRAG (pilot-level) pennies + Honcho on credit → **within the £10–15 target**. If projected recurring exceeds £15, stop and show the breakdown before proceeding (no silent acceptance).
