-- ===== 000001_create_users_table.up.sql =====
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'student',
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ===== 000002_create_courses_table.up.SQL =====
CREATE TABLE IF NOT EXISTS courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ===== 000003_create_lessons_table.up.sql =====
CREATE TABLE IF NOT EXISTS lessons (
    id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    video_url TEXT,
    duration INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lessons_course_id ON lessons(course_id);

-- ===== 000004_add_role_constraint.up.sql =====
-- The "role" column and its 'student' default already exist from migration
-- 000001. This migration only ADDS a CHECK constraint so the database itself
-- rejects any role outside the known set, keeping it in sync with
-- internal/constants/roles.go as Teacher/Parent/Admin get built out.
ALTER TABLE users
    ADD CONSTRAINT chk_users_role
    CHECK (role IN ('student', 'teacher', 'parent', 'admin'));

-- ===== 000005_replace_courses_with_categories.up.sql =====
-- Day 1 created placeholder "courses" and "lessons" tables that no feature
-- ever used. Day 2 replaces them with a proper hierarchy:
-- course_categories -> subjects -> lessons -> notes.
-- Drop the old, unused tables first (lessons references courses via FK,
-- so it must go first) before introducing the new schema.
DROP TABLE IF EXISTS lessons;
DROP TABLE IF EXISTS courses;

CREATE TABLE IF NOT EXISTS course_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    icon VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ===== 000006_create_subjects_table.up.sql =====
CREATE TABLE IF NOT EXISTS subjects (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES course_categories(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    thumbnail TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subjects_category_id ON subjects(category_id);

-- ===== 000007_create_lessons_table.up.sql =====
-- Recreates "lessons" with the Day 2 schema (subject_id, pdf_url, order_number)
-- replacing the Day 1 placeholder that was dropped in migration 000005.
CREATE TABLE IF NOT EXISTS lessons (
    id SERIAL PRIMARY KEY,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url TEXT,
    pdf_url TEXT,
    duration INTEGER,
    order_number INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lessons_subject_id ON lessons(subject_id);

-- ===== 000008_create_notes_table.up.sql =====
CREATE TABLE IF NOT EXISTS notes (
    id SERIAL PRIMARY KEY,
    lesson_id INTEGER NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    pdf_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notes_lesson_id ON notes(lesson_id);

-- ===== 000009_seed_course_data.up.sql =====
-- Sample data so the Flutter screens have something to render immediately.
-- Uses INSERT ... RETURNING via CTEs to wire up foreign keys without
-- hardcoding IDs (safe to run on a fresh database).

-- Categories
WITH cat_academic AS (
    INSERT INTO course_categories (name, icon) VALUES ('Academic', 'school') RETURNING id
),
cat_science AS (
    INSERT INTO course_categories (name, icon) VALUES ('Science', 'science') RETURNING id
),
cat_programming AS (
    INSERT INTO course_categories (name, icon) VALUES ('Programming', 'code') RETURNING id
),
cat_mathematics AS (
    INSERT INTO course_categories (name, icon) VALUES ('Mathematics', 'calculate') RETURNING id
),
cat_languages AS (
    INSERT INTO course_categories (name, icon) VALUES ('Languages', 'translate') RETURNING id
),
cat_competitive AS (
    INSERT INTO course_categories (name, icon) VALUES ('Competitive Exams', 'emoji_events') RETURNING id
),

-- Subjects under Academic -> Mathematics
subj_mathematics AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'Mathematics', 'Core mathematics concepts for school students.', NULL FROM cat_academic
    RETURNING id
),

-- Subjects under Science
subj_physics AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'Physics', 'Fundamentals of physics: motion, energy, and forces.', NULL FROM cat_science
    RETURNING id
),
subj_chemistry AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'Chemistry', 'Introduction to elements, compounds, and reactions.', NULL FROM cat_science
    RETURNING id
),
subj_biology AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'Biology', 'Life sciences: cells, genetics, and ecosystems.', NULL FROM cat_science
    RETURNING id
),

-- Subjects under Programming
subj_flutter AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'Flutter', 'Build cross-platform apps with Flutter and Dart.', NULL FROM cat_programming
    RETURNING id
),
subj_golang AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'Golang', 'Backend development with Go and the Gin framework.', NULL FROM cat_programming
    RETURNING id
),
subj_postgresql AS (
    INSERT INTO subjects (category_id, name, description, thumbnail)
    SELECT id, 'PostgreSQL', 'Relational databases and SQL fundamentals.', NULL FROM cat_programming
    RETURNING id
)

-- Lessons under Mathematics
INSERT INTO lessons (subject_id, title, description, video_url, pdf_url, duration, order_number)
SELECT id, 'Introduction', 'Overview of what this course covers.', NULL, NULL, 10, 1 FROM subj_mathematics
UNION ALL
SELECT id, 'Algebra', 'Variables, expressions, and equations.', NULL, NULL, 20, 2 FROM subj_mathematics
UNION ALL
SELECT id, 'Geometry', 'Shapes, angles, and spatial reasoning.', NULL, NULL, 25, 3 FROM subj_mathematics;

-- ===== 000010_create_progress_table.up.sql =====
-- Tracks which lessons each user has completed. One row per (user, lesson);
-- re-marking a lesson complete just updates completed_at instead of erroring.
CREATE TABLE IF NOT EXISTS lesson_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id INTEGER NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    completed_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_lesson_progress_user ON lesson_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_lesson ON lesson_progress(lesson_id);


-- ===== 000011_add_sample_media_urls.up.sql =====
-- Adds real, publicly hosted sample video/PDF URLs to the seeded lessons
-- (migration 000009 left video_url/pdf_url NULL) so video playback and PDF
-- notes can actually be tested end-to-end, not just their empty states.
UPDATE lessons SET
    video_url = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
WHERE title = 'Introduction' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

UPDATE lessons SET
    video_url = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4'
WHERE title = 'Algebra' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

UPDATE lessons SET
    video_url = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'
WHERE title = 'Geometry' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

