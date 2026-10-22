# Referential Audit

Inspect SQLite foreign-key consistency.

An empty result indicates no referential violations. This does not replace validation of business rules.

## Run

The SQL runs on SQLite. The example runner needs Python 3.11 or newer.

```sh
python main.py
python -m unittest discover -s tests -v
```

`schema.sql` defines the source tables. `query.sql` contains the standalone query.
The example runner creates and closes an isolated in-memory database.
