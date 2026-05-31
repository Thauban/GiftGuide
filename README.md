# GiftGuide

Professionelles Datenbanksetup für die GiftGuide-App mit PostgreSQL und Adminer.

## Datenbank sichtbar starten

```bash
docker compose up -d
```

Danach ist die Datenbank im Browser sichtbar:

- Adminer: http://localhost:8080
- System: `PostgreSQL`
- Server: `postgres`
- Benutzer: `giftguide`
- Passwort: `giftguide`
- Datenbank: `giftguide`

## Datenbank stoppen

```bash
docker compose down
```

## Datenbank komplett neu aufbauen

```bash
docker compose down -v
docker compose up -d
```

`-v` löscht den gespeicherten PostgreSQL-Stand und führt die Init-Skripte erneut aus.

## Projektstruktur

- `docker-compose.yml`: startet PostgreSQL und Adminer
- `db/postgres/01_schema.sql`: Tabellen, Primärschlüssel, Fremdschlüssel, Constraints, Views und Indizes
- `db/postgres/02_seed.sql`: Beispieldaten für Rollen, Nutzer, Shops, Fragen, Produkte und Empfehlungen
- `docs/erd.md`: sichtbares ER-Modell als Mermaid-Diagramm
- `docs/db_design.md`: DB-Design-Doku mit Kardinalitäten, relationalem Schema und Beispielabfragen
- `db/schema.sql`, `db/seed.sql`, `scripts/init_db.py`: optionales SQLite-Setup für lokale Tests

## Wichtige Tabellen

- `role`
- `app_user` entspricht der geplanten Tabelle `user`
- `partner_shop`
- `question`, `question_option`, `question_rule`
- `questionnaire_session`, `question_answer`
- `product_category`, `product`
- `recommendation`
- `favorite`
- `reminder`
- `affiliate_sale`

## Hilfreiche Views

- `recommendation_overview`: zeigt Empfehlungen mit Nutzer, Produkt, Shop, Kategorie und Begründung
- `affiliate_sale_overview`: zeigt Verkäufe mit Shop, Produkt, Kategorie und Provision

## Enthaltene Beispieldaten

Der Seed-Datensatz füllt die Datenbank direkt mit realistischen GiftGuide-Testdaten:

- 5 Nutzer inklusive Gastmodus, registrierten Nutzern und Admin
- 5 Partner-Shops
- 7 Fragebogenfragen mit 22 Antwortoptionen
- 7 Produktkategorien und 10 Produkte
- 4 Fragebogen-Sessions mit 21 Antworten
- 8 Empfehlungen mit Begründung und Score
- 5 Favoriten, 3 Erinnerungen und 3 Affiliate-Verkäufe
