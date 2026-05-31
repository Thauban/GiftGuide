# GiftGuide Datenbankdesign

## Ziel des Datenmodells

Die Datenbank bildet den Kernprozess der GiftGuide-App ab: Ein Nutzer oder Gast beantwortet einen kurzen Fragebogen, daraus entstehen personalisierte Geschenkempfehlungen mit Begründung, und passende Produkte können favorisiert oder über Partner-Shops gekauft werden.

## ER-Modell

Das vollständige ER-Modell liegt in [erd.md](./erd.md). Es enthält alle Entitäten, Primärschlüssel, Fremdschlüssel und Beziehungen.

Die wichtigsten Entitäten sind:

- `app_user`: Nutzer und Gastnutzer
- `questionnaire_session`: eine gestartete Fragebogenrunde
- `question_answer`: Antworten innerhalb einer Sitzung
- `product`: Geschenkprodukte aus Partner-Shops
- `recommendation`: empfohlene Produkte mit Begründung und Score
- `favorite`: Merkliste des Nutzers
- `affiliate_sale`: vermittelte Verkäufe und Provisionen

## Kardinalitäten

| Beziehung | Kardinalität | Bedeutung |
| --- | --- | --- |
| `role` zu `app_user` | 1:n | Eine Rolle kann vielen Nutzern zugeordnet sein. |
| `app_user` zu `questionnaire_session` | 1:n | Ein Nutzer kann mehrere Fragebogen-Sitzungen starten. |
| `questionnaire_session` zu `question_answer` | 1:n | Eine Sitzung enthält mehrere Antworten. |
| `question` zu `question_option` | 1:n | Eine Frage kann mehrere Antwortoptionen besitzen. |
| `question` zu `question_rule` | 1:n | Eine Frage kann Regeln auslösen und als nächste Frage referenziert werden. |
| `question` zu `question_answer` | 1:n | Eine Frage kann in vielen Sitzungen beantwortet werden. |
| `questionnaire_session` zu `recommendation` | 1:n | Eine Sitzung kann mehrere Empfehlungen erzeugen. |
| `product` zu `recommendation` | 1:n | Ein Produkt kann in vielen Empfehlungen vorkommen. |
| `product_category` zu `product` | 1:n | Eine Kategorie enthält mehrere Produkte. |
| `partner_shop` zu `product` | 1:n | Ein Shop bietet mehrere Produkte an. |
| `app_user` zu `favorite` | 1:n | Ein Nutzer kann mehrere Produkte speichern. |
| `product` zu `favorite` | 1:n | Ein Produkt kann von mehreren Nutzern gespeichert werden. |
| `partner_shop` zu `affiliate_sale` | 1:n | Ein Shop kann mehrere vermittelte Verkäufe haben. |
| `product` zu `affiliate_sale` | 1:n | Ein Produkt kann mehrfach verkauft werden. |

## Relationales Schema

`role(role_id PK, role_name UNIQUE)`

`app_user(user_id PK, role_id FK, username, email UNIQUE, password_hash, preferred_language, created_at, is_guest)`

`partner_shop(partner_shop_id PK, role_id FK, shop_name UNIQUE, website_url, commission_rate)`

`question(question_id PK, question_text, question_type, display_order, is_active)`

`question_option(question_option_id PK, question_id FK, option_text, option_value, sort_order, UNIQUE(question_id, option_value))`

`question_rule(question_rule_id PK, question_id FK, question_option_id FK, next_question_id FK, condition_value)`

`questionnaire_session(questionnaire_session_id PK, user_id FK, started_at, completed_at, status)`

`question_answer(question_answer_id PK, questionnaire_session_id FK, question_id FK, question_option_id FK, answer_text, answer_number)`

`product_category(product_category_id PK, category_name UNIQUE)`

`product(product_id PK, product_category_id FK, partner_shop_id FK, external_product_id, product_name, description, price, image_url, availability, affiliate_link, last_checked_at, UNIQUE(partner_shop_id, external_product_id))`

