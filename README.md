# Infraestructura Pila LAMP de dos niveles con Vagrant
**Autor:** Aitor  
**Módulo:** Implantación de Aplicaciones Web ASIR2
# 1. Introducción
En esta práctica montaremos una infraestructura de dos niveles y se desplegará en ella una aplicación de gestión de usuarios. Usaremos Vagrant para las máquinas virtuales.
 
- **Nivel 1 (frontend):** servidor web Apache + PHP. Es la **única** máquina con acceso a Internet.
- **Nivel 2 (backend):** servidor de base de datos. **Sin acceso a Internet**, solo es accesible desde el servidor web a través de una red interna.
- El acceso desde el equipo anfitrión se hace mediante **reenvío de puertos**.

# 2. Configuración del Vagrantfile 
```ruby
Vagrant.configure("2") do |config|
 
  config.vm.box = "debian/bookworm64"
 
  # Maquina de la base de datos (sin Internet)
  config.vm.define "mysql" do |mysql|
    mysql.vm.hostname = "aitormysql"
    mysql.vm.network "private_network", ip: "192.168.10.11", virtualbox__intnet: "red_interna"
    mysql.vm.provision "shell", path: "provision_mysql.sh"
    # Quita la salida a Internet (se ejecuta siempre que arranca la maquina)
    mysql.vm.provision "shell", run: "always", inline: "ip route del default"
  end
 
  # Maquina del servidor web (con Internet por el NAT)
  config.vm.define "apache" do |apache|
    apache.vm.hostname = "aitorapache"
    apache.vm.network "private_network", ip: "192.168.10.10", virtualbox__intnet: "red_interna"
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    apache.vm.provision "shell", path: "provision_apache.sh"
  end
 
end
```
 
Explicación:
 
- `config.vm.box = "debian/bookworm64"`: imagen base Debian 12.
- `config.vm.define "mysql"` y `"apache"`: define cada máquina. Se crea primero `mysql` para que la base de datos esté lista cuando se cree Apache.
- `vm.hostname`: nombre de cada máquina (`aitormysql` y `aitorapache`).
- `private_network` y `virtualbox__intnet`: red interna entre las dos máquinas (192.168.10.0/24).
- `forwarded_port guest: 80, host: 8080`: el puerto 8080 del equipo anfitrión llega al puerto 80 de Apache.
- `provision "shell", path:`: ejecuta el script bash de cada máquina.
- **Máquina sin Internet:** Vagrant siempre crea una interfaz NAT en cada máquina. Para quitar el acceso a Internet de la máquina de base de datos se borra su ruta por defecto con `ip route del default`. Se hace al final cuando ya se ha instalado todo, y con `run: "always"` para que se repita cada vez que arranca.
