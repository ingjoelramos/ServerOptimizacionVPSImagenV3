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
wget https://raw.githubusercontent.com/tu-usuario/tu-repo/main/install-ultra-v3-final.sh

# 2️⃣ Dar permisos de ejecución
chmod +x install-ultra-v3-final.sh

# 3️⃣ Ejecutar la instalación
sudo bash install-ultra-v3-final.sh

# 4️⃣ Guardar la API Key que se muestra al final
# ========================================
# API KEY MAESTRA GENERADA
# ========================================
# Key: a3f8b2c9d4e5f6789abcdef0123456789abcdef0123456789abcdef012345678
# ========================================
```

### 🎯 Instalación Alternativa (Una Línea)

```bash
curl -sSL https://raw.githubusercontent.com/tu-usuario/tu-repo/main/install-ultra-v3-final.sh | sudo bash
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

### 🔑 Gestión de API Keys

```bash
# Ver tu API Key maestra
sudo api-key-manager show

# Crear nueva API Key para WordPress
sudo api-key-manager create wordpress_plugin

# Listar todas las API Keys
sudo api-key-manager list
```

### 💻 Ejemplo de Integración con WordPress

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
}
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

## 🔧 Solución de Problemas

### La API no responde

```bash
# Verificar el worker
sudo systemctl status api-worker
sudo systemctl restart api-worker

# Verificar Redis
redis-cli ping
# Debe responder: PONG

# Verificar logs
tail -50 /var/www/image-processor/logs/api/worker.log
```

### Error de permisos

```bash
# Restablecer permisos
sudo chown -R www-data:www-data /var/www/image-processor
sudo chmod -R 755 /var/www/image-processor/api
```

### No se muestra la API Key

```bash
# Recuperar API Key maestra
sudo api-key-manager show

# Si no funciona, crear una nueva
sudo api-key-manager create master
```

### Redis no funciona

```bash
# NO modificar /etc/redis/redis.conf
# Solo reiniciar el servicio
sudo systemctl restart redis-server

# Verificar
redis-cli ping
```

### Nginx error 502

```bash
# Verificar PHP-FPM
sudo systemctl status php8.3-fpm
sudo systemctl restart php8.3-fpm

# Verificar socket
ls -la /var/run/php/php8.3-fpm.sock
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
