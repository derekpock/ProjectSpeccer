--
-- PostgreSQL database dump
--

-- Dumped from database version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)
-- Dumped by pg_dump version 10.8 (Ubuntu 10.8-0ubuntu0.18.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY public."user" DROP CONSTRAINT user_uid_fkey;
ALTER TABLE ONLY public.role DROP CONSTRAINT role_uid_fkey;
ALTER TABLE ONLY public.role DROP CONSTRAINT role_pid_fkey;
ALTER TABLE ONLY public.project DROP CONSTRAINT project_pid_fkey;
ALTER TABLE ONLY public.component DROP CONSTRAINT component_uid_fkey;
ALTER TABLE ONLY public.component DROP CONSTRAINT component_pid_fkey;
ALTER TABLE ONLY public.component DROP CONSTRAINT component_cid_fkey;
ALTER TABLE ONLY public.comment DROP CONSTRAINT comment_uid_fkey;
ALTER TABLE ONLY public.comment DROP CONSTRAINT comment_id_target_fkey;
ALTER TABLE ONLY public.comment DROP CONSTRAINT comment_id_fkey;
DROP INDEX public.component_index_pid;
DROP INDEX public.component_index_id_target;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_pkey;
ALTER TABLE ONLY public."user" DROP CONSTRAINT user_name_key;
ALTER TABLE ONLY public.role DROP CONSTRAINT role_pkey;
ALTER TABLE ONLY public.project DROP CONSTRAINT project_pkey;
ALTER TABLE ONLY public.identifier DROP CONSTRAINT identifiers_pkey;
ALTER TABLE ONLY public.component DROP CONSTRAINT component_revision_pid_type_key;
ALTER TABLE ONLY public.component DROP CONSTRAINT component_pkey;
ALTER TABLE ONLY public.comment DROP CONSTRAINT comment_pkey;
DROP TABLE public."user";
DROP TABLE public.role;
DROP TABLE public.project;
DROP TABLE public.identifier;
DROP TABLE public.component;
DROP TABLE public.comment;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: comment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comment (
    id uuid NOT NULL,
    uid uuid NOT NULL,
    id_target uuid NOT NULL,
    date_created timestamp with time zone NOT NULL,
    value json NOT NULL
);


ALTER TABLE public.comment OWNER TO postgres;

--
-- Name: component; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.component (
    cid uuid NOT NULL,
    revision integer NOT NULL,
    pid uuid NOT NULL,
    uid uuid NOT NULL,
    date_created timestamp with time zone NOT NULL,
    type smallint NOT NULL,
    data json NOT NULL
);


ALTER TABLE public.component OWNER TO postgres;

--
-- Name: identifier; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.identifier (
    id uuid NOT NULL,
    type smallint NOT NULL
);


ALTER TABLE public.identifier OWNER TO postgres;

--
-- Name: project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project (
    pid uuid NOT NULL,
    is_public boolean NOT NULL,
    date_founded timestamp with time zone NOT NULL
);


ALTER TABLE public.project OWNER TO postgres;

--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    uid uuid NOT NULL,
    pid uuid NOT NULL,
    is_owner boolean NOT NULL,
    is_developer boolean NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    uid uuid NOT NULL,
    name character varying(50) NOT NULL,
    passhash character(60) NOT NULL,
    date_join timestamp with time zone NOT NULL,
    email text
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: comment comment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: component component_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT component_pkey PRIMARY KEY (cid, revision);


--
-- Name: component component_revision_pid_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT component_revision_pid_type_key UNIQUE (revision, pid, type);


--
-- Name: identifier identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.identifier
    ADD CONSTRAINT identifiers_pkey PRIMARY KEY (id);


--
-- Name: project project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pkey PRIMARY KEY (pid);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (uid, pid);


--
-- Name: user user_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_name_key UNIQUE (name);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (uid);


--
-- Name: component_index_id_target; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX component_index_id_target ON public.comment USING btree (id_target);


--
-- Name: component_index_pid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX component_index_pid ON public.component USING btree (pid);


--
-- Name: comment comment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_id_fkey FOREIGN KEY (id) REFERENCES public.identifier(id);


--
-- Name: comment comment_id_target_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_id_target_fkey FOREIGN KEY (id_target) REFERENCES public.identifier(id);


--
-- Name: comment comment_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comment
    ADD CONSTRAINT comment_uid_fkey FOREIGN KEY (uid) REFERENCES public."user"(uid);


--
-- Name: component component_cid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT component_cid_fkey FOREIGN KEY (cid) REFERENCES public.identifier(id);


--
-- Name: component component_pid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT component_pid_fkey FOREIGN KEY (pid) REFERENCES public.project(pid);


--
-- Name: component component_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.component
    ADD CONSTRAINT component_uid_fkey FOREIGN KEY (uid) REFERENCES public."user"(uid);


--
-- Name: project project_pid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT project_pid_fkey FOREIGN KEY (pid) REFERENCES public.identifier(id);


--
-- Name: role role_pid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pid_fkey FOREIGN KEY (pid) REFERENCES public.project(pid);


--
-- Name: role role_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_uid_fkey FOREIGN KEY (uid) REFERENCES public."user"(uid);


--
-- Name: user user_uid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_uid_fkey FOREIGN KEY (uid) REFERENCES public.identifier(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO dlzp_client;


--
-- Name: TABLE comment; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.comment TO dlzp_client;


--
-- Name: TABLE component; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.component TO dlzp_client;


--
-- Name: TABLE identifier; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.identifier TO dlzp_client;


--
-- Name: TABLE project; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.project TO dlzp_client;


--
-- Name: TABLE role; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.role TO dlzp_client;


--
-- Name: TABLE "user"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public."user" TO dlzp_client;


--
-- PostgreSQL database dump complete
--

