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

INSERT INTO public.identifier VALUES ('2c11b68c-05b7-425d-85a7-d0661ac83c5e', 1);
INSERT INTO public.identifier VALUES ('d9b0b07d-bb33-48fe-8498-dcfa28da45bf', 1);
INSERT INTO public.identifier VALUES ('3663afd1-7d0b-4cf2-9ed2-d6bd79a4dc40', 1);
INSERT INTO public.identifier VALUES ('2c32c1d4-a954-4690-8599-160e478ce25b', 2);
INSERT INTO public.identifier VALUES ('db157dc2-b936-4781-9afc-7cce02dfc016', 2);


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."user" VALUES ('2c11b68c-05b7-425d-85a7-d0661ac83c5e', 'User1', '$2b$10$hSTGxpzFd385zl6tx2LFFO3WGVhFvO1OBdHAMp6ssgQVDzmOYRlme', '2019-04-26 20:21:55.814739+00', 'Â§
æé', 'user1@user1.com');
INSERT INTO public."user" VALUES ('d9b0b07d-bb33-48fe-8498-dcfa28da45bf', 'User2', '$2b$10$fVKKcmNIKNHxVF3/p3rjr.c9oJFRMu2pQ.zUu7fJIllY92OUCwGKq', '2019-04-26 20:22:13.717462+00', 'ôÔÔí±&x''', 'user2@user2.com');
INSERT INTO public."user" VALUES ('3663afd1-7d0b-4cf2-9ed2-d6bd79a4dc40', 'User3', '$2b$10$J7oVIlPjRb/5G2gL39StnOwAwA5Ffaiow38f6zG1jLPYQJbkPsXPW', '2019-04-26 20:22:28.008181+00', 'ÚMÅi¿¸¥', 'user3@user3.com');


--
-- Data for Name: comment; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.project VALUES ('db157dc2-b936-4781-9afc-7cce02dfc016', false, '2019-04-26 20:23:54+00');
INSERT INTO public.project VALUES ('2c32c1d4-a954-4690-8599-160e478ce25b', true, '2019-04-26 20:23:54+00');


--
-- Data for Name: component; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.role VALUES ('2c11b68c-05b7-425d-85a7-d0661ac83c5e', '2c32c1d4-a954-4690-8599-160e478ce25b', true, true);
INSERT INTO public.role VALUES ('2c11b68c-05b7-425d-85a7-d0661ac83c5e', 'db157dc2-b936-4781-9afc-7cce02dfc016', true, true);
INSERT INTO public.role VALUES ('d9b0b07d-bb33-48fe-8498-dcfa28da45bf', '2c32c1d4-a954-4690-8599-160e478ce25b', false, true);
INSERT INTO public.role VALUES ('d9b0b07d-bb33-48fe-8498-dcfa28da45bf', 'db157dc2-b936-4781-9afc-7cce02dfc016', false, true);


--
-- PostgreSQL database dump complete
--

