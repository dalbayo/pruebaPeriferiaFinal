--
-- PostgreSQL database dump
--

\restrict UEHrjGUfJUeVAYJLJlMtphVA6UJz6n5ee5CaHKQgzsxoQ1loesezMa0fdScwTh4

-- Dumped from database version 16.11
-- Dumped by pg_dump version 16.11

-- Started on 2026-09-10 05:29:00

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
-- TOC entry 239 (class 1255 OID 18448)
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
-- TOC entry 227 (class 1255 OID 18446)
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
-- TOC entry 226 (class 1255 OID 18444)
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
-- TOC entry 225 (class 1255 OID 18442)
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
-- TOC entry 224 (class 1259 OID 18429)
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
-- TOC entry 223 (class 1259 OID 18428)
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
-- TOC entry 222 (class 1259 OID 18420)
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
-- TOC entry 221 (class 1259 OID 18419)
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
-- TOC entry 218 (class 1259 OID 18370)
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id bigint NOT NULL,
    nombre character varying(100) NOT NULL,
    slug character varying(100) NOT NULL
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- TOC entry 4958 (class 0 OID 0)
-- Dependencies: 218
-- Name: TABLE categoria; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.categoria IS 'Categorías para clasificación de publicaciones';


--
-- TOC entry 217 (class 1259 OID 18369)
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
-- TOC entry 220 (class 1259 OID 18380)
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
-- TOC entry 4959 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE publicacion; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.publicacion IS 'Publicaciones y artículos generados por usuarios';


