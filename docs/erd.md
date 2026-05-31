# GiftGuide ER-Modell

```mermaid
erDiagram
    role ||--o{ app_user : besitzt
    role ||--o{ partner_shop : besitzt
    app_user ||--o{ questionnaire_session : startet
    app_user ||--o{ favorite : speichert
    app_user ||--o{ reminder : erstellt
    app_user ||--o{ affiliate_sale : verursacht

    question ||--o{ question_option : enthält
    question ||--o{ question_rule : steuert_und_verweist_auf_naechste
    question ||--o{ question_answer : wird_beantwortet
    question_option ||--o{ question_rule : löst_aus
    question_option ||--o{ question_answer : wird_ausgewählt
    questionnaire_session ||--o{ question_answer : enthält
    questionnaire_session ||--o{ recommendation : erzeugt

    product_category ||--o{ product : gruppiert
    partner_shop ||--o{ product : bietet_an
    product ||--o{ recommendation : wird_empfohlen
    product ||--o{ favorite : wird_gemerkt
    product ||--o{ affiliate_sale : wird_verkauft
    product_category ||--o{ affiliate_sale : wird_ausgewertet
    partner_shop ||--o{ affiliate_sale : erhält_sale

    role {
        integer role_id PK
        text role_name
    }

    app_user {
        integer user_id PK
        integer role_id FK
        text username
        text email
        text password_hash
        text preferred_language
        timestamp created_at
        boolean is_guest
    }

    partner_shop {
        integer partner_shop_id PK
        integer role_id FK
        text shop_name
        text website_url
        numeric commission_rate
    }

    question {
        integer question_id PK
        text question_text
        text question_type
        integer display_order
        boolean is_active
    }

    question_option {
        integer question_option_id PK
        integer question_id FK
        text option_text
        text option_value
        integer sort_order
    }

    question_rule {
        integer question_rule_id PK
        integer question_id FK
        integer question_option_id FK
        integer next_question_id FK
        text condition_value
    }

    questionnaire_session {
        integer questionnaire_session_id PK
        integer user_id FK
        timestamp started_at
        timestamp completed_at
        text status
    }

    question_answer {
        integer question_answer_id PK
        integer questionnaire_session_id FK
        integer question_id FK
        integer question_option_id FK
        text answer_text
        numeric answer_number
    }

    product_category {
        integer product_category_id PK
        text category_name
    }

    product {
        integer product_id PK
        integer product_category_id FK
        integer partner_shop_id FK
        text external_product_id
        text product_name
        text description
        numeric price
        text image_url
        text availability
        text affiliate_link
        timestamp last_checked_at
    }

    recommendation {
        integer recommendation_id PK
        integer questionnaire_session_id FK
        integer product_id FK
        text reason_text
        numeric score
        integer rank_position
        timestamp created_at
    }

    favorite {
        integer favorite_id PK
        integer user_id FK
        integer product_id FK
        timestamp created_at
    }

    reminder {
        integer reminder_id PK
        integer user_id FK
        text title
        timestamp reminder_date
        text occasion
        boolean is_done
        timestamp created_at
    }

    affiliate_sale {
        integer affiliate_sale_id PK
        integer user_id FK
        integer partner_shop_id FK
        integer product_id FK
        integer product_category_id FK
        timestamp sale_date
        numeric sale_amount
        numeric commission_amount
        text status
    }
```

Das Diagramm zeigt die wichtigsten Entitäten der GiftGuide-Datenbank. Im Zentrum stehen der Fragebogen, die daraus entstehenden Empfehlungen und die Produkte aus Partner-Shops.
