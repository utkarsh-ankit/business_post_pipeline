-- ============================================================
-- BUSINESS POST PIPELINE — POSTGRES SCHEMA
-- ============================================================
-- Run this once to initialise the memory and audit tables.
-- Usage:
--   docker exec -i mock-postgres psql -U postgres -d postgres < memory/schema.sql
-- ============================================================

-- ── Memory table: deduplication layer ──────────────────────
CREATE TABLE IF NOT EXISTS pipeline_memory (
  hash          VARCHAR(64) PRIMARY KEY,
  title         TEXT        NOT NULL,
  url           TEXT        NOT NULL,
  source_name   VARCHAR(100),
  source_type   VARCHAR(50),
  date_fetched  TIMESTAMPTZ DEFAULT NOW(),
  status        VARCHAR(30) DEFAULT 'pending_approval',
  outcome_at    TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_memory_hash
  ON pipeline_memory (hash);

CREATE INDEX IF NOT EXISTS idx_memory_status
  ON pipeline_memory (status);

-- ── Audit table: full decision log ─────────────────────────
CREATE TABLE IF NOT EXISTS pipeline_audit (
  id            SERIAL PRIMARY KEY,
  hash          VARCHAR(64) REFERENCES pipeline_memory(hash),
  action        VARCHAR(20) NOT NULL,
  actioned_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_audit_hash
  ON pipeline_audit (hash);

-- ── Confirm ─────────────────────────────────────────────────
SELECT 'pipeline_memory created' AS status
WHERE EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_name = 'pipeline_memory'
);

SELECT 'pipeline_audit created' AS status
WHERE EXISTS (
  SELECT FROM information_schema.tables
  WHERE table_name = 'pipeline_audit'
);
