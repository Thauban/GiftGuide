-- ============================================================
-- GiftGuide PostgreSQL-Schema
-- Diese Datei erstellt alle Tabellen, Beziehungen, Indizes und
-- komfortable Views für die GiftGuide-Datenbank.
-- ============================================================

-- Tabellen werden in umgekehrter Abhängigkeitsreihenfolge gelöscht.
-- CASCADE entfernt abhängige Views oder Fremdschlüssel automatisch.
DROP TABLE IF EXISTS affiliate_sale CASCADE;
DROP TABLE IF EXISTS reminder CASCADE;
DROP TABLE IF EXISTS favorite CASCADE;
DROP TABLE IF EXISTS recommendation CASCADE;
DROP TABLE IF EXISTS question_answer CASCADE;
DROP TABLE IF EXISTS questionnaire_session CASCADE;
DROP TABLE IF EXISTS question_rule CASCADE;
DROP TABLE IF EXISTS question_option CASCADE;
DROP TABLE IF EXISTS question CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS product_category CASCADE;
DROP TABLE IF EXISTS partner_shop CASCADE;
DROP TABLE IF EXISTS app_user CASCADE;
DROP TABLE IF EXISTS role CASCADE;

-- Rollen trennen Gast, registrierten Nutzer, Admin und Partnershop-Rolle.
CREATE TABLE role (
    role_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name TEXT NOT NULL UNIQUE
);

-- Nutzerkonto der App. Gäste werden ebenfalls gespeichert, aber ohne E-Mail und Passwort.
CREATE TABLE app_user (
    user_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id INTEGER NOT NULL REFERENCES role(role_id),
    username TEXT,
    email TEXT UNIQUE,
    password_hash TEXT,
    preferred_language TEXT NOT NULL DEFAULT 'de',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_guest BOOLEAN NOT NULL DEFAULT TRUE
);

-- Partner-Shops liefern Produkte und zahlen eine Provision bei Affiliate-Verkäufen.
CREATE TABLE partner_shop (
    partner_shop_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id INTEGER REFERENCES role(role_id),
    shop_name TEXT NOT NULL UNIQUE,
    website_url TEXT NOT NULL,
    commission_rate NUMERIC(5, 4) NOT NULL DEFAULT 0 CHECK (commission_rate >= 0)
);

-- Fragen des adaptiven Geschenk-Fragebogens.
CREATE TABLE question (
    question_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('single_choice', 'multiple_choice', 'number', 'text')),
    display_order INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Antwortoptionen für Fragen mit Auswahlmöglichkeiten.
CREATE TABLE question_option (
    question_option_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES question(question_id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    option_value TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    UNIQUE (question_id, option_value)
);

-- Regeln für die adaptive Navigation im Fragebogen.
CREATE TABLE question_rule (
    question_rule_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    question_id INTEGER NOT NULL REFERENCES question(question_id) ON DELETE CASCADE,
    question_option_id INTEGER REFERENCES question_option(question_option_id) ON DELETE CASCADE,
    next_question_id INTEGER NOT NULL REFERENCES question(question_id) ON DELETE CASCADE,
    condition_value TEXT
);

-- Eine Sitzung speichert einen gestarteten oder abgeschlossenen Fragebogen.
CREATE TABLE questionnaire_session (
    questionnaire_session_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    status TEXT NOT NULL DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'abgeschlossen', 'abgebrochen'))
);

-- Einzelne Antworten innerhalb einer Fragebogen-Sitzung.
CREATE TABLE question_answer (
    question_answer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    questionnaire_session_id INTEGER NOT NULL REFERENCES questionnaire_session(questionnaire_session_id) ON DELETE CASCADE,
    question_id INTEGER NOT NULL REFERENCES question(question_id),
    question_option_id INTEGER REFERENCES question_option(question_option_id),
    answer_text TEXT,
    answer_number NUMERIC(10, 2)
);

-- Produktkategorien bündeln Geschenke thematisch.
CREATE TABLE product_category (
    product_category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE
);

-- Produkte stammen aus Partner-Shops und enthalten Preis, Bild, Verfügbarkeit und Affiliate-Link.
CREATE TABLE product (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_category_id INTEGER NOT NULL REFERENCES product_category(product_category_id),
    partner_shop_id INTEGER NOT NULL REFERENCES partner_shop(partner_shop_id),
    external_product_id TEXT,
    product_name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    image_url TEXT,
    availability TEXT NOT NULL DEFAULT 'verfügbar',
    affiliate_link TEXT NOT NULL,
    last_checked_at TIMESTAMP,
    UNIQUE (partner_shop_id, external_product_id)
);

