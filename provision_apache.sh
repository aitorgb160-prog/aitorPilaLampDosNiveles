#!/bin/bash

# Actualizar e instalar Apache, PHP y git
apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql git

# Descargar la aplicacion
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git /tmp/app

# Copiar la aplicacion a la carpeta web
rm /var/www/html/index.html
cp -r /tmp/app/src/* /var/www/html/

# Cambiar la conexion a la base de datos (IP de la maquina mysql)
cat > /var/www/html/config.php <<'EOF2'
<?php
$mysqli = mysqli_connect("192.168.10.11", "lamp_user", "lamp_password", "lamp_db");
?>
EOF2

# Reiniciar Apache
systemctl restart apache2
