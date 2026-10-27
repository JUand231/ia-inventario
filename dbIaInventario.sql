/* ============================================================================
   dbIaInventario.sql — Ferretería Sacaclavos (proyecto Ia-Inventario)
   Script UNIFICADO: crea la base de datos completa con datos de ejemplo.
   
   Contenido:
     1. Base de datos dbIaInventario (solo se crea si NO existe)
     2. Tablas: categorias, productos, entradas, facturas, salidas
     3. Claves foráneas
     4. Vista vw_detalle_factura
     5. Datos de ejemplo: 5 categorías, 15 productos, 8 entradas, 10 salidas

   Cómo correrlo: abrir SQL Server Management Studio (o SSMS),
   conectar con autenticación de Windows y ejecutar este archivo completo.

   NOTA IMPORTANTE: si la base de datos ya existe, el script se ABORTA sin
   tocar nada (es un escudo para no borrar datos por accidente).
   ============================================================================ */

-- Si la BD ya existe, no hacemos nada (protección de datos)
IF DB_ID('dbIaInventario') IS NOT NULL
BEGIN
    PRINT 'ABORTADO: la base de datos dbIaInventario ya existe.';
    PRINT 'Este script solo sirve para crear la BD desde cero.';
    RETURN;
END
GO

CREATE DATABASE dbIaInventario;
GO

USE dbIaInventario;
GO

/* ============================== TABLAS ================================== */

CREATE TABLE categorias (
    Id      INT IDENTITY(1,1) PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL
);

CREATE TABLE productos (
    Id            INT IDENTITY(1,1) PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    descripcion   VARCHAR(100) NOT NULL,
    precio_compra DECIMAL(18,2) NOT NULL,
    precio_venta  DECIMAL(18,2) NOT NULL,
    stock         INT NOT NULL,
    stock_minimo  INT NOT NULL,
    Id_categoria  INT NOT NULL,
    estado        BIT NOT NULL DEFAULT 1,   -- 1 = activo, 0 = desactivado (borrado lógico)
    ubicacion     VARCHAR(80) NULL          -- ej: 'Pasillo 1 - Estante A'
);

CREATE TABLE facturas (
    Id          INT IDENTITY(1,1) PRIMARY KEY,
    fecha       DATETIME NOT NULL,
    cliente     VARCHAR(100) NULL,
    metodo_pago VARCHAR(20) NOT NULL,       -- EFECTIVO / TARJETA / TRANSFERENCIA
    total       DECIMAL(12,2) NOT NULL
);

CREATE TABLE entradas (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    Id_producto    INT NOT NULL,
    cantidad       INT NOT NULL,
    precio_unitario DECIMAL(18,2) NOT NULL,
    proveedor      VARCHAR(100) NOT NULL,
    fecha          DATETIME NOT NULL,
    observaciones  VARCHAR(100) NULL
);

CREATE TABLE salidas (
    Id             INT IDENTITY(1,1) PRIMARY KEY,
    Id_producto    INT NOT NULL,
    cantidad       INT NOT NULL,
    precio_unitario DECIMAL(18,2) NOT NULL,
    cliente        VARCHAR(50) NOT NULL,
    fecha          DATETIME NOT NULL,
    observaciones  VARCHAR(100) NULL,
    Id_factura     INT NULL                  -- NULL = salida manual (merma/ajuste)
);

/* ========================= CLAVES FORÁNEAS ============================== */

ALTER TABLE entradas ADD CONSTRAINT FK_entradas_productos
    FOREIGN KEY (Id_producto) REFERENCES productos(Id);

ALTER TABLE salidas ADD CONSTRAINT FK_salidas_producto
    FOREIGN KEY (Id_producto) REFERENCES productos(Id);

ALTER TABLE salidas ADD CONSTRAINT FK_salidas_facturas
    FOREIGN KEY (Id_factura) REFERENCES facturas(Id);

/* =============================== VISTA ================================== */

CREATE VIEW vw_detalle_factura AS
SELECT f.Id AS id_factura, f.fecha, f.cliente, f.metodo_pago, f.total,
       p.Id AS id_producto, p.nombre AS producto,
       s.cantidad, s.precio_unitario,
       s.cantidad * s.precio_unitario AS subtotal
FROM facturas f
JOIN salidas s   ON s.Id_factura = f.Id
JOIN productos p ON p.Id = s.Id_producto;
GO

/* ========================== DATOS DE EJEMPLO ============================ */

SET IDENTITY_INSERT categorias ON;
INSERT INTO categorias (Id, nombre) VALUES (1, 'Herramientas');
INSERT INTO categorias (Id, nombre) VALUES (2, 'Pinturas');
INSERT INTO categorias (Id, nombre) VALUES (3, 'Electricidad');
INSERT INTO categorias (Id, nombre) VALUES (4, 'Plomería');
INSERT INTO categorias (Id, nombre) VALUES (5, 'Construcción');
SET IDENTITY_INSERT categorias OFF;