`recommendation(recommendation_id PK, questionnaire_session_id FK, product_id FK, reason_text, score, rank_position, created_at, UNIQUE(questionnaire_session_id, product_id))`

`favorite(favorite_id PK, user_id FK, product_id FK, created_at, UNIQUE(user_id, product_id))`

`reminder(reminder_id PK, user_id FK, title, reminder_date, occasion, is_done, created_at)`

`affiliate_sale(affiliate_sale_id PK, user_id FK, partner_shop_id FK, product_id FK, product_category_id FK, sale_date, sale_amount, commission_amount, status)`

## Normalisierung

Das Modell ist bewusst normalisiert aufgebaut:

- Wiederholende Werte wie Rollen, Kategorien und Shops liegen in eigenen Tabellen.
- Produkte verweisen per Fremdschlüssel auf Kategorie und Partner-Shop.
- Fragebogen-Antworten werden getrennt von den Fragen gespeichert, damit jede Sitzung nachvollziehbar bleibt.
- Empfehlungen stehen in einer eigenen Tabelle, weil sie ein Ergebnis aus Sitzung und Produkt sind.
- Favoriten nutzen `UNIQUE(user_id, product_id)`, damit ein Nutzer dasselbe Produkt nicht mehrfach speichern kann.

Damit vermeidet das Modell unnötige Dopplungen und bleibt trotzdem gut verständlich.

## Wichtige Constraints

| Constraint | Zweck |
| --- | --- |
| `email UNIQUE` | Eine registrierte E-Mail soll nur einmal vorkommen. |
| `role_name UNIQUE` | Rollennamen sollen eindeutig sein. |
| `shop_name UNIQUE` | Jeder Partnershop wird nur einmal gespeichert. |
| `category_name UNIQUE` | Kategorien werden nicht doppelt angelegt. |
| `UNIQUE(question_id, option_value)` | Eine Antwortoption darf pro Frage nur einmal vorkommen. |
| `UNIQUE(questionnaire_session_id, product_id)` | Dasselbe Produkt wird pro Sitzung nicht doppelt empfohlen. |
| `UNIQUE(user_id, product_id)` | Dasselbe Produkt wird pro Nutzer nicht doppelt favorisiert. |
| `CHECK(price >= 0)` | Produktpreise dürfen nicht negativ sein. |
| `CHECK(status IN (...))` | Statuswerte bleiben kontrolliert. |

## Views

`recommendation_overview` zeigt Empfehlungen in lesbarer Form:

- Nutzername
- Produktname
- Kategorie
- Shop
- Preis
- Begründung
- Score und Rang

`affiliate_sale_overview` zeigt vermittelte Verkäufe:

- Nutzername
- Produkt
- Kategorie
- Shop
- Kaufbetrag
- Provision
- Status

Diese Views sind besonders gut für die Präsentation geeignet, weil sie mehrere Tabellen verständlich zusammenführen.

## Beispielabfragen

Empfehlungen mit Begründung anzeigen:

```sql
SELECT username, rank_position, product_name, shop_name, reason_text, score
FROM recommendation_overview
ORDER BY username, rank_position;
```

Favoriten mit Produktnamen anzeigen:

```sql
SELECT u.username, p.product_name, f.created_at
FROM favorite f
JOIN app_user u ON u.user_id = f.user_id
JOIN product p ON p.product_id = f.product_id
ORDER BY u.username, f.created_at;
```

Affiliate-Provisionen je Shop auswerten:

```sql
SELECT shop_name, SUM(sale_amount) AS umsatz, SUM(commission_amount) AS provision
FROM affiliate_sale_overview
GROUP BY shop_name
ORDER BY provision DESC;
```

## Designentscheidung

Die Tabelle heißt technisch `app_user` statt `user`, weil `user` in vielen Datenbanksystemen ein reservierter Begriff ist. Inhaltlich entspricht `app_user` der geplanten Nutzertabelle aus dem Entwurf.
