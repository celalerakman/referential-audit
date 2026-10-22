import json
import sqlite3
from pathlib import Path

ROOT=Path(__file__).resolve().parent

def example_database():
    db=sqlite3.connect(':memory:')
    db.row_factory=sqlite3.Row
    db.executescript((ROOT/'schema.sql').read_text())
    with db:
        db.execute("INSERT INTO projects VALUES ('SCHOOL-A','School A','EUR')")
        db.executemany('INSERT INTO boq VALUES (?,?,?,?,?)',[
            ('SCHOOL-A','CONC-01','m3',120000,11550),('SCHOOL-A','REBAR-01','kg',18000000,92)])
        db.executemany('INSERT INTO measurements(project_id,code,quantity_milli,source_ref) VALUES (?,?,?,?)',[
            ('SCHOOL-A','CONC-01',85000,'M1'),('SCHOOL-A','CONC-01',40000,'M2')])
    return db

def query(db):
    return [dict(row) for row in db.execute((ROOT/'query.sql').read_text())]

if __name__=='__main__':
    db=example_database()
    try: print(json.dumps(query(db),indent=2))
    finally: db.close()