-- Sample PDF notes (W3C's public dummy.pdf) attached to each Mathematics lesson.
INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, l.title || ' - Notes', 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf'
FROM lessons l
JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics';


-- ===== 000012_fix_sample_media_urls.up.sql =====
UPDATE lessons SET
    video_url = 'https://www.w3schools.com/html/mov_bbb.mp4'
WHERE subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics')
  AND video_url IS NOT NULL;

UPDATE notes SET
    pdf_url = 'https://raw.githubusercontent.com/mozilla/pdf.js/master/web/compressed.tracemonkey-pldi-09.pdf'
WHERE title LIKE '% - Notes';

-- ===== 000013_fix_sample_durations.up.sql =====
UPDATE lessons SET duration = 1
WHERE subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics')
  AND video_url IS NOT NULL;

-- ===== 000014_add_real_educational_content.up.sql =====
-- Replaces all shared/placeholder content with real, subject-specific
-- educational content. Every lesson below gets its own genuine PDF notes
-- (self-hosted from backend/static/notes/, served via /static/*).
--
-- Videos are intentionally set to NULL here: there is no freely available,
-- verified catalog of direct-linkable (.mp4) topic-matched educational
-- videos to seed with honestly. Leaving video_url NULL triggers the
-- existing "No video available for this lesson" empty state rather than
-- showing unrelated placeholder footage. Add real video_url values later
-- once actual lecture videos are recorded/hosted (Cloudinary, S3, etc.) â€”
-- no code change is needed, the player already reads whatever URL is set.

-- 1) New subjects: History (under Academic), English (under Languages).
INSERT INTO subjects (category_id, name, description, thumbnail)
SELECT id, 'History', 'Key events and figures that shaped the modern world.', NULL
FROM course_categories WHERE name = 'Academic'
ON CONFLICT DO NOTHING;

INSERT INTO subjects (category_id, name, description, thumbnail)
SELECT id, 'English', 'Grammar, vocabulary, and writing skills.', NULL
FROM course_categories WHERE name = 'Languages'
ON CONFLICT DO NOTHING;

-- 2) Remove the old cartoon video URLs from the Mathematics lessons â€”
-- see comment above on why no replacement video is seeded here.
UPDATE lessons SET video_url = NULL
WHERE subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

-- 3) Delete the old shared/placeholder notes rows entirely (GitHub PDF.js
-- paper, W3C dummy.pdf) â€” they'll be replaced by real per-lesson notes below.
DELETE FROM notes WHERE lesson_id IN (
    SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics'
);

-- 4) New lessons for Physics, Chemistry, Flutter, Golang, History, English
-- (3 each, matching Mathematics' existing structure).
INSERT INTO lessons (subject_id, title, description, video_url, pdf_url, duration, order_number)
SELECT s.id, 'Introduction to Physics', 'What physics is and its major branches.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Physics'
UNION ALL
SELECT s.id, 'Motion and Forces', 'Newton''s three laws of motion explained.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Physics'
UNION ALL
SELECT s.id, 'Energy and Work', 'Kinetic and potential energy, and conservation of energy.', NULL, NULL, 10, 3 FROM subjects s WHERE s.name = 'Physics'
UNION ALL
SELECT s.id, 'Introduction to Chemistry', 'States of matter and physical vs chemical change.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Chemistry'
UNION ALL
SELECT s.id, 'Atoms and Molecules', 'The building blocks of all matter.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Chemistry'
UNION ALL
SELECT s.id, 'Chemical Reactions', 'How substances transform into new substances.', NULL, NULL, 10, 3 FROM subjects s WHERE s.name = 'Chemistry'
UNION ALL
SELECT s.id, 'Introduction to Flutter', 'What Flutter is and why developers use it.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Flutter'
UNION ALL
SELECT s.id, 'Widgets and Layouts', 'Stateless vs stateful widgets and common layouts.', NULL, NULL, 12, 2 FROM subjects s WHERE s.name = 'Flutter'
UNION ALL
SELECT s.id, 'State Management', 'Managing app data with the Provider pattern.', NULL, NULL, 12, 3 FROM subjects s WHERE s.name = 'Flutter'
UNION ALL
SELECT s.id, 'Go Language Fundamentals', 'What Go is and writing your first program.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Golang'
UNION ALL
SELECT s.id, 'Functions and Structs', 'Defining functions, structs, and methods in Go.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Golang'
UNION ALL
SELECT s.id, 'Concurrency Basics', 'Goroutines and channels for concurrent programs.', NULL, NULL, 10, 3 FROM subjects s WHERE s.name = 'Golang'
UNION ALL
SELECT s.id, 'Ancient Civilizations', 'Mesopotamia, Egypt, the Indus Valley, and ancient China.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'History'
UNION ALL
SELECT s.id, 'World Wars', 'Causes and impact of World War I and II.', NULL, NULL, 12, 2 FROM subjects s WHERE s.name = 'History'
UNION ALL
SELECT s.id, 'Indian Independence Movement', 'Key figures and events leading to independence in 1947.', NULL, NULL, 10, 3 FROM subjects s WHERE s.name = 'History'
UNION ALL
SELECT s.id, 'Grammar Basics', 'Parts of speech, sentence structure, and tenses.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'English'
UNION ALL
SELECT s.id, 'Vocabulary Building', 'Using context clues, prefixes, and suffixes.', NULL, NULL, 8, 2 FROM subjects s WHERE s.name = 'English'
UNION ALL
SELECT s.id, 'Writing Skills', 'The writing process and clear paragraph structure.', NULL, NULL, 10, 3 FROM subjects s WHERE s.name = 'English';

-- 5) Real notes for every lesson across all 7 subjects, each pointing to
-- its own genuine PDF (relative path â€” Flutter resolves the full URL via
-- ApiConstants.resolveMediaUrl so it works on any host/deployment).
INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, l.title || ' Notes', '/static/notes/mathematics-introduction.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Introduction'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/mathematics-algebra.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Algebra'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/mathematics-geometry.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Geometry'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/physics-introduction.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Physics' AND l.title = 'Introduction to Physics'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/physics-motion-and-forces.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Physics' AND l.title = 'Motion and Forces'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/physics-energy-and-work.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Physics' AND l.title = 'Energy and Work'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/chemistry-introduction.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Chemistry' AND l.title = 'Introduction to Chemistry'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/chemistry-atoms-and-molecules.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Chemistry' AND l.title = 'Atoms and Molecules'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/chemistry-chemical-reactions.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Chemistry' AND l.title = 'Chemical Reactions'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/flutter-introduction.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Flutter' AND l.title = 'Introduction to Flutter'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/flutter-widgets-and-layouts.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Flutter' AND l.title = 'Widgets and Layouts'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/flutter-state-management.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Flutter' AND l.title = 'State Management'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/golang-fundamentals.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Golang' AND l.title = 'Go Language Fundamentals'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/golang-functions-and-structs.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Golang' AND l.title = 'Functions and Structs'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/golang-concurrency-basics.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Golang' AND l.title = 'Concurrency Basics'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/history-ancient-civilizations.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'Ancient Civilizations'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/history-world-wars.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'World Wars'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/history-indian-independence.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'Indian Independence Movement'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/english-grammar-basics.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'English' AND l.title = 'Grammar Basics'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/english-vocabulary-building.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'English' AND l.title = 'Vocabulary Building'
UNION ALL
SELECT l.id, l.title || ' Notes', '/static/notes/english-writing-skills.pdf' FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'English' AND l.title = 'Writing Skills';


-- ===== 000015_add_lesson_videos.up.sql =====
-- Adds a real, lesson-specific video to every lesson: a short slide-video
-- rendered directly from that lesson's own PDF notes (backend/static/videos/),
-- so the video content always matches the lesson topic exactly — no
-- generic/unrelated footage. Self-hosted via the same /static/* route
-- already used for PDF notes (see migration 000014 and main.go).
UPDATE lessons SET video_url = '/static/videos/mathematics-introduction.mp4'
WHERE title = 'Introduction' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

UPDATE lessons SET video_url = '/static/videos/mathematics-algebra.mp4'
WHERE title = 'Algebra' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

UPDATE lessons SET video_url = '/static/videos/mathematics-geometry.mp4'
WHERE title = 'Geometry' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Mathematics');

UPDATE lessons SET video_url = '/static/videos/physics-introduction.mp4'
WHERE title = 'Introduction to Physics' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Physics');

UPDATE lessons SET video_url = '/static/videos/physics-motion-and-forces.mp4'
WHERE title = 'Motion and Forces' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Physics');

UPDATE lessons SET video_url = '/static/videos/physics-energy-and-work.mp4'
WHERE title = 'Energy and Work' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Physics');

UPDATE lessons SET video_url = '/static/videos/chemistry-introduction.mp4'
WHERE title = 'Introduction to Chemistry' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Chemistry');

UPDATE lessons SET video_url = '/static/videos/chemistry-atoms-and-molecules.mp4'
WHERE title = 'Atoms and Molecules' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Chemistry');

UPDATE lessons SET video_url = '/static/videos/chemistry-chemical-reactions.mp4'
WHERE title = 'Chemical Reactions' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Chemistry');

UPDATE lessons SET video_url = '/static/videos/flutter-introduction.mp4'
WHERE title = 'Introduction to Flutter' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Flutter');

UPDATE lessons SET video_url = '/static/videos/flutter-widgets-and-layouts.mp4'
WHERE title = 'Widgets and Layouts' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Flutter');

UPDATE lessons SET video_url = '/static/videos/flutter-state-management.mp4'
WHERE title = 'State Management' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Flutter');

UPDATE lessons SET video_url = '/static/videos/golang-fundamentals.mp4'
WHERE title = 'Go Language Fundamentals' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Golang');

UPDATE lessons SET video_url = '/static/videos/golang-functions-and-structs.mp4'
WHERE title = 'Functions and Structs' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Golang');

UPDATE lessons SET video_url = '/static/videos/golang-concurrency-basics.mp4'
WHERE title = 'Concurrency Basics' AND subject_id IN (SELECT id FROM subjects WHERE name = 'Golang');

UPDATE lessons SET video_url = '/static/videos/history-ancient-civilizations.mp4'
WHERE title = 'Ancient Civilizations' AND subject_id IN (SELECT id FROM subjects WHERE name = 'History');

UPDATE lessons SET video_url = '/static/videos/history-world-wars.mp4'
WHERE title = 'World Wars' AND subject_id IN (SELECT id FROM subjects WHERE name = 'History');

UPDATE lessons SET video_url = '/static/videos/history-indian-independence.mp4'
WHERE title = 'Indian Independence Movement' AND subject_id IN (SELECT id FROM subjects WHERE name = 'History');

UPDATE lessons SET video_url = '/static/videos/english-grammar-basics.mp4'
WHERE title = 'Grammar Basics' AND subject_id IN (SELECT id FROM subjects WHERE name = 'English');

UPDATE lessons SET video_url = '/static/videos/english-vocabulary-building.mp4'
WHERE title = 'Vocabulary Building' AND subject_id IN (SELECT id FROM subjects WHERE name = 'English');

UPDATE lessons SET video_url = '/static/videos/english-writing-skills.mp4'
WHERE title = 'Writing Skills' AND subject_id IN (SELECT id FROM subjects WHERE name = 'English');


-- ===== 000016_add_thumbnail_to_lessons.up.sql =====
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;


-- ===== 000017_create_lesson_ai_content_table.up.sql =====
-- Stores AI-generated educational content per lesson: explanation, summary,
-- key points, worked examples, practice questions, and a quiz. This is what
-- LessonPlayerScreen renders instead of (or alongside) a video, replacing
-- the old cartoon/placeholder video approach.
CREATE TABLE IF NOT EXISTS lesson_ai_content (
    id SERIAL PRIMARY KEY,
    lesson_id INTEGER NOT NULL UNIQUE REFERENCES lessons(id) ON DELETE CASCADE,
    explanation TEXT NOT NULL,
    summary TEXT NOT NULL,
    key_points JSONB NOT NULL DEFAULT '[]',
    examples JSONB NOT NULL DEFAULT '[]',
    practice_questions JSONB NOT NULL DEFAULT '[]',
    quiz_json JSONB NOT NULL DEFAULT '[]',
    generated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);


-- ===== 000018_add_score_to_progress.up.sql =====
-- Lets "Mark Complete" optionally record a quiz score alongside completion.
ALTER TABLE lesson_progress ADD COLUMN IF NOT EXISTS score INTEGER;


-- ===== 000019_seed_ai_content.up.sql =====
-- 1) Add the missing Biology lesson (Biology subject already existed from Day 2 seed, with no lessons yet).
INSERT INTO lessons (subject_id, title, description, video_url, pdf_url, duration, order_number)
SELECT s.id, 'Introduction to Biology', 'The cell as the basic unit of life, and how cells build tissues, organs, and organisms.', NULL, NULL, 8, 1
FROM subjects s WHERE s.name = 'Biology'
ON CONFLICT DO NOTHING;

-- 2) AI-generated content per flagship lesson (explanation, summary, key points, examples, practice questions, quiz).
INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Mathematics is the study of numbers, quantities, shapes, and the patterns and relationships between them. It gives us a precise, universal language for describing the world: from counting objects, to measuring distances, to modeling how populations grow or how planets orbit the sun. At its core, mathematics is built from a small set of basic ideas (numbers, operations, and logical rules) that combine to describe almost anything quantifiable.$ai$, $ai$Math is the language of quantities, shapes, and patterns. Its major branches include arithmetic, algebra, geometry, and statistics, and mathematical thinking builds reasoning skills useful far beyond the classroom.$ai$,
    $js$["Mathematics studies numbers, shapes, and the relationships between them.", "Arithmetic covers basic operations: addition, subtraction, multiplication, division.", "Algebra uses symbols (like x) to represent unknown values.", "Geometry studies shapes, angles, and space.", "Statistics is about collecting and interpreting data."]$js$::jsonb, $js$["Counting 5 apples uses arithmetic.", "Solving 'x + 3 = 10' for x uses algebra.", "Finding the area of a room uses geometry.", "Calculating a class's average test score uses statistics."]$js$::jsonb, $js$["What are the four branches of mathematics mentioned in this lesson?", "Why is mathematics sometimes called a 'universal language'?", "Give one real-life example where you used arithmetic today."]$js$::jsonb, $js$[{"question": "Which branch of mathematics uses letters like x and y to represent unknown numbers?", "options": ["Arithmetic", "Algebra", "Geometry", "Statistics"], "correct_option": 1}, {"question": "Which branch of mathematics studies shapes and angles?", "options": ["Algebra", "Statistics", "Geometry", "Arithmetic"], "correct_option": 2}, {"question": "Collecting and interpreting data falls under which branch?", "options": ["Statistics", "Geometry", "Algebra", "Arithmetic"], "correct_option": 0}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics' AND l.title = 'Introduction'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Algebra is the branch of mathematics that uses symbols, usually letters like x and y, to represent numbers we don't yet know. An equation is a statement that two expressions are equal, and 'solving' an equation means finding the value of the unknown variable that makes the statement true. The key technique is keeping both sides of the equation balanced: whatever operation you perform on one side, you must perform on the other.$ai$, $ai$Algebra represents unknown numbers with variables and solves equations by performing the same operation on both sides to isolate the variable.$ai$,
    $js$["A variable is a symbol representing an unknown value.", "An equation states that two expressions are equal.", "Solving an equation means isolating the variable using balanced operations.", "PEMDAS defines the order of operations: Parentheses, Exponents, Multiplication/Division, Addition/Subtraction."]$js$::jsonb, $js$["x + 5 = 12 -> subtract 5 from both sides -> x = 7", "3x = 21 -> divide both sides by 3 -> x = 7", "x / 2 = 4 -> multiply both sides by 2 -> x = 8"]$js$::jsonb, $js$["Solve for x: x + 8 = 15", "Solve for x: 4x = 32", "Solve for x: 2x + 3 = 11"]$js$::jsonb, $js$[{"question": "What is the value of x in 'x + 5 = 12'?", "options": ["5", "7", "12", "17"], "correct_option": 1}, {"question": "What operation isolates x in '3x = 21'?", "options": ["Add 3", "Subtract 21", "Divide by 3", "Multiply by 3"], "correct_option": 2}, {"question": "In PEMDAS, what comes right after Parentheses?", "options": ["Addition", "Multiplication", "Exponents", "Subtraction"], "correct_option": 2}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics' AND l.title = 'Algebra'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Geometry is the branch of mathematics concerned with shapes, sizes, angles, and the space they occupy. Every shape is built from basic elements: points, lines, and angles. Understanding a few core shapes (triangles, squares, circles) and how to measure perimeter (the distance around a shape) and area (the space inside it) unlocks the ability to reason about the physical world, from room layouts to land surveying.$ai$, $ai$Geometry studies shapes, angles, perimeter, and area, using triangles, squares, and circles as building blocks for more complex spatial reasoning.$ai$,
    $js$["A triangle has 3 sides and its angles sum to 180 degrees.", "A square has 4 equal sides and 4 right angles (90 degrees each).", "A circle's points are all equidistant from its center.", "Perimeter is the distance around a shape; area is the space inside it."]$js$::jsonb, $js$["Rectangle perimeter = 2 x (length + width)", "Rectangle area = length x width", "Circle area = pi x radius squared"]$js$::jsonb, $js$["Find the perimeter of a rectangle with length 8 and width 5.", "Find the area of a square with side length 6.", "Is a 45-degree angle acute, right, or obtuse?"]$js$::jsonb, $js$[{"question": "How many degrees do a triangle's angles sum to?", "options": ["90", "180", "270", "360"], "correct_option": 1}, {"question": "What is the formula for a rectangle's area?", "options": ["length + width", "2 x (length + width)", "length x width", "length / width"], "correct_option": 2}, {"question": "An angle greater than 90 but less than 180 degrees is called:", "options": ["Acute", "Right", "Obtuse", "Straight"], "correct_option": 2}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics' AND l.title = 'Geometry'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Physics is the natural science that studies matter, energy, motion, and the forces that govern how objects behave. It explains everything from why an apple falls to the ground (gravity) to how a smartphone screen lights up (electromagnetism). Physics relies on the scientific method: physicists observe the world, form a hypothesis, test it with experiments, and refine their understanding based on the evidence they gather.$ai$, $ai$Physics studies matter, energy, and motion through branches like mechanics, thermodynamics, and electromagnetism, using the scientific method to build reliable, predictive models of nature.$ai$,
    $js$["Mechanics studies motion and forces.", "Thermodynamics studies heat and energy transfer.", "Electromagnetism studies electricity, magnetism, and light.", "The scientific method: observe, hypothesize, test, refine."]$js$::jsonb, $js$["A ball rolling and slowing due to friction is a mechanics example.", "A cup of hot tea cooling down is a thermodynamics example.", "A phone charging wirelessly is an electromagnetism example."]$js$::jsonb, $js$["Name the four steps of the scientific method.", "Which branch of physics would explain why a spoon in hot soup gets warm?", "Give one everyday example of mechanics in action."]$js$::jsonb, $js$[{"question": "Which branch of physics studies motion and forces?", "options": ["Thermodynamics", "Mechanics", "Electromagnetism", "Optics"], "correct_option": 1}, {"question": "What is the first step of the scientific method?", "options": ["Test", "Refine", "Observe", "Hypothesize"], "correct_option": 2}, {"question": "Heat transfer is studied under which branch of physics?", "options": ["Mechanics", "Thermodynamics", "Electromagnetism", "Modern Physics"], "correct_option": 1}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Physics' AND l.title = 'Introduction to Physics'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Chemistry is the study of matter: what it's made of, how it behaves, and how it changes when it interacts with other matter. All matter exists in one of three common states (solid, liquid, gas), and changes can be physical (like ice melting, where the substance stays the same) or chemical (like wood burning, which creates entirely new substances). Chemistry bridges physics and biology, explaining everything from cooking to medicine to materials science.$ai$, $ai$Chemistry studies matter's composition and behavior, distinguishing physical changes (appearance only) from chemical changes (new substances formed).$ai$,
    $js$["Solids have a fixed shape and volume.", "Liquids have a fixed volume but take their container's shape.", "Gases have no fixed shape or volume.", "A physical change alters appearance; a chemical change creates new substances."]$js$::jsonb, $js$["Ice melting into water is a physical change.", "Wood burning into ash and smoke is a chemical change.", "Water boiling into steam is a physical change (still H2O)."]$js$::jsonb, $js$["Name the three common states of matter.", "Is rusting iron a physical or chemical change? Why?", "Give one example each of a physical and a chemical change."]$js$::jsonb, $js$[{"question": "Which state of matter has no fixed shape or volume?", "options": ["Solid", "Liquid", "Gas", "Plasma"], "correct_option": 2}, {"question": "Ice melting into water is an example of a:", "options": ["Chemical change", "Physical change", "Nuclear change", "Biological change"], "correct_option": 1}, {"question": "Which of these is a chemical change?", "options": ["Water boiling", "Wood burning", "Ice melting", "Sugar dissolving"], "correct_option": 1}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Chemistry' AND l.title = 'Introduction to Chemistry'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Biology is the science of life and living organisms. It studies everything from the tiniest single-celled bacteria to the largest whales, examining how living things grow, reproduce, and interact with their environment. The cell is the basic unit of life: every living organism is made of one or more cells. Groups of similar cells form tissues, tissues form organs, and organs work together as organisms.$ai$, $ai$Biology studies living organisms, starting from the cell (life's basic unit) up through tissues, organs, and whole organisms.$ai$,
    $js$["The cell is the basic unit of life.", "Tissues are groups of similar cells working together.", "Organs are made of different tissues working together for a function.", "An organism is a complete living thing made of organs working together."]$js$::jsonb, $js$["A single red blood cell is a cell.", "Muscle tissue is made of many muscle cells together.", "The heart is an organ made of muscle and other tissues.", "A human being is an organism made of many organs."]$js$::jsonb, $js$["What is the basic unit of life called?", "Put in order from smallest to largest: organ, cell, tissue, organism.", "Name one organ in the human body and its main tissue type."]$js$::jsonb, $js$[{"question": "What is the basic unit of life?", "options": ["Tissue", "Organ", "Cell", "Organism"], "correct_option": 2}, {"question": "A group of similar cells working together is called a:", "options": ["Organ", "Tissue", "Organism", "Molecule"], "correct_option": 1}, {"question": "Which is the correct order from smallest to largest?", "options": ["Organism -> Organ -> Tissue -> Cell", "Cell -> Tissue -> Organ -> Organism", "Tissue -> Cell -> Organism -> Organ", "Organ -> Cell -> Tissue -> Organism"], "correct_option": 1}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Biology' AND l.title = 'Introduction to Biology'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$The earliest complex human societies arose near major rivers, where fertile soil supported farming and growing populations: Mesopotamia along the Tigris and Euphrates, Egypt along the Nile, the Indus Valley in South Asia, and China along the Yellow River. Each civilization developed unique innovations, from writing systems to monumental architecture, that still influence how societies function today. Later, the Roman Empire built on these foundations, spreading law, engineering, and governance across a vast territory.$ai$, $ai$Early river-valley civilizations (Mesopotamia, Egypt, Indus Valley, China) developed writing, law, and architecture; the Roman Empire later spread law and engineering across a huge territory.$ai$,
    $js$["Mesopotamia invented writing (cuneiform) and early law codes.", "Egypt built monumental pyramids and developed a solar calendar.", "The Indus Valley built planned cities with advanced drainage systems.", "Ancient China developed silk production and early bureaucracy.", "The Roman Empire spread law, engineering, and governance across Europe and beyond."]$js$::jsonb, $js$["The Code of Hammurabi is an early Mesopotamian law code.", "The Great Pyramid of Giza is a famous Egyptian monument.", "Roman aqueducts show advanced engineering used to transport water."]$js$::jsonb, $js$["Name the four early river-valley civilizations discussed in this lesson.", "What was one major achievement of Mesopotamia?", "How did the Roman Empire influence later societies?"]$js$::jsonb, $js$[{"question": "Which civilization invented one of the earliest writing systems (cuneiform)?", "options": ["Egypt", "Mesopotamia", "Indus Valley", "China"], "correct_option": 1}, {"question": "The Great Pyramid of Giza belongs to which ancient civilization?", "options": ["Mesopotamia", "China", "Egypt", "Rome"], "correct_option": 2}, {"question": "Which empire is known for spreading law and engineering (like aqueducts) across a vast territory?", "options": ["Indus Valley", "Roman Empire", "Ancient China", "Mesopotamia"], "correct_option": 1}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'History' AND l.title = 'Ancient Civilizations'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$India was under British colonial rule for nearly 200 years. Growing economic hardship and a rising demand for self-governance fueled a broad independence movement through the early 20th century. Mahatma Gandhi led nonviolent resistance (Satyagraha), including the Salt March and the Quit India Movement. Jawaharlal Nehru, a key leader of the Indian National Congress, later became independent India's first Prime Minister, while Bhagat Singh represented the movement's more revolutionary strand. India gained independence on August 15, 1947, though the transition also led to the partition of British India into India and Pakistan.$ai$, $ai$The Indian independence movement, led by figures like Gandhi (nonviolent resistance), Nehru, and Bhagat Singh, ended nearly 200 years of British rule on August 15, 1947, alongside the partition into India and Pakistan.$ai$,
    $js$["Mahatma Gandhi led nonviolent resistance (Satyagraha), including the Salt March.", "Jawaharlal Nehru led the Indian National Congress and became India's first Prime Minister.", "Bhagat Singh represented the more revolutionary strand of the movement.", "India became independent on August 15, 1947.", "Independence was accompanied by the partition of India and Pakistan."]$js$::jsonb, $js$["The Salt March (1930) was a nonviolent protest against the British salt tax.", "The Quit India Movement (1942) demanded an end to British rule."]$js$::jsonb, $js$["What method of resistance did Mahatma Gandhi use?", "On what date did India gain independence?", "Name one leader associated with the revolutionary strand of the movement."]$js$::jsonb, $js$[{"question": "What nonviolent method of resistance is associated with Mahatma Gandhi?", "options": ["Guerrilla warfare", "Satyagraha", "Diplomacy", "Armed rebellion"], "correct_option": 1}, {"question": "Who became India's first Prime Minister after independence?", "options": ["Mahatma Gandhi", "Bhagat Singh", "Jawaharlal Nehru", "Lord Mountbatten"], "correct_option": 2}, {"question": "On what date did India gain independence?", "options": ["January 26, 1950", "August 15, 1947", "October 2, 1869", "March 12, 1930"], "correct_option": 1}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'History' AND l.title = 'Indian Independence Movement'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Flutter is an open-source UI framework created by Google for building natively compiled applications for mobile, web, and desktop from a single codebase, using the Dart programming language. In Flutter, everything you see on screen is a widget: buttons, text, layout containers, even the app itself. Widgets combine to build a UI, and Flutter's 'hot reload' feature lets developers see code changes instantly without restarting the app, making UI development fast and iterative.$ai$, $ai$Flutter lets developers build native apps for multiple platforms from one Dart codebase, composing everything from widgets, with hot reload for fast iteration.$ai$,
    $js$["Flutter apps are written in the Dart programming language.", "Everything visible in a Flutter app is a widget.", "Hot reload shows code changes instantly without restarting the app.", "One codebase can target Android, iOS, web, and desktop."]$js$::jsonb, $js$["Text('Hello, Flutter!') displays a text widget.", "A Column widget arranges its children vertically.", "An ElevatedButton widget displays a clickable button."]$js$::jsonb, $js$["What programming language does Flutter use?", "What is a widget in Flutter?", "What does 'hot reload' let a developer do?"]$js$::jsonb, $js$[{"question": "What programming language is used to write Flutter apps?", "options": ["Java", "Swift", "Dart", "Kotlin"], "correct_option": 2}, {"question": "In Flutter, buttons, text, and layouts are all examples of:", "options": ["Packages", "Widgets", "Plugins", "Themes"], "correct_option": 1}, {"question": "What feature lets you see code changes instantly without restarting the app?", "options": ["Hot reload", "Cold start", "Live share", "Fast build"], "correct_option": 0}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Flutter' AND l.title = 'Introduction to Flutter'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

INSERT INTO lesson_ai_content (lesson_id, explanation, summary, key_points, examples, practice_questions, quiz_json)
SELECT l.id, $ai$Go (or Golang) is an open-source programming language created at Google, designed for simplicity, fast compilation, and strong built-in support for concurrent programs. It's widely used for backend servers, APIs, and cloud infrastructure. Every Go program starts with a 'package main' declaration and a 'main' function, the entry point where execution begins. Go compiles directly to a single, fast, native binary, which makes deployment simple.$ai$, $ai$Go is a simple, fast-compiling language built for concurrent backend systems, where every program starts from a 'main' function and compiles to a single native binary.$ai$,
    $js$["Go programs start with 'package main' and a 'main' function.", "Go compiles to a single, fast, native binary.", "Go has built-in support for concurrency via goroutines.", "Go's simple, readable syntax is strongly typed."]$js$::jsonb, $js$["package main; import \"fmt\"; func main() { fmt.Println(\"Hello, Go!\") }", "The Gin framework is commonly used to build REST APIs in Go."]$js$::jsonb, $js$["What is the name of the function where every Go program begins execution?", "Name one reason developers choose Go for backend systems.", "What does Go compile a program into?"]$js$::jsonb, $js$[{"question": "Which function is the entry point of every Go program?", "options": ["start()", "main()", "init()", "run()"], "correct_option": 1}, {"question": "What does Go compile a program into?", "options": ["A virtual machine bytecode", "A single native binary", "An interpreted script", "A Java archive"], "correct_option": 1}, {"question": "What Go feature provides built-in support for concurrent programs?", "options": ["Threads", "Goroutines", "Callbacks", "Promises"], "correct_option": 1}]$js$::jsonb
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Golang' AND l.title = 'Go Language Fundamentals'
ON CONFLICT (lesson_id) DO UPDATE SET
    explanation = EXCLUDED.explanation,
    summary = EXCLUDED.summary,
    key_points = EXCLUDED.key_points,
    examples = EXCLUDED.examples,
    practice_questions = EXCLUDED.practice_questions,
    quiz_json = EXCLUDED.quiz_json,
    updated_at = NOW();

-- 3) Point each flagship lesson's notes at the new, fuller AI-content PDF (self-hosted, replacing the older simple notes for these 10 lessons).
UPDATE notes SET title = 'Introduction - AI Notes', pdf_url = '/static/pdfs/mathematics-introduction-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Introduction');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Introduction - AI Notes', '/static/pdfs/mathematics-introduction-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics' AND l.title = 'Introduction'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Algebra - AI Notes', pdf_url = '/static/pdfs/mathematics-algebra-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Algebra');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Algebra - AI Notes', '/static/pdfs/mathematics-algebra-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics' AND l.title = 'Algebra'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Geometry - AI Notes', pdf_url = '/static/pdfs/mathematics-geometry-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Geometry');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Geometry - AI Notes', '/static/pdfs/mathematics-geometry-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Mathematics' AND l.title = 'Geometry'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Introduction to Physics - AI Notes', pdf_url = '/static/pdfs/physics-introduction-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Physics' AND l.title = 'Introduction to Physics');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Introduction to Physics - AI Notes', '/static/pdfs/physics-introduction-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Physics' AND l.title = 'Introduction to Physics'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Introduction to Chemistry - AI Notes', pdf_url = '/static/pdfs/chemistry-introduction-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Chemistry' AND l.title = 'Introduction to Chemistry');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Introduction to Chemistry - AI Notes', '/static/pdfs/chemistry-introduction-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Chemistry' AND l.title = 'Introduction to Chemistry'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Introduction to Biology - AI Notes', pdf_url = '/static/pdfs/biology-introduction-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Biology' AND l.title = 'Introduction to Biology');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Introduction to Biology - AI Notes', '/static/pdfs/biology-introduction-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Biology' AND l.title = 'Introduction to Biology'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Ancient Civilizations - AI Notes', pdf_url = '/static/pdfs/history-ancient-civilizations-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'Ancient Civilizations');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Ancient Civilizations - AI Notes', '/static/pdfs/history-ancient-civilizations-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'History' AND l.title = 'Ancient Civilizations'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Indian Independence Movement - AI Notes', pdf_url = '/static/pdfs/history-indian-independence-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'Indian Independence Movement');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Indian Independence Movement - AI Notes', '/static/pdfs/history-indian-independence-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'History' AND l.title = 'Indian Independence Movement'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Introduction to Flutter - AI Notes', pdf_url = '/static/pdfs/flutter-introduction-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Flutter' AND l.title = 'Introduction to Flutter');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Introduction to Flutter - AI Notes', '/static/pdfs/flutter-introduction-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Flutter' AND l.title = 'Introduction to Flutter'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

UPDATE notes SET title = 'Go Language Fundamentals - AI Notes', pdf_url = '/static/pdfs/golang-fundamentals-ai.pdf'
WHERE lesson_id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Golang' AND l.title = 'Go Language Fundamentals');

INSERT INTO notes (lesson_id, title, pdf_url)
SELECT l.id, 'Go Language Fundamentals - AI Notes', '/static/pdfs/golang-fundamentals-ai.pdf'
FROM lessons l JOIN subjects s ON s.id = l.subject_id
WHERE s.name = 'Golang' AND l.title = 'Go Language Fundamentals'
AND NOT EXISTS (SELECT 1 FROM notes n WHERE n.lesson_id = l.id);

-- 4) Educational thumbnails per subject and per flagship lesson.
UPDATE subjects SET thumbnail = '/static/thumbnails/mathematics.png' WHERE name = 'Mathematics';
UPDATE subjects SET thumbnail = '/static/thumbnails/physics.png' WHERE name = 'Physics';
UPDATE subjects SET thumbnail = '/static/thumbnails/chemistry.png' WHERE name = 'Chemistry';
UPDATE subjects SET thumbnail = '/static/thumbnails/biology.png' WHERE name = 'Biology';
UPDATE subjects SET thumbnail = '/static/thumbnails/history.png' WHERE name = 'History';
UPDATE subjects SET thumbnail = '/static/thumbnails/flutter.png' WHERE name = 'Flutter';
UPDATE subjects SET thumbnail = '/static/thumbnails/golang.png' WHERE name = 'Golang';
UPDATE lessons SET thumbnail_url = '/static/thumbnails/mathematics.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Introduction');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/mathematics.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Algebra');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/mathematics.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Mathematics' AND l.title = 'Geometry');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/physics.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Physics' AND l.title = 'Introduction to Physics');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/chemistry.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Chemistry' AND l.title = 'Introduction to Chemistry');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/biology.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Biology' AND l.title = 'Introduction to Biology');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/history.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'Ancient Civilizations');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/history.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'History' AND l.title = 'Indian Independence Movement');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/flutter.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Flutter' AND l.title = 'Introduction to Flutter');
UPDATE lessons SET thumbnail_url = '/static/thumbnails/golang.png'
WHERE id IN (SELECT l.id FROM lessons l JOIN subjects s ON s.id = l.subject_id WHERE s.name = 'Golang' AND l.title = 'Go Language Fundamentals');


-- ===== 000020_create_ai_tutor_tables.up.sql =====
-- AI Tutor chat: a conversation belongs to a user (optionally scoped to a
-- subject), and holds an ordered list of messages (user/assistant/system).
CREATE TABLE IF NOT EXISTS ai_conversations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_user ON ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_messages_conversation ON ai_messages(conversation_id);

-- Learning recommendations: "because you completed lesson_id, we recommend
-- recommended_lesson_id". Simple, rule-based (see internal/recommendations),
-- not a machine-learning model.
CREATE TABLE IF NOT EXISTS recommendations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id INTEGER NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    recommended_lesson_id INTEGER NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recommendations_user ON recommendations(user_id);


-- ===== 000021_create_ai_chat_sessions_messages.up.sql =====
-- Real LLM-backed AI Tutor chat (Groq API): a session belongs to a user,
-- optionally scoped to a subject, holding an ordered list of messages.
-- This replaces the earlier Day 3 rule-based ai_conversations/ai_messages
-- tables for new chats â€” those old tables are left in place (unused)
-- rather than dropped, so no existing data is lost.
CREATE TABLE IF NOT EXISTS ai_chat_sessions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_chat_messages (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES ai_chat_sessions(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
    message TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_chat_sessions_user ON ai_chat_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_chat_messages_session ON ai_chat_messages(session_id);


-- ===== 006_add_youtube_integration.sql =====
-- Migration: Add YouTube video integration
-- Safe to run on existing DB. Does NOT touch auth, categories, subjects, notes,
-- search, progress-tracking, or ai_tutor tables.

BEGIN;

-- 1. Extend lessons table
ALTER TABLE lessons
    ADD COLUMN IF NOT EXISTS youtube_search_query TEXT,
    ADD COLUMN IF NOT EXISTS youtube_enabled BOOLEAN DEFAULT true;

-- 2. Cache table (24h TTL, keyed by lesson_id + query)
CREATE TABLE IF NOT EXISTS youtube_cache (
    id            BIGSERIAL PRIMARY KEY,
    lesson_id     BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    query         TEXT NOT NULL,
    response_json JSONB NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    expires_at    TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_youtube_cache_lesson_id ON youtube_cache(lesson_id);
CREATE INDEX IF NOT EXISTS idx_youtube_cache_expires_at ON youtube_cache(expires_at);

-- 3. Per-user, per-video watch progress
CREATE TABLE IF NOT EXISTS lesson_video_progress (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id       BIGINT NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    video_id        TEXT NOT NULL,
    watched_seconds INTEGER NOT NULL DEFAULT 0,
    completed       BOOLEAN NOT NULL DEFAULT false,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, lesson_id, video_id)
);

CREATE INDEX IF NOT EXISTS idx_lesson_video_progress_user_lesson
    ON lesson_video_progress(user_id, lesson_id);

COMMIT;


-- ===== 007_expand_categories_and_subjects.sql =====
-- Consolidates course categories into a cleaner modern-EdTech structure:
-- Academic (all school subjects) + Competitive Exams (exam prep) +
-- Programming (untouched, unrelated to this request).
--
-- Root cause of "No subjects in this category yet": Physics/Chemistry sat
-- under a separate "Science" category, English sat under "Languages", and
-- a redundant empty "Mathematics" category existed alongside the
-- Mathematics subject that already lives under Academic. Competitive
-- Exams had zero subjects at all.

BEGIN;

-- 1) Move Physics, Chemistry, English into Academic.
UPDATE subjects SET category_id = (SELECT id FROM course_categories WHERE name = 'Academic')
WHERE name IN ('Physics', 'Chemistry', 'English');

-- 2) Delete the now-empty Science and Languages categories, and the
-- redundant empty standalone "Mathematics" category.
DELETE FROM course_categories WHERE name IN ('Science', 'Languages', 'Mathematics');

-- 3) New Academic subjects: Biology, Geography, Social Science,
-- Computer Science, Economics, General Knowledge (2 seed lessons each).
INSERT INTO subjects (category_id, name, description, thumbnail)
SELECT id, 'Biology', 'Life sciences: cells, genetics, and ecosystems.', NULL FROM course_categories WHERE name = 'Academic'
UNION ALL
SELECT id, 'Geography', 'Physical features of the Earth, climate, and human geography.', NULL FROM course_categories WHERE name = 'Academic'
UNION ALL
SELECT id, 'Social Science', 'Civics, society, and how communities are organized and governed.', NULL FROM course_categories WHERE name = 'Academic'
UNION ALL
SELECT id, 'Computer Science', 'Programming basics, data structures, and how computers work.', NULL FROM course_categories WHERE name = 'Academic'
UNION ALL
SELECT id, 'Economics', 'How individuals, businesses, and nations manage resources.', NULL FROM course_categories WHERE name = 'Academic'
UNION ALL
SELECT id, 'General Knowledge', 'Current affairs, notable facts, and general awareness.', NULL FROM course_categories WHERE name = 'Academic';

INSERT INTO lessons (subject_id, title, description, video_url, pdf_url, duration, order_number)
SELECT s.id, 'Introduction to Biology', 'What biology studies and its major branches.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Biology'
UNION ALL
SELECT s.id, 'Cells and Genetics', 'The basic unit of life and how traits are inherited.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Biology'
UNION ALL
SELECT s.id, 'Introduction to Geography', 'Earth''s physical features and how geographers study them.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Geography'
UNION ALL
SELECT s.id, 'Climate and Weather', 'What drives weather patterns and long-term climate.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Geography'
UNION ALL
SELECT s.id, 'Introduction to Social Science', 'How societies organize, govern, and interact.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Social Science'
UNION ALL
SELECT s.id, 'Civics and Government', 'How governments are structured and how citizens participate.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Social Science'
UNION ALL
SELECT s.id, 'Introduction to Computer Science', 'What computer science covers, from hardware to algorithms.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Computer Science'
UNION ALL
SELECT s.id, 'Programming Fundamentals', 'Variables, loops, and functions - the basics behind any language.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Computer Science'
UNION ALL
SELECT s.id, 'Introduction to Economics', 'Scarcity, supply and demand, and how markets work.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'Economics'
UNION ALL
SELECT s.id, 'Microeconomics vs Macroeconomics', 'The difference between individual choices and economy-wide trends.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Economics'
UNION ALL
SELECT s.id, 'Current Affairs Essentials', 'How to stay updated on national and world events.', NULL, NULL, 8, 1 FROM subjects s WHERE s.name = 'General Knowledge'
UNION ALL
SELECT s.id, 'General Awareness: Facts and Figures', 'Commonly tested static GK: geography, history, and science facts.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'General Knowledge';

-- 4) New Competitive Exams subjects (13), 2 seed lessons each.
INSERT INTO subjects (category_id, name, description, thumbnail)
SELECT id, 'UPSC', 'Civil Services Examination preparation: Prelims, Mains, and Interview.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'SSC', 'Staff Selection Commission exams: CGL, CHSL, and more.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'Banking', 'Bank PO and Clerk exams: IBPS, SBI, and RBI.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'Railway', 'RRB exams for technical and non-technical railway posts.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'NEET', 'National Eligibility cum Entrance Test for medical admissions.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'JEE', 'Joint Entrance Examination for engineering admissions.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'CAT', 'Common Admission Test for MBA admissions.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'GATE', 'Graduate Aptitude Test in Engineering for postgraduate admissions and PSU jobs.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'CUET', 'Common University Entrance Test for undergraduate admissions.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'NDA', 'National Defence Academy exam for the Army, Navy, and Air Force wings.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'CDS', 'Combined Defence Services exam for officer entry into the armed forces.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'State PSC', 'State Public Service Commission exams for state government posts.', NULL FROM course_categories WHERE name = 'Competitive Exams'
UNION ALL
SELECT id, 'Defence Exams', 'Other armed forces entrance exams beyond NDA/CDS.', NULL FROM course_categories WHERE name = 'Competitive Exams';

INSERT INTO lessons (subject_id, title, description, video_url, pdf_url, duration, order_number)
SELECT s.id, 'UPSC Exam Overview', 'Exam pattern, stages, and how the selection process works.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'UPSC'
UNION ALL
SELECT s.id, 'UPSC Key Preparation Areas', 'Core subjects and strategy for Prelims and Mains.', NULL, NULL, 12, 2 FROM subjects s WHERE s.name = 'UPSC'
UNION ALL
SELECT s.id, 'SSC Exam Overview', 'CGL, CHSL, and other SSC exam patterns explained.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'SSC'
UNION ALL
SELECT s.id, 'SSC Key Preparation Areas', 'Quant, reasoning, English, and general awareness focus areas.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'SSC'
UNION ALL
SELECT s.id, 'Banking Exam Overview', 'IBPS, SBI PO/Clerk exam structure and eligibility.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'Banking'
UNION ALL
SELECT s.id, 'Banking Key Preparation Areas', 'Quantitative aptitude, reasoning, and banking awareness.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Banking'
UNION ALL
SELECT s.id, 'Railway Exam Overview', 'RRB NTPC and Group D exam patterns explained.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'Railway'
UNION ALL
SELECT s.id, 'Railway Key Preparation Areas', 'Maths, general science, and general awareness focus areas.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Railway'
UNION ALL
SELECT s.id, 'NEET Exam Overview', 'Exam pattern and syllabus weightage across Physics, Chemistry, and Biology.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'NEET'
UNION ALL
SELECT s.id, 'NEET Key Preparation Areas', 'High-yield NCERT topics and how to prioritize revision.', NULL, NULL, 12, 2 FROM subjects s WHERE s.name = 'NEET'
UNION ALL
SELECT s.id, 'JEE Exam Overview', 'JEE Main vs Advanced, exam pattern, and eligibility.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'JEE'
UNION ALL
SELECT s.id, 'JEE Key Preparation Areas', 'Physics, Chemistry, and Maths weightage and strategy.', NULL, NULL, 12, 2 FROM subjects s WHERE s.name = 'JEE'
UNION ALL
SELECT s.id, 'CAT Exam Overview', 'Exam sections, scoring, and percentile-based selection.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'CAT'
UNION ALL
SELECT s.id, 'CAT Key Preparation Areas', 'Quant, Verbal Ability, and Data Interpretation focus areas.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'CAT'
UNION ALL
SELECT s.id, 'GATE Exam Overview', 'Exam pattern, scoring, and how GATE scores are used.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'GATE'
UNION ALL
SELECT s.id, 'GATE Key Preparation Areas', 'Core engineering subjects and aptitude section strategy.', NULL, NULL, 12, 2 FROM subjects s WHERE s.name = 'GATE'
UNION ALL
SELECT s.id, 'CUET Exam Overview', 'Exam structure for domain subjects, languages, and general test.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'CUET'
UNION ALL
SELECT s.id, 'CUET Key Preparation Areas', 'Choosing domain subjects and general test preparation.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'CUET'
UNION ALL
SELECT s.id, 'NDA Exam Overview', 'Written exam plus SSB interview process explained.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'NDA'
UNION ALL
SELECT s.id, 'NDA Key Preparation Areas', 'Maths and General Ability Test focus areas.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'NDA'
UNION ALL
SELECT s.id, 'CDS Exam Overview', 'Written exam plus SSB interview for officer entry.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'CDS'
UNION ALL
SELECT s.id, 'CDS Key Preparation Areas', 'English, GK, and Elementary Mathematics focus areas.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'CDS'
UNION ALL
SELECT s.id, 'State PSC Exam Overview', 'How state PSC exams differ from UPSC, state to state.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'State PSC'
UNION ALL
SELECT s.id, 'State PSC Key Preparation Areas', 'State-specific GK plus general aptitude focus areas.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'State PSC'
UNION ALL
SELECT s.id, 'Defence Exams Overview', 'Other entry routes into the armed forces beyond NDA/CDS.', NULL, NULL, 10, 1 FROM subjects s WHERE s.name = 'Defence Exams'
UNION ALL
SELECT s.id, 'Defence Exams Key Preparation Areas', 'Physical fitness, written test, and interview preparation.', NULL, NULL, 10, 2 FROM subjects s WHERE s.name = 'Defence Exams';

COMMIT;


-- ===== 008_add_subject_difficulty.sql =====
-- Adds an editorial difficulty tag to subjects (Beginner/Intermediate/
-- Advanced). This is a genuine content classification set by us, not a
-- fabricated statistic - unlike ratings or quiz/mock-test counts, which
-- stay out of the UI until those systems actually exist.

BEGIN;

ALTER TABLE subjects ADD COLUMN IF NOT EXISTS difficulty VARCHAR(20) NOT NULL DEFAULT 'Intermediate';

-- Academic: foundational/awareness subjects -> Beginner
UPDATE subjects SET difficulty = 'Beginner'
WHERE name IN ('English', 'History', 'Geography', 'Social Science', 'Economics', 'General Knowledge');

-- Academic: subjects requiring more conceptual depth -> Intermediate
UPDATE subjects SET difficulty = 'Intermediate'
WHERE name IN ('Mathematics', 'Physics', 'Chemistry', 'Biology', 'Computer Science');

-- Competitive Exams: all exam prep is Advanced by nature
UPDATE subjects SET difficulty = 'Advanced'
WHERE category_id = (SELECT id FROM course_categories WHERE name = 'Competitive Exams');

-- Programming subjects stay Intermediate (already the default, explicit for clarity)
UPDATE subjects SET difficulty = 'Intermediate'
WHERE name IN ('Flutter', 'Golang', 'PostgreSQL');

COMMIT;


-- ===== 009_create_quiz_attempts.sql =====
-- Quiz & Assessment module, scoped realistically to what this app can
-- actually support today: persisted quiz attempts (lesson-based AND
-- freeform AI-generated), per-question answer review, and analytics
-- computed from real attempt data. Does NOT include assignments,
-- leaderboards, certificates, or teacher/admin quiz authoring - those are
-- separate, much larger features.

BEGIN;

CREATE TABLE IF NOT EXISTS quiz_attempts (
    id                  SERIAL PRIMARY KEY,
    user_id             INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    lesson_id           INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
    subject_id          INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    topic               VARCHAR(255),
    total_questions     INTEGER NOT NULL,
    correct_count       INTEGER NOT NULL,
    score_percent       INTEGER NOT NULL,
    time_taken_seconds  INTEGER,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS quiz_attempt_answers (
    id               SERIAL PRIMARY KEY,
    attempt_id       INTEGER NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_index   INTEGER NOT NULL,
    question_text    TEXT NOT NULL,
    options          JSONB NOT NULL,
    selected_option  INTEGER, -- NULL means skipped
    correct_option   INTEGER NOT NULL,
    is_correct       BOOLEAN NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_subject ON quiz_attempts(subject_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_lesson ON quiz_attempts(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempt_answers_attempt ON quiz_attempt_answers(attempt_id);

COMMIT;


-- ===== 010_add_question_types.sql =====
-- Extends quiz attempts to support multiple question types (beyond
-- single-correct MCQ), scoped to the AI Quiz Generator (freeform) path.
-- Lesson-based quizzes are untouched - they keep using correct_option
-- exactly as before.

BEGIN;

ALTER TABLE quiz_attempt_answers
    ADD COLUMN IF NOT EXISTS question_type VARCHAR(30) NOT NULL DEFAULT 'single_mcq',
    ADD COLUMN IF NOT EXISTS correct_options JSONB,        -- for multiple_mcq: array of correct indices
    ADD COLUMN IF NOT EXISTS selected_options JSONB,       -- for multiple_mcq: array of selected indices
    ADD COLUMN IF NOT EXISTS correct_text TEXT,            -- for fill_blank / short_answer: accepted answer
    ADD COLUMN IF NOT EXISTS submitted_text TEXT,          -- for fill_blank / short_answer: student's answer
    ADD COLUMN IF NOT EXISTS hint TEXT,
    ADD COLUMN IF NOT EXISTS explanation TEXT,
    ADD COLUMN IF NOT EXISTS difficulty_score INTEGER;     -- 1-10, set by the AI generator

-- Options is only meaningful for MCQ-style types; relax NOT NULL so
-- fill_blank/short_answer rows (which have no options list) can insert '[]'.
ALTER TABLE quiz_attempt_answers ALTER COLUMN options SET DEFAULT '[]';

COMMIT;


-- ===== 011_create_streak_tracking.sql =====
-- Tracks which calendar days a user was active (completed a lesson,
-- attempted a quiz, or used AI Tutor), so "Learning Streak" on the
-- dashboard reflects real behavior instead of a fabricated number.

BEGIN;

CREATE TABLE IF NOT EXISTS user_activity_days (
    id            SERIAL PRIMARY KEY,
    user_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_date DATE NOT NULL,
    UNIQUE (user_id, activity_date)
);

CREATE INDEX IF NOT EXISTS idx_user_activity_days_user ON user_activity_days(user_id, activity_date DESC);

COMMIT;


-- ===== 012_add_user_status.sql =====
-- Adds account status so teacher applications can sit as "pending" until
-- an admin approves them, without touching existing student accounts
-- (which all default to 'active', so nothing about student login changes).

BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'active';

-- Backfill: every existing account (all students so far) is active.
UPDATE users SET status = 'active' WHERE status IS NULL;

-- Teacher-specific application details. Resume/certificate file URLs are
-- deliberately left out for now - that needs a file storage service
-- (e.g. Cloudinary) to be set up before file upload can be added safely.
CREATE TABLE IF NOT EXISTS teacher_profiles (
    id             SERIAL PRIMARY KEY,
    user_id        INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    phone          VARCHAR(30),
    qualification  VARCHAR(255),
    experience     VARCHAR(255),
    subjects       TEXT,
    bio            TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMIT;


-- ===== 013_add_role_check_constraint.sql =====
-- Restricts users.role to exactly three values at the database level -
-- belt-and-suspenders on top of the backend already never accepting role
-- from the frontend (RegisterRequest/TeacherApplyRequest have no role
-- field; the backend always assigns constants.RoleStudent /
-- constants.RoleTeacher itself). This constraint just makes it
-- impossible for any future code path to insert an invalid role, even
-- by accident.

BEGIN;

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check CHECK (role IN ('admin', 'teacher', 'student'));

COMMIT;


-- ===== 014_create_assignments.sql =====
-- Assignment & AI Auto-Evaluation module, Phase 1: Subject-level targeting
-- only. The assignment_targets table is deliberately polymorphic so
-- future phases (individual student, multiple students, batch,
-- classroom, section, group) can be added by inserting new target_type
-- values - no schema change needed, ever.

BEGIN;

CREATE TABLE IF NOT EXISTS assignments (
    id                SERIAL PRIMARY KEY,
    teacher_id        INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title             VARCHAR(255) NOT NULL,
    description       TEXT,
    instructions      TEXT,
    difficulty        VARCHAR(20) NOT NULL DEFAULT 'medium',
    estimated_minutes INTEGER,
    max_marks         INTEGER NOT NULL DEFAULT 10,
    passing_marks     INTEGER,
    start_date        TIMESTAMPTZ,
    due_date          TIMESTAMPTZ,
    status            VARCHAR(20) NOT NULL DEFAULT 'draft', -- draft | published | unpublished | archived
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Polymorphic targeting - Phase 1 only ever inserts target_type='subject'.
-- Future phases add target_type IN ('student','batch','classroom',
-- 'section','group') with target_id pointing into whichever table that
-- type refers to. No column changes needed to support them later.
CREATE TABLE IF NOT EXISTS assignment_targets (
    id            SERIAL PRIMARY KEY,
    assignment_id INTEGER NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    target_type   VARCHAR(20) NOT NULL,
    target_id     INTEGER NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (assignment_id, target_type, target_id)
);

CREATE INDEX IF NOT EXISTS idx_assignment_targets_lookup ON assignment_targets(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_assignment_targets_assignment ON assignment_targets(assignment_id);

CREATE TABLE IF NOT EXISTS assignment_submissions (
    id              SERIAL PRIMARY KEY,
    assignment_id   INTEGER NOT NULL REFERENCES assignments(id) ON DELETE CASCADE,
    student_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    submission_text TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'draft', -- draft | submitted | under_review | evaluated | returned
    submitted_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (assignment_id, student_id)
);

CREATE TABLE IF NOT EXISTS assignment_evaluations (
    id                     SERIAL PRIMARY KEY,
    submission_id          INTEGER NOT NULL UNIQUE REFERENCES assignment_submissions(id) ON DELETE CASCADE,
    ai_score               INTEGER,
    max_score              INTEGER,
    percentage             NUMERIC(5,2),
    strengths              JSONB,
    weaknesses             JSONB,
    missing_concepts       JSONB,
    suggestions            TEXT,
    teacher_override_score INTEGER,
    teacher_feedback       TEXT,
    reviewed_by_teacher    BOOLEAN NOT NULL DEFAULT false,
    evaluated_at           TIMESTAMPTZ,
    reviewed_at            TIMESTAMPTZ,
    created_at             TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_assignments_teacher ON assignments(teacher_id);
CREATE INDEX IF NOT EXISTS idx_assignments_status ON assignments(status);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX IF NOT EXISTS idx_assignment_submissions_student ON assignment_submissions(student_id);

COMMIT;


-- ===== 015_create_enrollments.sql =====
-- Lightweight enrollment: a student becomes "enrolled" in a subject the
-- first time they complete any lesson in it (see progress.Service hook).
-- Used to gate assignment visibility (only enrolled students see a
-- subject's assignments) without touching lesson access anywhere else.

BEGIN;

CREATE TABLE IF NOT EXISTS subject_enrollments (
    id          SERIAL PRIMARY KEY,
    student_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id  INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, subject_id)
);

CREATE INDEX IF NOT EXISTS idx_subject_enrollments_student ON subject_enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_subject_enrollments_subject ON subject_enrollments(subject_id);

COMMIT;


-- ===== 016_create_live_classes.sql =====
-- Live Class scheduling (Phase 1: calendar/schedule only - no video
-- infrastructure). Status is computed as "missed" dynamically for any
-- class whose end time has passed while still "scheduled" - no
-- background job needed for that.

BEGIN;

CREATE TABLE IF NOT EXISTS live_classes (
    id               SERIAL PRIMARY KEY,
    teacher_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id       INTEGER REFERENCES subjects(id) ON DELETE SET NULL,
    lesson_id        INTEGER REFERENCES lessons(id) ON DELETE SET NULL,
    title            VARCHAR(255) NOT NULL,
    description      TEXT,
    class_date       DATE NOT NULL,
    start_time       TIME NOT NULL,
    end_time         TIME NOT NULL,
    max_students     INTEGER,
    is_public        BOOLEAN NOT NULL DEFAULT true,
    meeting_password VARCHAR(50),
    record_class     BOOLEAN NOT NULL DEFAULT false,
    status           VARCHAR(20) NOT NULL DEFAULT 'scheduled', -- scheduled | completed | cancelled
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_live_classes_teacher ON live_classes(teacher_id);
CREATE INDEX IF NOT EXISTS idx_live_classes_subject ON live_classes(subject_id);
CREATE INDEX IF NOT EXISTS idx_live_classes_date ON live_classes(class_date);

COMMIT;


-- ===== 017_attendance_and_notifications.sql =====
-- Attendance: self-check-in model. There's no video infra to
-- automatically detect join/leave, so a student taps "I'm Present"
-- during the scheduled class window; checking in within the first 10
-- minutes of start counts as "present", after that as "late". "Absent"
-- is never stored - it's simply the absence of a row once class has ended.

BEGIN;

CREATE TABLE IF NOT EXISTS live_class_attendance (
    id            SERIAL PRIMARY KEY,
    live_class_id INTEGER NOT NULL REFERENCES live_classes(id) ON DELETE CASCADE,
    student_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    checked_in_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    status        VARCHAR(20) NOT NULL, -- present | late
    UNIQUE (live_class_id, student_id)
);

CREATE INDEX IF NOT EXISTS idx_attendance_class ON live_class_attendance(live_class_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student ON live_class_attendance(student_id);

-- Notifications: simple polling-based (fetched on app open/refresh) -
-- no WebSocket/push infra exists yet. Covers synchronous events (class
-- created, class cancelled) fine; a "starting soon" reminder would need
-- a background scheduler, which doesn't exist, so the countdown timer in
-- the UI covers that signal instead.
CREATE TABLE IF NOT EXISTS notifications (
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type       VARCHAR(40) NOT NULL, -- new_live_class | live_class_cancelled
    title      VARCHAR(255) NOT NULL,
    body       TEXT,
    related_id INTEGER,
    is_read    BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created ON notifications(created_at DESC);

COMMIT;


-- ===== 018_add_livekit_fields.sql =====
-- Adds real meeting state on top of the existing schedule/calendar
-- fields. meeting_status is separate from the existing `status` column
-- (scheduled/completed/cancelled) - this tracks the actual video session
-- lifecycle (not_started -> live -> ended), independent of whether the
-- teacher later marks the class "completed".

BEGIN;

ALTER TABLE live_classes ADD COLUMN IF NOT EXISTS room_name VARCHAR(100) UNIQUE;
ALTER TABLE live_classes ADD COLUMN IF NOT EXISTS meeting_status VARCHAR(20) NOT NULL DEFAULT 'not_started';
ALTER TABLE live_classes ADD COLUMN IF NOT EXISTS started_at TIMESTAMPTZ;
ALTER TABLE live_classes ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ;

COMMIT;


-- ===== 019_add_room_lock.sql =====
-- Adds a "locked" flag so a teacher can prevent new students from
-- joining an in-progress class (existing participants stay connected).

BEGIN;

ALTER TABLE live_classes ADD COLUMN IF NOT EXISTS locked BOOLEAN NOT NULL DEFAULT false;

COMMIT;


-- ===== 020_create_class_resources.sql =====
-- Class Resources: real files (PDF/PPT/images/docs/video) a teacher
-- uploads for a live class, stored on Cloudinary. Students can view/
-- download the list; only the uploading teacher can delete.

BEGIN;

CREATE TABLE IF NOT EXISTS class_resources (
    id               SERIAL PRIMARY KEY,
    live_class_id    INTEGER NOT NULL REFERENCES live_classes(id) ON DELETE CASCADE,
    teacher_id       INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_name        VARCHAR(255) NOT NULL,
    file_type        VARCHAR(50) NOT NULL,
    file_url         TEXT NOT NULL,
    cloudinary_id    VARCHAR(255) NOT NULL,
    file_size_bytes  BIGINT NOT NULL DEFAULT 0,
    uploaded_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_class_resources_class ON class_resources(live_class_id);

COMMIT;


-- ===== 021_create_badges.sql =====
-- Badges: 7 fixed badge definitions + a join table tracking which
-- students have earned which ones and when.

BEGIN;

CREATE TABLE IF NOT EXISTS badges (
    id SERIAL PRIMARY KEY,
    key VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    icon_key VARCHAR(50) NOT NULL
);

INSERT INTO badges (key, name, description, icon_key) VALUES
    ('quiz_master', 'Quiz Master', 'Passed 10 or more quizzes', 'quiz'),
    ('homework_hero', 'Homework Hero', 'Submitted 5 or more assignments', 'homework'),
    ('study_streak_7', '7-Day Study Streak', 'Maintained a 7-day learning streak', 'streak'),
    ('math_champion', 'Math Champion', 'Passed 5 or more Math quizzes', 'math'),
    ('perfect_score', 'Perfect Score', 'Scored 100% on a quiz', 'perfect'),
    ('course_finisher', 'Course Finisher', 'Completed every lesson in a subject', 'course'),
    ('attendance_star', 'Attendance Star', 'Attended every live class in a subject', 'attendance')
ON CONFLICT (key) DO NOTHING;

CREATE TABLE IF NOT EXISTS student_badges (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id INTEGER NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(student_id, badge_id)
);

COMMIT;


-- ===== 022_create_xp.sql =====
-- XP/Points: an append-only ledger (for idempotent awarding - e.g. course
-- completion or a daily-study bonus should never be double-counted) plus
-- a running-totals table for fast dashboard reads.

BEGIN;

CREATE TABLE IF NOT EXISTS xp_events (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(30) NOT NULL, -- quiz_completion | homework_submission | course_completion | daily_study | study_streak
    reference_key VARCHAR(100) NOT NULL, -- e.g. 'quiz-attempt-123', 'course-5', 'daily-2026-07-09', 'streak-milestone-1'
    xp_amount INTEGER NOT NULL,
    points_amount INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(student_id, activity_type, reference_key)
);

CREATE TABLE IF NOT EXISTS student_xp_totals (
    student_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    total_xp INTEGER NOT NULL DEFAULT 0,
    total_points INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_xp_events_student ON xp_events(student_id);

COMMIT;


-- ===== 023_add_class_section.sql =====
-- Class/Section: student-only fields, assigned exclusively by admin, used
-- only for Leaderboard filtering. Nullable so every existing user
-- (student or otherwise) stays exactly as-is until an admin sets these.

BEGIN;

ALTER TABLE users ADD COLUMN IF NOT EXISTS class VARCHAR(20);
ALTER TABLE users ADD COLUMN IF NOT EXISTS section VARCHAR(10);

CREATE INDEX IF NOT EXISTS idx_users_class_section ON users(class, section);

COMMIT;


-- ===== 024_create_certificates.sql =====
-- Certificates: one per (student, subject) - a subject IS "the course"
-- a student completes end-to-end. course_name/subject_name/
-- instructor_name are snapshotted at issue time so a certificate's
-- content never silently changes if the subject is later renamed or
-- reassigned.

BEGIN;

CREATE TABLE IF NOT EXISTS certificates (
    id SERIAL PRIMARY KEY,
    certificate_code VARCHAR(50) UNIQUE NOT NULL,
    student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    subject_id INTEGER NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    course_name VARCHAR(255) NOT NULL,
    subject_name VARCHAR(255) NOT NULL,
    instructor_name VARCHAR(255) NOT NULL,
    final_score NUMERIC(5,2) NOT NULL,
    grade VARCHAR(5) NOT NULL,
    completion_date DATE NOT NULL,
    issue_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(student_id, subject_id)
);

CREATE INDEX IF NOT EXISTS idx_certificates_student ON certificates(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_subject ON certificates(subject_id);

COMMIT;


-- ===== 025_add_course_management.sql =====
-- Course Management: subjects need a published/draft status (didn't
-- exist before - Create() always just... existed with no lifecycle).
-- Lessons get a dedicated assignment-document slot, separate from
-- pdf_url (lesson notes) and video_url (lesson video) - this is the
-- "Upload Assignments" admin feature, not the interactive Assignment
-- module which already has its own model.

BEGIN;

ALTER TABLE subjects ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'draft';
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS assignment_url TEXT;

CREATE INDEX IF NOT EXISTS idx_subjects_status ON subjects(status);

COMMIT;


-- ===== 026_qa_fixes.sql =====
-- QA fix: "Duplicate email registration race condition" - the app-level
-- SELECT EXISTS check in auth.Repository.CreateUser has a classic
-- time-of-check-to-time-of-use gap: two concurrent registrations with
-- the same email can both pass the check before either INSERTs. A DB-
-- level UNIQUE constraint is the only thing that actually closes this -
-- the app-level check becomes just a fast/friendly pre-check, backed by
-- this as the real guarantee.

BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS users_email_unique_idx ON users(email);

COMMIT;


-- ===== 027_lesson_resource_management.sql =====
-- Lesson Resource Management: lessons need a publish/draft lifecycle
-- (same pattern as subjects.status from migration 025), a way to tell
-- an uploaded video apart from a pasted YouTube URL, and a title/
-- description for the PDF notes attached to a lesson.
-- Safe to run on existing DB. Does NOT touch auth, categories, subjects,
-- notes, search, progress-tracking, or ai_tutor tables.

BEGIN;

ALTER TABLE lessons
    ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'draft',
    ADD COLUMN IF NOT EXISTS video_source VARCHAR(20) NOT NULL DEFAULT 'upload',
    ADD COLUMN IF NOT EXISTS pdf_title TEXT,
    ADD COLUMN IF NOT EXISTS pdf_description TEXT;

CREATE INDEX IF NOT EXISTS idx_lessons_status ON lessons(status);

COMMIT;