-- Empfehlungen verbinden Fragebogen-Sitzungen mit passenden Produkten.
-- reason_text ist die zentrale "Warum passt das?"-Begründung.
CREATE TABLE recommendation (
    recommendation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    questionnaire_session_id INTEGER NOT NULL REFERENCES questionnaire_session(questionnaire_session_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    reason_text TEXT NOT NULL,
    score NUMERIC(4, 2) NOT NULL CHECK (score >= 0),
    rank_position INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (questionnaire_session_id, product_id)
);

-- Favoriten bilden die Merkliste eines Nutzers ab.
CREATE TABLE favorite (
    favorite_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES product(product_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, product_id)
);

-- Erinnerungen helfen Nutzern, Geschenk-Anlässe nicht zu vergessen.
CREATE TABLE reminder (
    reminder_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES app_user(user_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    reminder_date TIMESTAMP NOT NULL,
    occasion TEXT,
    is_done BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Affiliate-Verkäufe speichern Provisionsdaten für Shop-Weiterleitungen.
CREATE TABLE affiliate_sale (
    affiliate_sale_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id INTEGER REFERENCES app_user(user_id) ON DELETE SET NULL,
    partner_shop_id INTEGER NOT NULL REFERENCES partner_shop(partner_shop_id),
    product_id INTEGER NOT NULL REFERENCES product(product_id),
    product_category_id INTEGER NOT NULL REFERENCES product_category(product_category_id),
    sale_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sale_amount NUMERIC(10, 2) NOT NULL CHECK (sale_amount >= 0),
    commission_amount NUMERIC(10, 2) NOT NULL CHECK (commission_amount >= 0),
    status TEXT NOT NULL DEFAULT 'offen' CHECK (status IN ('offen', 'bestätigt', 'storniert'))
);

-- Indizes beschleunigen häufige JOINs über Fremdschlüssel.
CREATE INDEX idx_app_user_role_id ON app_user(role_id);
CREATE INDEX idx_partner_shop_role_id ON partner_shop(role_id);
CREATE INDEX idx_product_category_id ON product(product_category_id);
CREATE INDEX idx_product_partner_shop_id ON product(partner_shop_id);
CREATE INDEX idx_question_answer_session_id ON question_answer(questionnaire_session_id);
CREATE INDEX idx_recommendation_session_id ON recommendation(questionnaire_session_id);
CREATE INDEX idx_favorite_user_id ON favorite(user_id);
CREATE INDEX idx_affiliate_sale_shop_id ON affiliate_sale(partner_shop_id);

-- View für eine gut lesbare Empfehlungsübersicht in Adminer.
CREATE VIEW recommendation_overview AS
SELECT
    r.recommendation_id,
    r.rank_position,
    r.score,
    u.username,
    p.product_name,
    pc.category_name,
    ps.shop_name,
    p.price,
    r.reason_text
FROM recommendation r
JOIN questionnaire_session qs ON qs.questionnaire_session_id = r.questionnaire_session_id
JOIN app_user u ON u.user_id = qs.user_id
JOIN product p ON p.product_id = r.product_id
JOIN product_category pc ON pc.product_category_id = p.product_category_id
JOIN partner_shop ps ON ps.partner_shop_id = p.partner_shop_id;

-- View für eine gut lesbare Verkaufs- und Provisionsübersicht.
CREATE VIEW affiliate_sale_overview AS
SELECT
    s.affiliate_sale_id,
    s.sale_date,
    s.status,
    u.username,
    p.product_name,
    pc.category_name,
    ps.shop_name,
    s.sale_amount,
    s.commission_amount
FROM affiliate_sale s
LEFT JOIN app_user u ON u.user_id = s.user_id
JOIN product p ON p.product_id = s.product_id
JOIN product_category pc ON pc.product_category_id = s.product_category_id
JOIN partner_shop ps ON ps.partner_shop_id = s.partner_shop_id;

-- ============================================================
-- Datenbank-Kommentare
-- Diese Kommentare werden als PostgreSQL-Metadaten gespeichert.
-- Viele DB-Tools können sie in der Strukturansicht anzeigen.
-- ============================================================

COMMENT ON TABLE role IS 'Rollen für Gast, registrierten Nutzer, Admin und Partner.';
COMMENT ON COLUMN role.role_id IS 'Eindeutige technische ID der Rolle.';
COMMENT ON COLUMN role.role_name IS 'Anzeigename der Rolle, z. B. Gast oder Admin.';

COMMENT ON TABLE app_user IS 'Nutzer der GiftGuide-App, inklusive Gastnutzern.';
COMMENT ON COLUMN app_user.user_id IS 'Eindeutige technische ID des Nutzers.';
COMMENT ON COLUMN app_user.role_id IS 'Verweis auf die Rolle des Nutzers.';
COMMENT ON COLUMN app_user.email IS 'E-Mail-Adresse, nur bei registrierten Nutzern erforderlich.';
COMMENT ON COLUMN app_user.password_hash IS 'Gehashtes Passwort; bei Gastnutzern leer.';
COMMENT ON COLUMN app_user.is_guest IS 'TRUE bedeutet Gastmodus, FALSE bedeutet registrierter Nutzer.';

COMMENT ON TABLE partner_shop IS 'Externe Shops, zu denen GiftGuide per Affiliate-Link weiterleitet.';
COMMENT ON COLUMN partner_shop.commission_rate IS 'Provisionssatz des Shops, z. B. 0.0400 für 4 %.';

COMMENT ON TABLE question IS 'Fragen des adaptiven GiftGuide-Fragebogens.';
COMMENT ON COLUMN question.question_type IS 'Legt fest, ob die Frage Auswahl, Zahl oder Freitext erwartet.';
COMMENT ON COLUMN question.display_order IS 'Standard-Reihenfolge der Frage im Fragebogen.';

COMMENT ON TABLE question_option IS 'Auswahlmöglichkeiten einer Frage.';
COMMENT ON COLUMN question_option.option_value IS 'Stabiler technischer Wert für die Auswertung.';

COMMENT ON TABLE question_rule IS 'Regeln für Sprünge zur nächsten Frage.';
COMMENT ON COLUMN question_rule.next_question_id IS 'Frage, die als Nächstes angezeigt werden soll.';

COMMENT ON TABLE questionnaire_session IS 'Eine konkrete Fragebogen-Sitzung eines Nutzers.';
COMMENT ON COLUMN questionnaire_session.status IS 'Status der Sitzung: aktiv, abgeschlossen oder abgebrochen.';

COMMENT ON TABLE question_answer IS 'Antworten, die in einer Fragebogen-Sitzung gegeben wurden.';
COMMENT ON COLUMN question_answer.answer_text IS 'Freitextantwort, wenn die Frage Text erwartet.';
COMMENT ON COLUMN question_answer.answer_number IS 'Zahlenantwort, z. B. das Budget.';

COMMENT ON TABLE product_category IS 'Thematische Kategorien für Geschenkprodukte.';
COMMENT ON TABLE product IS 'Geschenkprodukte aus Partner-Shops.';
COMMENT ON COLUMN product.external_product_id IS 'Produkt-ID aus dem externen Shopsystem.';
COMMENT ON COLUMN product.affiliate_link IS 'Tracking-Link für die Weiterleitung zum Partner-Shop.';
COMMENT ON COLUMN product.last_checked_at IS 'Zeitpunkt der letzten Aktualisierung von Preis oder Verfügbarkeit.';

COMMENT ON TABLE recommendation IS 'KI- oder regelbasierte Geschenkempfehlungen pro Fragebogen-Sitzung.';
COMMENT ON COLUMN recommendation.reason_text IS 'Begründung, warum das Produkt zur Person passt.';
COMMENT ON COLUMN recommendation.score IS 'Bewertung der Passung; je höher, desto besser.';
COMMENT ON COLUMN recommendation.rank_position IS 'Position in der Ergebnisliste.';

COMMENT ON TABLE favorite IS 'Merkliste: gespeicherte Produkte eines Nutzers.';
COMMENT ON TABLE reminder IS 'Erinnerungen an Geschenk-Anlässe.';

COMMENT ON TABLE affiliate_sale IS 'Erfasste Affiliate-Verkäufe und Provisionen.';
COMMENT ON COLUMN affiliate_sale.sale_amount IS 'Bruttowert des vermittelten Kaufs.';
COMMENT ON COLUMN affiliate_sale.commission_amount IS 'Provision, die GiftGuide erhält.';
COMMENT ON COLUMN affiliate_sale.status IS 'Verkaufsstatus: offen, bestätigt oder storniert.';

COMMENT ON VIEW recommendation_overview IS 'Lesbare Übersicht über Empfehlungen mit Nutzer, Produkt, Shop, Kategorie und Begründung.';
COMMENT ON VIEW affiliate_sale_overview IS 'Lesbare Übersicht über Affiliate-Verkäufe mit Produkt, Shop, Kategorie und Provision.';
