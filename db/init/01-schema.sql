 
--
-- PostgreSQL database dump
--

\restrict EPaPPQ5sBpQzOO9eMPNY0yrh2wqmHvIrHvXKu2FMauGbvEAMDAq443Dqf04rZHH

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

-- Started on 2026-09-10 02:19:43

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

--
-- TOC entry 245 (class 1255 OID 18448)
-- Name: fn_auditar_publicacion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_auditar_publicacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_usuario character varying(255);
    v_accion character varying(20);
    v_datos_previos jsonb := NULL;
BEGIN
    v_usuario := COALESCE(NULLIF(current_setting('app.current_user', true), ''), CURRENT_USER);

    IF (TG_OP = 'INSERT') THEN
        v_accion := 'INSERT';
        INSERT INTO public.auditoria_publicacion(publicacion_id, accion, usuario_accion, fecha_hora, datos_anteriores)
        VALUES (NEW.id, v_accion, v_usuario, CURRENT_TIMESTAMP, NULL);
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        IF (OLD.eliminado = 1 AND NEW.eliminado = 0) THEN
            v_accion := 'DELETE_LOGICO';
        ELSE
            v_accion := 'UPDATE';
        END IF;

        v_datos_previos := to_jsonb(OLD);

        INSERT INTO public.auditoria_publicacion(publicacion_id, accion, usuario_accion, fecha_hora, datos_anteriores)
        VALUES (NEW.id, v_accion, v_usuario, CURRENT_TIMESTAMP, v_datos_previos);
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.fn_auditar_publicacion() OWNER TO postgres;

--
-- TOC entry 233 (class 1255 OID 18446)
-- Name: fn_auditar_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_auditar_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_usuario character varying(255);
    v_accion character varying(20);
    v_datos_previos jsonb := NULL;
BEGIN
    v_usuario := COALESCE(NULLIF(current_setting('app.current_user', true), ''), CURRENT_USER);

    IF (TG_OP = 'INSERT') THEN
        v_accion := 'INSERT';
        INSERT INTO public.auditoria_usuario(usuario_id, accion, usuario_accion, fecha_hora, datos_anteriores)
        VALUES (NEW.id, v_accion, v_usuario, CURRENT_TIMESTAMP, NULL);
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        IF (OLD.eliminado = 1 AND NEW.eliminado = 0) THEN
            v_accion := 'DELETE_LOGICO';
        ELSE
            v_accion := 'UPDATE';
        END IF;

        v_datos_previos := to_jsonb(OLD);

        INSERT INTO public.auditoria_usuario(usuario_id, accion, usuario_accion, fecha_hora, datos_anteriores)
        VALUES (NEW.id, v_accion, v_usuario, CURRENT_TIMESTAMP, v_datos_previos);
        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION public.fn_auditar_usuario() OWNER TO postgres;

--
-- TOC entry 232 (class 1255 OID 18444)
-- Name: fn_soft_delete_publicacion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_soft_delete_publicacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.publicacion 
    SET eliminado = 0 
    WHERE id = OLD.id;
    
    RETURN NULL; -- Cancela la eliminación física
END;
$$;


ALTER FUNCTION public.fn_soft_delete_publicacion() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 18442)
-- Name: fn_soft_delete_usuario(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_soft_delete_usuario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.usuario 
    SET eliminado = 0 
    WHERE id = OLD.id;
    
    RETURN NULL; -- Cancela la eliminación física
END;
$$;


ALTER FUNCTION public.fn_soft_delete_usuario() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 230 (class 1259 OID 18429)
-- Name: auditoria_publicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_publicacion (
    id bigint NOT NULL,
    publicacion_id bigint NOT NULL,
    accion character varying(20) NOT NULL,
    usuario_accion character varying(255) NOT NULL,
    fecha_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_anteriores jsonb
);


ALTER TABLE public.auditoria_publicacion OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 18428)
-- Name: auditoria_publicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auditoria_publicacion ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auditoria_publicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 228 (class 1259 OID 18420)
-- Name: auditoria_usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auditoria_usuario (
    id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    accion character varying(20) NOT NULL,
    usuario_accion character varying(255) NOT NULL,
    fecha_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_anteriores jsonb
);


