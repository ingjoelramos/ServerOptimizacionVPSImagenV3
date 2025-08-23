# 🚀 Ultra Image Optimization Server v3.0 + WordPress API

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange.svg)](https://ubuntu.com/)
[![PHP](https://img.shields.io/badge/PHP-8.3-blue.svg)](https://www.php.net/)
[![Redis](https://img.shields.io/badge/Redis-Ready-red.svg)](https://redis.io/)
[![API](https://img.shields.io/badge/API-REST-green.svg)](https://www.php.net/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Sistema ultra optimizado de procesamiento paralelo masivo de imágenes con API REST integrada para WordPress. Detecta automáticamente el hardware y configura todo para máximo rendimiento.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación Rápida](#-instalación-rápida-4-comandos)
- [Capacidad por Tipo de VPS](#-capacidad-por-tipo-de-vps)
- [API para WordPress](#-api-para-wordpress)
- [Comandos Disponibles](#-comandos-disponibles)
- [Monitoreo](#-monitoreo)
- [Solución de Problemas](#-solución-de-problemas)

## ✨ Características

### 🎯 Optimización de Imágenes
- **Formatos soportados**: JPG, PNG, WebP, AVIF, GIF, SVG, TIFF, HEIF
- **Procesamiento paralelo masivo** con auto-detección de cores
- **Optimización automática** según el hardware disponible
- **Queue system** con Redis para alta carga
- **Callbacks y webhooks** para notificaciones en tiempo real

### 🔧 Herramientas Instaladas
- **JPEG**: jpegoptim, mozjpeg (compilado si hay recursos)
- **PNG**: optipng, pngquant, oxipng, pngcrush
- **WebP**: cwebp, dwebp con libwebp completo
- **AVIF**: avifenc con libavif optimizado
- **Suites**: ImageMagick, GraphicsMagick, VIPS
- **Monitoreo**: Netdata con dashboard en tiempo real

### 🔌 API REST para WordPress
- **Autenticación** con API Keys seguras
- **Endpoints** RESTful completos
- **Procesamiento asíncrono** con worker en background
- **Rate limiting** configurable
- **CORS** habilitado para peticiones cross-origin
- **Callbacks** automáticos a WordPress

### 🔒 Seguridad
- **Firewall UFW** configurado automáticamente
- **Fail2ban** para protección contra ataques
- **SSL/TLS** con Let's Encrypt (opcional)
- **Headers de seguridad** en Nginx
- **Actualizaciones automáticas** de seguridad

## 📦 Requisitos

- **Sistema Operativo**: Ubuntu 24.04 LTS
- **RAM mínima**: 1GB (2GB+ recomendado)
- **CPU**: 1+ cores (2+ recomendado)
- **Espacio disco**: 10GB mínimo
- **Acceso**: Root o sudo
- **Red**: Conexión a Internet activa

## 🚀 Instalación Rápida (4 Comandos)

```bash
# 1️⃣ Descargar el script
wget https://raw.githubusercontent.com/ingjoelramos/ServerOptimizacionVPSImagenV3/main/install-ultra-v3.sh

# 2️⃣ Dar permisos de ejecución
chmod +x install-ultra-v3.sh

# 3️⃣ Ejecutar la instalación
sudo bash install-ultra-v3.sh

# 4️⃣ Guardar la API Key que se muestra al final
# ========================================
# API KEY MAESTRA GENERADA
# ========================================
# Key: a3f8b2c9d4e5f6789abcdef0123456789abcdef0123456789abcdef012345678
# ========================================
```

### 🎯 Instalación Alternativa (Una Línea)

```bash
curl -sSL https://raw.githubusercontent.com/ingjoelramos/ServerOptimizacionVPSImagenV3/main/install-ultra-v3.sh | sudo bash
```

## 📊 Capacidad por Tipo de VPS

El script detecta automáticamente tu hardware y configura todo para máximo rendimiento:

| Tier | CPU | RAM | Capacidad Diaria | Workers |
|------|-----|-----|------------------|---------|
| **MICRO** | 1 core | 1GB | 500-1,000 imágenes | 1 |
| **SMALL** | 2 cores | 2GB | 1,000-3,000 imágenes | 2-4 |
| **MEDIUM** | 4 cores | 4GB | 3,000-8,000 imágenes | 4-12 |
| **LARGE** | 8 cores | 8GB | 8,000-20,000 imágenes | 8-24 |
| **XL** | 16 cores | 16GB | 20,000-50,000 imágenes | 16-48 |
| **XXL** | 16+ cores | 16+ GB | 50,000+ imágenes | 16-64 |

## 🔌 API para WordPress

### 📡 Endpoints Disponibles

```
Base URL: http://tu-vps.com/api/v1
```

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/health` | Estado del sistema |
| POST | `/optimize` | Optimizar imagen |
| GET | `/status/{job_id}` | Estado del job |
| GET | `/download/{job_id}` | Descargar resultado |
| POST | `/batch` | Procesamiento en lote |

### 🔑 Gestión Completa de API Keys

#### Consultar API Key Maestra
```bash
# Ver la API Key maestra generada durante la instalación
sudo api-key-manager show

# O si prefieres verla con más detalles
sudo -u www-data /usr/local/bin/api-key-manager show
```

#### Crear Nuevas API Keys
```bash
# Crear API Key para WordPress Plugin
sudo api-key-manager create wordpress_production

# Crear API Key para desarrollo
sudo api-key-manager create wordpress_dev

# Crear API Key para staging
sudo api-key-manager create wordpress_staging

# Crear API Key con nombre personalizado
sudo api-key-manager create mi_cliente_especial
```

#### Gestionar API Keys Existentes
```bash
# Listar todas las API Keys activas
sudo api-key-manager list

# Ver el archivo JSON completo de keys
cat /var/www/image-processor/config/api/api_keys.json | jq '.'

# Backup de API Keys
cp /var/www/image-processor/config/api/api_keys.json ~/api_keys_backup_$(date +%Y%m%d).json
```

#### Rotar API Keys (Seguridad)
```bash
# Crear nueva key y desactivar la anterior manualmente
sudo api-key-manager create wordpress_new
# Luego editar el archivo JSON para desactivar la key antigua
sudo nano /var/www/image-processor/config/api/api_keys.json
# Cambiar "active": true a "active": false para la key antigua
```

### 💻 Ejemplos de Uso de la API

#### Plugin WordPress Completo
```php
// En tu plugin de WordPress
class ImageOptimizerClient {
    private $api_url = 'http://tu-vps.com';
    private $api_key = 'tu-api-key-aqui';
    
    public function optimizeImage($image_path) {
        $response = wp_remote_post($this->api_url . '/api/v1/optimize', [
            'headers' => [
                'X-API-Key' => $this->api_key,
                'Content-Type' => 'application/json'
            ],
            'body' => json_encode([
                'image' => base64_encode(file_get_contents($image_path)),
                'quality' => 85,
                'webp' => true,
                'avif' => false,
                'callback_url' => home_url('/wp-json/tu-plugin/v1/callback')
            ]),
            'timeout' => 30
        ]);
        
        if (!is_wp_error($response)) {
            $body = json_decode(wp_remote_retrieve_body($response), true);
            return $body['job_id']; // Usar para verificar estado
        }
        
        return false;
    }
    
    public function checkStatus($job_id) {
        $response = wp_remote_get($this->api_url . '/api/v1/status/' . $job_id, [
            'headers' => [
                'X-API-Key' => $this->api_key
            ]
        ]);
        
        if (!is_wp_error($response)) {
            return json_decode(wp_remote_retrieve_body($response), true);
        }
        
        return false;
    }
    
    public function downloadOptimized($job_id) {
        $response = wp_remote_get($this->api_url . '/api/v1/download/' . $job_id, [
            'headers' => [
                'X-API-Key' => $this->api_key
            ],
            'timeout' => 60
        ]);
        
        if (!is_wp_error($response)) {
            return wp_remote_retrieve_body($response);
        }
        
        return false;
    }
}
```

#### Uso con cURL desde Terminal
```bash
# Verificar estado del sistema
curl -X GET http://tu-vps.com/api/v1/health \
  -H "X-API-Key: tu-api-key-aqui"

# Optimizar una imagen
curl -X POST http://tu-vps.com/api/v1/optimize \
  -H "X-API-Key: tu-api-key-aqui" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "'"$(base64 -w 0 imagen.jpg)"'",
    "quality": 85,
    "webp": true,
    "avif": false
  }'

# Verificar estado de un job
curl -X GET http://tu-vps.com/api/v1/status/job_123456 \
  -H "X-API-Key: tu-api-key-aqui"

# Descargar imagen optimizada
curl -X GET http://tu-vps.com/api/v1/download/job_123456 \
  -H "X-API-Key: tu-api-key-aqui" \
  -o imagen_optimizada.jpg
```

#### JavaScript/Node.js
```javascript
const axios = require('axios');
const fs = require('fs');

class ImageOptimizer {
    constructor(apiUrl, apiKey) {
        this.apiUrl = apiUrl;
        this.apiKey = apiKey;
    }

    async optimizeImage(imagePath) {
        const imageBuffer = fs.readFileSync(imagePath);
        const base64Image = imageBuffer.toString('base64');

        try {
            const response = await axios.post(
                `${this.apiUrl}/api/v1/optimize`,
                {
                    image: base64Image,
                    quality: 85,
                    webp: true,
                    avif: false
                },
                {
                    headers: {
                        'X-API-Key': this.apiKey,
                        'Content-Type': 'application/json'
                    }
                }
            );
            return response.data.job_id;
        } catch (error) {
            console.error('Error:', error.message);
            return null;
        }
    }

    async checkStatus(jobId) {
        try {
            const response = await axios.get(
                `${this.apiUrl}/api/v1/status/${jobId}`,
                {
                    headers: {
                        'X-API-Key': this.apiKey
                    }
                }
            );
            return response.data;
        } catch (error) {
            console.error('Error:', error.message);
            return null;
        }
    }
}

// Uso
const optimizer = new ImageOptimizer('http://tu-vps.com', 'tu-api-key');
const jobId = await optimizer.optimizeImage('./foto.jpg');
const status = await optimizer.checkStatus(jobId);
```

#### Python
```python
import requests
import base64
import json

class ImageOptimizerAPI:
    def __init__(self, api_url, api_key):
        self.api_url = api_url
        self.api_key = api_key
        self.headers = {
            'X-API-Key': api_key,
            'Content-Type': 'application/json'
        }
    
    def optimize_image(self, image_path, quality=85, webp=True, avif=False):
        """Optimiza una imagen usando la API"""
        with open(image_path, 'rb') as img_file:
            image_base64 = base64.b64encode(img_file.read()).decode('utf-8')
        
        payload = {
            'image': image_base64,
            'quality': quality,
            'webp': webp,
            'avif': avif
        }
        
        response = requests.post(
            f'{self.api_url}/api/v1/optimize',
            headers=self.headers,
            json=payload
        )
        
        if response.status_code == 200:
            return response.json()['job_id']
        else:
            raise Exception(f'Error: {response.status_code} - {response.text}')
    
    def check_status(self, job_id):
        """Verifica el estado de un job"""
        response = requests.get(
            f'{self.api_url}/api/v1/status/{job_id}',
            headers={'X-API-Key': self.api_key}
        )
        return response.json()
    
    def download_result(self, job_id, output_path):
        """Descarga la imagen optimizada"""
        response = requests.get(
            f'{self.api_url}/api/v1/download/{job_id}',
            headers={'X-API-Key': self.api_key}
        )
        
        if response.status_code == 200:
            with open(output_path, 'wb') as f:
                f.write(response.content)
            return True
        return False

# Ejemplo de uso
api = ImageOptimizerAPI('http://tu-vps.com', 'tu-api-key-aqui')
job_id = api.optimize_image('foto.jpg', quality=90)
status = api.check_status(job_id)
print(f"Estado: {status}")
```

## 🧪 Testing y Validación de la API

### Test Rápido de Funcionamiento
```bash
# 1. Verificar que la API responde
curl -I http://tu-vps.com/api/v1/health

# 2. Test con imagen de prueba
echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" > test.b64
curl -X POST http://tu-vps.com/api/v1/optimize \
  -H "X-API-Key: $(sudo api-key-manager show)" \
  -H "Content-Type: application/json" \
  -d '{"image": "'$(cat test.b64)'", "quality": 85}'

# 3. Verificar logs en tiempo real
tail -f /var/www/image-processor/logs/api/worker.log
```

### Validación Completa del Sistema
```bash
# Ejecutar suite de validación
verify-ultra

# Test de carga básico
for i in {1..10}; do
  curl -X POST http://tu-vps.com/api/v1/optimize \
    -H "X-API-Key: $(sudo api-key-manager show)" \
    -H "Content-Type: application/json" \
    -d '{"image": "'"$(base64 -w 0 test-image.jpg)"'", "quality": 85}' &
done
wait

# Verificar métricas de rendimiento
redis-cli info stats
systemctl status api-worker --no-pager
```

### Monitoreo de Métricas
```bash
# Ver estadísticas de la API
redis-cli
> KEYS api:*
> GET api:stats:total_requests
> GET api:stats:total_optimized
> exit

# Ver trabajos en cola
redis-cli LLEN image_optimization_queue

# Ver trabajos procesados hoy
grep "$(date +%Y-%m-%d)" /var/www/image-processor/logs/api/worker.log | wc -l
```

## 🛠️ Comandos Disponibles

### Optimización de Imágenes

```bash
# Optimizar un directorio completo
optimize-ultra /ruta/entrada /ruta/salida jpg

# Optimizar todos los formatos en paralelo
optimize-ultra /uploads /processed all

# Procesamiento en lotes automático
batch-optimize-ultra

# Benchmark de rendimiento
benchmark-ultra
```

### Monitoreo y Gestión

```bash
# Monitor en tiempo real de optimización
monitor-optimization

# Monitor de la API
monitor-api

# Verificación completa del sistema
verify-ultra

# Mantenimiento manual
maintenance-ultra
```

### Gestión SSL (Opcional)

```bash
# Configurar SSL para tu dominio
sudo certbot --nginx -d tu-dominio.com

# Renovar SSL manualmente
ssl-renew
```

## 📊 Monitoreo

### Netdata Dashboard
Accede al dashboard de monitoreo en tiempo real:
```
http://tu-vps:19999
```

### Logs del Sistema

```bash
# Log de instalación
tail -f /var/log/image-server-ultra-setup.log

# Logs de la API
tail -f /var/www/image-processor/logs/api/worker.log

# Logs de optimización
tail -f /var/www/image-processor/logs/optimization.log

# Logs de Nginx
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Estado de Servicios

```bash
# Estado general
systemctl status nginx
systemctl status php8.3-fpm
systemctl status redis-server
systemctl status api-worker
systemctl status netdata

# Reiniciar servicios si es necesario
sudo systemctl restart nginx
sudo systemctl restart php8.3-fpm
sudo systemctl restart api-worker
```

## 🔧 Solución de Problemas Detallada

### La API no responde

```bash
# 1. Verificar el worker
sudo systemctl status api-worker
sudo systemctl restart api-worker

# 2. Verificar Redis
redis-cli ping
# Debe responder: PONG

# 3. Verificar logs completos
tail -50 /var/www/image-processor/logs/api/worker.log
tail -50 /var/log/nginx/error.log

# 4. Verificar que el puerto 80 está abierto
sudo ufw status
sudo netstat -tlnp | grep :80
```

### Error de permisos

```bash
# Restablecer TODOS los permisos correctamente
sudo chown -R www-data:www-data /var/www/image-processor
sudo chmod -R 755 /var/www/image-processor/api
sudo chmod -R 775 /var/www/image-processor/logs
sudo chmod -R 775 /var/www/image-processor/temp
sudo chmod -R 775 /var/www/image-processor/cache
sudo chmod 644 /var/www/image-processor/config/api/api_keys.json
```

### No se muestra la API Key o error PHP

```bash
# Error: "JIT is incompatible with third party extensions"
# Solución: Ya está corregido en el script, pero si persiste:
sudo bash -c 'echo "opcache.jit=0" > /etc/php/8.3/cli/conf.d/99-disable-jit.ini'

# Recuperar API Key maestra
sudo api-key-manager show

# Si sale error de sintaxis PHP
sudo nano /usr/local/bin/api-key-manager
# Verificar que NO haya backslashes antes de los signos $

# Crear nueva key si es necesario
sudo -u www-data /usr/local/bin/api-key-manager create master
```

### Redis no funciona o no conecta

```bash
# IMPORTANTE: NO modificar /etc/redis/redis.conf
# Ubuntu 24.04 tiene su propia configuración

# Verificar que Redis está corriendo
sudo systemctl status redis-server

# Reiniciar Redis
sudo systemctl restart redis-server

# Test de conexión
redis-cli ping
# Debe responder: PONG

# Ver configuración actual
redis-cli CONFIG GET bind
redis-cli CONFIG GET protected-mode

# Si hay problemas de conexión
sudo netstat -tlnp | grep 6379
```

### Nginx error 502 Bad Gateway

```bash
# 1. Verificar PHP-FPM
sudo systemctl status php8.3-fpm
sudo systemctl restart php8.3-fpm

# 2. Verificar socket PHP-FPM
ls -la /var/run/php/php8.3-fpm.sock
# Debe existir y ser propiedad de www-data

# 3. Ver logs de error específicos
sudo tail -100 /var/log/php8.3-fpm.log
sudo tail -100 /var/log/nginx/error.log

# 4. Verificar configuración de Nginx
sudo nginx -t
sudo systemctl reload nginx

# 5. Verificar pool de PHP-FPM
sudo nano /etc/php/8.3/fpm/pool.d/image-processor.conf
# Asegurarse que listen = /var/run/php/php8.3-fpm.sock
```

### API devuelve error 500

```bash
# 1. Habilitar modo debug temporalmente
sudo nano /var/www/image-processor/api/v1/index.php
# Cambiar las primeras líneas a:
# error_reporting(E_ALL);
# ini_set('display_errors', 1);

# 2. Ver error específico
curl -X GET http://localhost/api/v1/health -H "X-API-Key: $(sudo api-key-manager show)"

# 3. Revisar logs de PHP
sudo tail -100 /var/log/php8.3-fpm.log

# 4. Verificar que existen los archivos necesarios
ls -la /var/www/image-processor/api/auth/ApiAuth.php
ls -la /var/www/image-processor/config/api/config.php
ls -la /var/www/image-processor/config/api/api_keys.json
```

### Worker no procesa imágenes

```bash
# 1. Ver estado del worker
sudo systemctl status api-worker

# 2. Ver logs del worker en tiempo real
sudo journalctl -u api-worker -f

# 3. Verificar cola de Redis
redis-cli LLEN image_optimization_queue

# 4. Reiniciar worker
sudo systemctl restart api-worker

# 5. Verificar que el script del worker existe
cat /var/www/image-processor/scripts/api-worker.php
```

### Problemas de memoria o rendimiento

```bash
# 1. Ver uso de memoria
free -h
htop

# 2. Ajustar workers de PHP-FPM según RAM disponible
sudo nano /etc/php/8.3/fpm/pool.d/image-processor.conf
# Para 1GB RAM: pm.max_children = 5
# Para 2GB RAM: pm.max_children = 10
# Para 4GB RAM: pm.max_children = 20

# 3. Limpiar cache si es necesario
sudo rm -rf /var/www/image-processor/cache/*
sudo rm -rf /var/www/image-processor/temp/*

# 4. Ver procesos que consumen más recursos
ps aux | sort -nrk 3,3 | head -10

# 5. Reiniciar servicios
sudo systemctl restart php8.3-fpm
sudo systemctl restart nginx
sudo systemctl restart api-worker
```

## 🔒 Seguridad y Mejores Prácticas

### Configuración de Seguridad Recomendada

#### 1. Proteger las API Keys
```bash
# Rotar API Keys regularmente
sudo api-key-manager create nueva_key_$(date +%Y%m)

# Hacer backup seguro de keys
sudo cp /var/www/image-processor/config/api/api_keys.json /root/api_keys_backup_$(date +%Y%m%d).json
sudo chmod 600 /root/api_keys_backup_*.json

# Limitar acceso al archivo de keys
sudo chmod 600 /var/www/image-processor/config/api/api_keys.json
sudo chown www-data:www-data /var/www/image-processor/config/api/api_keys.json
```

#### 2. Configurar Firewall Estricto
```bash
# Permitir solo IPs específicas (reemplazar con tus IPs)
sudo ufw allow from 192.168.1.100 to any port 80
sudo ufw allow from 203.0.113.0/24 to any port 80

# Bloquear todo lo demás
sudo ufw default deny incoming
sudo ufw enable

# Ver reglas actuales
sudo ufw status numbered
```

#### 3. Implementar Rate Limiting
```bash
# Agregar rate limiting en Nginx
sudo nano /etc/nginx/sites-available/image-optimizer

# Agregar dentro del bloque server:
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
location /api/ {
    limit_req zone=api burst=20 nodelay;
    # ... resto de configuración
}

# Reiniciar Nginx
sudo nginx -t && sudo systemctl reload nginx
```

#### 4. Monitoreo de Seguridad
```bash
# Ver intentos de acceso fallidos
sudo grep "401\|403\|404" /var/log/nginx/access.log | tail -50

# Ver IPs que más solicitudes hacen
sudo awk '{print $1}' /var/log/nginx/access.log | sort | uniq -c | sort -rn | head -20

# Configurar alertas con fail2ban
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

#### 5. SSL/TLS con Let's Encrypt
```bash
# Instalar certbot si no está instalado
sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado SSL
sudo certbot --nginx -d tu-dominio.com --email tu-email@gmail.com --agree-tos --non-interactive

# Renovación automática (ya configurada)
sudo certbot renew --dry-run
```

### Mejores Prácticas de Uso

#### Para Producción
```bash
# 1. Deshabilitar debug en producción
sudo nano /var/www/image-processor/api/v1/index.php
# Asegurar que está así:
# error_reporting(0);
# ini_set('display_errors', 0);

# 2. Configurar logs rotativos
sudo nano /etc/logrotate.d/image-processor
```

Contenido del archivo:
```
/var/www/image-processor/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload php8.3-fpm > /dev/null
    endscript
}
```

#### Backup y Recuperación
```bash
# Backup completo del sistema
sudo tar -czf /backup/image-processor-$(date +%Y%m%d).tar.gz \
    /var/www/image-processor \
    /etc/nginx/sites-available/image-optimizer \
    /etc/php/8.3/fpm/pool.d/image-processor.conf

# Backup de configuración y keys
sudo mkdir -p /backup/config
sudo cp -r /var/www/image-processor/config /backup/config/$(date +%Y%m%d)

# Script de backup automático
cat << 'EOF' > /usr/local/bin/backup-image-processor
#!/bin/bash
BACKUP_DIR="/backup/image-processor"
DATE=$(date +%Y%m%d-%H%M%S)
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/backup-$DATE.tar.gz \
    /var/www/image-processor/config \
    /var/www/image-processor/api \
    /usr/local/bin/api-key-manager
echo "Backup completado: $BACKUP_DIR/backup-$DATE.tar.gz"
# Eliminar backups de más de 30 días
find $BACKUP_DIR -name "backup-*.tar.gz" -mtime +30 -delete
EOF
sudo chmod +x /usr/local/bin/backup-image-processor

# Agregar a crontab para backup diario
(crontab -l 2>/dev/null; echo "0 2 * * * /usr/local/bin/backup-image-processor") | crontab -
```

#### Monitoreo Continuo
```bash
# Dashboard de monitoreo en tiempo real
screen -S monitoring

# En la sesión de screen, dividir pantalla:
# Ctrl+A, luego |  (para dividir verticalmente)
# Ctrl+A, luego Tab (para cambiar panel)
# Ctrl+A, luego c (para nueva ventana)

# Panel 1: Logs de API
tail -f /var/www/image-processor/logs/api/worker.log

# Panel 2: Métricas del sistema
htop

# Panel 3: Logs de Nginx
tail -f /var/log/nginx/access.log

# Salir de screen: Ctrl+A, luego d
# Volver a screen: screen -r monitoring
```

## 📈 Optimización Adicional

### Para VPS con poca RAM (1-2GB)

```bash
# Reducir workers de PHP-FPM
sudo nano /etc/php/8.3/fpm/pool.d/image-processor.conf
# Cambiar pm.max_children a un valor menor

# Reducir workers paralelos
sudo nano /usr/local/bin/optimize-ultra
# Cambiar WORKERS a 1 o 2
```

### Para VPS potentes (8GB+)

```bash
# Aumentar límites
sudo nano /etc/security/limits.conf
# Ya están configurados al máximo

# Aumentar workers
# El script ya lo hace automáticamente
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

## 🆘 Soporte

Si necesitas ayuda:

1. Revisa la sección de [Solución de Problemas](#-solución-de-problemas)
2. Ejecuta `verify-ultra` para diagnóstico automático
3. Revisa los logs en `/var/log/image-server-ultra-setup.log`
4. Abre un issue en GitHub con los detalles del problema

## 🙏 Agradecimientos

- Ubuntu 24.04 LTS por la base sólida
- Todas las herramientas open source utilizadas
- La comunidad de WordPress por la inspiración

---

**⚡ Desarrollado para máximo rendimiento en procesamiento de imágenes**

*Versión 3.0 - Ultra Optimized with WordPress API Integration*
