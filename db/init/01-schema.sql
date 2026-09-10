--
-- PostgreSQL Database Script - Estructura Completa
--

CREATE DATABASE prueba_periferia;
\connect prueba_periferia

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

-- =============================================================================
-- 1. TABLAS PRINCIPALES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabla: usuario
-- -----------------------------------------------------------------------------
CREATE TABLE public.usuario (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username character varying(255) NOT NULL UNIQUE,
    tipo_documento character varying(10),
    numero_documento character varying(20),
    empleado_id bigint,
    activo boolean DEFAULT true NOT NULL,
    token character varying(255),
    expirydate timestamp without time zone,
    password character varying(255),
    eliminado smallint DEFAULT 1 NOT NULL, -- 1: Activo (No borrado), 0: Borrado
    
    CONSTRAINT uq_usuario_documento UNIQUE (tipo_documento, numero_documento),
    CONSTRAINT chk_usuario_eliminado CHECK (eliminado IN (0, 1))
);

COMMENT ON TABLE public.usuario IS 'Usuarios autenticados en la plataforma';

-- -----------------------------------------------------------------------------
-- Tabla: perfil
-- -----------------------------------------------------------------------------
CREATE TABLE public.perfil (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre character varying(255) NOT NULL UNIQUE
);

COMMENT ON TABLE public.perfil IS 'Perfiles funcionales / roles';