ALTER TABLE public.auditoria_usuario OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 18419)
-- Name: auditoria_usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.auditoria_usuario ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.auditoria_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 222 (class 1259 OID 18370)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    slug character varying(100) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 4992 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE categoria; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.categoria IS 'Categorías para clasificación de publicaciones';


--
-- TOC entry 221 (class 1259 OID 18369)
-- Name: categoria_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.categoria ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.categoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 18346)
-- Name: perfil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfil (
    id bigint NOT NULL,
    nombre character varying(255) NOT NULL
);


ALTER TABLE public.perfil OWNER TO postgres;

--
-- TOC entry 4993 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE perfil; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.perfil IS 'Perfiles funcionales / roles';


--
-- TOC entry 217 (class 1259 OID 18345)
-- Name: perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.perfil ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.perfil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 224 (class 1259 OID 18380)
-- Name: publicacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publicacion (
    id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    categoria_id bigint,
    titulo character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    resumen text,
    contenido text NOT NULL,
    estado smallint DEFAULT 0 NOT NULL,
    fecha_publicacion timestamp without time zone,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    eliminado smallint DEFAULT 1 NOT NULL,
    CONSTRAINT chk_publicacion_eliminado CHECK ((eliminado = ANY (ARRAY[0, 1]))),
    CONSTRAINT chk_publicacion_estado CHECK ((estado = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE public.publicacion OWNER TO postgres;

--
-- TOC entry 4994 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE publicacion; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.publicacion IS 'Publicaciones y artículos generados por usuarios';


--
-- TOC entry 226 (class 1259 OID 18406)
-- Name: publicacion_adjunto; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publicacion_adjunto (
    id bigint NOT NULL,
    publicacion_id bigint NOT NULL,
    url_archivo character varying(500) NOT NULL,
    tipo_mime character varying(50),
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.publicacion_adjunto OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 18405)
-- Name: publicacion_adjunto_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.publicacion_adjunto ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.publicacion_adjunto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 223 (class 1259 OID 18379)
-- Name: publicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.publicacion ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.publicacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 216 (class 1259 OID 18331)
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id bigint NOT NULL,
    username character varying(255) NOT NULL,
    tipo_documento character varying(10),
    numero_documento character varying(20),
    empleado_id bigint,
    activo boolean DEFAULT true NOT NULL,
    token character varying(255),
    expirydate timestamp without time zone,
    password character varying(255),
    eliminado smallint DEFAULT 1 NOT NULL,
    refresh_token character varying(255),
    refresh_token_expiry timestamp without time zone,
    CONSTRAINT chk_usuario_eliminado CHECK ((eliminado = ANY (ARRAY[0, 1])))
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE usuario; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.usuario IS 'Usuarios autenticados en la plataforma';


--
-- TOC entry 215 (class 1259 OID 18330)
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.usuario ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 220 (class 1259 OID 18354)
-- Name: usuario_perfil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario_perfil (
    id bigint NOT NULL,
    usuario_id bigint NOT NULL,
    perfil_id bigint NOT NULL
);


ALTER TABLE public.usuario_perfil OWNER TO postgres;

--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE usuario_perfil; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.usuario_perfil IS 'Relación N:M usuario-perfil';


--
-- TOC entry 219 (class 1259 OID 18353)
-- Name: usuario_perfil_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.usuario_perfil ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.usuario_perfil_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 4986 (class 0 OID 18429)
-- Dependencies: 230
-- Data for Name: auditoria_publicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4984 (class 0 OID 18420)
-- Dependencies: 228
-- Data for Name: auditoria_usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (1, 1, 'INSERT', 'postgres', '2026-09-09 21:16:03.53196', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (2, 2, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (3, 3, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (4, 4, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (5, 5, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (6, 6, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (7, 7, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (8, 8, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (9, 9, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (10, 10, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (11, 11, 'INSERT', 'postgres', '2026-09-09 21:16:03.555409', NULL);
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (12, 1, 'UPDATE', 'postgres', '2026-09-09 23:34:31.63775', '{"id": 1, "token": "TOKEN_ADMIN_001", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-03-16T16:12:26.460879", "empleado_id": null, "refresh_token": null, "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": null}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (13, 1, 'UPDATE', 'postgres', '2026-09-09 23:35:28.975429', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkYW5pZWwiLCJpYXQiOjE3ODkwMTQ4NzEsImV4cCI6MTc4OTAxNTQ3MX0.ha7InYwNdnNhImg11Vo2BgV9e2hayimu_I7r4VCYtIg", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-09T23:44:31.59124", "empleado_id": null, "refresh_token": "d50728f6-cc7e-4503-a1b0-5b83f6d6421f", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-16T23:34:31.59124"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (14, 1, 'UPDATE', 'postgres', '2026-09-09 23:40:04.090571', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkYW5pZWwiLCJpYXQiOjE3ODkwMTQ5MjgsImV4cCI6MTc4OTAxNTUyOH0.K0Ra3M0EMAICMLDBMzZMri0zckAAYh0I8HrZo8HTDV4", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-09T23:45:28.966731", "empleado_id": null, "refresh_token": "e7135d5f-eb06-4654-9363-0dea3ec33a5b", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-16T23:35:28.966731"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (15, 1, 'UPDATE', 'postgres', '2026-09-09 23:40:19.413555', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkYW5pZWwiLCJpYXQiOjE3ODkwMTUyMDMsImV4cCI6MTc4OTAxNTgwM30.2kCFcPeoB8E0G9Vn_pl2vOHeH0ePpdbJoKmyH_jOfx4", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-09T23:50:04.031918", "empleado_id": null, "refresh_token": "a62893f4-c2c5-4adc-b5f7-e8b0fcec9342", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-16T23:40:04.031918"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (16, 1, 'UPDATE', 'postgres', '2026-09-09 23:50:55.09555', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkYW5pZWwiLCJpYXQiOjE3ODkwMTUyMTksImV4cCI6MTc4OTAxNTgxOX0.4IarpyNU7kr51gb4Ee6RgvI1fY6I75t_3RZH6fbZa34", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-09T23:50:19.409686", "empleado_id": null, "refresh_token": "34ef842c-19ee-4687-b3d0-95f8945b3c42", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-16T23:40:19.409686"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (17, 1, 'UPDATE', 'postgres', '2026-09-09 23:51:31.646254', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkYW5pZWwiLCJpYXQiOjE3ODkwMTU4NTUsImV4cCI6MTc4OTAxNjQ1NX0.Xn3-OOBqT2dIxUwHzWc3FLYVoRmYZWCt1fO4Jp2IjDE", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:00:55.08064", "empleado_id": null, "refresh_token": "3674abed-cd5c-4b83-b1af-8ae0e3522505", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-16T23:50:55.081637"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (18, 1, 'UPDATE', 'postgres', '2026-09-10 00:14:21.587188', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJkYW5pZWwiLCJpYXQiOjE3ODkwMTU4OTEsImV4cCI6MTc4OTAxNjQ5MX0.St7VrmvqUoErflT67oZlfwCvofBq51aD-UNPuvhjA8I", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:01:31.639102", "empleado_id": null, "refresh_token": "e9be028f-5ee5-4547-84a2-32c19d859f97", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-16T23:51:31.639102"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (19, 1, 'UPDATE', 'postgres', '2026-09-10 00:14:40.316825', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxNzI2MSwiZXhwIjoxNzg5MDE3ODYxfQ.gjL7IUXwVsVNoiNQgZC3T3s-1QQOrGHbAwQPM6bI22Q", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:24:21.528473", "empleado_id": null, "refresh_token": "8e5e8950-da7c-40b2-923c-b720feb43cf2", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:14:21.528473"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (20, 1, 'UPDATE', 'postgres', '2026-09-10 00:25:38.591416', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxNzI4MCwiZXhwIjoxNzg5MDE3ODgwfQ.YyXQ0VSWGoSzHZaZDWiUtA5C6ePLqgca3hDQWfWVLDs", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:24:40.310781", "empleado_id": null, "refresh_token": "9799fe30-0b2e-414a-b18e-906c7b24f751", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:14:40.310781"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (21, 1, 'UPDATE', 'postgres', '2026-09-10 00:31:03.072825', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxNzkzOCwiZXhwIjoxNzg5MDE4NTM4fQ.3eDEvPQHOxDLcU290OiwLO7yj1HyGZwFdMxTN0nWqr4", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:35:38.58194", "empleado_id": null, "refresh_token": "c27198ed-0ded-435e-9cfc-1922a7a73732", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:25:38.58194"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (22, 1, 'UPDATE', 'postgres', '2026-09-10 00:34:47.890977', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxODI2MiwiZXhwIjoxNzg5MDE4ODYyfQ.SMPwyO8VHjU1UVLmcelUeyIA0fO_WDmVbE26xirvZHY", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:41:03.016526", "empleado_id": null, "refresh_token": "6aff979a-0be1-42eb-8258-08b57731452c", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:31:03.016526"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (23, 1, 'UPDATE', 'postgres', '2026-09-10 00:40:45.63524', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxODQ4NywiZXhwIjoxNzg5MDE5MDg3fQ.eHQlTEqZ9dHGuQB0m1WhYYu_HJxAsLbw4MBnNV_FR7E", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:44:47.879928", "empleado_id": null, "refresh_token": "d5c04169-28ba-43a0-97e4-1ce126813001", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:34:47.879928"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (24, 1, 'UPDATE', 'postgres', '2026-09-10 00:51:40.110632', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxODg0NSwiZXhwIjoxNzg5MDE5NDQ1fQ.aoaeUL2pSH--XtZ8VsdDXJa5pDaBsQMGqtbgkCtN3sc", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T00:50:45.618263", "empleado_id": null, "refresh_token": "bebcab1a-b7d0-46a5-a41e-d56ee6c95061", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:40:45.619288"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (25, 1, 'UPDATE', 'postgres', '2026-09-10 00:58:01.685935', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxOTQ5OSwiZXhwIjoxNzg5MDIwMDk5fQ.N-HM3XsYbi7zLOwgPiOHl3GiDxNRXqYRxfmSIMLbOSw", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T01:01:40.033113", "empleado_id": null, "refresh_token": "daa72b8d-476e-4fb6-a780-65f97181b64d", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:51:40.033113"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (26, 1, 'UPDATE', 'postgres', '2026-09-10 01:00:35.378923', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAxOTg4MSwiZXhwIjoxNzg5MDIwNDgxfQ.vlHARXgn9r8uM6jpWU6yh51_C8Z2YjXFG6KxpOv0O1M", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T01:08:01.603414", "empleado_id": null, "refresh_token": "a8f3f893-2045-4086-8ebc-14ab90eae687", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T00:58:01.603414"}');


--
-- TOC entry 4978 (class 0 OID 18370)
-- Dependencies: 222
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (1, 'General', 'general');
INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (2, 'Tecnología', 'tecnologia');
INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (3, 'Noticias', 'noticias');
INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (4, 'Anuncios', 'anuncios');


--
-- TOC entry 4974 (class 0 OID 18346)
-- Dependencies: 218
-- Data for Name: perfil; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.perfil OVERRIDING SYSTEM VALUE VALUES (1, 'ADMINISTRADOR');
INSERT INTO public.perfil OVERRIDING SYSTEM VALUE VALUES (3, 'VISITANTE');
INSERT INTO public.perfil OVERRIDING SYSTEM VALUE VALUES (2, 'NORMAL');


--
-- TOC entry 4980 (class 0 OID 18380)
-- Dependencies: 224
-- Data for Name: publicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4982 (class 0 OID 18406)
-- Dependencies: 226
-- Data for Name: publicacion_adjunto; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4972 (class 0 OID 18331)
-- Dependencies: 216
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (2, 'usuario1', 'CC', '22222222', NULL, true, 'TOKEN_USR_001', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (3, 'usuario2', 'CC', '33333333', NULL, true, 'TOKEN_USR_002', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (4, 'usuario3', 'CC', '44444444', NULL, true, 'TOKEN_USR_003', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (5, 'usuario4', 'CC', '55555555', NULL, true, 'TOKEN_USR_004', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (6, 'usuario5', 'CC', '66666666', NULL, true, 'TOKEN_USR_005', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (7, 'usuario6', 'CC', '77777777', NULL, true, 'TOKEN_USR_006', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (8, 'usuario7', 'CC', '88888888', NULL, true, 'TOKEN_USR_007', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (9, 'usuario8', 'CC', '99999999', NULL, true, 'TOKEN_USR_008', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (10, 'usuario9', 'CC', '10101010', NULL, true, 'TOKEN_USR_009', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (11, 'usuario10', 'CC', '11111112', NULL, true, 'TOKEN_USR_010', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, NULL, NULL);
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (1, 'daniel', 'CC', '111111111', NULL, true, 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyMDAzNSwiZXhwIjoxNzg5MDIwNjM1fQ.lsG6BFA01huhY9Gspw6TDuC7-b4oIzVI22nxC2pco6E', '2026-09-10 01:10:35.376314', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, 'd3e5f4b1-6917-4a57-a09d-1f2724dd6448', '2026-09-17 01:00:35.376314');


--
-- TOC entry 4976 (class 0 OID 18354)
-- Dependencies: 220
-- Data for Name: usuario_perfil; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 229
-- Name: auditoria_publicacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_publicacion_id_seq', 1, false);


--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 227
-- Name: auditoria_usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_usuario_id_seq', 26, true);


--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 221
-- Name: categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_seq', 4, true);


--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 217
-- Name: perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.perfil_id_seq', 3, true);


--
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 225
-- Name: publicacion_adjunto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publicacion_adjunto_id_seq', 1, false);


--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 223
-- Name: publicacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publicacion_id_seq', 1, false);


--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 215
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_seq', 11, true);


--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 219
-- Name: usuario_perfil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_perfil_id_seq', 1, false);


--
-- TOC entry 4818 (class 2606 OID 18436)
-- Name: auditoria_publicacion auditoria_publicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_publicacion
    ADD CONSTRAINT auditoria_publicacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4816 (class 2606 OID 18427)
-- Name: auditoria_usuario auditoria_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_usuario
    ADD CONSTRAINT auditoria_usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 4800 (class 2606 OID 18376)
-- Name: categoria categoria_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_nombre_key UNIQUE (nombre);


--
-- TOC entry 4802 (class 2606 OID 18374)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 4804 (class 2606 OID 18378)
-- Name: categoria categoria_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_slug_key UNIQUE (slug);


--
-- TOC entry 4794 (class 2606 OID 18352)
-- Name: perfil perfil_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil
    ADD CONSTRAINT perfil_nombre_key UNIQUE (nombre);


--
-- TOC entry 4796 (class 2606 OID 18350)
-- Name: perfil perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil
    ADD CONSTRAINT perfil_pkey PRIMARY KEY (id);


--
-- TOC entry 4814 (class 2606 OID 18413)
-- Name: publicacion_adjunto publicacion_adjunto_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion_adjunto
    ADD CONSTRAINT publicacion_adjunto_pkey PRIMARY KEY (id);


--
-- TOC entry 4810 (class 2606 OID 18392)
-- Name: publicacion publicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT publicacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4812 (class 2606 OID 18394)
-- Name: publicacion publicacion_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT publicacion_slug_key UNIQUE (slug);


--
-- TOC entry 4788 (class 2606 OID 18344)
-- Name: usuario uq_usuario_documento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT uq_usuario_documento UNIQUE (tipo_documento, numero_documento);


--
-- TOC entry 4798 (class 2606 OID 18358)
-- Name: usuario_perfil usuario_perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_perfil
    ADD CONSTRAINT usuario_perfil_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 2606 OID 18340)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 18342)
-- Name: usuario usuario_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_username_key UNIQUE (username);


--
-- TOC entry 4805 (class 1259 OID 18439)
-- Name: idx_publicacion_categoria; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_categoria ON public.publicacion USING btree (categoria_id);


--
-- TOC entry 4806 (class 1259 OID 18441)
-- Name: idx_publicacion_estado_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_estado_fecha ON public.publicacion USING btree (estado, fecha_publicacion DESC);


--
-- TOC entry 4807 (class 1259 OID 18440)
-- Name: idx_publicacion_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_slug ON public.publicacion USING btree (slug);


--
-- TOC entry 4808 (class 1259 OID 18438)
-- Name: idx_publicacion_usuario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_usuario ON public.publicacion USING btree (usuario_id);


--
-- TOC entry 4786 (class 1259 OID 18437)
-- Name: idx_usuario_documento; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usuario_documento ON public.usuario USING btree (tipo_documento, numero_documento);


--
-- TOC entry 4826 (class 2620 OID 18449)
-- Name: publicacion trg_auditoria_publicacion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_publicacion AFTER INSERT OR UPDATE ON public.publicacion FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_publicacion();


--
-- TOC entry 4824 (class 2620 OID 18447)
-- Name: usuario trg_auditoria_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_usuario AFTER INSERT OR UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_usuario();


--
-- TOC entry 4827 (class 2620 OID 18445)
-- Name: publicacion trg_soft_delete_publicacion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_soft_delete_publicacion BEFORE DELETE ON public.publicacion FOR EACH ROW EXECUTE FUNCTION public.fn_soft_delete_publicacion();


--
-- TOC entry 4825 (class 2620 OID 18443)
-- Name: usuario trg_soft_delete_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_soft_delete_usuario BEFORE DELETE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_soft_delete_usuario();


--
-- TOC entry 4823 (class 2606 OID 18414)
-- Name: publicacion_adjunto fk_adjunto_publicacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion_adjunto
    ADD CONSTRAINT fk_adjunto_publicacion FOREIGN KEY (publicacion_id) REFERENCES public.publicacion(id) ON DELETE CASCADE;


--
-- TOC entry 4821 (class 2606 OID 18400)
-- Name: publicacion fk_publicacion_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT fk_publicacion_categoria FOREIGN KEY (categoria_id) REFERENCES public.categoria(id) ON DELETE SET NULL;


--
-- TOC entry 4822 (class 2606 OID 18395)
-- Name: publicacion fk_publicacion_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT fk_publicacion_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- TOC entry 4819 (class 2606 OID 18364)
-- Name: usuario_perfil fk_usuario_perfil_perfil; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_perfil
    ADD CONSTRAINT fk_usuario_perfil_perfil FOREIGN KEY (perfil_id) REFERENCES public.perfil(id) ON DELETE CASCADE;


--
-- TOC entry 4820 (class 2606 OID 18359)
-- Name: usuario_perfil fk_usuario_perfil_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario_perfil
    ADD CONSTRAINT fk_usuario_perfil_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


-- Completed on 2026-09-10 02:19:43

--
-- PostgreSQL database dump complete
--

\unrestrict EPaPPQ5sBpQzOO9eMPNY0yrh2wqmHvIrHvXKu2FMauGbvEAMDAq443Dqf04rZHH

