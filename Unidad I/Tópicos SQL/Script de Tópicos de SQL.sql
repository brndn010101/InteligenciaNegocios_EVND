IF NOT EXISTS (SELECT NAME FROM sys.databases WHERE NAME = N'miniBD')
BEGIN
	CREATE DATABASE miniBD
	COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END
GO

SELECT NAME FROM sys.databases

USE  miniBD
GO

IF OBJECT_ID ('clientes', 'u') IS NOT NULL DROP TABLE clientes
CREATE TABLE clientes(
	IdCliente INT NOT NULL,
	Nombre NVARCHAR (100),
	Edad INT,
	Ciudad NVARCHAR (100),
	CONSTRAINT Pk_Clientes
	PRIMARY KEY (IdCliente)
)
GO

IF OBJECT_ID ('productos', 'u') IS NOT NULL DROP TABLE productos
CREATE TABLE productos(
	IdProducto INT PRIMARY KEY,
	NombreProducto NVARCHAR (200),
	Categoria NVARCHAR (200),
	Precio DECIMAL (12,2)
)

GO

INSERT INTO clientes
VALUES (1, 'Ana Torres', 25, 'Ciudad de Mexico')

INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
VALUES (2, 'Luis Perez', 34, 'Guadalajara')

INSERT INTO clientes (IdCliente, Edad, Nombre, Ciudad)
VALUES (3, 29, 'Soyla Vaca', NULL)

INSERT INTO clientes (IdCliente, Nombre, Edad)
VALUES (4, 'Natacha', 41)

INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
VALUES (5, 'Sofia Lopez', 19, 'Chapulhuacan'),
       (6, 'Laura Hernandez', 38, NULL),
	   (7, 'Victor Trujillo', 25, 'Zacualtipan')

SELECT *
FROM clientes

GO

CREATE OR ALTER PROCEDURE sp_add_customer
@id INT,
@nombre NVARCHAR (100),
@edad INT,
@ciudad NVARCHAR (100)
AS
BEGIN
	INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
	VALUES (@id, @nombre, @edad, @ciudad)
END
GO

EXEC sp_add_customer 8, 'Carlos Ruiz', 41, 'Monterrey';
EXEC sp_add_customer 9, 'Jose Angel', 74, 'Salte Si Puedes';

SELECT *
FROM clientes

SELECT COUNT(*) as [Numero de Clientes]
FROM clientes

--Mostrar todos los clientes ordenados por edad de mayor a menor
SELECT UPPER (Nombre) as [Cliente], Edad, Ciudad, UPPER (Ciudad) as [Ciudad]
FROM clientes
ORDER BY Edad DESC

--Listar los clientes que viven en Guadalajara
SELECT Nombre, Ciudad
FROM clientes
WHERE Ciudad = 'Guadalajara'

--Listar los clientes con una edad mayor o igual a 30
SELECT Nombre, Edad, Ciudad
FROM clientes
WHERE edad >= 30

--Listar los clientes cuya ciudad sea nula
SELECT Nombre, Edad, Ciudad
FROM clientes
WHERE Ciudad IS NULL

--Reemplazar en la consulta la ciudades nulas por la palabra "DESCONOCIDA" sin modificar los datos
SELECT Nombre, Edad, ISNULL (Ciudad, 'DESCONOCIDO') AS 'Ciudad'
FROM clientes

--Seleccina los clientes que tengan entre 20 y 35 y que vivan en Puebla o Monterrey

SELECT Nombre, Edad, Ciudad
FROM clientes
WHERE Edad BETWEEN 20 AND 35
	  AND Ciudad IN ('Guadalajara', 'Chapulhuacan')


SELECT *
FROM clientes
--Actualización
UPDATE clientes
SET Ciudad = 'Xochitlan'
WHERE IdCliente = 5

UPDATE clientes
SET Ciudad = 'Sin Ciudad'
WHERE Ciudad IS NULL

UPDATE clientes
SET Edad = 30
WHERE IdCliente BETWEEN 3 AND 6

UPDATE clientes
SET Ciudad = 'Metropoli'
WHERE Ciudad IN ('Ciudad de Mexico','Monterrey','Guadalajara')

UPDATE clientes
SET Nombre = 'Juan Perez', Edad = 27, Ciudad = 'Ciudad Gotica'
WHERE IdCliente = 2

UPDATE clientes
SET Nombre = 'Cliente Premium'
WHERE Nombre LIKE 'A%'

UPDATE clientes
SET Nombre = 'Silver Customer'
WHERE Nombre LIKE '%er%'

