--
-- PostgreSQL database dump
--

\restrict QwaI7ZvUykELwdYqWe7ooppTT1M31MOCpI8OgFOV3i5T7ceyXbpfwZ2zmelQddQ

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
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    is_free_trial boolean DEFAULT false NOT NULL
);


ALTER TABLE public.batches OWNER TO postgres;

--
-- Name: exams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exams (
    id integer NOT NULL,
    code character varying(20) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.exams OWNER TO postgres;

--
-- Name: exams_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exams_id_seq OWNER TO postgres;

--
-- Name: exams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exams_id_seq OWNED BY public.exams.id;


--
-- Name: user_exams; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_exams (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    exam_id integer NOT NULL,
    selected_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_exams OWNER TO postgres;

--
-- Name: exams id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exams ALTER COLUMN id SET DEFAULT nextval('public.exams_id_seq'::regclass);


--
-- Data for Name: batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.batches (id, exam_id, title, description, thumbnail, is_active, created_at, display_order, updated_at, is_free_trial) FROM stdin;
bb8e643f-4238-4433-81ee-503909c3ffd0	1	UPSC Foundation Batch	Complete UPSC prep batch	https://example.com/thumb.jpg	t	2026-07-23 06:34:07.573449-04	0	2026-07-24 00:05:09.084504-04	f
c287d750-d156-447e-bc84-c53d171bafc1	5	NEET Foundation Batch	NEET prep batch		t	2026-07-23 23:32:48.559715-04	0	2026-07-24 00:09:55.692464-04	t
\.


--
-- Data for Name: exams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exams (id, code, name) FROM stdin;
1	UPSC	UPSC
2	SSC	SSC
3	BANKING	Banking
4	RAILWAY	Railway
5	NEET	NEET
6	JEE	JEE
7	STATE_PSC	State PSC
\.


--
-- Data for Name: user_exams; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_exams (id, user_id, exam_id, selected_at) FROM stdin;
81279b63-1d8e-45b5-842d-1dafe8121c20	dad07dfb-f0d8-4990-be8f-af00dc5e60eb	3	2026-07-22 06:41:09.640034-04
f342f71c-69dc-4153-93e8-c32ab6a20987	dad07dfb-f0d8-4990-be8f-af00dc5e60eb	6	2026-07-22 06:43:04.62637-04
711e8037-2fcf-4964-a725-1a21b041d06f	dad07dfb-f0d8-4990-be8f-af00dc5e60eb	5	2026-07-22 06:50:08.022845-04
0b8bdd72-16fe-4e6c-ac1f-6e715420e9b3	dad07dfb-f0d8-4990-be8f-af00dc5e60eb	7	2026-07-22 23:20:46.667801-04
5f96ff4f-336d-4b75-81d8-ee3b0f02e0ea	dad07dfb-f0d8-4990-be8f-af00dc5e60eb	1	2026-07-22 23:33:13.956525-04
88e1f049-5ef0-4021-8c47-87376cf8e537	ff677a06-6d04-43ae-9791-cafa5a60c54a	1	2026-07-22 23:57:04.904122-04
14e24f9f-6b50-43c4-a500-03705ae65ea0	dad07dfb-f0d8-4990-be8f-af00dc5e60eb	4	2026-07-23 23:26:11.260217-04
\.


--
-- Name: exams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exams_id_seq', 7, true);


--
-- Name: batches batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (id);


--
-- Name: exams exams_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_code_key UNIQUE (code);


--
-- Name: exams exams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exams
    ADD CONSTRAINT exams_pkey PRIMARY KEY (id);


--
-- Name: user_exams user_exams_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exams
    ADD CONSTRAINT user_exams_pkey PRIMARY KEY (id);


--
-- Name: user_exams user_exams_user_id_exam_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exams
    ADD CONSTRAINT user_exams_user_id_exam_id_key UNIQUE (user_id, exam_id);


--
-- Name: idx_batches_exam_display_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_exam_display_order ON public.batches USING btree (exam_id, display_order);


--
-- Name: idx_batches_exam_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_exam_id ON public.batches USING btree (exam_id);


--
-- Name: idx_batches_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_batches_is_active ON public.batches USING btree (is_active);


--
-- Name: idx_user_exams_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_exams_user_id ON public.user_exams USING btree (user_id);


--
-- Name: uq_batches_free_trial_per_exam; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX uq_batches_free_trial_per_exam ON public.batches USING btree (exam_id) WHERE (is_free_trial = true);


--
-- Name: batches trg_batches_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_batches_updated_at BEFORE UPDATE ON public.batches FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: batches batches_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exams(id) ON DELETE CASCADE;


--
-- Name: user_exams user_exams_exam_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exams
    ADD CONSTRAINT user_exams_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES public.exams(id) ON DELETE RESTRICT;


--
-- Name: user_exams user_exams_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_exams
    ADD CONSTRAINT user_exams_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict QwaI7ZvUykELwdYqWe7ooppTT1M31MOCpI8OgFOV3i5T7ceyXbpfwZ2zmelQddQ

