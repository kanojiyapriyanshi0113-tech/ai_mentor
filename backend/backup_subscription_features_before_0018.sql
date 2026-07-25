--
-- PostgreSQL database dump
--

\restrict j91UGJt1D9ew8SRQ8geRkaPVID9DAqmj9beTKdhvMNohgzKGJhCPVOUsZ9gMW1f

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
-- Name: subscription_features; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subscription_features (
    id integer NOT NULL,
    plan_id integer NOT NULL,
    feature_key character varying(50) NOT NULL,
    feature_limit integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.subscription_features OWNER TO postgres;

--
-- Name: subscription_features_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subscription_features_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subscription_features_id_seq OWNER TO postgres;

--
-- Name: subscription_features_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subscription_features_id_seq OWNED BY public.subscription_features.id;


--
-- Name: subscription_features id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_features ALTER COLUMN id SET DEFAULT nextval('public.subscription_features_id_seq'::regclass);


--
-- Data for Name: subscription_features; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subscription_features (id, plan_id, feature_key, feature_limit) FROM stdin;
1	1	max_exams	1
2	1	max_batches	1
3	1	max_chapters	5
4	1	max_lectures	10
5	1	max_notes	5
6	1	max_mock_tests	5
7	1	pyq_limit	-1
8	1	ai_chat_daily_limit	20
9	1	has_streak	1
10	1	has_progress_tracking	1
11	1	has_reminders	1
12	2	max_exams	3
13	2	max_batches	3
14	2	max_chapters	-1
15	2	max_lectures	-1
16	2	max_notes	-1
17	2	max_mock_tests	30
18	2	pyq_limit	-1
19	2	ai_chat_daily_limit	100
20	2	has_streak	1
21	2	has_progress_tracking	1
22	2	has_reminders	1
23	3	max_exams	5
24	3	max_batches	5
25	3	max_chapters	-1
26	3	max_lectures	-1
27	3	max_notes	-1
28	3	max_mock_tests	100
29	3	pyq_limit	-1
30	3	ai_chat_daily_limit	300
31	3	has_streak	1
32	3	has_progress_tracking	1
33	3	has_reminders	1
34	4	max_exams	-1
35	4	max_batches	-1
36	4	max_chapters	-1
37	4	max_lectures	-1
38	4	max_notes	-1
39	4	max_mock_tests	-1
40	4	pyq_limit	-1
41	4	ai_chat_daily_limit	-1
42	4	has_streak	1
43	4	has_progress_tracking	1
44	4	has_reminders	1
\.


--
-- Name: subscription_features_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subscription_features_id_seq', 44, true);


--
-- Name: subscription_features subscription_features_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_features
    ADD CONSTRAINT subscription_features_pkey PRIMARY KEY (id);


--
-- Name: subscription_features subscription_features_plan_id_feature_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_features
    ADD CONSTRAINT subscription_features_plan_id_feature_key_key UNIQUE (plan_id, feature_key);


--
-- Name: idx_subscription_features_plan_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_subscription_features_plan_id ON public.subscription_features USING btree (plan_id);


--
-- Name: subscription_features subscription_features_plan_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subscription_features
    ADD CONSTRAINT subscription_features_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES public.plans(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict j91UGJt1D9ew8SRQ8geRkaPVID9DAqmj9beTKdhvMNohgzKGJhCPVOUsZ9gMW1f

