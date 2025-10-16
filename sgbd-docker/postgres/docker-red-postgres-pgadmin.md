# PGADMIN y POSTGRES

## Docker Hub Images

[postgres] https://hub.docker.com/_/postgres

[pgadmin] https://hub.docker.com/r/dpage/pgadmin4


1. Crear un volumen para almacenar la información de la base de datos

`docker volume creat postgres-db3`

2. Crear el contenedor de postgres

docker container run `
-d `
--name postgres-dbbi `
-e POSTGRES_PASSWORD=123456 `
-p 5434:5432 `
-v postgres-db3:/var/lib/postgresql/data `
postgres:15.1

### Comandos para crear un volumen
docker create volume postgres-db3

### Comandos para eliminar un volumen
docker volume rm postgres-db3

### Comando para elminar un contenedor
docker container rm -f postgres_dbbi

3. Crear el contenedor de pgAdmin

docker container run `
-d `
--name pgadmin2 `
-e PGADMIN_DEFAULT_PASSWORD=123456 `
-e PGADMIN_DEFAULT_EMAIL=ssj@google.com `
-p 8089:80 `
dpage/pgadmin4:6.17

4. Crear red
docker network create postgres-net

### Eliminar una red
docker network rm postgres-net

5. Conectar ambos contenedores
`docker network connect nombreContenedor`

docker network connect postgres-net pgadmin2
docker network connect postgres-net postgres-dbbi

