# Actividad de Evaluación: Funciones SQL

- **Nombre:** Brandon Manuel Hernández Mendoza
- **Matrícula:** 22300095
- **Materia:** Inteligencia de Negocios
- **Fecha:** 09-Octubre-2025


## Creación de la base de datos y tabla

Se crea una base de datos para contener una tabla llamada `Estudiantes`. La tabla contiene campos de texto (NVARCHAR), numéricos (DECIMAL) y de fecha (DATE) para poder demostrar funciones de cadenas, fechas y control de nulos.

```sql
-- 1. Crear base de datos y usarla
CREATE DATABASE Actividad_Funciones_SQL;
GO
USE Actividad_Funciones_SQL;
GO

-- 2. Crear tabla Estudiantes
CREATE TABLE dbo.Estudiantes (
  id INT NOT NULL PRIMARY KEY,
  nombre NVARCHAR(100) NOT NULL,
  apellido_paterno NVARCHAR(100) NOT NULL,
  apellido_materno NVARCHAR(100) NULL,
  calificacion DECIMAL(2,1) NULL,
  fecha_registro DATE NOT NULL
);
GO
```


## Datos

```sql
-- 3. Insertar datos
INSERT INTO dbo.Estudiantes (id, nombre, apellido_paterno, apellido_materno, calificacion, fecha_registro) VALUES
(1, 'Ana', 'García', 'López', 9.5, '2025-09-01'),
(2, ' Bruno', 'Ramírez', NULL, NULL, '2025-09-25'),
(3, 'Carlos', 'Núñez', 'Díaz', 7.8, '2025-10-01'),
(4, 'María', 'Ortiz', 'Santos', 8.2, '2025-06-15'),
(5, 'Luis', 'Fernández', 'Márquez', 5.9, '2025-10-09'),
(6, 'Ana María', 'Hernández', 'Pérez', 9.0, '2025-09-30');
GO
```


## 1. Funciones de cadenas

Las funciones de cadenas permiten medir, transformar y buscar dentro de textos. Ejemplos comunes: `LEN`, `LEFT`, `SUBSTRING`, `UPPER`, `LOWER`, `LTRIM`, `RTRIM`, `REPLACE`, `CHARINDEX`, `CONCAT`, y el operador `+` para concatenar (con diferencias en el tratamiento de `NULL`).

### Sintaxis y ejemplo
```sql
-- Ejemplo: Funciones de cadenas
SELECT
  id,
  nombre,
  LTRIM(RTRIM(nombre)) AS nombre_trim,
  UPPER(nombre) AS nombre_upper,
  LEN(nombre) AS len_nombre, -- LEN excluye espacios finales
  LEFT(LTRIM(RTRIM(nombre)),1) AS inicial,
  SUBSTRING(apellido_paterno,1,3) AS ap_p_3,
  CHARINDEX('a', LOWER(LTRIM(RTRIM(nombre)))) AS pos_a,
  REPLACE(nombre,' ','') AS nombre_sin_espacios,
  nombre + ' ' + apellido_paterno + ' ' + apellido_materno AS concatenacion_plus_nullprop, -- NULL propaga NULL
  nombre + ' ' + apellido_paterno + ' ' + ISNULL(apellido_materno,'') AS concatenacion_plus_isnull, -- Usando ISNULL
  CONCAT(nombre, ' ', apellido_paterno, ' ', apellido_materno) AS concatenacion_concat -- CONCAT trata NULL como ''
FROM dbo.Estudiantes;
```

### Resultado

| id | nombre | nombre_trim | nombre_upper | len_nombre | inicial | ap_p_3 | pos_a | nombre_sin_espacios | concatenacion_plus_nullprop | concatenacion_plus_isnull | concatenacion_concat |
| --- | --- | --- | --- | ---: | --- | --- | ---: | --- | --- | --- | --- |
| 1 | Ana | Ana | ANA | 3 | A | Gar | 1 | Ana | Ana García López | Ana García López | Ana García López |
| 2 |  Bruno | Bruno |  BRUNO | 6 | B | Ram | 0 | Bruno | NULL |  Bruno Ramírez  |  Bruno Ramírez  |
| 3 | Carlos | Carlos | CARLOS | 6 | C | Núñ | 2 | Carlos | Carlos Núñez Díaz | Carlos Núñez Díaz | Carlos Núñez Díaz |
| 4 | María | María | MARÍA | 5 | M | Ort | 2 | María | María Ortiz Santos | María Ortiz Santos | María Ortiz Santos |
| 5 | Luis | Luis | LUIS | 4 | L | Fer | 0 | Luis | Luis Fernández Márquez | Luis Fernández Márquez | Luis Fernández Márquez |
| 6 | Ana María | Ana María | ANA MARÍA | 9 | A | Her | 1 | AnaMaría | Ana María Hernández Pérez | Ana María Hernández Pérez | Ana María Hernández Pérez |


## 2. Funciones de fechas

Funciones útiles: `CAST`/`CONVERT` para cambio de tipo, `DATEADD` para sumar unidades de tiempo, `DATEDIFF` para calcular diferencias, `DATEPART` o `DATENAME` para extraer partes de la fecha.

### Sintaxis y ejemplo
```sql
-- Ejemplo: Funciones de fecha (usando fecha fija '2025-10-09' para reproducibilidad)
SELECT
  id,
  fecha_registro,
  CAST(fecha_registro AS DATE) AS fecha_solo,
  DATEADD(day, 7, fecha_registro) AS fecha_mas_7,
  DATEDIFF(day, CAST(fecha_registro AS DATE), CAST('2025-10-09' AS DATE)) AS dias_hasta_2025_10_09,
  DATEPART(MONTH, fecha_registro) AS mes_numero
FROM dbo.Estudiantes;
```

