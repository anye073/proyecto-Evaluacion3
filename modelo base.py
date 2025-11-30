-- Crear la base de datos
CREATE DATABASE IF NOT EXISTS proyecto_evaluacion;
USE proyecto_evaluacion;

-- ============================
-- TABLA: usuarios
-- ============================
CREATE TABLE usuarios (
    id INT(11) NOT NULL AUTO_INCREMENT,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre VARCHAR(150),
    email VARCHAR(150),
    rol VARCHAR(50) DEFAULT 'usuario',git add app_flutter/lib

    creado_en TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (id)
);

-- ============================
-- TABLA: paquetes
-- ============================
CREATE TABLE paquetes (
    id INT(11) NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(100) NOT NULL UNIQUE,
    direccion_destino VARCHAR(255) NOT NULL,
    descripcion TEXT,
    asignado_a INT(11),
    creado_en TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (id),
    FOREIGN KEY (asignado_a) REFERENCES usuarios(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ============================
-- TABLA: evidencias_entrega
-- ============================
CREATE TABLE evidencias_entrega (
    id INT(11) NOT NULL AUTO_INCREMENT,
    paquete_id INT(11) NOT NULL,
    foto_ruta VARCHAR(255) NOT NULL,
    latitud DECIMAL(10,6),
    longitud DECIMAL(10,6),
    entregado_en TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (id),
    FOREIGN KEY (paquete_id) REFERENCES paquetes(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