--
-- TOC entry 219 (class 1259 OID 18379)
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
-- TOC entry 4960 (class 0 OID 0)
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
-- TOC entry 4952 (class 0 OID 18429)
-- Dependencies: 224
-- Data for Name: auditoria_publicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (1, 1, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (2, 2, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (3, 3, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (4, 4, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (5, 5, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (6, 6, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (7, 7, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (8, 8, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (9, 9, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (10, 10, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (11, 11, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (12, 12, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (13, 13, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (14, 14, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (15, 15, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (16, 16, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (17, 17, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (18, 18, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (19, 19, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (20, 20, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (21, 21, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (22, 22, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (23, 23, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (24, 24, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (25, 25, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (26, 26, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (27, 27, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (28, 28, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (29, 29, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (30, 30, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (31, 31, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (32, 32, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (33, 33, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (34, 34, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (35, 35, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (36, 36, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (37, 37, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (38, 38, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (39, 39, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (40, 40, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (41, 41, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (42, 42, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (43, 43, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (44, 44, 'INSERT', 'postgres', '2026-09-10 02:58:12.586344', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (45, 1, 'UPDATE', 'postgres', '2026-09-10 04:02:58.526256', '{"id": 1, "slug": "publicacion-1-daniel-6445ba", "estado": 1, "titulo": "Publicación N° 1 de daniel", "resumen": "Resumen breve para la publicación número 1 del usuario daniel.", "contenido": "Contenido completo y detallado para la publicación 1 registrada por el usuario daniel.", "creado_en": "2026-08-29T17:09:46.707358", "eliminado": 1, "usuario_id": 1, "categoria_id": 3, "actualizado_en": "2026-09-10T02:58:12.586344", "fecha_publicacion": "2026-08-19T20:03:54.183974"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (46, 1, 'UPDATE', 'postgres', '2026-09-10 04:04:15.586105', '{"id": 1, "slug": "publicacion-1-daniel-6445ba", "estado": 1, "titulo": "Título editado", "resumen": "Resumen breve para la publicación número 1 del usuario daniel.", "contenido": "Contenido editado", "creado_en": "2026-08-29T17:09:46.707358", "eliminado": 1, "usuario_id": 1, "categoria_id": 3, "actualizado_en": "2026-09-10T04:02:58.483234", "fecha_publicacion": "2026-08-19T20:03:54.183974"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (47, 45, 'INSERT', 'postgres', '2026-09-10 04:05:40.893382', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (48, 2, 'UPDATE', 'postgres', '2026-09-10 04:15:19.26394', '{"id": 2, "slug": "publicacion-2-daniel-f5e30b", "estado": 0, "titulo": "Publicación N° 2 de daniel", "resumen": "Resumen breve para la publicación número 2 del usuario daniel.", "contenido": "Contenido completo y detallado para la publicación 2 registrada por el usuario daniel.", "creado_en": "2026-08-18T12:15:35.931587", "eliminado": 1, "usuario_id": 1, "categoria_id": 4, "actualizado_en": "2026-09-10T02:58:12.586344", "fecha_publicacion": "2026-08-20T00:56:13.514877"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (49, 3, 'UPDATE', 'postgres', '2026-09-10 04:15:25.45384', '{"id": 3, "slug": "publicacion-3-daniel-481831", "estado": 2, "titulo": "Publicación N° 3 de daniel", "resumen": "Resumen breve para la publicación número 3 del usuario daniel.", "contenido": "Contenido completo y detallado para la publicación 3 registrada por el usuario daniel.", "creado_en": "2026-09-03T21:25:07.427399", "eliminado": 1, "usuario_id": 1, "categoria_id": 3, "actualizado_en": "2026-09-10T02:58:12.586344", "fecha_publicacion": "2026-08-28T21:22:29.154072"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (50, 3, 'UPDATE', 'postgres', '2026-09-10 04:15:41.017816', '{"id": 3, "slug": "publicacion-3-daniel-481831", "estado": 2, "titulo": "Publicación N° 3 de daniel1", "resumen": "Resumen breve para la publicación número 3 del usuario daniel.", "contenido": "Contenido completo y detallado para la publicación 3 registrada por el usuario daniel.", "creado_en": "2026-09-03T21:25:07.427399", "eliminado": 1, "usuario_id": 1, "categoria_id": 3, "actualizado_en": "2026-09-10T04:15:25.450874", "fecha_publicacion": "2026-08-28T00:00:00"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (51, 46, 'INSERT', 'postgres', '2026-09-10 04:15:53.05486', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (53, 46, 'UPDATE', 'postgres', '2026-09-10 04:16:28.26996', '{"id": 46, "slug": "aaa-1789031753037", "estado": 0, "titulo": "aaa", "resumen": "aaa", "contenido": "aaa", "creado_en": "2026-09-10T04:15:53.039037", "eliminado": 1, "usuario_id": 1, "categoria_id": 4, "actualizado_en": "2026-09-10T04:15:53.039037", "fecha_publicacion": "2026-09-10T00:00:00"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (54, 1, 'UPDATE', 'postgres', '2026-09-10 05:05:40.876682', '{"id": 1, "slug": "publicacion-1-daniel-6445ba", "estado": 1, "titulo": "Título editado", "resumen": "Resumen breve para la publicación número 1 del usuario daniel.", "contenido": "Contenido editado", "creado_en": "2026-08-29T17:09:46.707358", "eliminado": 1, "usuario_id": 1, "categoria_id": 3, "actualizado_en": "2026-09-10T04:04:15.582619", "fecha_publicacion": "2026-08-19T20:03:54.183974"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (55, 4, 'UPDATE', 'postgres', '2026-09-10 05:11:54.207639', '{"id": 4, "slug": "publicacion-4-daniel-8b063f", "estado": 1, "titulo": "Publicación N° 4 de daniel", "resumen": "Resumen breve para la publicación número 4 del usuario daniel.", "contenido": "Contenido completo y detallado para la publicación 4 registrada por el usuario daniel.", "creado_en": "2026-09-04T11:59:53.174635", "eliminado": 1, "usuario_id": 1, "categoria_id": 3, "actualizado_en": "2026-09-10T02:58:12.586344", "fecha_publicacion": "2026-08-28T10:05:48.341003"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (56, 47, 'INSERT', 'postgres', '2026-09-10 05:12:06.603995', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (57, 48, 'INSERT', 'postgres', '2026-09-10 05:12:12.927423', NULL);
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (59, 5, 'UPDATE', 'postgres', '2026-09-10 05:25:24.664371', '{"id": 5, "slug": "publicacion-1-usuario1-d89b29", "estado": 0, "titulo": "Publicación N° 1 de usuario1", "resumen": "Resumen breve para la publicación número 1 del usuario usuario1.", "contenido": "Contenido completo y detallado para la publicación 1 registrada por el usuario usuario1.", "creado_en": "2026-09-07T04:15:41.046006", "eliminado": 1, "usuario_id": 2, "categoria_id": 2, "actualizado_en": "2026-09-10T02:58:12.586344", "fecha_publicacion": "2026-09-04T09:11:00.08867"}');
INSERT INTO public.auditoria_publicacion OVERRIDING SYSTEM VALUE VALUES (61, 46, 'UPDATE', 'postgres', '2026-09-10 05:25:38.873713', '{"id": 46, "slug": "aaa-1789031753037", "estado": 0, "titulo": "aaab", "resumen": "aaa", "contenido": "aaa", "creado_en": "2026-09-10T04:15:53.039037", "eliminado": 1, "usuario_id": 1, "categoria_id": 4, "actualizado_en": "2026-09-10T04:16:28.267312", "fecha_publicacion": "2026-09-10T00:00:00"}');


--
-- TOC entry 4950 (class 0 OID 18420)
-- Dependencies: 222
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
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (27, 1, 'UPDATE', 'postgres', '2026-09-10 02:36:29.002028', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyMDAzNSwiZXhwIjoxNzg5MDIwNjM1fQ.lsG6BFA01huhY9Gspw6TDuC7-b4oIzVI22nxC2pco6E", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T01:10:35.376314", "empleado_id": null, "refresh_token": "d3e5f4b1-6917-4a57-a09d-1f2724dd6448", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T01:00:35.376314"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (28, 1, 'UPDATE', 'postgres', '2026-09-10 02:37:50.758607', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNTc4OCwiZXhwIjoxNzg5MDI2Mzg4fQ.rZVmyn6lPyWn3lQVb96v2OQe4Z2QmTZk2bARXT9HIqA", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T02:46:28.963529", "empleado_id": null, "refresh_token": "873f64ed-d365-4935-b600-948e517927d3", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T02:36:28.963529"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (29, 1, 'UPDATE', 'postgres', '2026-09-10 02:48:51.939225', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNTg3MCwiZXhwIjoxNzg5MDI2NDcwfQ.FE0QW-yOKND94zIbtfJw5DtL2sTJ4itZT0WJwAIMzyw", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T02:47:50.75278", "empleado_id": null, "refresh_token": "56299c05-85ca-484d-8be8-1407b4b1f4c2", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T02:37:50.75278"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (30, 1, 'UPDATE', 'postgres', '2026-09-10 02:52:55.6181', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNjUzMSwiZXhwIjoxNzg5MDI3MTMxfQ.QNCB7GRnUuI1_yg_vR9ZsFuK_Oyy6c9j4HUnTFWyZNg", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T02:58:51.931992", "empleado_id": null, "refresh_token": "f12f5f6a-1738-4e6b-bc26-60bcefac8336", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T02:48:51.931992"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (31, 1, 'UPDATE', 'postgres', '2026-09-10 02:59:02.590049', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNjc3NSwiZXhwIjoxNzg5MDI3Mzc1fQ.bE8n0sAmU5ZXB7txBXI3tGKRUs-yIhNZSpj23DbAgDg", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:02:55.613467", "empleado_id": null, "refresh_token": "832a86e4-5329-476b-b927-8b066dfea4b6", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T02:52:55.613467"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (32, 1, 'UPDATE', 'postgres', '2026-09-10 03:00:53.92622', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNzE0MiwiZXhwIjoxNzg5MDI3NzQyfQ.Pwjm4NStg3EYqiaGAm3_tEQMQBneRWJetQku3iTzgVw", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:09:02.583569", "empleado_id": null, "refresh_token": "9b5ec7fa-cceb-4839-9ca8-aeb534d9dd20", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T02:59:02.583569"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (33, 1, 'UPDATE', 'postgres', '2026-09-10 03:08:31.609404', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNzI1MywiZXhwIjoxNzg5MDI3ODUzfQ.LS9VXczkA5Rq-cKo_sbC-ZLQeNlQvNc5aKiFDfhbQk0", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:10:53.920889", "empleado_id": null, "refresh_token": "64c0ea2c-cb95-4ff4-a55c-dca872066c0e", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:00:53.920889"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (34, 1, 'UPDATE', 'postgres', '2026-09-10 03:21:23.581192', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyNzcxMSwiZXhwIjoxNzg5MDI4MzExfQ._3J42K-oUIznRHUBkHv_ChN5qtSbvFeJM4C3fBhnAR0", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:18:31.573755", "empleado_id": null, "refresh_token": "976f8164-9c07-440d-82a6-84c3dd646aed", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:08:31.573755"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (35, 1, 'UPDATE', 'postgres', '2026-09-10 03:31:48.744835', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyODQ4MywiZXhwIjoxNzg5MDI5MDgzfQ.MUZ7sutIMTRgNJr24YG49h_mETCxA4nWL6NkN0Z_dw4", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:31:23.540901", "empleado_id": null, "refresh_token": "0850d072-efea-413d-ae67-49b046f483c1", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:21:23.540901"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (36, 1, 'UPDATE', 'postgres', '2026-09-10 03:37:49.185143', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyOTEwOCwiZXhwIjoxNzg5MDI5NzA4fQ.I-TVnNNDt1P3bAqnhYz4CpuCEhynM8Fa2YZyUgdUIOQ", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:41:48.708222", "empleado_id": null, "refresh_token": "78e57526-22f3-4fc0-9dad-b88e8470018d", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:31:48.708222"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (37, 1, 'UPDATE', 'postgres', '2026-09-10 03:47:15.812905', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAyOTQ2OSwiZXhwIjoxNzg5MDMwMDY5fQ.pZ8zKcTW2xzqigaQhr4FQMbCPhWGF2p8kxwDYZlC9bk", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:47:49.176971", "empleado_id": null, "refresh_token": "a651c2bd-b360-4d99-b44d-b9ecf736181a", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:37:49.176971"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (38, 1, 'UPDATE', 'postgres', '2026-09-10 03:47:57.506656', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzMDAzNSwiZXhwIjoxNzg5MDMwNjM1fQ.lBoF6K83jmhMjPGt1pxDfITqlz1iIrzSJa_aRX0injU", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:57:15.759273", "empleado_id": null, "refresh_token": "2c6d3b30-d910-4859-a116-bb55c1640f4c", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:47:15.759273"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (39, 1, 'UPDATE', 'postgres', '2026-09-10 03:52:55.621992', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzMDA3NywiZXhwIjoxNzg5MDMwNjc3fQ.NinBPa3XOz8P-BbdkY0TrO-24LmTu49h21-0GGbyZy8", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T03:57:57.497941", "empleado_id": null, "refresh_token": "04f73500-4666-430b-9ad6-d48c29df8165", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:47:57.497941"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (40, 1, 'UPDATE', 'postgres', '2026-09-10 04:02:05.345984', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzMDM3NSwiZXhwIjoxNzg5MDMwOTc1fQ.CMDnPbQZUvR-tlsjs6RCV-msVL3id9xzhocAxS4eVSo", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T04:02:55.61444", "empleado_id": null, "refresh_token": "f8d80403-f752-4bd3-b681-1193a6435e2c", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T03:52:55.61444"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (41, 1, 'UPDATE', 'postgres', '2026-09-10 04:03:49.677831', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzMDkyNSwiZXhwIjoxNzg5MDMxNTI1fQ.IycpNGZdE1F0z9KuECONcXYNCqygPo_kYmZIx_XuPt8", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T04:12:05.303435", "empleado_id": null, "refresh_token": "95b05640-263f-40de-a6aa-a2eea0392aba", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T04:02:05.303435"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (42, 1, 'UPDATE', 'postgres', '2026-09-10 04:15:14.066387', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzMTAyOSwiZXhwIjoxNzg5MDMxNjI5fQ.6Layj0NlY0tvYmzAQTCHW2YJWgIY5bJm35OiWmIVKMk", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T04:13:49.67134", "empleado_id": null, "refresh_token": "e43b1290-9f2e-4328-89ee-abaaed6a0435", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T04:03:49.67134"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (43, 1, 'UPDATE', 'postgres', '2026-09-10 05:05:12.095063', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzMTcxMywiZXhwIjoxNzg5MDMyMzEzfQ.T_4BQNRTJmObHrB7n0TQDe_vH47Oyd-U8THn7p5lqtw", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T04:25:14.023318", "empleado_id": null, "refresh_token": "b6ed29a6-f870-4cf0-9113-9658c37b7358", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T04:15:14.023318"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (44, 1, 'UPDATE', 'postgres', '2026-09-10 05:11:47.913452', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzNDcxMiwiZXhwIjoxNzg5MDM1MzEyfQ.VcFRf_Vl2Py_bTuQ5cEHqXekwj5twRuVVA3KsDPu3uw", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T05:15:12.048642", "empleado_id": null, "refresh_token": "2a0b3e39-d851-4eec-854b-5eb7e9fb5631", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T05:05:12.048642"}');
INSERT INTO public.auditoria_usuario OVERRIDING SYSTEM VALUE VALUES (45, 1, 'UPDATE', 'postgres', '2026-09-10 05:25:17.34409', '{"id": 1, "token": "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzNTEwNywiZXhwIjoxNzg5MDM1NzA3fQ.atN_QUfXXF0daqPOlQ78mcgz20Vwy8RBMZFmW-UxNBs", "activo": true, "password": "$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C", "username": "daniel", "eliminado": 1, "expirydate": "2026-09-10T05:21:47.907531", "empleado_id": null, "refresh_token": "b5797c27-3a15-4f80-9b7e-f6d698b98feb", "tipo_documento": "CC", "numero_documento": "111111111", "refresh_token_expiry": "2026-09-17T05:11:47.907531"}');


--
-- TOC entry 4946 (class 0 OID 18370)
-- Dependencies: 218
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (1, 'General', 'general');
INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (2, 'Tecnología', 'tecnologia');
INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (3, 'Noticias', 'noticias');
INSERT INTO public.categoria OVERRIDING SYSTEM VALUE VALUES (4, 'Anuncios', 'anuncios');


--
-- TOC entry 4948 (class 0 OID 18380)
-- Dependencies: 220
-- Data for Name: publicacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (6, 2, 4, 'Publicación N° 2 de usuario1', 'publicacion-2-usuario1-9d786b', 'Resumen breve para la publicación número 2 del usuario usuario1.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario1.', 2, '2026-08-15 21:02:49.569729', '2026-08-13 03:07:29.128911', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (7, 2, 3, 'Publicación N° 3 de usuario1', 'publicacion-3-usuario1-601d96', 'Resumen breve para la publicación número 3 del usuario usuario1.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario1.', 2, '2026-09-09 20:26:16.377426', '2026-08-18 10:12:21.8056', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (8, 2, 3, 'Publicación N° 4 de usuario1', 'publicacion-4-usuario1-ac8b51', 'Resumen breve para la publicación número 4 del usuario usuario1.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario1.', 2, '2026-08-28 15:21:35.457324', '2026-09-06 07:34:47.274951', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (9, 3, 1, 'Publicación N° 1 de usuario2', 'publicacion-1-usuario2-ee3324', 'Resumen breve para la publicación número 1 del usuario usuario2.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario2.', 1, '2026-09-08 06:20:19.88567', '2026-09-08 03:36:29.654269', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (10, 3, 3, 'Publicación N° 2 de usuario2', 'publicacion-2-usuario2-4e4c56', 'Resumen breve para la publicación número 2 del usuario usuario2.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario2.', 0, '2026-09-07 12:40:29.168281', '2026-08-31 06:23:35.990958', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (11, 3, 4, 'Publicación N° 3 de usuario2', 'publicacion-3-usuario2-c557ad', 'Resumen breve para la publicación número 3 del usuario usuario2.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario2.', 1, '2026-09-10 01:46:21.368317', '2026-08-27 06:40:50.50164', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (12, 3, 4, 'Publicación N° 4 de usuario2', 'publicacion-4-usuario2-748a7d', 'Resumen breve para la publicación número 4 del usuario usuario2.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario2.', 0, '2026-08-17 14:22:08.119983', '2026-08-26 09:12:17.155205', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (13, 4, 1, 'Publicación N° 1 de usuario3', 'publicacion-1-usuario3-db1255', 'Resumen breve para la publicación número 1 del usuario usuario3.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario3.', 1, '2026-08-28 13:44:10.660277', '2026-08-24 01:43:26.499531', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (14, 4, 2, 'Publicación N° 2 de usuario3', 'publicacion-2-usuario3-a87ea3', 'Resumen breve para la publicación número 2 del usuario usuario3.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario3.', 2, '2026-08-28 13:01:06.531364', '2026-08-18 02:34:59.348141', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (15, 4, 4, 'Publicación N° 3 de usuario3', 'publicacion-3-usuario3-932a0f', 'Resumen breve para la publicación número 3 del usuario usuario3.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario3.', 2, '2026-09-06 21:31:22.619398', '2026-08-28 00:13:03.955219', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (16, 4, 3, 'Publicación N° 4 de usuario3', 'publicacion-4-usuario3-7070ac', 'Resumen breve para la publicación número 4 del usuario usuario3.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario3.', 0, '2026-08-21 01:25:22.543322', '2026-09-03 19:57:26.880199', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (17, 5, 3, 'Publicación N° 1 de usuario4', 'publicacion-1-usuario4-9c5334', 'Resumen breve para la publicación número 1 del usuario usuario4.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario4.', 0, '2026-08-11 08:53:33.38074', '2026-09-09 08:40:53.42574', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (18, 5, 1, 'Publicación N° 2 de usuario4', 'publicacion-2-usuario4-bfd33e', 'Resumen breve para la publicación número 2 del usuario usuario4.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario4.', 1, '2026-08-30 08:37:41.115226', '2026-08-18 11:30:38.303955', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (19, 5, 3, 'Publicación N° 3 de usuario4', 'publicacion-3-usuario4-d67852', 'Resumen breve para la publicación número 3 del usuario usuario4.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario4.', 0, '2026-08-31 11:15:33.256279', '2026-08-18 14:47:24.881822', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (20, 5, 1, 'Publicación N° 4 de usuario4', 'publicacion-4-usuario4-7b0f4e', 'Resumen breve para la publicación número 4 del usuario usuario4.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario4.', 2, '2026-08-23 17:30:50.239374', '2026-09-06 01:00:27.962299', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (21, 6, 2, 'Publicación N° 1 de usuario5', 'publicacion-1-usuario5-9e20aa', 'Resumen breve para la publicación número 1 del usuario usuario5.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario5.', 1, '2026-08-12 14:56:33.693421', '2026-08-19 18:09:27.751757', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (22, 6, 2, 'Publicación N° 2 de usuario5', 'publicacion-2-usuario5-aea18e', 'Resumen breve para la publicación número 2 del usuario usuario5.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario5.', 2, '2026-08-27 20:19:38.091081', '2026-08-12 21:38:41.055743', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (23, 6, 1, 'Publicación N° 3 de usuario5', 'publicacion-3-usuario5-416542', 'Resumen breve para la publicación número 3 del usuario usuario5.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario5.', 1, '2026-09-09 09:00:02.956117', '2026-08-27 10:31:05.935473', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (24, 6, 4, 'Publicación N° 4 de usuario5', 'publicacion-4-usuario5-b6a55d', 'Resumen breve para la publicación número 4 del usuario usuario5.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario5.', 0, '2026-08-25 15:12:20.18093', '2026-08-20 05:01:01.0656', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (25, 7, 1, 'Publicación N° 1 de usuario6', 'publicacion-1-usuario6-b657b3', 'Resumen breve para la publicación número 1 del usuario usuario6.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario6.', 0, '2026-08-11 22:53:44.73084', '2026-09-04 11:09:07.766896', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (26, 7, 3, 'Publicación N° 2 de usuario6', 'publicacion-2-usuario6-bc72aa', 'Resumen breve para la publicación número 2 del usuario usuario6.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario6.', 2, '2026-09-03 01:56:48.07924', '2026-08-12 05:05:46.183562', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (2, 1, 4, 'Publicación N° 2 de daniel', 'publicacion-2-daniel-f5e30b', 'Resumen breve para la publicación número 2 del usuario daniel.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario daniel.', 0, '2026-08-20 00:00:00', '2026-08-18 12:15:35.931587', '2026-09-10 04:15:19.222637', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (3, 1, 3, 'Publicación N° 3 de daniel', 'publicacion-3-daniel-481831', 'Resumen breve para la publicación número 3 del usuario daniel.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario daniel.', 2, '2026-08-28 00:00:00', '2026-09-03 21:25:07.427399', '2026-09-10 04:15:41.014975', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (4, 1, 3, 'Publicación N° 4 de daniel', 'publicacion-4-daniel-8b063f', 'Resumen breve para la publicación número 4 del usuario daniel.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario daniel.', 1, '2026-08-28 00:00:00', '2026-09-04 11:59:53.174635', '2026-09-10 05:11:54.204441', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (5, 2, 2, 'Publicación N° 1 de usuario1', 'publicacion-1-usuario1-d89b29', 'Resumen breve para la publicación número 1 del usuario usuario1.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario1.', 0, '2026-09-04 00:00:00', '2026-09-07 04:15:41.046006', '2026-09-10 05:25:24.624243', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (27, 7, 2, 'Publicación N° 3 de usuario6', 'publicacion-3-usuario6-3efcdb', 'Resumen breve para la publicación número 3 del usuario usuario6.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario6.', 2, '2026-09-04 22:02:32.545038', '2026-08-18 09:53:09.691706', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (28, 7, 2, 'Publicación N° 4 de usuario6', 'publicacion-4-usuario6-6d6db3', 'Resumen breve para la publicación número 4 del usuario usuario6.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario6.', 2, '2026-08-17 21:28:03.300151', '2026-08-22 18:27:53.508295', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (29, 8, 1, 'Publicación N° 1 de usuario7', 'publicacion-1-usuario7-017546', 'Resumen breve para la publicación número 1 del usuario usuario7.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario7.', 1, '2026-09-08 23:25:40.062704', '2026-09-04 11:19:46.025141', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (30, 8, 3, 'Publicación N° 2 de usuario7', 'publicacion-2-usuario7-601fb1', 'Resumen breve para la publicación número 2 del usuario usuario7.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario7.', 0, '2026-08-28 13:06:59.969744', '2026-08-28 20:13:27.252688', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (31, 8, 1, 'Publicación N° 3 de usuario7', 'publicacion-3-usuario7-af6804', 'Resumen breve para la publicación número 3 del usuario usuario7.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario7.', 1, '2026-08-23 20:55:13.605322', '2026-08-27 14:13:31.299047', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (32, 8, 2, 'Publicación N° 4 de usuario7', 'publicacion-4-usuario7-d40bc9', 'Resumen breve para la publicación número 4 del usuario usuario7.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario7.', 0, '2026-09-01 13:23:02.215624', '2026-09-03 12:25:37.652575', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (33, 9, 4, 'Publicación N° 1 de usuario8', 'publicacion-1-usuario8-4e18c7', 'Resumen breve para la publicación número 1 del usuario usuario8.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario8.', 2, '2026-09-02 06:54:37.679244', '2026-08-27 14:44:01.365849', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (34, 9, 3, 'Publicación N° 2 de usuario8', 'publicacion-2-usuario8-3665c7', 'Resumen breve para la publicación número 2 del usuario usuario8.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario8.', 1, '2026-08-23 11:45:52.564898', '2026-08-23 02:26:57.582609', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (35, 9, 1, 'Publicación N° 3 de usuario8', 'publicacion-3-usuario8-961e83', 'Resumen breve para la publicación número 3 del usuario usuario8.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario8.', 2, '2026-09-03 14:28:35.912395', '2026-09-07 20:08:02.162791', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (36, 9, 4, 'Publicación N° 4 de usuario8', 'publicacion-4-usuario8-e0b0ea', 'Resumen breve para la publicación número 4 del usuario usuario8.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario8.', 1, '2026-08-17 07:14:38.217237', '2026-08-21 00:29:34.05848', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (37, 10, 4, 'Publicación N° 1 de usuario9', 'publicacion-1-usuario9-988a3c', 'Resumen breve para la publicación número 1 del usuario usuario9.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario9.', 0, '2026-09-06 01:30:13.427332', '2026-08-18 17:19:17.616631', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (38, 10, 1, 'Publicación N° 2 de usuario9', 'publicacion-2-usuario9-c70342', 'Resumen breve para la publicación número 2 del usuario usuario9.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario9.', 0, '2026-08-20 14:14:44.495683', '2026-08-25 05:26:11.228403', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (39, 10, 4, 'Publicación N° 3 de usuario9', 'publicacion-3-usuario9-a6dcac', 'Resumen breve para la publicación número 3 del usuario usuario9.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario9.', 0, '2026-08-11 04:46:15.281893', '2026-08-18 09:27:04.761674', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (40, 10, 1, 'Publicación N° 4 de usuario9', 'publicacion-4-usuario9-60f1ea', 'Resumen breve para la publicación número 4 del usuario usuario9.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario9.', 1, '2026-08-23 07:09:21.137528', '2026-08-26 04:28:51.734458', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (41, 11, 3, 'Publicación N° 1 de usuario10', 'publicacion-1-usuario10-098202', 'Resumen breve para la publicación número 1 del usuario usuario10.', 'Contenido completo y detallado para la publicación 1 registrada por el usuario usuario10.', 2, '2026-09-06 20:44:20.584537', '2026-09-07 07:59:09.42671', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (42, 11, 2, 'Publicación N° 2 de usuario10', 'publicacion-2-usuario10-96d132', 'Resumen breve para la publicación número 2 del usuario usuario10.', 'Contenido completo y detallado para la publicación 2 registrada por el usuario usuario10.', 2, '2026-08-19 18:31:22.337061', '2026-08-30 01:20:17.77478', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (43, 11, 3, 'Publicación N° 3 de usuario10', 'publicacion-3-usuario10-afa267', 'Resumen breve para la publicación número 3 del usuario usuario10.', 'Contenido completo y detallado para la publicación 3 registrada por el usuario usuario10.', 1, '2026-08-21 17:14:51.203362', '2026-09-04 01:12:51.193477', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (44, 11, 3, 'Publicación N° 4 de usuario10', 'publicacion-4-usuario10-ce4a0a', 'Resumen breve para la publicación número 4 del usuario usuario10.', 'Contenido completo y detallado para la publicación 4 registrada por el usuario usuario10.', 1, '2026-08-29 05:37:55.67051', '2026-08-20 14:59:59.291596', '2026-09-10 02:58:12.586344', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (45, 1, 1, 'Mi primera publicación', 'mi-primera-publicacin-1789031140876', 'Resumen corto', 'Contenido de prueba', 0, NULL, '2026-09-10 04:05:40.879748', '2026-09-10 04:05:40.879748', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (1, 1, 3, 'Título editado', 'publicacion-1-daniel-6445ba', 'Resumen breve para la publicación número 1 del usuario daniel.', 'Contenido editado', 1, '2026-08-19 20:03:54.183974', '2026-08-29 17:09:46.707358', '2026-09-10 05:05:40.843177', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (47, 1, 4, 'aaa', 'aaa-1789035126588', 'aaa', 'aaa', 0, '2026-09-10 00:00:00', '2026-09-10 05:12:06.5901', '2026-09-10 05:12:06.5901', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (48, 1, NULL, 'aaa', 'aaa-1789035132925', NULL, 'aaa', 1, '2026-09-10 00:00:00', '2026-09-10 05:12:12.925669', '2026-09-10 05:12:12.925669', 1);
INSERT INTO public.publicacion OVERRIDING SYSTEM VALUE VALUES (46, 1, 4, 'aaabc', 'aaa-1789031753037', 'aaa', 'aaa', 0, '2026-09-10 00:00:00', '2026-09-10 04:15:53.039037', '2026-09-10 05:25:38.870282', 1);


--
-- TOC entry 4944 (class 0 OID 18331)
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
INSERT INTO public.usuario OVERRIDING SYSTEM VALUE VALUES (1, 'daniel', 'CC', '111111111', NULL, true, 'eyJhbGciOiJIUzI1NiJ9.eyJyb2xlcyI6W10sInN1YiI6ImRhbmllbCIsImlhdCI6MTc4OTAzNTkxNywiZXhwIjoxNzg5MDM2NTE3fQ.oG212guUXZiMs3pobz8YKPfAJTy-i4EHIfEw-1xFQjA', '2026-09-10 05:35:17.289507', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1, '6de873f6-08ad-4b90-938a-aa8057a9bfa4', '2026-09-17 05:25:17.289507');


--
-- TOC entry 4961 (class 0 OID 0)
-- Dependencies: 223
-- Name: auditoria_publicacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_publicacion_id_seq', 61, true);


--
-- TOC entry 4962 (class 0 OID 0)
-- Dependencies: 221
-- Name: auditoria_usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auditoria_usuario_id_seq', 45, true);


--
-- TOC entry 4963 (class 0 OID 0)
-- Dependencies: 217
-- Name: categoria_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_seq', 4, true);


--
-- TOC entry 4964 (class 0 OID 0)
-- Dependencies: 219
-- Name: publicacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.publicacion_id_seq', 48, true);


--
-- TOC entry 4965 (class 0 OID 0)
-- Dependencies: 215
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_seq', 11, true);


--
-- TOC entry 4794 (class 2606 OID 18436)
-- Name: auditoria_publicacion auditoria_publicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_publicacion
    ADD CONSTRAINT auditoria_publicacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 18427)
-- Name: auditoria_usuario auditoria_usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auditoria_usuario
    ADD CONSTRAINT auditoria_usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 4778 (class 2606 OID 18376)
-- Name: categoria categoria_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_nombre_key UNIQUE (nombre);


--
-- TOC entry 4780 (class 2606 OID 18374)
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id);


--
-- TOC entry 4782 (class 2606 OID 18378)
-- Name: categoria categoria_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_slug_key UNIQUE (slug);


--
-- TOC entry 4788 (class 2606 OID 18392)
-- Name: publicacion publicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT publicacion_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 2606 OID 18394)
-- Name: publicacion publicacion_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT publicacion_slug_key UNIQUE (slug);


--
-- TOC entry 4772 (class 2606 OID 18344)
-- Name: usuario uq_usuario_documento; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT uq_usuario_documento UNIQUE (tipo_documento, numero_documento);


--
-- TOC entry 4774 (class 2606 OID 18340)
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- TOC entry 4776 (class 2606 OID 18342)
-- Name: usuario usuario_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_username_key UNIQUE (username);


--
-- TOC entry 4783 (class 1259 OID 18439)
-- Name: idx_publicacion_categoria; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_categoria ON public.publicacion USING btree (categoria_id);


--
-- TOC entry 4784 (class 1259 OID 18441)
-- Name: idx_publicacion_estado_fecha; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_estado_fecha ON public.publicacion USING btree (estado, fecha_publicacion DESC);


--
-- TOC entry 4785 (class 1259 OID 18440)
-- Name: idx_publicacion_slug; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_slug ON public.publicacion USING btree (slug);


--
-- TOC entry 4786 (class 1259 OID 18438)
-- Name: idx_publicacion_usuario; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_publicacion_usuario ON public.publicacion USING btree (usuario_id);


--
-- TOC entry 4770 (class 1259 OID 18437)
-- Name: idx_usuario_documento; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_usuario_documento ON public.usuario USING btree (tipo_documento, numero_documento);


--
-- TOC entry 4799 (class 2620 OID 18449)
-- Name: publicacion trg_auditoria_publicacion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_publicacion AFTER INSERT OR UPDATE ON public.publicacion FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_publicacion();


--
-- TOC entry 4797 (class 2620 OID 18447)
-- Name: usuario trg_auditoria_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_auditoria_usuario AFTER INSERT OR UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_auditar_usuario();


--
-- TOC entry 4798 (class 2620 OID 18443)
-- Name: usuario trg_soft_delete_usuario; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_soft_delete_usuario BEFORE DELETE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.fn_soft_delete_usuario();


--
-- TOC entry 4795 (class 2606 OID 18400)
-- Name: publicacion fk_publicacion_categoria; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT fk_publicacion_categoria FOREIGN KEY (categoria_id) REFERENCES public.categoria(id) ON DELETE SET NULL;


--
-- TOC entry 4796 (class 2606 OID 18395)
-- Name: publicacion fk_publicacion_usuario; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publicacion
    ADD CONSTRAINT fk_publicacion_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


-- Completed on 2026-09-10 05:29:00

--
-- PostgreSQL database dump complete
--

\unrestrict UEHrjGUfJUeVAYJLJlMtphVA6UJz6n5ee5CaHKQgzsxoQ1loesezMa0fdScwTh4

