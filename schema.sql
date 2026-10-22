PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    currency TEXT NOT NULL CHECK(length(currency)=3)
);
CREATE TABLE IF NOT EXISTS boq (
    project_id TEXT NOT NULL REFERENCES projects(id),
    code TEXT NOT NULL,
    unit TEXT NOT NULL,
    quantity_milli INTEGER NOT NULL CHECK(quantity_milli >= 0),
    rate_cents INTEGER NOT NULL CHECK(rate_cents >= 0),
    PRIMARY KEY(project_id, code)
);
CREATE TABLE IF NOT EXISTS measurements (
    id INTEGER PRIMARY KEY,
    project_id TEXT NOT NULL,
    code TEXT NOT NULL,
    quantity_milli INTEGER NOT NULL CHECK(quantity_milli > 0),
    source_ref TEXT NOT NULL UNIQUE CHECK(length(trim(source_ref)) > 0),
    recorded_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    FOREIGN KEY(project_id, code) REFERENCES boq(project_id, code)
);
CREATE INDEX IF NOT EXISTS idx_measurement_item ON measurements(project_id, code);
CREATE TRIGGER IF NOT EXISTS measurements_no_update BEFORE UPDATE ON measurements
BEGIN SELECT RAISE(ABORT, 'Measurements are append-only'); END;
CREATE TRIGGER IF NOT EXISTS measurements_no_delete BEFORE DELETE ON measurements
BEGIN SELECT RAISE(ABORT, 'Measurements are append-only'); END;
CREATE VIEW IF NOT EXISTS reconciliation AS
SELECT b.project_id, b.code, b.unit, b.quantity_milli AS contract_milli,
       COALESCE(SUM(m.quantity_milli),0) AS measured_milli,
       COALESCE(SUM(m.quantity_milli),0) - b.quantity_milli AS variance_milli,
       b.rate_cents
FROM boq b LEFT JOIN measurements m ON m.project_id=b.project_id AND m.code=b.code
GROUP BY b.project_id, b.code;
