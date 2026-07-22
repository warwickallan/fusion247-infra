#!/usr/bin/env python3
"""
Honcho pilot — selective-memory acceptance test for Fusion247 (SDK honcho-ai v2.x).

Ingests ONLY allowed content (decisions, preferences, corrections, a compact summary).
Never ingests raw logs, tool output, code diffs, or sensitive data.
Reads HONCHO_API_KEY from env. No secrets in this file.
"""
import os, sys, time

try:
    from honcho import Honcho
except Exception as e:
    print("IMPORT_ERROR:", e); sys.exit(2)

API_KEY = os.environ.get("HONCHO_API_KEY")
WS = os.environ.get("HONCHO_WORKSPACE", "Fusion247")
if not API_KEY:
    print("NO_API_KEY"); sys.exit(2)

honcho = Honcho(api_key=API_KEY, workspace_id=WS)
PEER_ID = "warwick"
SESSION_ID = "fusion247-pilot-1"

# Selected, non-sensitive items only (per content policy).
ITEMS = [
    "I want Fusion247 to run on a cloud engine room, not on my Yoga laptop.",
    "My working preference: Claude does the technical work; I only handle passwords and approvals.",
    "Decision: we chose a Hetzner CX33 server in Nuremberg as the engine room.",
    "Correction: the ops Supabase project is kerdinlgcfxnjrztwqde; the dev one is iiqstxfqjbrbyplwwsql.",
    "I like keeping infrastructure cost to about ten to fifteen pounds a month.",
]

def main():
    print("workspace:", WS)
    peer = honcho.peer(PEER_ID)
    session = honcho.session(SESSION_ID)
    session.add_peers(peer)
    print("peer + session ready")

    chars = 0
    msgs = []
    for m in ITEMS:
        msgs.append(peer.message(m))
        chars += len(m)
    session.add_messages(msgs)
    approx_tokens = chars // 4
    print(f"ingested {len(ITEMS)} messages, ~{chars} chars (~{approx_tokens} tokens)")

    query = "What are this user's working preferences and the key Fusion247 architecture decisions?"
    answer = None
    for attempt in range(1, 5):
        print(f"query attempt {attempt} (waiting for representation)...")
        time.sleep(20)
        answer = peer.chat(query, reasoning_level="medium")
        if answer:
            break
    print("RESPONSE_START")
    print(answer if answer else "(no representation yet)")
    print("RESPONSE_END")
    print(f"METER ingest_tokens_approx={approx_tokens}")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        import traceback
        print("RUN_ERROR:", repr(e)); traceback.print_exc(); sys.exit(1)
