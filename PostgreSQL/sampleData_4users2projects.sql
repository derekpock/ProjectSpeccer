--
-- PostgreSQL database dump
--

-- Dumped from database version 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.6 (Ubuntu 10.6-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: identifier; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.identifier VALUES ('a13724e0-22d4-44e1-b078-60bd7de2e8c5', 1);
INSERT INTO public.identifier VALUES ('1bc0bbc4-df5b-4afb-b9df-02bc466956fb', 1);
INSERT INTO public.identifier VALUES ('bdcd1a7d-56df-4c1f-9812-866160174db5', 1);
INSERT INTO public.identifier VALUES ('bdcd1a7d-56df-4c1f-9812-86616017000a', 2);
INSERT INTO public.identifier VALUES ('bdcd1a7d-56df-4c1f-9812-86616017000b', 2);
INSERT INTO public.identifier VALUES ('5f41db54-bfd6-4e43-a961-8b2f0b864088', 1);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."user" VALUES ('a13724e0-22d4-44e1-b078-60bd7de2e8c5', 'a', '$2b$10$5YFic6LXNIUdADryZc7AfeH5YtKuJzCh6unkrnbdPNk1Mo50W2mIK', '2019-04-29 00:13:43.117869+00', 'a@a.a');
INSERT INTO public."user" VALUES ('1bc0bbc4-df5b-4afb-b9df-02bc466956fb', 'b', '$2b$10$enyeqvlNteLoGfbN1A.sJ.wp1cNfVel0b4YtIHgrF0XUuow9hRAaq', '2019-04-29 00:13:55.296702+00', 'b@b.b');
INSERT INTO public."user" VALUES ('bdcd1a7d-56df-4c1f-9812-866160174db5', 'c', '$2b$10$7k47AZK9rawQYcU6oMretevapX5AJocFWfPS168VTUKDjuo0eSSly', '2019-04-29 00:14:04.81795+00', 'c@c.c');
INSERT INTO public."user" VALUES ('5f41db54-bfd6-4e43-a961-8b2f0b864088', 'd', '$2b$10$0/eSRhub3uT49AnM3ql/xu8xQnwOQPfV95yGyzpTdxloYMLFSQpIi', '2019-04-29 00:21:54.416946+00', 'd@d.d');


--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.project VALUES ('bdcd1a7d-56df-4c1f-9812-86616017000a', true, '2019-04-26 20:23:54+00');
INSERT INTO public.project VALUES ('bdcd1a7d-56df-4c1f-9812-86616017000b', false, '2019-04-26 20:23:54+00');


--
-- Data for Name: component; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.role VALUES ('a13724e0-22d4-44e1-b078-60bd7de2e8c5', 'bdcd1a7d-56df-4c1f-9812-86616017000a', true, true);
INSERT INTO public.role VALUES ('a13724e0-22d4-44e1-b078-60bd7de2e8c5', 'bdcd1a7d-56df-4c1f-9812-86616017000b', true, true);
INSERT INTO public.role VALUES ('1bc0bbc4-df5b-4afb-b9df-02bc466956fb', 'bdcd1a7d-56df-4c1f-9812-86616017000a', false, true);
INSERT INTO public.role VALUES ('1bc0bbc4-df5b-4afb-b9df-02bc466956fb', 'bdcd1a7d-56df-4c1f-9812-86616017000b', false, true);
INSERT INTO public.role VALUES ('bdcd1a7d-56df-4c1f-9812-866160174db5', 'bdcd1a7d-56df-4c1f-9812-86616017000a', false, false);
INSERT INTO public.role VALUES ('bdcd1a7d-56df-4c1f-9812-866160174db5', 'bdcd1a7d-56df-4c1f-9812-86616017000b', false, false);


--
-- PostgreSQL database dump complete
--

