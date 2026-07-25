-- +migrate Up
CREATE TABLE exams (
    id    SERIAL PRIMARY KEY,
    code  VARCHAR(20) NOT NULL UNIQUE,
    name  VARCHAR(100) NOT NULL
);

INSERT INTO exams (code, name) VALUES
    ('UPSC',      'UPSC'),
    ('SSC',       'SSC'),
    ('BANKING',   'Banking'),
    ('RAILWAY',   'Railway'),
    ('NEET',      'NEET'),
    ('JEE',       'JEE'),
    ('STATE_PSC', 'State PSC')
ON CONFLICT (code) DO NOTHING;
