-- ===========================================
-- CREACIÓN DE LA BASE DE DATOS
-- ===========================================

-- Si no existe, se crea una base de datos llamada "Universidad"
CREATE DATABASE IF NOT EXISTS Universidad;

-- Activamos la base de datos "Universidad" para usarla a partir de ahora.
USE Universidad;


-- ===========================================
--  TABLA PERSONA
-- ===========================================

CREATE TABLE PERSONA (
    dni CHAR(9) PRIMARY KEY,  -- DNI español 9 caracteres, Clave única
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    edad TINYINT UNSIGNED NOT NULL,  -- Solo permite valores de 0 a 255
    sexo ENUM('Masculino', 'Femenino', 'Prefiero no indicar nada') DEFAULT NULL
);


-- ===========================================
--  TABLA TELEFONO (Entidad débil de PERSONA)
-- ===========================================

CREATE TABLE TELEFONO (
    dni CHAR(9),  -- Clave foránea de la tabla PERSONA
    numero VARCHAR(20),  -- Número de teléfono
    PRIMARY KEY (dni, numero),  -- Clave compuesta
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE  --Si se elimina una persona de la tabla PERSONA se eliminan tambien el telefono asociado
        ON UPDATE CASCADE  --Si se modifica el DNI de la tabla persona se modifica tambien el DNI (Foráneo) en la tabla TELEFONO 
);


-- ===========================================
--  TABLA ALUMNO (subtipo de PERSONA)
-- ===========================================

CREATE TABLE ALUMNO (
    dni CHAR(9) PRIMARY KEY,
    especialidad ENUM('Ingeniería', 'Filología', 'Biología', 'Medicina', 'Humanidades') NOT NULL,  --Elige especialidad
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ===========================================
--  TABLA PROFESOR (subtipo de PERSONA)
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
--  TABLA ADMINISTRATIVO (subtipo de PERSONA)
-- ===========================================

CREATE TABLE ADMINISTRATIVO (
    dni CHAR(9) PRIMARY KEY,
    especializacion VARCHAR(50) NOT NULL,
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADEI
        ON UPDATE CASCADE
);


-- ===========================================
--  TABLA AUDITOR (subtipo de PERSONA)
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
--  TABLA VISITA (subtipo de PERSONA)
-- ===========================================

CREATE TABLE VISITA (
    dni CHAR(9) PRIMARY KEY,
    FOREIGN KEY (dni) REFERENCES PERSONA(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ===========================================
--  TABLA DEPARTAMENTO
-- ===========================================

CREATE TABLE DEPARTAMENTO (
    is_departamento INT AUTO_INCREMENT PRIMARY KEY,  --Genera un ID automaticamente
    nombre VARCHAR(100) NOT NULL UNIQUE,  --Nos asegura que no haya dos nombres iguales con UNIQUE
    años_existencia TYNYINT UNSIGNED NOT NULL,
    primer_profesor CHAR(9),
    FOREIGN KEY (primer_profesor) REFERENCES PROFESOR(dni)
    ON DELETE SET NULL  --Si el profesor se elimina lo dejamos en NULL para no perder el departamento
    ON UPDATE CASCADE
);


-- ===========================================
--  TABLA CURSO_ORIENTACION
-- ===========================================

CREATE TABLE CURSO_ORIENTACION (
    id_curso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    horas TINYINT UNSIGNED NOT NULL,
    id_departamento INT UNIQUE,
    FOREIGN KEY (id_departamento) REFERENCES DEPARTAMENTO(id_departamento)
    ON DELETE CASCADE  --Si eliminamos el departamento eliminamos tambien su curso asociado
    ON UPDATE CASCADE
);


-- ===========================================
--  TABLA AULA
-- ===========================================

CREATE TABLE AULA (
    id_aula INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(10) NOT NULL,
    planta VARCHAR(10) NOT NULL,
    edificio VARCHAR(50) NOT NULL,
    capacidad TINYINT UNSIGNED,
    tiene_tablon BOOLEAN
);


-- ===========================================
--  TABLA ASIGNATURA
-- ===========================================

CREATE TABLE ASIGNATURA (
    id_asignatura INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_profesor CHAR(9) NOT NULL,
    id_aula INT,
    id_prerrequisito INT,
    FOREIGN KEY (id_profesor) REFERENCES PROFESOR(dni)
        ON DELETE RESTRICT  --No podemos borra un profesor si hay asignaturas que dependen de el
        ON UPDATE CASCADE,
    FOREIGN KEY (id_aula) REFERENCES AULA(id_aula)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (id_prerrequisito) REFERENCES ASIGNATURA(id_asignatura)
        ON DELETE SET NULL  --Si eliminamos la asignatura que es prerrequisito) eliminamos la relacion pero no la asignatura principal
        ON UPDATE CASCADE

);


-- ===========================================
--  TABLA CONVOCATORIA
-- ===========================================

CREATE TABLE CONVOCATORIA (
    id_convocatoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);


-- ===========================================
--  TABLA MATRICULA (relación ternaria)
-- ===========================================

CREATE TABLE MATRICULA (
    dni_alumno CHAR(9),
    id_asignatura INT,
    id_convocatoria INT,
    PRECIO decimal(6,2) NOT NULL,
    nota DECIMAL(4,2),  --Puede ser NULL si aún no se ha evaluado
    PRIMARY KEY (dni_alumno, id_asignatura, id_convocatoria),  --Clave primaria compuesta por la relacion ternaria
    FOREIGN KEY (dni_alumno)REFERENCES ALUMNO(dni)  --Si se borra un alumno se elimina la matrícula
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_asignatura) REFERENCES ASIGNATURA(id_asignatura)  --Si se borra una asignatura se elimina la matrícula
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_convocatoria) REFERENCES CONVOCATORIA(id_convocatoria)  --Si se borra una convocatoria se elimina la matrícula
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CHECK (precio > 0)  --Comprobamos que el precio es mayor que 0
);


