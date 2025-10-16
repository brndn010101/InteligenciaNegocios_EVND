IF NOT EXISTS (SELECT NAME FROM sys.databases WHERE NAME = N'miniBD2')
BEGIN
	CREATE DATABASE miniBD2
	COLLATE Latin1_General_100_CI_AS_SC_UTF8;
END
GO

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

CREATE TYPE TipoDetalleVentas AS TABLE(
	Producto NVARCHAR (100),
	Cantidad INT,
	Precio DECIMAL (10,2)
)

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