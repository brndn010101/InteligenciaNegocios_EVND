Para descargar:

docker pull mcr.microsoft.com/mssql/server:2025-latest


## Comando para ejecutar en Linux
```docker
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Mipassw0rd123!" \
-p 1422:1433 --name sqlserverBI \
-v sqlserver-volume:/var/opt/mssql \
-d mcr.microsoft.com/mssql/server:2025-latest
```

## Comandos crear volumen
docker volume create sqlserver-volume

## Comando para ejecutar en Windows
```docker
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=StrongP@ss123!" `
-p 1422:1433 --name sqlserverBI `
-v sqlserver-volume:/var/opt/mssql `
-d mcr.microsoft.com/mssql/server:2022-latest
```