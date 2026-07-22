// Fusion247 Neo4j acceptance dataset (derived, rebuildable). Idempotent (MERGE).
// Models the infra decision/topology so a real multi-hop question can be answered.

MERGE (w:Person {name:'Warwick'})

MERGE (d1:Decision {name:'Cloud engine room'})
  SET d1.source='remote-control brief 2026-07-22', d1.provenance='Fusion247 infra brief'
MERGE (d0:Decision {name:'Yoga self-hosting'})
  SET d0.provenance='earlier plan (superseded)'

MERGE (s:Server {name:'fusion247-core'}) SET s.type='Hetzner CX33', s.region='Nuremberg'
MERGE (co:Technology {name:'Coolify'})
MERGE (ts:Technology {name:'Tailscale'})
MERGE (dir:Service {name:'Directus'})
MERGE (lr:Service {name:'LightRAG'})
MERGE (n4:Service {name:'Neo4j'})
MERGE (rd:Service {name:'Redis'})
MERGE (db:Database {name:'Supabase ops'}) SET db.ref='kerdinlgcfxnjrztwqde'

MERGE (w)-[:MADE]->(d1)
MERGE (d1)-[:SUPERSEDES]->(d0)
MERGE (d1)-[:CHOSE]->(s)
MERGE (s)-[:RUNS]->(co)
MERGE (s)-[:JOINS]->(ts)
MERGE (s)-[:HOSTS]->(dir)
MERGE (s)-[:HOSTS]->(lr)
MERGE (s)-[:HOSTS]->(n4)
MERGE (s)-[:HOSTS]->(rd)
MERGE (dir)-[:READS]->(db)
;
