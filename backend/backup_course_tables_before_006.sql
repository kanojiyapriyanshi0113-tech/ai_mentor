--
-- PostgreSQL database dump
--

\restrict WWzlDoS8uhc6NN9THn1MesAFmnYnzF6HzyUKbKQ7FVf5tSPOQdnn9GohgspVXuy

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.batches (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    exam_id integer NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    thumbnail character varying(500),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.batches OWNER TO postgres;

--
-- Name: chapters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chapters (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    subject_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    display_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.chapters OWNER TO postgres;

--
-- Name: lectures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.lectures (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    chapter_id uuid NOT NULL,
    title character varying(200) NOT NULL,
    description text,
    duration_minutes integer DEFAULT 0 NOT NULL,
    video_url character varying(500) NOT NULL,
    is_preview boolean DEFAULT false NOT NULL,
    display_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.lectures OWNER TO postgres;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    batch_id uuid NOT NULL,
    name character varying(200) NOT NULL,
    icon character varying(500),
    display_order integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- Data for Name: batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.batches (id, exam_id, title, description, thumbnail, is_active, created_at) FROM stdin;
bb8e643f-4238-4433-81ee-503909c3ffd0	1	UPSC Foundation Batch	Complete UPSC prep batch	https://example.com/thumb.jpg	t	2026-07-23 06:34:07.573449-04
c287d750-d156-447e-bc84-c53d171bafc1	5	NEET Foundation Batch	NEET prep batch		t	2026-07-23 23:32:48.559715-04
\.


--
-- Data for Name: chapters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chapters (id, subject_id, title, description, display_order) FROM stdin;
51a88425-4c2b-4a1d-93d9-40b3992531c3	792220f7-49e9-42ce-a131-2272a2cbf578	Ancient India	Indus Valley to Gupta Empire	1
30a13af8-b00c-46f0-a5da-763ef9e73a31	59ff526c-fdba-49fc-9f59-5d906f565c81	Cell Biology	\N	1
\.


--
-- Data for Name: lectures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.lectures (id, chapter_id, title, description, duration_minutes, video_url, is_preview, display_order) FROM stdin;
ac18707a-1a22-4103-b9a8-b8d973718085	51a88425-4c2b-4a1d-93d9-40b3992531c3	Introduction to Indus Valley Civilization	Overview of urban planning and trade	25	https://example.com/video1.mp4	t	1
e45c3e2d-5ded-491c-881d-bd5a0aa8b369	30a13af8-b00c-46f0-a5da-763ef9e73a31	Introduction to Cells	\N	15	https://example.com/video1.mp4	f	1
901cffd0-f7bb-4107-9b94-f49b07a74fa9	30a13af8-b00c-46f0-a5da-763ef9e73a31	Cell Membrane Structure	\N	20	https://example.com/video2.mp4	f	2
\.


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, batch_id, name, icon, display_order) FROM stdin;
792220f7-49e9-42ce-a131-2272a2cbf578	bb8e643f-4238-4433-81ee-503909c3ffd0	History	https://example.com/history-icon.png	1
59ff526c-fdba-49fc-9f59-5d906f565c81	c287d750-d156-447e-bc84-c53d171bafc1	Biology	\N	1
\.


--
-- Name: batches batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (id);


--
-- Name: chapters chapters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_pkey PRIMARY KEY (id);


--
-- Name: lectures lectures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lectures
    ADD CONSTRAINT lectures_pkey PRIMARY KEY (id);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: idx_batches_exam_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_exam_id ON public.batches USING btree (exam_id);


--
-- Name: idx_batches_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_is_active ON public.batches USING btree (is_active);


--
-- Name: idx_chapters_subject_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chapters_subject_display_order ON public.chapters USING btree (subject_id, display_order);


--
-- Name: idx_chapters_subject_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chapters_subject_id ON public.chapters USING btree (subject_id);


--
-- Name: idx_chapters_subject_id_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chapters_subject_id_display_order ON public.chapters USING btree (subject_id, display_order);


--
-- Name: idx_lectures_chapter_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lectures_chapter_display_order ON public.lectures USING btree (chapter_id, display_order);


--
-- Name: idx_lectures_chapter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lectures_chapter_id ON public.lectures USING btree (chapter_id);


--
-- Name: idx_lectures_chapter_id_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_lectures_chapter_id_display_order ON public.lectures USING btree (chapter_id, display_order);


--
-- Name: idx_subjects_batch_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subjects_batch_display_order ON public.subjects USING btree (batch_id, display_order);


--
-- Name: idx_subjects_batch_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subjects_batch_id ON public.subjects USING btree (batch_id);


--
-- Name: idx_subjects_batch_id_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subjects_batch_id_display_order ON public.subjects USING btree (batch_id, display_order);


--
-- Name: batches trg_batches_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_batches_updated_at BEFORE UPDATE ON public.batches FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: chapters trg_chapters_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_chapters_updated_at BEFORE UPDATE ON public.chapters FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: lectures trg_lectures_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_lectures_updated_at BEFORE UPDATE ON public.lectures FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: subjects trg_subjects_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_subjects_updated_at BEFORE UPDATE ON public.subjects FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: batches batches_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exams(id) ON DELETE CASCADE;


--
-- Name: chapters chapters_subject_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chapters
    ADD CONSTRAINT chapters_subject_id_fkey FOREIGN KEY (subject_id) REFERENCES public.subjects(id) ON DELETE CASCADE;


--
-- Name: lectures lectures_chapter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.lectures
    ADD CONSTRAINT lectures_chapter_id_fkey FOREIGN KEY (chapter_id) REFERENCES public.chapters(id) ON DELETE CASCADE;


--
-- Name: subjects subjects_batch_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict WWzlDoS8uhc6NN9THn1MesAFmnYnzF6HzyUKbKQ7FVf5tSPOQdnn9GohgspVXuy

