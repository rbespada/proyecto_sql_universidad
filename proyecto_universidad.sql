-- ===========================================
-- CREACIÓN DE LA BASE DE DATOS
-- ===========================================

-- Si no existe, se crea una base de datos llamada "Universidad"
CREATE DATABASE IF NOT EXISTS Universidad;

-- Activamos la base de datos "Universidad" para usarla a partir de ahora.
USE Universidad;


-- ===========================================
-- 1. TABLA PERSONA
-- ===========================================

-- Esta tabla almacena todos los datos comunes a las personas que acceden a la universidad.

CREATE TABLE PERSONA (
    dni CHAR(9) PRIMARY KEY,  -- DNI español 9 caracteres, Clave única
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    edad TINYINT UNSIGNED NOT NULL,  -- Solo permite valores de 0 a 255
    sexo ENUM('Masculino', 'Femenino', 'Prefiero no indicar nada') DEFAULT NULL
);


-- ===========================================
-- 2. TABLA TELEFONO (Entidad débil de PERSONA)
-- ===========================================

-- Esta tabla almacena los teléfonos asociados a cada persona.
-- Una persona puede tener uno o varios teléfonos.

CREATE TABLE TELEFONO (
    dni CHAR(9),  -- Clave foránea de la tabla PERSONA
    numero VARCHAR(20),  -- Número de teléfono
    PRIMARY KEY (dni, numero),  -- Clave compuesta
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE  --Si se elimina una persona de la tabla PERSONA se eliminan tambien el telefono asociado
        ON UPDATE CASCADE  --Si se modifica el DNI de la tabla persona se modifica tambien el DNI (Foráneo) en la tabla TELEFONO 
);


-- ===========================================
-- 3. TABLA ALUMNO (subtipo de PERSONA)
-- ===========================================

CREATE TABLE ALUMNO (
    dni CHAR(9) PRIMARY KEY,
    especialidad ENUM('Ingeniería', 'Filología', 'Biología', 'Medicina', 'Humanidades') NOT NULL,  --Elige especialidad
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ===========================================
-- 4. TABLA PROFESOR (subtipo de PERSONA)
-- ===========================================

CREATE TABLE PROFESOR (
    dni CHAR(9) PRIMARY KEY,
    salario_anual DECIMAL(8,2) NOT NULL,  --Permite 8 digitos en total y dos de ellos decimales, como por ejemplo 599999,95
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (salario_anual > 0 AND salario_anual <= 60000)  --Revisa que sea mayor que 0 y menor o igual que 60000
);


-- ===========================================
-- 5. TABLA ADMINISTRATIVO (subtipo de PERSONA)
-- ===========================================

CREATE TABLE ADMINISTRATIVO (
    dni CHAR(9) PRIMARY KEY,
    especializacion VARCHAR(50) NOT NULL,
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADEI
        ON UPDATE CASCADE
);


-- ===========================================
-- 6. TABLA AUDITOR (subtipo de PERSONA)
-- ===========================================

CREATE TABLE AUDITOR (
    dni CHAR(9) PRIMARY KEY,
    años_experiencia TINYINT UNSIGNED NOT NULL,
    trabaja_fuera BOOLEAN NOT NULL,   -- Especifica entre SI o NO valor booleano 1,0
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ===========================================
-- 7. TABLA VISITA (subtipo de PERSONA)
-- ===========================================

CREATE TABLE VISITA (
    dni CHAR(9) PRIMARY KEY,
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
