#!/usr/bin/env bash
# Fusion247 recovery backup — run on fusion247-core (root).
# Backs up the one thing NOT reconstructable from Git/Supabase: Coolify's config DB.
# Security: plaintext is staged only in a protected temp dir and always shredded via trap;
# output is an ENCRYPTED, chmod-600 bundle, verified before the script reports success.
# Usage: BPASS='<passphrase>' bash backup.sh    (passphrase from C:\.fusion247\backup-key.env)
set -euo pipefail
umask 077
: "${BPASS:?set BPASS to the encryption passphrase (from C:\\.fusion247\\backup-key.env)}"

TS=$(date +%Y%m%d-%H%M%S)
OUT=/root/backups
mkdir -p "$OUT"; chmod 700 "$OUT"

# Protected temp staging for ALL plaintext; removed on any exit.
WORK=$(mktemp -d "$OUT/.stage.XXXXXX")
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT INT TERM

CDB=$(docker ps -q -f name=coolify-db)
DBU=$(docker exec "$CDB" printenv POSTGRES_USER); DBN=$(docker exec "$CDB" printenv POSTGRES_DB)
docker exec "$CDB" pg_dump -U "$DBU" "$DBN" > "$WORK/coolify-db.sql"
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' > "$WORK/services.txt"
cat > "$WORK/manifest.txt" <<M
Fusion247 recovery bundle $TS
Canonical (authoritative): GitHub warwickallan/fusion247-infra + managed Supabase
Rebuildable: Neo4j -> scripts/neo4j/acceptance.cypher ; LightRAG -> re-ingest packets
Backed up here: Coolify config DB (apps/env/persistent-storage defs), service inventory
Persistent volumes on host: neo4j-data, lightrag-data (Docker named volumes) — snapshot separately if needed
Secrets NOT in Git; in Coolify + C:\.fusion247\*.env ; this bundle is ENCRYPTED (aes-256-cbc, pbkdf2)
M
( cd "$WORK" && sha256sum coolify-db.sql services.txt manifest.txt > SHA256SUMS )
tar czf "$WORK/bundle.tar.gz" -C "$WORK" coolify-db.sql services.txt manifest.txt SHA256SUMS

ENC="$OUT/$TS.tar.gz.enc"
openssl enc -aes-256-cbc -pbkdf2 -salt -in "$WORK/bundle.tar.gz" -out "$ENC" -pass env:BPASS
chmod 600 "$ENC"

# Verify the encrypted output decrypts + is a valid archive BEFORE reporting success.
if ! openssl enc -d -aes-256-cbc -pbkdf2 -in "$ENC" -pass env:BPASS 2>/dev/null | tar tz >/dev/null 2>&1; then
  echo "ERROR: encrypted bundle failed verification" >&2; rm -f "$ENC"; exit 1
fi

# Now that the encrypted bundle exists + verified, remove any legacy plaintext timestamp dirs.
find "$OUT" -maxdepth 1 -type d -regextype posix-extended -regex '.*/[0-9]{8}-[0-9]{6}' -exec rm -rf {} + 2>/dev/null || true

echo "OK: verified encrypted bundle $ENC"
sha256sum "$ENC"
# trap shreds $WORK (all plaintext) on exit.
#
# Pull to the Yoga:  scp root@100.101.240.85:/root/backups/<TS>.tar.gz.enc C:/.fusion247/backups/
# RESTORE REHEARSAL (non-destructive): decrypt (-pass env:BPASS) -> extract in a temp dir ->
#   restore coolify-db.sql into a throwaway `postgres:16` -> verify counts -> docker rm -f throwaway.
# Persistent-volume note: neo4j-data / lightrag-data are Docker named volumes; to snapshot,
#   `docker run --rm -v <vol>:/v -v $WORK:/b alpine tar czf /b/<vol>.tgz -C /v .` into the staging dir.