-- -----------------------------------------------------------------------------
-- Tabla: usuario_perfil
-- -----------------------------------------------------------------------------
CREATE TABLE public.usuario_perfil (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id bigint NOT NULL,
    perfil_id bigint NOT NULL,
    
    CONSTRAINT fk_usuario_perfil_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE,
    CONSTRAINT fk_usuario_perfil_perfil FOREIGN KEY (perfil_id) REFERENCES public.perfil(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.usuario_perfil IS 'Relación N:M usuario-perfil';

-- -----------------------------------------------------------------------------
-- Tabla: categoria
-- -----------------------------------------------------------------------------
CREATE TABLE public.categoria (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre character varying(100) NOT NULL UNIQUE,
    slug character varying(100) NOT NULL UNIQUE
);

COMMENT ON TABLE public.categoria IS 'Categorías para clasificación de publicaciones';

-- -----------------------------------------------------------------------------
-- Tabla: publicacion
-- -----------------------------------------------------------------------------
CREATE TABLE public.publicacion (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id bigint NOT NULL,
    categoria_id bigint,
    titulo character varying(255) NOT NULL,
    slug character varying(255) NOT NULL UNIQUE,
    resumen text,
    contenido text NOT NULL,
    estado smallint DEFAULT 0 NOT NULL, -- 0: Borrador, 1: Publicado, 2: Archivado
    fecha_publicacion timestamp without time zone,
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    actualizado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    eliminado smallint DEFAULT 1 NOT NULL, -- 1: Activo (No borrado), 0: Borrado
    
    CONSTRAINT fk_publicacion_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE,
    CONSTRAINT fk_publicacion_categoria FOREIGN KEY (categoria_id) REFERENCES public.categoria(id) ON DELETE SET NULL,
    CONSTRAINT chk_publicacion_estado CHECK (estado IN (0, 1, 2)),
    CONSTRAINT chk_publicacion_eliminado CHECK (eliminado IN (0, 1))
);

COMMENT ON TABLE public.publicacion IS 'Publicaciones y artículos generados por usuarios';

-- -----------------------------------------------------------------------------
-- Tabla: publicacion_adjunto
-- -----------------------------------------------------------------------------
CREATE TABLE public.publicacion_adjunto (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    publicacion_id bigint NOT NULL,
    url_archivo character varying(500) NOT NULL,
    tipo_mime character varying(50),
    creado_en timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    CONSTRAINT fk_adjunto_publicacion FOREIGN KEY (publicacion_id) REFERENCES public.publicacion(id) ON DELETE CASCADE
);

-- =============================================================================
-- 2. TABLAS DE AUDITORÍA
-- =============================================================================

CREATE TABLE public.auditoria_usuario (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id bigint NOT NULL,
    accion character varying(20) NOT NULL, -- INSERT, UPDATE, DELETE_LOGICO
    usuario_accion character varying(255) NOT NULL,
    fecha_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_anteriores jsonb
);

CREATE TABLE public.auditoria_publicacion (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    publicacion_id bigint NOT NULL,
    accion character varying(20) NOT NULL, -- INSERT, UPDATE, DELETE_LOGICO
    usuario_accion character varying(255) NOT NULL,
    fecha_hora timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    datos_anteriores jsonb
);

-- =============================================================================
-- 3. ÍNDICES DE RENDIMIENTO
-- =============================================================================

CREATE INDEX idx_usuario_documento ON public.usuario(tipo_documento, numero_documento);
CREATE INDEX idx_publicacion_usuario ON public.publicacion(usuario_id);
CREATE INDEX idx_publicacion_categoria ON public.publicacion(categoria_id);
CREATE INDEX idx_publicacion_slug ON public.publicacion(slug);
CREATE INDEX idx_publicacion_estado_fecha ON public.publicacion(estado, fecha_publicacion DESC);

-- =============================================================================
-- 4. FUNCIONES Y TRIGGERS: BORRADO LÓGICO (SOFT DELETE)
-- =============================================================================

-- Soft Delete: usuario
CREATE OR REPLACE FUNCTION public.fn_soft_delete_usuario()
RETURNS trigger AS $$
BEGIN
    UPDATE public.usuario 
    SET eliminado = 0 
    WHERE id = OLD.id;
    
    RETURN NULL; -- Cancela la eliminación física
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soft_delete_usuario
BEFORE DELETE ON public.usuario
FOR EACH ROW
EXECUTE FUNCTION public.fn_soft_delete_usuario();

-- Soft Delete: publicacion
CREATE OR REPLACE FUNCTION public.fn_soft_delete_publicacion()
RETURNS trigger AS $$
BEGIN
    UPDATE public.publicacion 
    SET eliminado = 0 
    WHERE id = OLD.id;
    
    RETURN NULL; -- Cancela la eliminación física
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_soft_delete_publicacion
BEFORE DELETE ON public.publicacion
FOR EACH ROW
EXECUTE FUNCTION public.fn_soft_delete_publicacion();

-- =============================================================================
-- 5. FUNCIONES Y TRIGGERS: AUDITORÍA
-- =============================================================================

-- Auditoría: usuario
CREATE OR REPLACE FUNCTION public.fn_auditar_usuario()
RETURNS trigger AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_usuario
AFTER INSERT OR UPDATE ON public.usuario
FOR EACH ROW
EXECUTE FUNCTION public.fn_auditar_usuario();

-- Auditoría: publicacion
CREATE OR REPLACE FUNCTION public.fn_auditar_publicacion()
RETURNS trigger AS $$
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
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_publicacion
AFTER INSERT OR UPDATE ON public.publicacion
FOR EACH ROW
EXECUTE FUNCTION public.fn_auditar_publicacion();

-- =============================================================================
-- 6. DATOS INICIALES (SEMILLAS)
-- =============================================================================

-- Perfiles iniciales
INSERT INTO public.perfil (nombre) VALUES ('ADMINISTRADOR');
INSERT INTO public.perfil (nombre) VALUES ('NORMAL');
INSERT INTO public.perfil (nombre) VALUES ('VISITANTE');

-- Categorías iniciales
INSERT INTO public.categoria (nombre, slug) VALUES ('General', 'general');
INSERT INTO public.categoria (nombre, slug) VALUES ('Tecnología', 'tecnologia');
INSERT INTO public.categoria (nombre, slug) VALUES ('Noticias', 'noticias');
INSERT INTO public.categoria (nombre, slug) VALUES ('Anuncios', 'anuncios');


-- Usuario 1 (Daniel)
INSERT INTO public.usuario (id, username, tipo_documento, numero_documento, empleado_id, activo, token, expirydate, password, eliminado)
OVERRIDING SYSTEM VALUE VALUES 
(1, 'daniel', 'CC', '111111111', NULL, true, 'TOKEN_ADMIN_001', '2026-03-16 16:12:26.460879', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1);

-- 10 Usuarios adicionales (usuario1 a usuario10) con documentos secuenciales (22222222 en adelante)
INSERT INTO public.usuario (id, username, tipo_documento, numero_documento, empleado_id, activo, token, expirydate, password, eliminado)
OVERRIDING SYSTEM VALUE VALUES 
(2,  'usuario1',  'CC', '22222222', NULL, true, 'TOKEN_USR_001', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(3,  'usuario2',  'CC', '33333333', NULL, true, 'TOKEN_USR_002', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(4,  'usuario3',  'CC', '44444444', NULL, true, 'TOKEN_USR_003', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(5,  'usuario4',  'CC', '55555555', NULL, true, 'TOKEN_USR_004', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(6,  'usuario5',  'CC', '66666666', NULL, true, 'TOKEN_USR_005', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(7,  'usuario6',  'CC', '77777777', NULL, true, 'TOKEN_USR_006', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(8,  'usuario7',  'CC', '88888888', NULL, true, 'TOKEN_USR_007', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(9,  'usuario8',  'CC', '99999999', NULL, true, 'TOKEN_USR_008', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(10, 'usuario9',  'CC', '10101010', NULL, true, 'TOKEN_USR_009', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1),
(11, 'usuario10', 'CC', '11111112', NULL, true, 'TOKEN_USR_010', '2026-12-31 23:59:59', '$2a$10$QoM4BUcNJKWaRFvoeIX3nOWoeYjgARll90A3EpsEF0S7vebwc1R/C', 1);

-- Reiniciar el valor de la secuencia autonumérica IDENTITY para futuras inserciones
SELECT pg_catalog.setval('public.usuario_id_seq', 11, true);


-- 1. Limpieza de datos anteriores y reinicio del ID correlativo
TRUNCATE TABLE public.publicacion RESTART IDENTITY CASCADE;

-- 2. Inserción aleatoria de publicaciones (mínimo 4 por cada usuario)
INSERT INTO public.publicacion (
    usuario_id, 
    categoria_id, 
    titulo, 
    slug, 
    resumen, 
    contenido, 
    estado, 
    fecha_publicacion, 
    creado_en, 
    actualizado_en, 
    eliminado
)
SELECT 
    u.id AS usuario_id,
    -- Categoría aleatoria (IDs 1 a 4)
    (FLOOR(RANDOM() * 4) + 1)::int8 AS categoria_id,
    
    -- Título amigable con el correlativo y nombre del usuario
    'Publicación N° ' || p.num || ' de ' || u.username AS titulo,
    
    -- Generación de Slug único (mantenimiento de la restricción publicacion_slug_key)
    'publicacion-' || p.num || '-' || u.username || '-' || SUBSTRING(MD5(RANDOM()::text) FROM 1 FOR 6) AS slug,
    
    -- Resumen explicativo
    'Resumen breve para la publicación número ' || p.num || ' del usuario ' || u.username || '.' AS resumen,
    
    -- Contenido detallado
    'Contenido completo y detallado para la publicación ' || p.num || ' registrada por el usuario ' || u.username || '.' AS contenido,
    
    -- Estado aleatorio: 0 (Borrador), 1 (Publicado), 2 (Archivado)
    (FLOOR(RANDOM() * 3))::int2 AS estado,
    
    -- Fecha de publicación dentro de los últimos 30 días
    CURRENT_TIMESTAMP - (RANDOM() * INTERVAL '30 days') AS fecha_publicacion,
    
    -- Fechas de creación y actualización
    CURRENT_TIMESTAMP - (RANDOM() * INTERVAL '30 days') AS creado_en,
    CURRENT_TIMESTAMP AS actualizado_en,
    
    -- Indicador activo (1: No eliminado)
    1::int2 AS eliminado
FROM 
    public.usuario u
CROSS JOIN 
    GENERATE_SERIES(1, 4) AS p(num)
ORDER BY 
    u.id, p.num;