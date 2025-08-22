# 🚀 Servidor de Optimización de Imágenes Ultra v3.0

[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange?style=flat-square&logo=ubuntu)](https://ubuntu.com)
[![Version](https://img.shields.io/badge/Version-3.0-blue?style=flat-square)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=flat-square)](https://github.com)

> **Servidor ultra optimizado para procesamiento paralelo masivo de imágenes con detección automática de hardware y configuración inteligente.**

## 📋 Tabla de Contenidos

- [🌟 Características](#-características)
- [⚡ Instalación Rápida](#-instalación-rápida)
- [🎯 Capacidades por Hardware](#-capacidades-por-hardware)
- [🛠️ Comandos Disponibles](#️-comandos-disponibles)
- [📊 Formatos Soportados](#-formatos-soportados)
- [🔧 Configuración](#-configuración)
- [📈 Monitoreo y Rendimiento](#-monitoreo-y-rendimiento)
- [🧪 Ejemplos de Uso](#-ejemplos-de-uso)
- [🔧 Solución de Problemas](#-solución-de-problemas)
- [📞 Soporte](#-soporte)

---

## 🔐 SSL Auto-Renovación

### **⚡ Configuración Automática**

El script v3.0 configura **automáticamente** la renovación SSL si proporcionas un dominio durante la instalación:

```bash
# Durante la instalación se te preguntará:
¿Tienes un dominio configurado para este servidor? (s/n): s
Ingresa tu dominio (ej: optimserver.com): tu-dominio.com
```

### **🔄 Cómo Funciona la Auto-Renovación**

#### **📅 Verificación Diaria Automática**
```bash
# Cron job ejecuta TODOS LOS DÍAS a las 2:30 AM:
30 2 * * * /usr/local/bin/ssl-renew
```

#### **🤖 Lógica de Detección Inteligente**
- **Certbot verifica automáticamente** todos los certificados
- **Si vence en >30 días**: No hace nada
- **Si vence en ≤30 días**: Renueva automáticamente
- **Tras renovación exitosa**: Reinicia Nginx automáticamente
- **Todo se registra** en `/var/log/ssl-renewal.log`

#### **📊 Ejemplo Real de Funcionamiento**
```
Certificado instalado: 15 Agosto
Vence: 15 Noviembre (90 días)

15 Agosto - 15 Octubre: ✅ Script ejecuta, NO renueva (>30 días)
16 Octubre: 🔄 Script ejecuta, SÍ renueva (<30 días)
Nuevo vencimiento: 15 Febrero (90 días más)
```

### **🛡️ Sistema de Respaldo Doble**

#### **1. Cron Job (Principal)**
```bash
# Verificar cron configurado
crontab -l | grep ssl-renew
```

#### **2. Systemd Timer (Respaldo)**
```bash
# Verificar timer activo
systemctl status ssl-renew.timer
```

### **📋 Comandos de Verificación SSL**

```bash
# Ver estado de todos los certificados
certbot certificates

# Verificar próximo vencimiento
certbot certificates | grep "Expiry Date"

# Probar renovación sin ejecutar
certbot renew --dry-run

# Ver logs de renovación
tail -20 /var/log/ssl-renewal.log

# Forzar renovación manual (para pruebas)
ssl-renew
```

### **🔍 Monitoreo SSL Incluido**

El comando `verify-ultra` también verifica el estado SSL:

```bash
verify-ultra
```

**Muestra:**
```
[SSL Y CERTIFICADOS]
✓ Certificados SSL: 1 configurados
✓ Renovación automática: cron configurado
✓ Renovación automática: systemd timer activo
```

---

## 🌟 Características

### **🚀 Nuevas en v3.0**
- ✅ **Detección automática de hardware** - Se adapta a cualquier VPS
- ✅ **Procesamiento paralelo masivo** - Múltiples imágenes simultáneas  
- ✅ **Configuración inteligente** - Optimizada según tus recursos
- ✅ **Sistema de colas con Redis** - Para alta concurrencia
- ✅ **Procesamiento en lotes** - Miles de imágenes automáticamente
- ✅ **Monitoreo en tiempo real** - Netdata integrado
- ✅ **Benchmarks automáticos** - Prueba tu rendimiento
- ✅ **Mantenimiento automático** - Sistema de limpieza
- ✅ **Auto-renovación SSL** - Certificados SSL se renuevan automáticamente

### **⚡ Optimizaciones Ultra**
- **Kernel optimizado** - Parámetros extremos para rendimiento
- **Nginx ultra** - Workers dinámicos según hardware
- **PHP-FPM masivo** - Configuración automática de workers
- **Redis queue system** - Memoria optimizada automáticamente
- **Paralelización inteligente** - GNU Parallel con jobs calculados

### **🔐 SSL Auto-Renovación**
- **Detección automática** - Certbot verifica vencimiento cada día
- **Renovación inteligente** - Solo renueva si faltan <30 días
- **Doble respaldo** - Cron job + Systemd timer
- **Logging completo** - Registro de todas las renovaciones
- **Reinicio automático** - Nginx se recarga tras renovación exitosa

### **🎯 Formatos Soportados**
| Formato | Herramientas | Optimización |
|---------|-------------|--------------|
| **JPG/JPEG** | jpegoptim, mozjpeg compilado | ✅ Ultra |
| **PNG** | optipng, pngquant, oxipng, pngcrush | ✅ Ultra |
| **WebP** | cwebp, dwebp, gif2webp | ✅ Ultra |
| **AVIF** | avifenc optimizado con todos los codecs | ✅ Ultra |
| **GIF** | gifsicle optimizado | ✅ Ultra |
| **SVG** | svgo con Node.js | ✅ Ultra |
| **TIFF** | libtiff-tools completo | ✅ Ultra |

---

## ⚡ Instalación Rápida

### **Requisitos**
- Ubuntu 24.04 LTS
- Acceso root (sudo)
- Mínimo 1GB RAM, 2GB recomendado
- Conexión a internet

### **📝 Solo 4 Pasos**

```bash
# 1️⃣ CREAR EL ARCHIVO
nano install-ultra-v3.sh
# (Copiar y pegar el script completo v3.0)

# ALTERNATIVA AL PASO 1️⃣ INSTALACION POR GITHUB DIRECTO
wget https://raw.githubusercontent.com/ingjoelramos/ServerOptimizacionVPSImagenV3/main/install-ultra-v3.sh


# 2️⃣ DAR PERMISOS
chmod +x install-ultra-v3.sh

# 3️⃣ EJECUTAR INSTALACIÓN
sudo ./install-ultra-v3.sh

# 4️⃣ REINICIAR SERVIDOR
sudo reboot
```

### **✅ Verificación Post-Instalación**

```bash
# Verificar que todo funciona
verify-ultra

# Probar rendimiento
benchmark-ultra

# Monitorear sistema
monitor-optimization
```

**¡LISTO! Tu servidor está optimizado y funcionando.**

---

## 🎯 Capacidades por Hardware

El script **detecta automáticamente** tu hardware y se configura para máximo rendimiento:

### **📊 Tabla de Rendimiento**

| Tier VPS | CPU | RAM | Workers | Capacidad/Día | Ideal Para |
|----------|-----|-----|---------|---------------|------------|
| **MICRO** | 1-2 cores | 1-2GB | 2-4 | 500-1,000 | Blog personal |
| **SMALL** | 2 cores | 2GB | 4-6 | 1,000-3,000 | Sitio web pequeño |
| **MEDIUM** | 4 cores | 4GB | 8-12 | 3,000-8,000 | E-commerce |
| **LARGE** | 8 cores | 8GB | 16-24 | 8,000-20,000 | Alto tráfico |
| **XL** | 16+ cores | 16GB+ | 32-64 | 20,000-50,000+ | Empresarial |

### **🔧 Configuración Automática**

El script calcula automáticamente:
- **Workers PHP-FPM**: Según RAM disponible
- **Jobs paralelos**: Según cores del CPU  
- **Memoria Redis**: 25% de RAM total
- **Tamaño max imagen**: Dinámico según recursos
- **Swap optimal**: Calculado según RAM

---

## 🛠️ Comandos Disponibles

### **🚀 Comandos Ultra Principales**

```bash
# Verificación completa del sistema
verify-ultra

# Optimización paralela masiva
optimize-ultra <input_dir> <output_dir> <format>

# Procesamiento en lotes ultra rápido  
batch-optimize-ultra

# Monitor de rendimiento en tiempo real
monitor-optimization

# Benchmark completo de rendimiento
benchmark-ultra

# Mantenimiento y limpieza
maintenance-ultra

# Renovación manual SSL
ssl-renew
```

### **🔐 Comandos SSL Automáticos**

```bash
# Verificar estado de certificados SSL
certbot certificates

# Renovar SSL manualmente (para pruebas)
ssl-renew

# Ver logs de renovación automática
tail -f /var/log/ssl-renewal.log

# Verificar configuración de renovación automática
crontab -l | grep ssl-renew

# Estado del timer de renovación
systemctl status ssl-renew.timer

# Probar renovación sin ejecutar (dry-run)
certbot renew --dry-run
```

### **📁 Comandos por Formato**

```bash
# Optimizar solo JPEG en paralelo
optimize-ultra /uploads /processed jpg

# Optimizar solo PNG en paralelo
optimize-ultra /uploads /processed png

# Crear WebP en paralelo
optimize-ultra /uploads /processed webp

# Crear AVIF en paralelo
optimize-ultra /uploads /processed avif

# Optimizar TODOS los formatos simultáneamente
optimize-ultra /uploads /processed all
```

### **📊 Comandos de Monitoreo**

```bash
# Ver estadísticas en tiempo real
monitor-optimization

# Ver logs de optimización
tail -f /var/www/image-processor/logs/optimization.log

# Ver estado de servicios
systemctl status nginx php8.3-fpm redis-server netdata

# Ver uso de recursos
htop
```

---

## 📊 Formatos Soportados

### **🎨 Capacidades Completas**

#### **📸 JPEG/JPG**
- **Herramientas**: jpegoptim, mozjpeg (compilado)
- **Optimización**: Sin pérdida + recompresión
- **Metadatos**: Eliminación automática
- **Velocidad**: Ultra rápida con parallel

#### **🎨 PNG** 
- **Herramientas**: optipng, pngquant, oxipng, pngcrush
- **Optimización**: Sin pérdida + quantización
- **Transparencia**: Preservada y optimizada
- **Algoritmos**: Múltiples para mejor compresión

#### **🌐 WebP**
- **Herramientas**: cwebp, dwebp, gif2webp
- **Compresión**: 25-35% mejor que JPEG
- **Transparencia**: Soporte completo
- **Animación**: Conversión desde GIF

#### **🚀 AVIF** 
- **Herramientas**: avifenc optimizado con todos los codecs
- **Compresión**: La mejor disponible actualmente
- **Codecs**: AOM, DAV1D, RAV1E, SVT-AV1
- **HDR**: Soporte wide color gamut

#### **🎬 GIF**
- **Herramientas**: gifsicle optimizado
- **Optimización**: Paletas + frames
- **Conversión**: A WebP animado automática

#### **🎯 SVG**
- **Herramientas**: svgo con Node.js
- **Optimización**: Minificación + limpieza
- **Paths**: Optimización de trazados
- **Tamaño**: Reducción significativa

---

## 🔧 Configuración

### **📁 Estructura de Directorios**

```
/var/www/image-processor/
├── uploads/          # Imágenes originales
│   ├── pending/      # Por procesar
│   ├── processing/   # En procesamiento
│   └── completed/    # Procesadas
├── processed/        # Imágenes optimizadas
│   ├── jpg/          # JPEG optimizados
│   ├── png/          # PNG optimizados
│   ├── webp/         # WebP generados
│   └── avif/         # AVIF generados
├── temp/             # Archivos temporales
├── cache/            # Cache de resultados
├── queue/            # Sistema de colas
├── logs/             # Logs del sistema
└── scripts/          # Scripts de optimización
```

### **🌐 URLs de Acceso**

```bash
# Servidor web
http://tu-servidor

# Panel de monitoreo Netdata
http://tu-servidor:19999

# Con dominio y SSL
https://tu-dominio.com
```

### **⚙️ Configuraciones Principales**

| Servicio | Configuración | Ubicación |
|----------|---------------|-----------|
| **Nginx** | Workers automáticos | `/etc/nginx/nginx.conf` |
| **PHP-FPM** | Pool optimizado | `/etc/php/8.3/fpm/pool.d/` |
| **Redis** | Queue system | `/etc/redis/redis.conf` |
| **Kernel** | Optimizaciones extremas | `/etc/sysctl.conf` |

---

## 📈 Monitoreo y Rendimiento

### **📊 Panel Netdata**

Accede a `http://tu-servidor:19999` para ver:
- ✅ **CPU usage** en tiempo real
- ✅ **Memory usage** detallado  
- ✅ **Disk I/O** y transferencia
- ✅ **Network traffic** 
- ✅ **Procesos activos** de optimización
- ✅ **Redis statistics** de colas
- ✅ **PHP-FPM workers** estado

### **⚡ Comando de Monitoreo**

```bash
monitor-optimization
```

**Muestra:**
```
========================================
MONITOR DE OPTIMIZACIÓN ULTRA
========================================

🖥️  SISTEMA:
   CPU Cores: 4
   RAM Total: 8GB  
   Workers Configurados: 12

📁 ARCHIVOS:
   Pendientes: 150
   Procesados: 2,847
   En caché: 1,205

⚡ RENDIMIENTO:
   Procesos activos: 8
   Uso de CPU: 65%
   Uso de RAM: 45.2%

🔴 REDIS:
   Conexiones activas: 12
   Memoria usada: 256MB
   Items en cola: 45
```

### **🧪 Benchmark Automático**

```bash
benchmark-ultra
```

**Resultados típicos:**
```
=================================================
BENCHMARK ULTRA - SERVIDOR DE OPTIMIZACIÓN v3.0
=================================================

[JPEG] ✓ EXITOSO - 2.5 img/s - 216,000 daily
[PNG]  ✓ EXITOSO - 1.8 img/s - 155,520 daily  
[WebP] ✓ EXITOSO - 3.2 img/s - 276,480 daily
[AVIF] ✓ EXITOSO - 1.2 img/s - 103,680 daily

Rendimiento combinado: 2.1 imágenes/segundo
Capacidad diaria estimada: 181,440 imágenes
🚀 EXCELENTE: Tu servidor está listo para alta carga
```

---

## 🧪 Ejemplos de Uso

### **📸 Optimización Básica**

```bash
# Optimizar todas las imágenes JPEG
optimize-ultra /uploads /processed jpg

# Optimizar solo PNG  
optimize-ultra /uploads /processed png

# Crear versiones WebP
optimize-ultra /uploads /processed webp

# Procesar TODOS los formatos
optimize-ultra /uploads /processed all
```

### **⚡ Procesamiento Masivo**

```bash
# Procesar lotes automáticamente
batch-optimize-ultra

# Monitorear mientras procesa
monitor-optimization &
batch-optimize-ultra
```

### **🔧 Uso Avanzado**

```bash
# Optimizar con calidad específica
cwebp -q 90 imagen.jpg -o imagen.webp

# Usar múltiples cores manualmente
find /uploads -name "*.jpg" | parallel -j8 jpegoptim --strip-all {}

# Crear thumbnails con VIPS
vipsthumbnail imagen.jpg --size 300x300 --output thumb.jpg
```

### **📊 Integración con Scripts**

```bash
#!/bin/bash
# Script personalizado de procesamiento

# Subir imágenes
cp /source/*.jpg /var/www/image-processor/uploads/pending/

# Procesar automáticamente
batch-optimize-ultra

# Verificar resultados
echo "Procesadas: $(find /var/www/image-processor/processed -name "*.jpg" | wc -l)"
```

---

## 🔧 Solución de Problemas

### **❗ Problemas Comunes**

#### **🚫 Error: "Comando no encontrado"**
```bash
# Verificar instalación
verify-ultra

# Reinstalar si es necesario
sudo ./install-ultra-v3.sh
```

#### **🐌 Rendimiento Lento**
```bash
# Verificar recursos
htop

# Ver procesos activos
ps aux | grep -E "(jpegoptim|optipng|cwebp)"

# Revisar configuración
monitor-optimization
```

#### **💾 Espacio Insuficiente**
```bash
# Limpiar temporales
maintenance-ultra

# Ver uso de disco
df -h

# Limpiar cache
rm -rf /var/www/image-processor/cache/*
```

#### **🔴 Redis No Conecta**
```bash
# Verificar Redis
systemctl status redis-server

# Reiniciar Redis
sudo systemctl restart redis-server

# Ver logs
journalctl -u redis-server
```

#### **🔐 Problemas SSL**
```bash
# Verificar certificados
certbot certificates

# Probar renovación
ssl-renew

# Ver logs de renovación
tail -f /var/log/ssl-renewal.log

# Verificar cron SSL
crontab -l | grep ssl

# Reiniciar timer SSL
sudo systemctl restart ssl-renew.timer
```

#### **⏰ Auto-Renovación No Funciona**
```bash
# Verificar que cron esté funcionando
systemctl status cron

# Verificar timer SSL
systemctl status ssl-renew.timer

# Probar renovación manualmente
ssl-renew

# Ver configuración cron
crontab -l

# Verificar permisos del script
ls -la /usr/local/bin/ssl-renew
```

### **🔍 Logs Importantes**

```bash
# Log principal de instalación
/var/log/image-server-ultra-setup.log

# Logs de optimización
/var/www/image-processor/logs/optimization.log

# Logs de errores
/var/www/image-processor/logs/errors.log

# Logs de renovación SSL
/var/log/ssl-renewal.log

# Logs de Nginx
/var/log/nginx/error.log

# Logs de PHP
/var/log/php8.3-fpm.log

# Logs de Certbot
/var/log/letsencrypt/letsencrypt.log
```

### **🛠️ Comandos de Diagnóstico**

```bash
# Verificación completa
verify-ultra

# Estado de servicios
systemctl status nginx php8.3-fpm redis-server netdata

# Test de herramientas
jpegoptim --version
optipng --version  
cwebp -version
avifenc --help

# Test de paralelización
echo -e "test1\ntest2\ntest3" | parallel echo "Processing: {}"

# Diagnóstico SSL completo
certbot certificates
ssl-renew --dry-run
systemctl status ssl-renew.timer
crontab -l | grep ssl

# Test de conectividad SSL (si tienes dominio)
openssl s_client -connect tu-dominio.com:443 -servername tu-dominio.com
```

---

## 📞 Soporte

### **🆘 Obtener Ayuda**

1. **Verificar documentación** en este README
2. **Ejecutar diagnósticos**:
   ```bash
   verify-ultra
   monitor-optimization
   ```
3. **Revisar logs** de errores
4. **Crear issue** con información del sistema

### **📋 Información para Soporte**

Cuando reportes un problema, incluye:

```bash
# Información del sistema
uname -a
lsb_release -a
free -h
df -h

# Estado de servicios
systemctl status nginx php8.3-fpm redis-server netdata

# Verificación completa
verify-ultra

# Estado SSL (si aplica)
certbot certificates
systemctl status ssl-renew.timer
tail -20 /var/log/ssl-renewal.log

# Logs recientes
tail -50 /var/log/image-server-ultra-setup.log
```

### **🔗 Recursos Útiles**

- **Documentación Ubuntu**: [https://ubuntu.com/server/docs](https://ubuntu.com/server/docs)
- **Nginx Documentation**: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
- **ImageMagick Guide**: [https://imagemagick.org/](https://imagemagick.org/)
- **VIPS Documentation**: [https://www.libvips.org/](https://www.libvips.org/)
- **Certbot Documentation**: [https://certbot.eff.org/docs/](https://certbot.eff.org/docs/)
- **Let's Encrypt**: [https://letsencrypt.org/docs/](https://letsencrypt.org/docs/)

---

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 🙏 Agradecimientos

- **Ubuntu Team** - Por el excelente sistema operativo
- **ImageMagick Community** - Por las herramientas de procesamiento
- **Mozilla Team** - Por mozjpeg optimizado  
- **Google Team** - Por WebP y AVIF
- **Nginx Team** - Por el servidor web ultra rápido
- **PHP Community** - Por PHP-FPM optimizado
- **Redis Team** - Por el sistema de colas
- **Netdata Team** - Por el monitoreo en tiempo real

---

## 📊 Estadísticas del Proyecto

![Status](https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square)
![Version](https://img.shields.io/badge/Version-3.0-blue?style=flat-square)
![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

---

<div align="center">

### 🚀 ¡Tu servidor está listo para procesar miles de imágenes diariamente con SSL automático!

**Servidor de Optimización Ultra v3.0** - *Procesamiento paralelo masivo con detección automática de hardware y SSL auto-renovable*

**Made with ❤️ for high-performance image processing**

</div>

---

*Última actualización: Agosto 2025 | Versión: 3.0 | Compatibilidad: Ubuntu 24.04 LTS*
