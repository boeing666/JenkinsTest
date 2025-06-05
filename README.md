# Guía de Despliegue: Aplicación Python con Jenkins y Terraform

Este documento guía paso a paso el despliegue de una aplicación Python utilizando Jenkins como servidor de integración continua y Terraform para la infraestructura.

---

## Requisitos Previos

- Docker y Docker Compose instalados.
- Terraform instalado.
- Cuenta de GitHub con el repositorio forkeado.
- Acceso a puerto `8080` en tu máquina local

---

## 1. Preparación del Repositorio

### Fork y Configuración Inicial

1. Realiza un *fork* del repositorio `simple-python-pyinstaller-app` en tu cuenta de GitHub.
2. Renombra la rama principal a `main` si es necesario.

---

## 2. Construcción de Imagen Jenkins Personalizada

### Crear Dockerfile

En el directorio `/docs`, crea un archivo `Dockerfile` con las dependencias necesarias para Jenkins y Blue Ocean.

### Construir la Imagen

Desde la misma carpeta `/docs`, ejecuta:

```bash
docker build -t myjenkins-blueocean .
```
## 3. Despliegue de Infraestructura con Terraform

### Archivo de Configuración

Crea un archivo llamado `main.tf` en la carpeta `/docs` con tu configuración deseada.

### Comandos para Inicializar y Aplicar
```bash
terraform init
terraform plan
terraform apply
```
Esto levantará la infraestructura necesaria para Jenkins.
## 4. Configuración de Jenkins

### Acceder al Panel Web

Abre el navegador y entra a:

`http://localhost:8080`

### Obtener la Contraseña de Desbloqueo

Ejecuta:


`docker logs jenkins-blueocean` 

Copia la contraseña que aparece en consola e introdúcela en la interfaz web para completar la configuración inicial.
## 5. Crear el Pipeline

### Nuevo Proyecto

1.  Haz clic en `New item` desde el panel de Jenkins.
    
2.  Asigna un nombre y selecciona `Pipeline`.
    
3.  Activa la opción `SCM Polling` para habilitar la ejecución automática.
    
4.  Configura el origen del script:
    
    -   SCM: `GIT`
        
    -   URL del repositorio:
      
    -   Rama: `*/main`
        
    -   Ruta al Jenkinsfile: `docs/jenkinsfile`
        
## 6. Ejecutar el Pipeline

1.  Desde Jenkins, inicia el pipeline manualmente o espera a que detecte cambios.
    
2.  El pipeline ejecutará automáticamente las siguientes etapas:
    
    -   **Build**
        
    -   **Test**
        
    -   **Deliver**
        
## 7. Verificar el Artefacto Generado

Si la ejecución es exitosa, el artefacto `add2vals` será generado y almacenado.  

