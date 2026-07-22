# LightRAG Pilot — Acceptance Result

**Date:** 2026-07-22 · **Image:** `ghcr.io/hkuds/lightrag` v1.5.4, digest `sha256:de09cd75e32b6b45b104625a9fb229f84f3dec4827ecffc825aa4438b196cbe6` · **Port:** 9621 (tailnet-only) · Coolify uuid `g327xy3z5zv3qzrf75htbkse`

## Model config (per-role, per Warwick's decision)
| Role | Model | OpenAI validated |
|---|---|---|
| Extract | `gpt-5-mini` | ✅ |
| Keyword | `gpt-5-nano` | ✅ |
| Query | `gpt-5.6-terra` | ✅ |
| Embedding | `text-embedding-3-large` (dim 3072) | ✅ |

OpenAI key stored **only in Coolify** (dedicated project **Fusion247 LightRAG**, £10 prepaid, auto-recharge OFF).

## Result: ✅ PASS
1. **Deploy** — healthy on :9621, OpenAI bindings loaded.
2. **Ingest** — one non-sensitive accepted packet (`karpathy-packet-1`, ML fundamentals).
3. **Index/graph** — extracted **23 entities, 25 relations**.
4. **Semantic query** — "backpropagation & micrograd" → accurate answer, **cited** `[1] karpathy-packet-1`.
5. **Relationship / multi-hop query** — "nanoGPT → GPT → Transformer → Vaswani et al. → 'Attention Is All You Need'" → correct traversal, cited.
6. **Provenance** — source reference returned with answers. ✅
7. **Directus stayed healthy** (HTTP 200) during ingestion — acceptance #8. ✅
8. **Temp media removed.**

## Cost / metering
- **Per-role = per-model**, isolated in the dedicated OpenAI project → the project dashboard shows exact £ by model (= by role). This is the meter.
- This run: tiny (short packet, few extraction calls, 2 queries) — estimated **< £0.05**; exact figure in the OpenAI project dashboard (propagates within ~an hour).
- **Cost controls (per spec):** alert at projected **£3/mo**; stop non-essential ingestion at **£5**; do **not** ingest the full vault; **do not** change the embedding model after indexing without rebuilding vectors (3072-dim vectors are model-specific).

## Follow-ups
- Persistent volume for `/app/data` before real corpus (current pilot storage is in-container; digest pinned).
- Set `TOKEN_SECRET` (currently guest-mode JWT; API still protected by `X-API-Key` + firewall + tailnet-only).
- Add concurrency already capped (`MAX_ASYNC_LLM=4`, per-role 2).
