PRAGMA foreign_keys = ON;

-- Optionales SQLite-Schema für lokale Tests ohne Docker.
-- Die professionelle Hauptdatenbank liegt unter db/postgres.

-- Tabellen in umgekehrter Reihenfolge löschen, damit Fremdschlüssel nicht stören.
DROP TABLE IF EXISTS affiliate_sale;
DROP TABLE IF EXISTS reminder;
DROP TABLE IF EXISTS favorite;
DROP TABLE IF EXISTS recommendation;
DROP TABLE IF EXISTS question_answer;
DROP TABLE IF EXISTS questionnaire_session;
DROP TABLE IF EXISTS question_rule;
DROP TABLE IF EXISTS question_option;
DROP TABLE IF EXISTS question;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS product_category;
DROP TABLE IF EXISTS partner_shop;
DROP TABLE IF EXISTS app_user;
DROP TABLE IF EXISTS role;

-- Rollen für Gast, Nutzer, Admin und Partner.
CREATE TABLE role (
    role_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role_name TEXT NOT NULL UNIQUE
);

-- app_user entspricht der Tabelle "user" aus dem Entwurf.
-- Der Name vermeidet Konflikte mit reservierten Datenbankbegriffen.
CREATE TABLE app_user (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role_id INTEGER NOT NULL,
    username TEXT,
    email TEXT UNIQUE,
    password_hash TEXT,
    preferred_language TEXT NOT NULL DEFAULT 'de',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_guest INTEGER NOT NULL DEFAULT 1 CHECK (is_guest IN (0, 1)),
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- Partner-Shops mit Website und Provisionssatz.
CREATE TABLE partner_shop (
    partner_shop_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role_id INTEGER,
    shop_name TEXT NOT NULL UNIQUE,
    website_url TEXT NOT NULL,
    commission_rate REAL NOT NULL DEFAULT 0 CHECK (commission_rate >= 0),
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

-- Fragen des Geschenk-Fragebogens.
CREATE TABLE question (
    question_id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('single_choice', 'multiple_choice', 'number', 'text')),
    display_order INTEGER NOT NULL,
    is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))
);

-- Antwortoptionen für Auswahlfragen.
CREATE TABLE question_option (
    question_option_id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    option_text TEXT NOT NULL,
    option_value TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (question_id) REFERENCES question(question_id) ON DELETE CASCADE,
    UNIQUE (question_id, option_value)
);

-- Regeln für adaptive Fragebogen-Sprünge.
CREATE TABLE question_rule (
    question_rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
    question_id INTEGER NOT NULL,
    question_option_id INTEGER,
    next_question_id INTEGER NOT NULL,
    condition_value TEXT,
    FOREIGN KEY (question_id) REFERENCES question(question_id) ON DELETE CASCADE,
    FOREIGN KEY (question_option_id) REFERENCES question_option(question_option_id) ON DELETE CASCADE,
    FOREIGN KEY (next_question_id) REFERENCES question(question_id) ON DELETE CASCADE
);

-- Gestartete oder abgeschlossene Fragebogen-Sitzungen.
CREATE TABLE questionnaire_session (
    questionnaire_session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME,
    status TEXT NOT NULL DEFAULT 'aktiv' CHECK (status IN ('aktiv', 'abgeschlossen', 'abgebrochen')),
    FOREIGN KEY (user_id) REFERENCES app_user(user_id) ON DELETE CASCADE
);

-- Einzelne Antworten innerhalb einer Sitzung.
CREATE TABLE question_answer (
    question_answer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    questionnaire_session_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,
    question_option_id INTEGER,
    answer_text TEXT,
    answer_number REAL,
    FOREIGN KEY (questionnaire_session_id) REFERENCES questionnaire_session(questionnaire_session_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES question(question_id),
    FOREIGN KEY (question_option_id) REFERENCES question_option(question_option_id)
);

-- Produktkategorien wie Technik, Bücher oder Wellness.
CREATE TABLE product_category (
    product_category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name TEXT NOT NULL UNIQUE
);

-- Produkte aus Partner-Shops inklusive Preis, Bild und Affiliate-Link.
CREATE TABLE product (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_category_id INTEGER NOT NULL,
    partner_shop_id INTEGER NOT NULL,
    external_product_id TEXT,
    product_name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL CHECK (price >= 0),
    image_url TEXT,
    availability TEXT NOT NULL DEFAULT 'verfuegbar',
    affiliate_link TEXT NOT NULL,
    last_checked_at DATETIME,
    FOREIGN KEY (product_category_id) REFERENCES product_category(product_category_id),
    FOREIGN KEY (partner_shop_id) REFERENCES partner_shop(partner_shop_id)
);

-- Empfehlungen mit Begründung und Score.
CREATE TABLE recommendation (
    recommendation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    questionnaire_session_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    reason_text TEXT NOT NULL,
    score REAL NOT NULL CHECK (score >= 0),
    rank_position INTEGER,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (questionnaire_session_id) REFERENCES questionnaire_session(questionnaire_session_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    UNIQUE (questionnaire_session_id, product_id)
);

-- Favoriten bilden die Merkliste ab.
CREATE TABLE favorite (
    favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES app_user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE CASCADE,
    UNIQUE (user_id, product_id)
);

-- Erinnerungen an Geschenk-Anlässe.
CREATE TABLE reminder (
    reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    reminder_date DATETIME NOT NULL,
    occasion TEXT,
    is_done INTEGER NOT NULL DEFAULT 0 CHECK (is_done IN (0, 1)),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES app_user(user_id) ON DELETE CASCADE
);

-- Affiliate-Verkäufe mit Kaufwert und Provision.
CREATE TABLE affiliate_sale (
    affiliate_sale_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    partner_shop_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    product_category_id INTEGER NOT NULL,
    sale_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sale_amount REAL NOT NULL CHECK (sale_amount >= 0),
    commission_amount REAL NOT NULL CHECK (commission_amount >= 0),
    status TEXT NOT NULL DEFAULT 'offen' CHECK (status IN ('offen', 'bestaetigt', 'storniert')),
    FOREIGN KEY (user_id) REFERENCES app_user(user_id) ON DELETE SET NULL,
    FOREIGN KEY (partner_shop_id) REFERENCES partner_shop(partner_shop_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (product_category_id) REFERENCES product_category(product_category_id)
);

-- Indizes auf Fremdschlüsseln beschleunigen JOIN-Abfragen.
CREATE INDEX idx_app_user_role_id ON app_user(role_id);
CREATE INDEX idx_partner_shop_role_id ON partner_shop(role_id);
CREATE INDEX idx_product_category_id ON product(product_category_id);
CREATE INDEX idx_product_partner_shop_id ON product(partner_shop_id);
CREATE INDEX idx_question_answer_session_id ON question_answer(questionnaire_session_id);
CREATE INDEX idx_recommendation_session_id ON recommendation(questionnaire_session_id);
CREATE INDEX idx_favorite_user_id ON favorite(user_id);
CREATE INDEX idx_affiliate_sale_shop_id ON affiliate_sale(partner_shop_id);