UPDATE clientes
SET Edad = (Edad * 2)
WHERE Edad >= 30 AND Ciudad = 'Metropoli'


--Eliminar Datos
DELETE FROM clientes
WHERE Edad BETWEEN 25 AND 30

DELETE clientes
WHERE Nombre LIKE '%l'

GO
--Store Procedures
CREATE OR ALTER PROCEDURE sp_update_customers
@id INT,
@nombre NVARCHAR (100),
@edad INT,
@ciudad NVARCHAR (100)

AS
BEGIN
	UPDATE clientes
	SET Nombre = @nombre, Edad = @edad, Ciudad = @ciudad
	WHERE IdCliente = @id
END
GO

EXEC sp_update_customers 7, 'Benito Kano', 24, 'Lima Los Pies'

SELECT *
FROM  clientes

GO
EXEC sp_update_customers  @ciudad = 'Martinez de la Torre', @edad = 56, @id = 3, @nombre = 'Toribio Trompudo'


-- Ejercicio completo donde se pueda insertar datos en una tabla principal
-- y en una tabla detalle utilizando un SP

CREATE TABLE Ventas (
	IdVenta INT IDENTITY (1,1) PRIMARY KEY,
	FechaVenta DATETIME NOT NULL DEFAULT GETDATE(),
	Cliente NVARCHAR (100) NOT NULL,
	Total DECIMAL (10,2) NULL
)

ALTER TABLE Ventas
ALTER COLUMN Total DECIMAL(10,2) NULL;

CREATE TABLE DetalleVenta(
	IdDetalle INT IDENTITY (1,1) PRIMARY KEY,
	IdVenta INT NOT NULL,
	Producto NVARCHAR (100) NOT NULL,
	Cantidad INT NOT NULL,
	Precio DECIMAL (10,2) NOT NULL,
	CONSTRAINT pk_detalleVenta_venta
	FOREIGN KEY (IdVenta)
	REFERENCES Ventas(IdVenta)
)

-- Crear un tipo de tabla type (Table Type)
-- Este tipo de tabla servirá como estructura para envíar los detalles al SP

CREATE TYPE TipoDetalleVentas AS TABLE(
	Producto NVARCHAR (100),
	Cantidad INT,
	Precio DECIMAL (10,2)
)

-- Crear el SP
-- El SP insertará el encabezado y luego todos los detalles utilizando el tipo de tabla
GO
CREATE OR ALTER PROCEDURE InsertarVentaConDetalle
@cliente NVARCHAR (100),
@detalles TipoDetalleVentas READONLY

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @idVenta INT
	BEGIN TRY
		BEGIN TRANSACTION;
		--Insertar en la tabla principal
		INSERT INTO Ventas (Cliente)
		VALUES (@cliente)

		--Obtener el ID recin generado
		SET @idVenta = SCOPE_IDENTITY()

		--Insertar los detalles (Tabla detalles)
		INSERT INTO DetalleVenta (IdVenta, Producto, Cantidad, Precio)
		SELECT @idVenta, Producto, Cantidad, Precio
		FROM @detalles

		--Calcular el total de venta

		UPDATE Ventas
		SET Total = (SELECT SUM(Cantidad * Precio) FROM @detalles)
		WHERE IdVenta = @idVenta
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW
	END CATCH
END
GO
-- Ejecutar el SP con datos de prueba

--Declarar una variable de tipo tabla}

DECLARE @misDetalles AS TipoDetalleVentas;

-- Insertar productos en el Type Table
INSERT INTO @misDetalles (Producto, Cantidad, Precio)
VALUES
    ('Laptop', 1, 15000),
    ('Mouse', 2, 300),
    ('Teclado', 1, 500),
    ('Pantalla', 5, 4500);

-- Ejecutar el SP
EXEC InsertarVentaConDetalle
    @cliente = 'Uriel Edgar',
    @detalles = @misDetalles;

-- Funciones Integradas (Built-in Function)

SELECT *
FROM clientes

SELECT 
	UPPER(Nombre) AS Mayusculas,
	LOWER(Nombre) AS Minusculas,
	LEN(Nombre) AS Longitud,
	SUBSTRING(Nombre, 1, 3)
FROM clientes

INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
VALUES (8, 'Luis Lopez', 45, 'Achichilco')

INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
VALUES (9, ' German Galindo', 32, 'Achichilco2  ')

INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
VALUES (10, ' Jaen Porfirio ', 19, 'Achichilco3  ')


