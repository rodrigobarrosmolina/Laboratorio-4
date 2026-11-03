-- ============================================================
-- ICN292 — Lab4 — Austral Editores
-- ============================================================

-- ============================================================
-- ENTREGABLE 1: CREACIÓN DE TABLAS
-- ============================================================

-- Tabla: colecciones (debe ir antes que libros, porque libros la referencia)
CREATE TABLE colecciones (
    id_coleccion     INT AUTO_INCREMENT,
    titulo           VARCHAR(120) NOT NULL,
    fecha_publicacion DATE        NOT NULL,
    PRIMARY KEY (id_coleccion)
);

-- Tabla: autores
CREATE TABLE autores (
    id_autor  INT AUTO_INCREMENT,
    nombre    VARCHAR(80)  NOT NULL,
    pais      VARCHAR(60),
    genero    ENUM('Cómic','Ensayo','Infantil','Novela','Poesía') NOT NULL,
    PRIMARY KEY (id_autor)
);

-- Tabla: libros
CREATE TABLE libros (
    id_libro           INT AUTO_INCREMENT,
    id_autor           INT          NOT NULL,
    id_coleccion       INT          NOT NULL,
    titulo             VARCHAR(120) NOT NULL,
    paginas            INT,
    ejemplares_vendidos INT,
    anio               INT,
    PRIMARY KEY (id_libro),
    FOREIGN KEY (id_autor)     REFERENCES autores(id_autor),
    FOREIGN KEY (id_coleccion) REFERENCES colecciones(id_coleccion)
);

-- Tabla: pagos
CREATE TABLE pagos (
    id_pago     INT AUTO_INCREMENT,
    id_autor    INT            NOT NULL,
    fecha_pago  DATE           NOT NULL,
    monto       DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (id_pago),
    FOREIGN KEY (id_autor) REFERENCES autores(id_autor)
);

-- ============================================================
-- CARGA OFICIAL
-- ============================================================

-- Autores (6 filas; Kenji Arakawa sin país → NULL)
INSERT INTO autores (nombre, pais, genero) VALUES
    ('Elena Pizarro',     'Chile',          'Novela'),
    ('Harold Finch',      'Inglaterra',     'Ensayo'),
    ('Rodrigo Bahamonde', 'Chile',          'Poesía'),
    ('Valentina Correa',  'Argentina',      'Infantil'),
    ('Nora Keller',       'Estados Unidos', 'Novela'),
    ('Kenji Arakawa',     NULL,             'Cómic');

-- Colecciones de prueba (necesarias para poder cargar los 12 libros)
INSERT INTO colecciones (titulo, fecha_publicacion) VALUES
    ('Colección Sur',    '2022-01-15'),
    ('Colección Norte',  '2023-06-01');

-- Libros (12 filas; id_coleccion asignado arbitrariamente para cumplir el FK)
-- id_autor sigue el orden de carga: Elena=1, Harold=2, Rodrigo=3,
--                                   Valentina=4, Nora=5, Kenji=6
INSERT INTO libros (id_autor, id_coleccion, titulo, paginas, ejemplares_vendidos, anio) VALUES
    (1, 1, 'Cielo de Enero',       210, 1500, 2024),
    (1, 1, 'Marea Baja',           185,  800, 2023),
    (1, 2, 'El Norte',             200, 2200, 2024),
    (2, 1, 'Estrellas que Caen',   240, 3000, 2022),
    (2, 2, 'Máquinas',             215,  450, 2024),
    (3, 1, 'Luz Artificial',       300, 1200, 2024),
    (3, 2, 'Ruido Blanco',         280,  600, 2023),
    (4, 1, 'El Barrio de Lila',    190, 5000, 2024),
    (4, 2, 'Antes del Amanecer',   205, 2700, 2024),
    (4, 1, 'La Calle 8',           175,  900, 2023),
    (5, 2, 'Flor de Hierro',       195, 4100, 2024),
    (5, 1, 'Hora Dorada',          220, 1800, 2022);

-- Pagos de prueba (≥3 filas; dos al mismo autor)
INSERT INTO pagos (id_autor, fecha_pago, monto) VALUES
    (1, '2026-03-10', 1500000.00),
    (1, '2026-07-15', 2200000.00),
    (4, '2026-05-20',  980000.00);

-- ============================================================
-- ENTREGABLE 2: CONSULTAS 1–10
-- ============================================================

-- Consulta 1
-- pais <> 'Chile' descarta los NULL sin avisarlo: MySQL no los compara
-- con =, <>, < ni >; para incluirlos hay que agregar OR pais IS NULL.
SELECT nombre, genero
FROM   autores
WHERE  pais <> 'Chile' OR pais IS NULL
ORDER BY nombre;

-- Consulta 2
SELECT titulo, paginas
FROM   libros
WHERE  paginas BETWEEN 190 AND 220
ORDER BY paginas;

-- Consulta 3
SELECT COUNT(*)                AS total_libros,
       SUM(ejemplares_vendidos) AS total_ejemplares,
       AVG(paginas)             AS promedio_paginas,
       MIN(anio)                AS anio_mas_antiguo,
       MAX(ejemplares_vendidos) AS max_ejemplares
FROM   libros;

-- Consulta 4
SELECT DISTINCT genero
FROM   autores
ORDER BY genero;

-- Consulta 5
SELECT a.nombre, COUNT(*) AS libros_2024
FROM   autores a
JOIN   libros  l ON a.id_autor = l.id_autor
WHERE  l.anio = 2024
GROUP BY a.id_autor, a.nombre
HAVING COUNT(*) > 1
ORDER BY a.nombre;

-- Consulta 6
SELECT titulo, ejemplares_vendidos
FROM   libros
WHERE  anio = 2024 AND ejemplares_vendidos > 2000
ORDER BY ejemplares_vendidos DESC
LIMIT 3;

-- Consulta 7
-- INSERT del libro temporal
INSERT INTO libros (id_autor, id_coleccion, titulo, paginas, ejemplares_vendidos, anio)
VALUES (3, 1, 'Papel Mojado', 260, 50, 2024);

-- SELECT previo al DELETE (ver la fila que se va a borrar)
SELECT * FROM libros WHERE titulo = 'Papel Mojado';

-- DELETE filtrado por título
DELETE FROM libros WHERE titulo = 'Papel Mojado';

-- SELECT posterior (verificar que ya no está)
SELECT * FROM libros WHERE titulo = 'Papel Mojado';

-- Consulta 8
-- SELECT previo (ver ejemplares actuales de Cielo de Enero)
SELECT * FROM libros WHERE titulo = 'Cielo de Enero';

-- UPDATE que calcula el nuevo valor a partir del actual
UPDATE libros
SET    ejemplares_vendidos = ejemplares_vendidos + 100
WHERE  titulo = 'Cielo de Enero';

-- SELECT posterior (verificar el cambio)
SELECT * FROM libros WHERE titulo = 'Cielo de Enero';

-- Consulta 9
SELECT l.titulo          AS libro,
       c.titulo          AS coleccion,
       c.fecha_publicacion
FROM   libros      l
JOIN   colecciones c ON l.id_coleccion = c.id_coleccion;

-- Consulta 10 — dos sentencias
-- 10a: lista de pagos con nombre del autor
SELECT a.nombre, p.fecha_pago, p.monto
FROM   pagos   p
JOIN   autores a ON p.id_autor = a.id_autor;

-- 10b: total pagado por autor
SELECT a.nombre, SUM(p.monto) AS total_pagado
FROM   pagos   p
JOIN   autores a ON p.id_autor = a.id_autor
GROUP BY a.id_autor, a.nombre;
