-- +migrate Up
CREATE TABLE plans (
    id            SERIAL PRIMARY KEY,
    code          VARCHAR(30) NOT NULL UNIQUE,
    name          VARCHAR(50) NOT NULL,
    price_paise   INT NOT NULL DEFAULT 0,
    duration_days INT NOT NULL DEFAULT 30,
    is_trial      BOOLEAN NOT NULL DEFAULT false,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO plans (code, name, price_paise, duration_days, is_trial) VALUES
    ('free_trial', 'Free Trial', 0, 7, true),
    ('pro',        'Pro',        49900, 30, false),
    ('ultra',      'Ultra',      99900, 30, false),
    ('ultra_max',  'Ultra Max',  199900, 30, false);