SET IDENTITY_INSERT productos ON;
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (1, 'Taladro Bosch GSB 500W', 'Taladro percutor 500W con maletin', 85000.00, 120000.00, 15, 5, 1, 0, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (2, 'Martillo Stanley 16 oz', 'Martillo de uña con mango de fibra', 18000.00, 28000.00, 40, 10, 1, 1, 'Pasillo 1 · Estante A');
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (3, 'Llave inglesa 12"', 'Llave ajustable de 12 pulgadas', 22000.00, 35000.00, 3, 5, 1, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (4, 'Pintura Sinex Blanco 1G', 'Pintura vinilica blanca 1 galon', 28000.00, 42000.00, 25, 8, 2, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (5, 'Pintura Negra Mate 1G', 'Pintura latex negra efecto mate 1 galon', 30000.00, 45000.00, 2, 6, 2, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (6, 'Rodillo de pintura 9"', 'Rodillo algodon 9 pulgadas con soporte', 6000.00, 11000.00, 18, 6, 2, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (7, 'Cable 12 AWG (rollo 100m)', 'Rollo de cable calibre 12 de 100 metros', 95000.00, 140000.00, 12, 4, 3, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (8, 'Enchufe hembra doble', 'Enchufe doble para pared', 2500.00, 5000.00, 60, 20, 3, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (9, 'Bombillo LED 9W', 'Bombillo LED frio 9 vatios', 3800.00, 7000.00, 4, 15, 3, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (10, 'Cinta Teflon 12m', 'Cinta teflon blanca 12 metros', 1500.00, 3500.00, 80, 25, 4, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (11, 'Silicona transparente 300ml', 'Silicona de sellado transparente 300 ml', 7500.00, 13000.00, 30, 10, 4, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (12, 'Llave de paso 1/2"', 'Llave de paso de agua 1/2 pulgada', 12000.00, 20000.00, 9, 5, 4, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (13, 'Cemento Pizarreño 50kg', 'Cemento gris tipo I bolsa de 50 kg', 18000.00, 25000.00, 50, 15, 5, 1, NULL);
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (14, 'Clavos 2" (libra)', 'Clavos lisos de 2 pulgadas por libra', 3000.00, 5500.00, 4, 20, 5, 1, 'Pasillo 2 · Estante C');
INSERT INTO productos (Id, nombre, descripcion, precio_compra, precio_venta, stock, stock_minimo, Id_categoria, estado, ubicacion) VALUES (15, 'Arena fina (bulto)', 'Arena fina lavada bulto de 25 kg', 16000.00, 22000.00, 20, 10, 5, 1, NULL);
SET IDENTITY_INSERT productos OFF;

SET IDENTITY_INSERT entradas ON;
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (1, 1, 10, 85000.00, 'Distribuciones El Constructor', '2026-10-01 09:00:00', 'Pedido quincenal');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (2, 4, 20, 28000.00, 'Pinturas del Valle', '2026-10-03 10:30:00', 'Reposicion mensual');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (3, 7, 15, 95000.00, 'Electricidad Total S.A.', '2026-10-05 08:15:00', 'Compra mayorista');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (4, 14, 40, 3000.00, 'Ferreteria Mayorista Andes', '2026-10-07 14:00:00', 'Surtido semanal');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (5, 9, 30, 3800.00, 'Electricidad Total S.A.', '2026-10-10 11:45:00', 'Pedido quincenal');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (6, 13, 60, 18000.00, 'Cementos Andinos', '2026-10-12 07:30:00', 'Entrega a bodega');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (7, 3, 12, 22000.00, 'Distribuciones El Constructor', '2026-10-15 16:20:00', 'Reposicion');
INSERT INTO entradas (Id, Id_producto, cantidad, precio_unitario, proveedor, fecha, observaciones) VALUES (8, 11, 25, 7500.00, 'Plomeria Express', '2026-10-18 10:10:00', 'Surtido semanal');
SET IDENTITY_INSERT entradas OFF;

SET IDENTITY_INSERT salidas ON;
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (1, 1, 2, 120000.00, 'Maestro Ernesto', '2026-10-04 14:15:00', 'Venta mostrador', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (2, 5, 4, 45000.00, 'Constructora Hermanos Ruiz', '2026-10-06 09:40:00', 'Venta credito', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (3, 9, 15, 7000.00, 'Doña Carmen', '2026-10-08 15:25:00', 'Venta mostrador', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (4, 14, 25, 5500.00, 'Maestro Ernesto', '2026-10-11 10:05:00', 'Venta mostrador', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (5, 2, 5, 28000.00, 'Albañil Jairo', '2026-10-13 16:50:00', 'Venta mostrador', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (6, 8, 20, 5000.00, 'Electricista Ruben', '2026-10-16 11:30:00', 'Venta por mayor', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (7, 10, 30, 3500.00, 'Plomero Alvarez', '2026-10-17 08:55:00', 'Venta mostrador', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (8, 13, 10, 25000.00, 'Constructora Hermanos Ruiz', '2026-10-19 13:20:00', 'Venta a obra', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (9, 6, 6, 11000.00, 'Doña Carmen', '2026-10-20 10:45:00', 'Venta mostrador', NULL);
INSERT INTO salidas (Id, Id_producto, cantidad, precio_unitario, cliente, fecha, observaciones, Id_factura) VALUES (10, 12, 3, 20000.00, 'Plomero Alvarez', '2026-10-21 15:35:00', 'Venta mostrador', NULL);
SET IDENTITY_INSERT salidas OFF;
GO

/* ============================ VERIFICACIÓN ============================== */

SELECT 'Base de datos dbIaInventario creada correctamente' AS Resultado;
SELECT 'categorias' AS Tabla, COUNT(*) AS Registros FROM categorias
UNION ALL SELECT 'productos', COUNT(*) FROM productos
UNION ALL SELECT 'entradas', COUNT(*) FROM entradas
UNION ALL SELECT 'salidas', COUNT(*) FROM salidas
UNION ALL SELECT 'facturas', COUNT(*) FROM facturas;
GO
