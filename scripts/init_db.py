from pathlib import Path
import sqlite3


# Projektwurzel: scripts/init_db.py liegt eine Ebene unter dem Root-Ordner.
ROOT_DIR = Path(__file__).resolve().parents[1]

# SQLite-Datei für lokale Tests. Die professionelle Hauptdatenbank läuft über PostgreSQL.
DB_PATH = ROOT_DIR / "giftguide.db"
SCHEMA_PATH = ROOT_DIR / "db" / "schema.sql"
SEED_PATH = ROOT_DIR / "db" / "seed.sql"


def run_script(connection: sqlite3.Connection, path: Path) -> None:
    """Führt eine SQL-Datei vollständig gegen die SQLite-Verbindung aus."""
    connection.executescript(path.read_text(encoding="utf-8"))


def main() -> None:
    # Eine Verbindung zur SQLite-Datei öffnen oder die Datei neu anlegen.
    with sqlite3.connect(DB_PATH) as connection:
        # Fremdschlüssel sind in SQLite nicht automatisch aktiv.
        connection.execute("PRAGMA foreign_keys = ON;")

        # Erst Tabellenstruktur erstellen, danach Beispieldaten einfügen.
        run_script(connection, SCHEMA_PATH)
        run_script(connection, SEED_PATH)

        # Kleine Kontrolle, damit beim Ausführen direkt sichtbar ist, ob Tabellen entstanden sind.
        table_count = connection.execute(
            "SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%';"
        ).fetchone()[0]

    # Ausgabe für die Konsole.
    print(f"Datenbank erstellt: {DB_PATH}")
    print(f"Tabellen erstellt: {table_count}")


if __name__ == "__main__":
    main()