SELECT
	Nombre AS [Nombre Fuente],
	LTRIM(UPPER(Nombre)) AS Mayusculas,
	LOWER(Nombre) AS Minusculas,
	LEN(Nombre) AS Longitud,
	SUBSTRING(Nombre, 1, 3),
	LTRIM (Nombre) AS [Sin Espacios Izquierda],
	RTRIM (Nombre) AS [Sin Espacios Derecha],
	CONCAT (Nombre, ' - ', Edad) AS [Nombe Edad],
	UPPER(REPLACE(TRIM(Ciudad), 'Chapulhuacan', 'Chapu')) AS [Ciudad Nombre]
FROM clientes

INSERT INTO clientes (IdCliente, Nombre, Edad, Ciudad)
VALUES (11, ' Roberto Estrada  ', 19, 'Chapulhuacan  ')


-- Crear una tabla a partir de una consulta
SELECT TOP 0
	IdCliente,
	Nombre AS [Nombre Fuente],
	LTRIM(UPPER(Nombre)) AS Mayusculas,
	LOWER(Nombre) AS Minusculas,
	LEN(Nombre) AS Longitud,
	SUBSTRING(Nombre, 1, 3) AS [Primeros 3],
	LTRIM (Nombre) AS [Sin Espacios Izquierda],
	RTRIM (Nombre) AS [Sin Espacios Derecha],
	CONCAT (Nombre, ' - ', Edad) AS [Nombe Edad],
	UPPER(REPLACE(TRIM(Ciudad), 'Chapulhuacan', 'Chapu')) AS [Ciudad Nombre]
INTO stage_clientes
FROM clientes

--Agrega un constraint a la tabla (primary key)
ALTER TABLE stage_clientes
ADD CONSTRAINT pk_stage_clientes
PRIMARY KEY (idCliente)

INSERT INTO stage_clientes(
	IdCliente,
	[Nombre Fuente],
	Mayusculas,
	Minusculas,
	Longitud,
	[Primeros 3],
	[Sin Espacios Izquierda],
	[Sin Espacios Derecha],
	[Nombe Edad],
	[Ciudad Nombre]
)
SELECT
	IdCliente,
	Nombre AS [Nombre Fuente],
	LTRIM(UPPER(Nombre)) AS Mayusculas,
	LOWER(Nombre) AS Minusculas,
	LEN(Nombre) AS Longitud,
	SUBSTRING(Nombre, 1, 3) AS [Primeros 3],
	LTRIM (Nombre) AS [Sin Espacios Izquierda],
	RTRIM (Nombre) AS [Sin Espacios Derecha],
	CONCAT (Nombre, ' - ', Edad) AS [Nombe Edad],
	UPPER(REPLACE(TRIM(Ciudad), 'Chapulhuacan', 'Chapu')) AS [Ciudad Nombre]
FROM clientes

-----------------------------
-- Funciones de Fecha
USE NORTHWND

SELECT OrderDate,  
GETDATE() AS [Fecha Actual],  
DATEADD(DAY, 10, OrderDate) AS [FechaMas10Dias],  
DATEPART(QUARTER, OrderDate) AS [Trimestre],  
DATEPART(MONTH, OrderDate) AS [MesConNumero],  
DATENAME(MONTH, OrderDate) AS [MesConNombre],  
DATENAME(WEEKDAY, OrderDate) AS [NombreDia],  
DATEDIFF(DAY, OrderDate, GETDATE()) AS [DiasTranscurridos],  
DATEDIFF(YEAR, OrderDate, GETDATE()) AS [AnosTranscurridos],  
DATEDIFF(YEAR, '2003-07-13', GETDATE()) AS [EdadYael],  
DATEDIFF(YEAR, '1979-07-13', GETDATE()) AS [EdadProfe]  
FROM Orders


--Manejo de Valores Nulos
USE miniBD
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    SecondaryEmail NVARCHAR(100),
    Phone NVARCHAR(20),
    Salary DECIMAL(10,2),
    Bonus DECIMAL(10,2)
);

INSERT INTO Employees(
	EmployeeID,
	FirstName,
	LastName,
	Email,
	SecondaryEmail,
	Phone,
	Salary,
	Bonus
)
VALUES(1, 'Ana', 'Lopez', 'ana.lopez@empresa.com',NULL,'555-2345', 12000, 100),
      (2, 'Carlos', 'Ramirez', NULL, 'c.ramirez@empresa.com', NULL, 9500, NULL),
      (3, 'Laura', 'Gomez', NULL, NULL, '555-8900', 0, 500),
      (4, 'Jorge', 'Diaz', 'jorge.diaz@empresa.com', NULL, NULL, 15000, 0);

