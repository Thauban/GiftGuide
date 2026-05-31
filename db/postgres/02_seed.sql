-- ============================================================
-- GiftGuide Seed-Daten
-- Diese Datei füllt die Datenbank mit realistischen Beispieldaten,
-- damit Tabellen, Views und Beziehungen in Adminer sichtbar sind.
-- ============================================================

-- Grundrollen der Anwendung.
INSERT INTO role (role_name) VALUES
    ('Gast'),
    ('Nutzer'),
    ('Admin'),
    ('Partner');

-- Beispielnutzer: zwei Gäste, zwei registrierte Nutzer und ein Admin.
INSERT INTO app_user (role_id, username, email, password_hash, preferred_language, is_guest) VALUES
    ((SELECT role_id FROM role WHERE role_name = 'Gast'), 'gast_anna', NULL, NULL, 'de', TRUE),
    ((SELECT role_id FROM role WHERE role_name = 'Gast'), 'gast_leon', NULL, NULL, 'de', TRUE),
    ((SELECT role_id FROM role WHERE role_name = 'Nutzer'), 'max123', 'max@example.com', 'demo_hash_only', 'de', FALSE),
    ((SELECT role_id FROM role WHERE role_name = 'Nutzer'), 'selma_h', 'selma@example.com', 'demo_hash_only', 'de', FALSE),
    ((SELECT role_id FROM role WHERE role_name = 'Admin'), 'admin', 'admin@giftguide.local', 'demo_hash_only', 'de', FALSE);

-- Partner-Shops mit unterschiedlichen Provisionssätzen.
INSERT INTO partner_shop (role_id, shop_name, website_url, commission_rate) VALUES
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Amazon', 'https://www.amazon.de', 0.0400),
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Otto', 'https://www.otto.de', 0.0500),
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Etsy', 'https://www.etsy.com', 0.0600),
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'Thalia', 'https://www.thalia.de', 0.0350),
    ((SELECT role_id FROM role WHERE role_name = 'Partner'), 'MediaMarkt', 'https://www.mediamarkt.de', 0.0300);

-- Fragen des kompakten Fragebogens: Empfänger, Anlass, Interessen, Stil, Budget und Freitext.
INSERT INTO question (question_text, question_type, display_order, is_active) VALUES
    ('Für wen ist das Geschenk?', 'single_choice', 1, TRUE),
    ('Wie alt ist die Person ungefähr?', 'single_choice', 2, TRUE),
    ('Zu welchem Anlass suchst du ein Geschenk?', 'single_choice', 3, TRUE),
    ('Welche Interessen passen zur Person?', 'multiple_choice', 4, TRUE),
    ('Welcher Stil passt am besten?', 'single_choice', 5, TRUE),
    ('Wie hoch ist dein Budget?', 'number', 6, TRUE),
    ('Gibt es etwas, das wir beachten sollen?', 'text', 7, TRUE);

-- Antwortoptionen für Auswahlfragen. option_value bleibt als technischer Code bewusst ASCII.
INSERT INTO question_option (question_id, option_text, option_value, sort_order) VALUES
    (1, 'Partnerin oder Partner', 'partner', 1),
    (1, 'Familie', 'familie', 2),
    (1, 'Freundin oder Freund', 'freund', 3),
    (1, 'Kollegin oder Kollege', 'kollege', 4),
    (2, 'Kind', 'kind', 1),
    (2, 'Teenager', 'teenager', 2),
    (2, 'Erwachsen', 'erwachsen', 3),
    (2, 'Seniorin oder Senior', 'senior', 4),
    (3, 'Geburtstag', 'geburtstag', 1),
    (3, 'Weihnachten', 'weihnachten', 2),
    (3, 'Danke sagen', 'danke', 3),
    (3, 'Jahrestag', 'jahrestag', 4),
    (4, 'Technik', 'technik', 1),
    (4, 'Bücher', 'buecher', 2),
    (4, 'Kreativität', 'kreativitaet', 3),
    (4, 'Wellness', 'wellness', 4),
    (4, 'Kochen', 'kochen', 5),
    (4, 'Gaming', 'gaming', 6),
    (5, 'Praktisch', 'praktisch', 1),
    (5, 'Persönlich', 'persoenlich', 2),
    (5, 'Luxuriös', 'luxurioes', 3),
    (5, 'Nachhaltig', 'nachhaltig', 4);

