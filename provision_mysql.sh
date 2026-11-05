#!/bin/bash

# Actualizar e instalar MariaDB y git
apt-get update
apt-get install -y mariadb-server git

# Hacer que MariaDB escuche en la IP de la red interna
sed -i 's/127.0.0.1/192.168.10.11/' /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# Descargar la aplicacion
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/app

# Crear la base de datos y el usuario (solo puede entrar desde el servidor apache)
mysql -u root -e "CREATE DATABASE IF NOT EXISTS lamp_db;"
mysql -u root -e "CREATE USER 'lamp_user'@'192.168.10.10' IDENTIFIED BY 'lamp_password';"
mysql -u root -e "GRANT ALL PRIVILEGES ON lamp_db.* TO 'lamp_user'@'192.168.10.10';"
mysql -u root -e "FLUSH PRIVILEGES;"

# Importar las tablas de la aplicacion
mysql -u root lamp_db < /tmp/app/db/database.sql
