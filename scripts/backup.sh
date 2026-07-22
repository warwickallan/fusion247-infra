#!/usr/bin/env bash
# Fusion247 recovery backup — run on fusion247-core (root).
# Backs up the one thing NOT reconstructable from Git/Supabase: Coolify's config DB.
# Produces an ENCRYPTED bundle (aes-256-cbc) + manifest + checksums.
# Usage: BPASS='<passphrase>' bash backup.sh    (passphrase stored off-repo on the Yoga)
set -e
TS=$(date +%Y%m%d-%H%M%S)
DIR=/root/backups/$TS; mkdir -p "$DIR"
: "${BPASS:?set BPASS to the encryption passphrase (from C:\\.fusion247\\backup-key.env)}"

CDB=$(docker ps -q -f name=coolify-db)
DBU=$(docker exec "$CDB" printenv POSTGRES_USER); DBN=$(docker exec "$CDB" printenv POSTGRES_DB)
docker exec "$CDB" pg_dump -U "$DBU" "$DBN" > "$DIR/coolify-db.sql"
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' > "$DIR/services.txt"
cat > "$DIR/manifest.txt" <<M
Fusion247 recovery bundle $TS
Canonical (authoritative): GitHub warwickallan/fusion247-infra + managed Supabase
Rebuildable: Neo4j -> scripts/neo4j/acceptance.cypher ; LightRAG -> re-ingest packets
Backed up here: Coolify config DB, service inventory
Secrets NOT in Git; in Coolify + C:\.fusion247\*.env ; bundle is ENCRYPTED
M
( cd "$DIR" && sha256sum coolify-db.sql services.txt manifest.txt > SHA256SUMS )
( cd /root/backups && tar czf "$TS.tar.gz" "$TS" \
  && openssl enc -aes-256-cbc -pbkdf2 -salt -in "$TS.tar.gz" -out "$TS.tar.gz.enc" -pass pass:"$BPASS" \
  && rm -f "$TS.tar.gz" )
echo "bundle: /root/backups/$TS.tar.gz.enc"
sha256sum "/root/backups/$TS.tar.gz.enc"
# Then pull to the Yoga:  scp root@100.101.240.85:/root/backups/$TS.tar.gz.enc C:/.fusion247/backups/
#
# RESTORE REHEARSAL (non-destructive): decrypt -> extract -> restore coolify-db.sql into a
# throwaway `postgres:16` container -> verify table/row counts -> docker rm -f the throwaway.