-- Einfache lineare Regeln: Nach jeder Frage folgt die nächste Frage.
-- Die Tabelle erlaubt später trotzdem adaptive Sprünge abhängig von Antworten.
INSERT INTO question_rule (question_id, question_option_id, next_question_id, condition_value) VALUES
    (1, NULL, 2, NULL),
    (2, NULL, 3, NULL),
    (3, NULL, 4, NULL),
    (4, NULL, 5, NULL),
    (5, NULL, 6, NULL),
    (6, NULL, 7, NULL);

-- Kategorien, unter denen Geschenkprodukte gruppiert werden.
INSERT INTO product_category (category_name) VALUES
    ('Technik'),
    ('Bücher'),
    ('Wellness'),
    ('Kreativ'),
    ('Küche'),
    ('Gaming'),
    ('Erlebnis');

-- Beispielprodukte aus verschiedenen Shops und Kategorien.
-- Die externen Produkt-IDs simulieren IDs aus echten Shop-APIs.
INSERT INTO product (product_category_id, partner_shop_id, external_product_id, product_name, description, price, image_url, availability, affiliate_link, last_checked_at) VALUES
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Technik'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'), 'AMZ-TRACK-001', 'Bluetooth Tracker', 'Kleiner Tracker für Schlüssel, Rucksack oder Tasche.', 24.99, 'https://example.com/images/bluetooth-tracker.jpg', 'verfügbar', 'https://example.com/affiliate/bluetooth-tracker', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Technik'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'MediaMarkt'), 'MM-SPEAKER-101', 'Mini Bluetooth Speaker', 'Kompakter Lautsprecher für Musik unterwegs.', 39.99, 'https://example.com/images/speaker.jpg', 'verfügbar', 'https://example.com/affiliate/speaker', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Wellness'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Otto'), 'OTT-DIFF-001', 'Aroma Diffuser', 'Diffuser mit warmem Licht für entspannte Abende.', 34.99, 'https://example.com/images/diffuser.jpg', 'verfügbar', 'https://example.com/affiliate/diffuser', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Wellness'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'), 'AMZ-MASS-204', 'Nackenmassagekissen', 'Massagekissen für Alltag, Homeoffice und Entspannung.', 49.99, 'https://example.com/images/massagekissen.jpg', 'verfügbar', 'https://example.com/affiliate/massagekissen', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Kreativ'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Etsy'), 'ETS-NOTE-001', 'Personalisiertes Notizbuch', 'Notizbuch mit Wunschname und schlichtem Cover.', 18.50, 'https://example.com/images/notizbuch.jpg', 'verfügbar', 'https://example.com/affiliate/notizbuch', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Kreativ'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Etsy'), 'ETS-PRINT-044', 'Individuelles Sternbild-Poster', 'Poster mit Datum, Ort und persönlichem Sternbild.', 29.90, 'https://example.com/images/sternbild-poster.jpg', 'verfügbar', 'https://example.com/affiliate/sternbild-poster', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Bücher'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Thalia'), 'THA-BOOK-778', 'Inspirierendes Sachbuch', 'Modernes Sachbuch für persönliche Entwicklung.', 16.00, 'https://example.com/images/sachbuch.jpg', 'verfügbar', 'https://example.com/affiliate/sachbuch', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Küche'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Otto'), 'OTT-COOK-092', 'Gewürzset Weltreise', 'Ausgewählte Gewürze für kreative Küchenabende.', 22.99, 'https://example.com/images/gewuerzset.jpg', 'verfügbar', 'https://example.com/affiliate/gewuerzset', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Gaming'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'MediaMarkt'), 'MM-GAME-512', 'Gaming Headset', 'Bequemes Headset mit Mikrofon und gutem Klang.', 59.99, 'https://example.com/images/gaming-headset.jpg', 'verfügbar', 'https://example.com/affiliate/gaming-headset', CURRENT_TIMESTAMP),
    ((SELECT product_category_id FROM product_category WHERE category_name = 'Erlebnis'), (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'), 'AMZ-EXP-300', 'Escape-Room Gutschein', 'Gemeinsames Erlebnis für zwei Personen.', 45.00, 'https://example.com/images/escape-room.jpg', 'verfügbar', 'https://example.com/affiliate/escape-room', CURRENT_TIMESTAMP);

-- Mehrere Fragebogen-Sitzungen zeigen abgeschlossene und aktive Nutzung.
INSERT INTO questionnaire_session (user_id, started_at, completed_at, status) VALUES
    ((SELECT user_id FROM app_user WHERE username = 'gast_anna'), '2026-05-20 18:10:00', '2026-05-20 18:14:00', 'abgeschlossen'),
    ((SELECT user_id FROM app_user WHERE username = 'gast_leon'), '2026-05-21 12:30:00', '2026-05-21 12:35:00', 'abgeschlossen'),
    ((SELECT user_id FROM app_user WHERE username = 'max123'), '2026-05-22 20:00:00', '2026-05-22 20:07:00', 'abgeschlossen'),
    ((SELECT user_id FROM app_user WHERE username = 'selma_h'), '2026-05-23 09:15:00', NULL, 'aktiv');

-- Antworten zu drei abgeschlossenen Fragebogen-Sitzungen.
-- Auswahlantworten nutzen question_option_id, Budget nutzt answer_number, Freitext nutzt answer_text.
INSERT INTO question_answer (questionnaire_session_id, question_id, question_option_id, answer_text, answer_number) VALUES
    -- Sitzung 1: praktisches Technikgeschenk für Partner zum Geburtstag.
    (1, 1, (SELECT question_option_id FROM question_option WHERE question_id = 1 AND option_value = 'partner'), NULL, NULL),
    (1, 2, (SELECT question_option_id FROM question_option WHERE question_id = 2 AND option_value = 'erwachsen'), NULL, NULL),
    (1, 3, (SELECT question_option_id FROM question_option WHERE question_id = 3 AND option_value = 'geburtstag'), NULL, NULL),
    (1, 4, (SELECT question_option_id FROM question_option WHERE question_id = 4 AND option_value = 'technik'), NULL, NULL),
    (1, 5, (SELECT question_option_id FROM question_option WHERE question_id = 5 AND option_value = 'praktisch'), NULL, NULL),
    (1, 6, NULL, NULL, 40),
    (1, 7, NULL, 'Soll nützlich sein und nicht zu kitschig wirken.', NULL),

    -- Sitzung 2: ruhiges Wellness-Geschenk für Familie zu Weihnachten.
    (2, 1, (SELECT question_option_id FROM question_option WHERE question_id = 1 AND option_value = 'familie'), NULL, NULL),
    (2, 2, (SELECT question_option_id FROM question_option WHERE question_id = 2 AND option_value = 'senior'), NULL, NULL),
    (2, 3, (SELECT question_option_id FROM question_option WHERE question_id = 3 AND option_value = 'weihnachten'), NULL, NULL),
    (2, 4, (SELECT question_option_id FROM question_option WHERE question_id = 4 AND option_value = 'wellness'), NULL, NULL),
    (2, 5, (SELECT question_option_id FROM question_option WHERE question_id = 5 AND option_value = 'persoenlich'), NULL, NULL),
    (2, 6, NULL, NULL, 55),
    (2, 7, NULL, 'Bitte etwas Ruhiges für zuhause.', NULL),

    -- Sitzung 3: kleine Aufmerksamkeit für einen Freund, der gerne kocht.
    (3, 1, (SELECT question_option_id FROM question_option WHERE question_id = 1 AND option_value = 'freund'), NULL, NULL),
    (3, 2, (SELECT question_option_id FROM question_option WHERE question_id = 2 AND option_value = 'erwachsen'), NULL, NULL),
    (3, 3, (SELECT question_option_id FROM question_option WHERE question_id = 3 AND option_value = 'danke'), NULL, NULL),
    (3, 4, (SELECT question_option_id FROM question_option WHERE question_id = 4 AND option_value = 'kochen'), NULL, NULL),
    (3, 5, (SELECT question_option_id FROM question_option WHERE question_id = 5 AND option_value = 'nachhaltig'), NULL, NULL),
    (3, 6, NULL, NULL, 25),
    (3, 7, NULL, 'Kleine Aufmerksamkeit, am besten alltagstauglich.', NULL);

-- Empfehlungen zeigen den Kern-USP: Produkt plus nachvollziehbare Begründung.
INSERT INTO recommendation (questionnaire_session_id, product_id, reason_text, score, rank_position) VALUES
    -- Empfehlungen für Sitzung 1.
    (1, (SELECT product_id FROM product WHERE product_name = 'Bluetooth Tracker'), 'Passt zum Technik-Interesse, ist praktisch und bleibt im angegebenen Budget.', 0.94, 1),
    (1, (SELECT product_id FROM product WHERE product_name = 'Mini Bluetooth Speaker'), 'Technisches Geschenk mit hohem Nutzwert, aber etwas näher an der Budgetgrenze.', 0.86, 2),
    (1, (SELECT product_id FROM product WHERE product_name = 'Personalisiertes Notizbuch'), 'Ergänzende persönliche Option, falls das Geschenk emotionaler wirken soll.', 0.72, 3),

    -- Empfehlungen für Sitzung 2.
    (2, (SELECT product_id FROM product WHERE product_name = 'Nackenmassagekissen'), 'Passt zum Wunsch nach Entspannung zuhause und liegt innerhalb des Budgets.', 0.91, 1),
    (2, (SELECT product_id FROM product WHERE product_name = 'Aroma Diffuser'), 'Ruhiges Wellness-Geschenk für gemütliche Abende.', 0.87, 2),
    (2, (SELECT product_id FROM product WHERE product_name = 'Inspirierendes Sachbuch'), 'Gute Alternative, wenn die Person gerne liest und ein ruhiges Geschenk gewünscht ist.', 0.69, 3),

    -- Empfehlungen für Sitzung 3.
    (3, (SELECT product_id FROM product WHERE product_name = 'Gewürzset Weltreise'), 'Kleine, alltagstaugliche Aufmerksamkeit für jemanden, der gerne kocht.', 0.93, 1),
    (3, (SELECT product_id FROM product WHERE product_name = 'Inspirierendes Sachbuch'), 'Preislich passend und als Danke-Geschenk neutral genug.', 0.74, 2);

-- Favoriten bilden die Merkliste ab.
INSERT INTO favorite (user_id, product_id) VALUES
    ((SELECT user_id FROM app_user WHERE username = 'gast_anna'), (SELECT product_id FROM product WHERE product_name = 'Bluetooth Tracker')),
    ((SELECT user_id FROM app_user WHERE username = 'gast_anna'), (SELECT product_id FROM product WHERE product_name = 'Mini Bluetooth Speaker')),
    ((SELECT user_id FROM app_user WHERE username = 'gast_leon'), (SELECT product_id FROM product WHERE product_name = 'Nackenmassagekissen')),
    ((SELECT user_id FROM app_user WHERE username = 'max123'), (SELECT product_id FROM product WHERE product_name = 'Gewürzset Weltreise')),
    ((SELECT user_id FROM app_user WHERE username = 'selma_h'), (SELECT product_id FROM product WHERE product_name = 'Individuelles Sternbild-Poster'));

-- Erinnerungen für kommende Geschenk-Anlässe.
INSERT INTO reminder (user_id, title, reminder_date, occasion, is_done) VALUES
    ((SELECT user_id FROM app_user WHERE username = 'max123'), 'Geschenk für Geburtstag kaufen', '2026-06-15 09:00:00', 'Geburtstag', FALSE),
    ((SELECT user_id FROM app_user WHERE username = 'selma_h'), 'Weihnachtsgeschenk für Mama prüfen', '2026-12-05 18:00:00', 'Weihnachten', FALSE),
    ((SELECT user_id FROM app_user WHERE username = 'max123'), 'Danke-Geschenk bestellen', '2026-06-03 12:00:00', 'Danke sagen', TRUE);

-- Beispielhafte Affiliate-Verkäufe mit Kaufwert, Provision und Status.
INSERT INTO affiliate_sale (user_id, partner_shop_id, product_id, product_category_id, sale_date, sale_amount, commission_amount, status) VALUES
    -- Bestätigter Kauf eines registrierten Nutzers.
    (
        (SELECT user_id FROM app_user WHERE username = 'max123'),
        (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Otto'),
        (SELECT product_id FROM product WHERE product_name = 'Gewürzset Weltreise'),
        (SELECT product_category_id FROM product_category WHERE category_name = 'Küche'),
        '2026-05-22 20:20:00',
        22.99,
        1.15,
        'bestätigt'
    ),
    -- Bestätigter Kauf aus einer Gast-Session.
    (
        (SELECT user_id FROM app_user WHERE username = 'gast_anna'),
        (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'),
        (SELECT product_id FROM product WHERE product_name = 'Bluetooth Tracker'),
        (SELECT product_category_id FROM product_category WHERE category_name = 'Technik'),
        '2026-05-20 18:30:00',
        24.99,
        1.00,
        'bestätigt'
    ),
    -- Offener Kauf, dessen Provision noch nicht final bestätigt wurde.
    (
        (SELECT user_id FROM app_user WHERE username = 'gast_leon'),
        (SELECT partner_shop_id FROM partner_shop WHERE shop_name = 'Amazon'),
        (SELECT product_id FROM product WHERE product_name = 'Nackenmassagekissen'),
        (SELECT product_category_id FROM product_category WHERE category_name = 'Wellness'),
        '2026-05-21 12:50:00',
        49.99,
        2.00,
        'offen'
    );