--Ejercicio 1
--Mostrar el nombre completo del empleado junto con su número de teléfono
--Si no tiene teléfono, mostrar el texto 'No Disponible'
SELECT CONCAT(FirstName, ' ', LastName) AS [FullName],
	ISNULL(Phone, 'No Disponible') AS [Phone]
FROM Employees

--Ejercicio 2
--Mostrar el nombre del empleado y su correo de contacto
SELECT CONCAT(FirstName, ' ', LastName) AS [Nombre Completo],
	Email,
	SecondaryEmail,
	COALESCE (Email, SecondaryEmail, 'Sin Correo') AS [Correo Contacto]
FROM Employees

--Ejercicio 3. NULLIF
--Mostrar el nombre del empleado, su salario y el resultado de NULLIF (Salary, 0)
--para detectar quién tiene salario 0

SELECT CONCAT(FirstName, ' ', LastName) AS [NombreCompleto],
Salary,
NULLIF (Salary, 0) AS [SalarioEvaluable]
FROM Employees

--Evita error de división por cero

SELECT FirstName, Bonus, (Bonus / NULLIF(Salary, 0)) AS [BonusSalario]
FROM Employees



-- Expresiones condicionales CASE
-- Permite crear condiciones 

SELECT UPPER(CONCAT(FirstName, ' ', LastName)) AS [FullName],
	ROUND(Salary, 2) AS [Salario],
	CASE
		WHEN ROUND(Salary, 2) >= 10000 THEN 'Alto'
		WHEN ROUND(Salary, 2) BETWEEN 5000 AND 9999 THEN 'Medio'
	ELSE 'Bajo'
	END AS [NivelSalarial]
FROM Employees

-- Combinar Funciones y CASE
-- Seleccionar el nombre del producto, la fecha de la orden, telefono, el nombre del
-- cliente en mayusculas, validar si el teléfono es null, poner la palabra
-- 'No Disponible'. Comprobar la fecha de la orden restando los dias de a fecha de orden
-- con respecto a la fecha de hoy, si estos dias son menores a 30, entonces mostrar la palabra
-- 'Reciente', y si no 'Antiguo', el campo debe llamarse 'Estado de Pedido', utiliza la BA Northwind

USE NORTHWND

SELECT 
    p.ProductName AS 'NombreProducto',
    o.OrderDate AS 'FechaOrden',
    CASE 
        WHEN c.Phone IS NULL OR c.Phone = '' THEN 'No Disponible'
        ELSE c.Phone
    END AS 'Telefono',
    UPPER(c.CompanyName) AS 'NombreCliente',
    CASE 
        WHEN DATEDIFF(DAY, o.OrderDate, GETDATE()) < 30 THEN 'Reciente'
        ELSE 'Antiguo'
    END AS 'Estado de Pedido'
FROM 
    Orders o
    INNER JOIN Customers c ON o.CustomerID = c.CustomerID
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    INNER JOIN Products p ON od.ProductID = p.ProductID
ORDER BY 
    o.OrderDate DESC;

--Consulta Clase
SELECT 
    UPPER(c.CompanyName) AS [Nombre Cliente],
    ISNULL(c.Phone, 'No disponible') AS [Telefono],
    p.ProductName AS [Producto],
    o.OrderDate AS [Fecha Pedido],
    CASE
        WHEN DATEDIFF(DAY, o.OrderDate, GETDATE()) < 30 THEN 'Reciente'
        ELSE 'Antiguo'
    END AS [Estado Pedido]
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate DESC;

--Crear tabla

SELECT 
    UPPER(c.CompanyName) AS [Nombre Cliente],
    ISNULL(c.Phone, 'No disponible') AS [Telefono],
    p.ProductName AS [Producto],
    o.OrderDate AS [Fecha Pedido],
    CASE
        WHEN DATEDIFF(DAY, o.OrderDate, GETDATE()) < 30 THEN 'Reciente'
        ELSE 'Antiguo'
    END AS [Estado Pedido]
INTO Tabla_Formateada
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
ORDER BY o.OrderDate DESC;
GO;

CREATE OR ALTER VIEW v_pedidosAntiguos
AS
SELECT [Nombre Cliente], Producto, [Estado Pedido]
FROM Tabla_Formateada
WHERE [Estado Pedido] = 'Antiguo'

SELECT *
FROM v_pedidosAntiguos

--Seleccionar el nombre completo del empleado, seleccionar el correo disponible
--utilizando un COALESCE, comprobar si el teléfono está null, si es así, poner la
--palabra 'disponible'. Validar el bonus si es NULL obligarlo a ser 0 y si es 0 poner
-- la palabra 'Sin bono', y si no es 0 concatenar el bonus anteponiedo el símbolo $