-- ===========================================
--  TABLA REPRESENTA (relación reflexiva en ALUMNO)
-- ===========================================

CREATE TABLE REPRESENTA (
    dni_representado CHAR(9) PRIMARY KEY,
    dni_representante CHAR(9) NOT NULL,
    FOREIGN KEY (dni_representado) REFERENCES ALUMNO(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (dni_representante) REFERENCES ALUMNO(dni)
        ON DELETE RESTRICT  -- No podemos eliminar el representante si otro alumno lo esta usando.
        ON UPDATE CASCADE
);


-- ===========================================
--  TABLA AUDITORIA_DOCENTE (agregación)
-- ===========================================

CREATE TABLE AUDITORIA_DOCENTE (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    dni_auditor CHAR(9) NOT NULL,
    dni_profesor CHAR(9) NOT NULL,
    id_asignatura INT NOT NULL,
    id_curso_orientacion INT NOT NULL,
    
    FOREIGN KEY (dni_auditor) REFERENCES AUDITOR(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    FOREIGN KEY (dni_profesor) REFERENCES PROFESOR(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    FOREIGN KEY (id_asignatura) REFERENCES ASIGNATURA(id_asignatura)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    FOREIGN KEY (id_curso_orientacion) REFERENCES CURSO_ORIENTACION(id_curso)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);


-- ===========================================
--  TABLA PREMIO
-- ===========================================

CREATE TABLE PREMIO (
    id_premio INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT  --Cuadro de texto para describir el premio.
);


-- ===========================================
--  TABLA IMPARTICION_PREMIO (agregación)
-- ===========================================

CREATE TABLE IMPARTICION_PREMIO (
    dni_profesor CHAR(9),
    id_asignatura INT,
    id_premio INT,
    PRIMARY KEY (dni_profesor, id_asignatura, id_premio),  --La imparticion se define por PROFESOR + ASIGNATURA
    
    FOREIGN KEY (dni_profesor) REFERENCES PROFESOR(dni)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    FOREIGN KEY (id_asignatura) REFERENCES ASIGNATURA(id_asignatura)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
        
    FOREIGN KEY (id_premio) REFERENCES PREMIO(id_premio)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
