-- Optionaler SQLite-Seed für lokale Tests ohne Docker.
-- Die ausführlicheren PostgreSQL-Daten liegen in db/postgres/02_seed.sql.

-- Grundrollen der Anwendung.
INSERT INTO role (role_name) VALUES
    ('Gast'),
    ('Nutzer'),
    ('Admin'),
    ('Partner');

-- Demo-Nutzer: ein Gast und ein registrierter Nutzer.
INSERT INTO app_user (role_id, username, email, password_hash, preferred_language, is_guest) VALUES
    ((SELECT role_id FROM role WHERE role_name = 'Gast'), 'gast_demo', NULL, NULL, 'de', 1),
    ((SELECT role_id FROM role WHERE role_name = 'Nutzer'), 'max123', 'max@example.com', 'demo_hash_only', 'de', 0);

-- Drei Beispielshops für Affiliate-Weiterleitungen.
INSERT INTO partner_shop (role_id, shop_name, website_url, commission_rate) VALUES
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Amazon', 'https://www.amazon.de', 0.04),
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Otto', 'https://www.otto.de', 0.05),
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Etsy', 'https://www.etsy.com', 0.06);

-- Kompakter Fragebogen für den Geschenkprozess.
INSERT INTO question (question_text, question_type, display_order, is_active) VALUES
    ('Fuer wen ist das Geschenk?', 'single_choice', 1, 1),
    ('Zu welchem Anlass suchst du ein Geschenk?', 'single_choice', 2, 1),
    ('Welche Interessen passen zur Person?', 'multiple_choice', 3, 1),
    ('Wie hoch ist dein Budget?', 'number', 4, 1),
    ('Gibt es etwas, das wir beachten sollen?', 'text', 5, 1);

-- Antwortoptionen zu Anlass, Empfänger und Interessen.
INSERT INTO question_option (question_id, option_text, option_value, sort_order) VALUES
    (1, 'Freundin oder Freund', 'partner', 1),
    (1, 'Familie', 'familie', 2),
    (1, 'Kollegin oder Kollege', 'kollege', 3),
    (2, 'Geburtstag', 'geburtstag', 1),
    (2, 'Weihnachten', 'weihnachten', 2),
    (2, 'Danke sagen', 'danke', 3),
    (3, 'Technik', 'technik', 1),
    (3, 'Buecher', 'buecher', 2),
    (3, 'Kreativitaet', 'kreativitaet', 3),
    (3, 'Wellness', 'wellness', 4);

-- Einfache Regeln für die Reihenfolge der Fragen.
INSERT INTO question_rule (question_id, question_option_id, next_question_id, condition_value) VALUES
    (1, (SELECT question_option_id FROM question_option WHERE question_id = 1 AND option_value = 'partner'), 2, 'partner'),
    (1, (SELECT question_option_id FROM question_option WHERE question_id = 1 AND option_value = 'familie'), 2, 'familie'),
    (2, NULL, 3, NULL),
    (3, NULL, 4, NULL),
    (4, NULL, 5, NULL);

-- Produktkategorien für die Beispielprodukte.
INSERT INTO product_category (category_name) VALUES
    ('Technik'),
    ('Buecher'),
    ('Wellness'),
    ('Kreativ');

-- Beispielprodukte mit Preisen und Affiliate-Links.
INSERT INTO product (product_category_id, partner_shop_id, external_product_id, product_name, description, price, image_url, availability, affiliate_link, last_checked_at) VALUES
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Technik'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'), 'AMZ-001', 'Bluetooth Tracker', 'Kleiner Tracker fuer Schluessel oder Tasche.', 24.99, 'https://example.com/tracker.jpg', 'verfuegbar', 'https://example.com/affiliate/tracker', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Wellness'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Otto'), 'OTT-001', 'Aroma Diffuser', 'Diffuser mit Licht fuer entspannte Abende.', 34.99, 'https://example.com/diffuser.jpg', 'verfuegbar', 'https://example.com/affiliate/diffuser', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Kreativ'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Etsy'), 'ETS-001', 'Personalisiertes Notizbuch', 'Notizbuch mit personalisierbarem Namen.', 18.50, 'https://example.com/notizbuch.jpg', 'verfuegbar', 'https://example.com/affiliate/notizbuch', CURRENT_TIMESTAMP);

-- Eine abgeschlossene Demo-Sitzung.
INSERT INTO questionnaire_session (user_id, completed_at, status) VALUES
    ((SELECT user_id FROM app_user WHERE username = 'gast_demo'), CURRENT_TIMESTAMP, 'abgeschlossen');

-- Antworten der Demo-Sitzung.
INSERT INTO question_answer (questionnaire_session_id, question_id, question_option_id, answer_text, answer_number) VALUES
    (1, 1, (SELECT question_option_id FROM question_option WHERE question_id = 1 AND option_value = 'partner'), NULL, NULL),
    (1, 2, (SELECT question_option_id FROM question_option WHERE question_id = 2 AND option_value = 'geburtstag'), NULL, NULL),
    (1, 3, (SELECT question_option_id FROM question_option WHERE question_id = 3 AND option_value = 'technik'), NULL, NULL),
    (1, 4, NULL, NULL, 30),
    (1, 5, NULL, 'Soll persoenlich wirken, aber nicht zu teuer sein.', NULL);

-- Empfehlungen mit Begründung und Score.
INSERT INTO recommendation (questionnaire_session_id, product_id, reason_text, score, rank_position) VALUES
    (1, (SELECT product_id FROM product WHERE product_name = 'Bluetooth Tracker'), 'Passt zum Technik-Interesse und bleibt im Budget.', 0.92, 1),
    (1, (SELECT product_id FROM product WHERE product_name = 'Personalisiertes Notizbuch'), 'Wirkt persoenlich und eignet sich gut als Geburtstagsgeschenk.', 0.81, 2);

-- Merkliste des Gastnutzers.
INSERT INTO favorite (user_id, product_id) VALUES
    ((SELECT user_id FROM app_user WHERE username = 'gast_demo'), (SELECT product_id FROM product WHERE product_name = 'Bluetooth Tracker'));

-- Beispiel-Erinnerung für einen registrierten Nutzer.
INSERT INTO reminder (user_id, title, reminder_date, occasion) VALUES
    ((SELECT user_id FROM app_user WHERE username = 'max123'), 'Geschenk fuer Geburtstag kaufen', '2026-06-15 09:00:00', 'Geburtstag');

-- Beispielhafter Affiliate-Verkauf.
INSERT INTO affiliate_sale (user_id, partner_shop_id, product_id, product_category_id, sale_amount, commission_amount, status) VALUES
    (
        (SELECT user_id FROM app_user WHERE username = 'max123'),
        (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'),
        (SELECT product_id FROM product WHERE product_name = 'Bluetooth Tracker'),
        (SELECT product_category_id FROM product_category WHERE category_name = 'Technik'),
        24.99,
        1.00,
        'bestaetigt'
    );
