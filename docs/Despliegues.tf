# La configuración básica de Terraform.
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Configura el proveedor Docker para que Terraform interactue con Docker en mi máquina local
provider "docker" {}

# Crear la red Docker para que los contenedores se comuniquen
resource "docker_network" "jenkins_network" {
  name = "jenkins"
}

# Crear el contenedor Docker in Docker (DinD)
resource "docker_container" "jenkins_dind" {
  image       = "docker:dind"
  name        = "jenkins-dind"
  privileged  = true
  networks_advanced {
    name    = docker_network.jenkins_network.name
    aliases = ["dind"]
  }
  env = {
    # Habilitamos TLS para seguridad
    DOCKER_TLS_CERTDIR = "/certs"
  }
  ports {
    # El puerto 2376 es el puerto estándar utilizado por Docker para habilitar comunicación segura mediante TLS 
    internal = 2376
    external = 2376
  }
}

# Crear el contenedor de Jenkins
resource "docker_container" "jenkins" {
  image       = "myjenkins-blueocean"
  name        = "jenkins-blueocean"
  networks_advanced {
    name    = docker_network.jenkins_network.name
    aliases = ["jenkins"]
  }
  env = {
    # Define la dirección del servidor Docker con el que Jenkins se conectará.
    DOCKER_HOST       = "tcp://dind:2376"
    # Especifica la ruta en el contenedor donde están almacenados los certificados TLS necesarios para la autenticación segura.
    DOCKER_CERT_PATH  = "/certs/client"
    # Habilita la verificación TLS para asegurar que la comunicación entre Jenkins y jenkins-dind sea cifrada y autenticada.
    DOCKER_TLS_VERIFY = "1"
  }
  ports {
    # Permite acceder a la interfaz de Jenkins desde el navegador
    internal = 8080
    external = 8080
  }
  ports {
    # Permite que agentes de Jenkins se conecten al servidor Jenkins.
    internal = 50000
    external = 50000
  }
}