### Resultado

| id | fecha_registro | fecha_solo | fecha_mas_7 | dias_hasta_2025-10-09 | mes_numero |
| --- | --- | --- | --- | ---: | ---: |
| 1 | 2025-09-01 | 2025-09-01 | 2025-09-08 | 38 | 9 |
| 2 | 2025-09-25 | 2025-09-25 | 2025-10-02 | 14 | 9 |
| 3 | 2025-10-01 | 2025-10-01 | 2025-10-08 | 8 | 10 |
| 4 | 2025-06-15 | 2025-06-15 | 2025-06-22 | 116 | 6 |
| 5 | 2025-10-09 | 2025-10-09 | 2025-10-16 | 0 | 10 |
| 6 | 2025-09-30 | 2025-09-30 | 2025-10-07 | 9 | 9 |


## 3. Control de valores nulos

- `ISNULL(valor, sustituto)` reemplaza `NULL` por `sustituto`.  
- `COALESCE(valor1, valor2, ...)` devuelve el primer valor no nulo.  
- `NULLIF(x, y)` devuelve `NULL` si `x = y`; de lo contrario devuelve `x`.

### Sintaxis y ejemplo
```sql
SELECT
  id,
  calificacion,
  ISNULL(calificacion, 0) AS calificacion_no_nula,
  COALESCE(apellido_materno, 'N/A') AS apellido_materno_coalesce
FROM dbo.Estudiantes;
```

### Resultado

| id | calificacion | calificacion_no_nula | apellido_materno_coalesce |
| --- | ---: | ---: | --- |
| 1 | 9.5 | 9.5 | López |
| 2 | NULL | 0 | N/A |
| 3 | 7.8 | 7.8 | Díaz |
| 4 | 8.2 | 8.2 | Santos |
| 5 | 5.9 | 5.9 | Márquez |
| 6 | 9.0 | 9.0 | Pérez |


## 4. Uso de MERGE

`MERGE` permite combinar acciones (`INSERT`, `UPDATE`, `DELETE`) en una tabla objetivo a partir de una fuente. Aquí usamos una fuente derivada con `VALUES`, por lo que no es necesaria otra tabla física.

### Sintaxis y ejemplo
```sql
-- Ejemplo MERGE: Actualiza la calificación del id=3 a 8.5 y agrega id=7
MERGE dbo.Estudiantes AS target
USING (VALUES
  (3, 'Carlos', 'Núñez', 'Díaz', 8.5, '2025-10-01'),
  (7, 'Pedro', 'Gómez', 'Ruiz', 7.2, '2025-10-09')
) AS source (id, nombre, apellido_paterno, apellido_materno, calificacion, fecha_registro)
ON (target.id = source.id)
WHEN MATCHED THEN
  UPDATE SET
    nombre = source.nombre,
    apellido_paterno = source.apellido_paterno,
    apellido_materno = source.apellido_materno,
    calificacion = source.calificacion,
    fecha_registro = source.fecha_registro
WHEN NOT MATCHED BY TARGET THEN
  INSERT (id, nombre, apellido_paterno, apellido_materno, calificacion, fecha_registro)
  VALUES (source.id, source.nombre, source.apellido_paterno, source.apellido_materno, source.calificacion, source.fecha_registro);
GO
```

### Resultado

| id | nombre | apellido_paterno | apellido_materno | calificacion | fecha_registro |
| --- | --- | --- | --- | ---: | --- |
| 1 | Ana | García | López | 9.5 | 2025-09-01 |
| 2 |  Bruno | Ramírez | NULL | NULL | 2025-09-25 |
| 3 | Carlos | Núñez | Díaz | 8.5 | 2025-10-01 |
| 4 | María | Ortiz | Santos | 8.2 | 2025-06-15 |
| 5 | Luis | Fernández | Márquez | 5.9 | 2025-10-09 |
| 6 | Ana María | Hernández | Pérez | 9.0 | 2025-09-30 |
| 7 | Pedro | Gómez | Ruiz | 7.2 | 2025-10-09 |


## 5. Uso de CASE

`CASE` permite devolver valores condicionales (similar a `if/else`). Se usa para clasificar, por ejemplo, calificaciones en letras.

### Sintaxis y ejemplo
```sql
SELECT
  id,
  nombre,
  calificacion,
  CASE
    WHEN calificacion IS NULL THEN 'Sin calificación'
    WHEN calificacion >= 9 THEN 'A'
    WHEN calificacion >= 8 THEN 'B'
    WHEN calificacion >= 7 THEN 'C'
    WHEN calificacion >= 6 THEN 'D'
    ELSE 'F'
  END AS calificacion_letra,
  CASE WHEN calificacion >= 6 THEN 'Aprobado' ELSE 'Reprobado' END AS estado
FROM dbo.Estudiantes;
```

### Resultado

| id | nombre | calificacion | calificacion_letra | estado |
| --- | --- | ---: | --- | --- |
| 1 | Ana | 9.5 | A | Aprobado |
| 2 |  Bruno | NULL | Sin calificación | Reprobado |
| 3 | Carlos | 7.8 | C | Aprobado |
| 4 | María | 8.2 | B | Aprobado |
| 5 | Luis | 5.9 | F | Reprobado |
| 6 | Ana María | 9.0 | A | Aprobado |
| 7 | Pedro | 7.2 | C | Aprobado |