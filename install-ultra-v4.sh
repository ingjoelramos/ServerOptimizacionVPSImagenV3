#!/bin/bash

#################################################################################
# Script Ultra Optimizado VPS Ubuntu 24.04 
# Servidor de Optimización de Imágenes PARALELA MASIVA v4.1
# Autor: Sistema de Configuración Avanzada Ultra Optimizada
# Versión: 4.1 - MÁXIMO RENDIMIENTO PARALELO + AUTO-DETECTION + API FIX + DOWNLOAD FIX
# Fecha: 2025
# Descripción: Configuración automática para procesamiento paralelo masivo
#              con detección de hardware y optimizaciones extremas
#################################################################################

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Variables globales mejoradas
SCRIPT_VERSION="4.1"
LOG_FILE="/var/log/image-server-ultra-setup.log"
DOMAIN=""
INSTALL_SSL=false

# Variables de hardware (auto-detectadas)
CPU_CORES=0
TOTAL_RAM_GB=0
AVAILABLE_RAM_GB=0
DISK_SPACE_GB=0
OPTIMAL_WORKERS=0
OPTIMAL_PARALLEL_JOBS=0
MAX_IMAGE_SIZE_MB=0
SWAP_SIZE_GB=0
VPS_TIER=""

# Función para imprimir mensajes con timestamp mejorada
print_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${GREEN}[INFO]${NC} $1" | tee -a $LOG_FILE
}

print_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${YELLOW}[WARNING]${NC} $1" | tee -a $LOG_FILE
}

print_success() {
    echo -e "${CYAN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${CYAN}[SUCCESS]${NC} $1" | tee -a $LOG_FILE
}

print_ultra() {
    echo -e "${WHITE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} ${WHITE}[ULTRA]${NC} $1" | tee -a $LOG_FILE
}

# Función para verificar el resultado con reintentos
check_result_with_retry() {
    local max_retries=3
    local attempt=1
    
    while [ $attempt -le $max_retries ]; do
        if [ $? -eq 0 ]; then
            print_success "$1 completado exitosamente"
            return 0
        else
            if [ $attempt -lt $max_retries ]; then
                print_warning "$1 falló. Reintentando ($attempt/$max_retries)..."
                sleep 2
                ((attempt++))
            else
                print_error "$1 falló después de $max_retries intentos. Continuando..."
                return 1
            fi
        fi
    done
}

#################################################################################
# DETECCIÓN AUTOMÁTICA DE HARDWARE Y OPTIMIZACIÓN INTELIGENTE
#################################################################################

detect_hardware() {
    print_ultra "========================================="
    print_ultra "DETECCIÓN AUTOMÁTICA DE HARDWARE"
    print_ultra "========================================="
    
    # Detectar cores de CPU
    CPU_CORES=$(nproc)
    print_message "CPU Cores detectados: $CPU_CORES"
    
    # Detectar RAM total y disponible con precisión
    TOTAL_RAM_MB=$(free -m | awk 'NR==2{print $2}')
    AVAILABLE_RAM_MB=$(free -m | awk 'NR==2{print $7}')
    
    # Calcular GB - usar enteros para evitar problemas con operadores aritméticos
    TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))
    [ $TOTAL_RAM_GB -eq 0 ] && TOTAL_RAM_GB=1
    
    # Guardar valor decimal solo para mostrar
    if command -v bc >/dev/null 2>&1; then
        TOTAL_RAM_GB_DISPLAY=$(echo "scale=1; $TOTAL_RAM_MB/1024" | bc)
    else
        TOTAL_RAM_GB_DISPLAY=$TOTAL_RAM_GB
    fi
    
    # Para sistemas con exactamente 2GB o menos, ser más conservador
    if [ $TOTAL_RAM_MB -le 2048 ]; then
        print_warning "Sistema con RAM limitada detectado: ${TOTAL_RAM_MB}MB"
        print_message "Aplicando configuraciones conservadoras..."
    fi
    
    print_message "RAM Total: ${TOTAL_RAM_GB_DISPLAY}GB (${TOTAL_RAM_MB}MB)"
    print_message "RAM Disponible: ${AVAILABLE_RAM_MB}MB"
    
    # Detectar espacio en disco
    DISK_SPACE_GB=$(df / | awk 'NR==2{print int($4/1024/1024)}')
    print_message "Espacio libre en disco: ${DISK_SPACE_GB}GB"
    
    # Calcular configuraciones óptimas automáticamente
    calculate_optimal_settings
    
    # Determinar tier del VPS
    determine_vps_tier
    
    echo ""
    print_ultra "CONFIGURACIÓN AUTOMÁTICA CALCULADA:"
    print_ultra "=====================================​="
    print_message "VPS Tier: $VPS_TIER"
    print_message "Workers paralelos óptimos: $OPTIMAL_WORKERS"
    print_message "Jobs paralelos simultáneos: $OPTIMAL_PARALLEL_JOBS"
    print_message "Tamaño máximo de imagen: ${MAX_IMAGE_SIZE_MB}MB"
    print_message "Swap recomendado: ${SWAP_SIZE_GB}GB"
    
    # Exportar variables globales para que estén disponibles en todas las funciones
    export TOTAL_RAM_MB
    export TOTAL_RAM_GB
    export CPU_CORES
    export OPTIMAL_WORKERS
    export OPTIMAL_PARALLEL_JOBS
}

calculate_optimal_settings() {
    # Instalar bc si no está disponible para cálculos
    command -v bc >/dev/null 2>&1 || apt install -y bc >/dev/null 2>&1
    
    # Calcular workers óptimos (basado en cores y RAM)
    if [ $CPU_CORES -le 2 ]; then
        OPTIMAL_WORKERS=$CPU_CORES
        OPTIMAL_PARALLEL_JOBS=$CPU_CORES
    elif [ $CPU_CORES -le 4 ]; then
        OPTIMAL_WORKERS=$((CPU_CORES))
        OPTIMAL_PARALLEL_JOBS=$((CPU_CORES * 2))
    elif [ $CPU_CORES -le 8 ]; then
        OPTIMAL_WORKERS=$((CPU_CORES))
        OPTIMAL_PARALLEL_JOBS=$((CPU_CORES * 3))
    else
        OPTIMAL_WORKERS=$((CPU_CORES))
        OPTIMAL_PARALLEL_JOBS=$((CPU_CORES * 4))
    fi
    
    # Ajustar según RAM disponible
    RAM_GB_INT=$TOTAL_RAM_GB
    if [ $RAM_GB_INT -le 2 ]; then
        OPTIMAL_PARALLEL_JOBS=$((OPTIMAL_PARALLEL_JOBS / 2))
        MAX_IMAGE_SIZE_MB=50
        SWAP_SIZE_GB=$((RAM_GB_INT * 2))
    elif [ $RAM_GB_INT -le 4 ]; then
        MAX_IMAGE_SIZE_MB=100
        SWAP_SIZE_GB=$RAM_GB_INT
    elif [ $RAM_GB_INT -le 8 ]; then
        MAX_IMAGE_SIZE_MB=200
        SWAP_SIZE_GB=$((RAM_GB_INT / 2))
    else
        MAX_IMAGE_SIZE_MB=500
        SWAP_SIZE_GB=4
    fi
    
    # Límites mínimos y máximos
    [ $OPTIMAL_WORKERS -lt 1 ] && OPTIMAL_WORKERS=1
    [ $OPTIMAL_PARALLEL_JOBS -lt 2 ] && OPTIMAL_PARALLEL_JOBS=2
    [ $OPTIMAL_PARALLEL_JOBS -gt 64 ] && OPTIMAL_PARALLEL_JOBS=64
    [ $SWAP_SIZE_GB -gt 8 ] && SWAP_SIZE_GB=8
}

determine_vps_tier() {
    RAM_GB_INT=$TOTAL_RAM_GB
    
    if [ $CPU_CORES -le 1 ] && [ $RAM_GB_INT -le 1 ]; then
        VPS_TIER="MICRO (Limitado)"
    elif [ $CPU_CORES -le 2 ] && [ $RAM_GB_INT -le 2 ]; then
        VPS_TIER="SMALL (Básico)"
    elif [ $CPU_CORES -le 4 ] && [ $RAM_GB_INT -le 4 ]; then
        VPS_TIER="MEDIUM (Estándar)"
    elif [ $CPU_CORES -le 8 ] && [ $RAM_GB_INT -le 8 ]; then
        VPS_TIER="LARGE (Alto rendimiento)"
    elif [ $CPU_CORES -le 16 ] && [ $RAM_GB_INT -le 16 ]; then
        VPS_TIER="XL (Muy alto rendimiento)"
    else
        VPS_TIER="XXL (Rendimiento extremo)"
    fi
}

# Banner mejorado con información de hardware
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║     SERVIDOR DE OPTIMIZACIÓN PARALELA MASIVA ULTRA v3.0         ║"
    echo "║                    Ubuntu 24.04 - AUTO-OPTIMIZED                ║"
    echo "║══════════════════════════════════════════════════════════════════║"
    echo "║  🚀 PARALELIZACIÓN MASIVA  📊 AUTO-DETECTION  ⚡ ULTRA SPEED   ║"
    echo "║  Formatos: JPG, PNG, WEBP, AVIF, GIF, SVG, TIFF, HEIF          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    # Detectar hardware automáticamente al inicio
    detect_hardware
}

# Verificar que se ejecuta como root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root o con sudo"
        exit 1
    fi
    
    # Verificar sistema operativo
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        print_warning "Este script está optimizado para Ubuntu 24.04"
    fi
    
    # Verificar conexión a internet
    if ! ping -c 1 google.com >> $LOG_FILE 2>&1 && ! ping -c 1 8.8.8.8 >> $LOG_FILE 2>&1; then
        print_error "Se requiere conexión a Internet para continuar"
        exit 1
    fi
}

# Configuración inicial mejorada
initial_setup() {
    print_ultra "========================================="
    print_ultra "CONFIGURACIÓN INICIAL INTELIGENTE"
    print_ultra "========================================="
    
    echo -e "${YELLOW}Este script configurará automáticamente tu VPS ($VPS_TIER) para:${NC}"
    echo "• Procesamiento paralelo con $OPTIMAL_PARALLEL_JOBS jobs simultáneos"
    echo "• Optimización automática según tu hardware detectado"
    echo "• Queue system con Redis para alta carga"
    echo "• Monitoreo en tiempo real con Netdata"
    echo "• Scripts de optimización en lote ultra rápidos"
    echo ""
    
    read -p "¿Tienes un dominio configurado para este servidor? (s/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        read -p "Ingresa tu dominio (ej: optimserver.com): " DOMAIN
        INSTALL_SSL=true
        print_message "Se configurará SSL para: $DOMAIN"
    else
        print_message "Configuración sin dominio. Podrás agregarlo más tarde."
    fi
    
    echo ""
    read -p "¿Deseas continuar con la instalación AUTO-OPTIMIZADA? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        print_warning "Instalación cancelada por el usuario"
        exit 0
    fi
}

#################################################################################
# CONFIGURACIÓN ULTRA OPTIMIZADA DEL SISTEMA
#################################################################################

configure_system_ultra() {
    print_ultra "========================================="
    print_ultra "CONFIGURACIÓN ULTRA OPTIMIZADA DEL SISTEMA"
    print_ultra "========================================="
    
    # Actualizar el sistema
    print_message "Actualizando el sistema..."
    export DEBIAN_FRONTEND=noninteractive
    apt update && apt upgrade -y >> $LOG_FILE 2>&1
    check_result_with_retry "Actualización del sistema"
    
    # Configurar timezone
    print_message "Configurando timezone..."
    timedatectl set-timezone America/New_York
    
    # Configurar swap dinámico basado en detección de hardware
    print_message "Configurando swap optimizado (${SWAP_SIZE_GB}GB)..."
    if [ -f /swapfile ]; then
        swapoff /swapfile 2>/dev/null
        rm -f /swapfile
    fi
    
    fallocate -l ${SWAP_SIZE_GB}G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    
    # Asegurar que esté en fstab
    grep -q '/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
    print_success "Swap configurado: ${SWAP_SIZE_GB}GB"
    
    # Optimizar swappiness dinámicamente
    if [ "$VPS_TIER" = "MICRO (Limitado)" ] || [ "$VPS_TIER" = "SMALL (Básico)" ]; then
        SWAPPINESS=60  # Más agresivo para VPS pequeños
    else
        SWAPPINESS=10  # Conservador para VPS grandes
    fi
    
    sysctl vm.swappiness=$SWAPPINESS
    echo "vm.swappiness=$SWAPPINESS" >> /etc/sysctl.conf
    print_message "Swappiness configurado: $SWAPPINESS"
    
    # Configurar límites del sistema EXTREMOS
    print_message "Configurando límites extremos del sistema..."
    cat << EOF >> /etc/security/limits.conf
# Límites ultra optimizados para procesamiento masivo
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 131072
* hard nproc 131072
* soft memlock unlimited
* hard memlock unlimited
root soft nofile 1048576
root hard nofile 1048576
www-data soft nofile 1048576
www-data hard nofile 1048576
EOF

    # Configurar systemd límites
    mkdir -p /etc/systemd/system.conf.d
    cat << EOF > /etc/systemd/system.conf.d/limits.conf
[Manager]
DefaultLimitNOFILE=1048576
DefaultLimitNPROC=131072
EOF

    # Aplicar límites inmediatamente
    systemctl daemon-reload
}

#################################################################################
# CONFIGURACIÓN DE SEGURIDAD MEJORADA
#################################################################################

configure_security_enhanced() {
    print_ultra "========================================="
    print_ultra "CONFIGURACIÓN DE SEGURIDAD MEJORADA"
    print_ultra "========================================="
    
    # Instalar herramientas de seguridad
    print_message "Instalando herramientas de seguridad..."
    apt install -y ufw fail2ban unattended-upgrades apt-listchanges \
        rkhunter chkrootkit lynis >> $LOG_FILE 2>&1
    check_result_with_retry "Instalación de herramientas de seguridad"
    
    # Configurar firewall UFW con reglas optimizadas
    print_message "Configurando firewall UFW..."
    ufw --force reset >/dev/null 2>&1
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp comment 'SSH'
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    ufw allow 19999/tcp comment 'Netdata'
    ufw allow 6379/tcp comment 'Redis (internal)'
    ufw --force enable
    print_success "Firewall configurado con puertos optimizados"
    
    # Configurar fail2ban mejorado
    print_message "Configurando fail2ban avanzado..."
    cat << EOF > /etc/fail2ban/jail.local
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd

[sshd]
enabled = true
port = 22
filter = sshd
logpath = %(sshd_log)s
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
port = http,https
logpath = /var/log/nginx/error.log

[nginx-limit-req]
enabled = true
filter = nginx-limit-req
port = http,https
logpath = /var/log/nginx/error.log
maxretry = 10
EOF
    
    systemctl enable fail2ban
    systemctl restart fail2ban
    
    # Configurar actualizaciones automáticas optimizadas
    print_message "Configurando actualizaciones automáticas..."
    cat << EOF > /etc/apt/apt.conf.d/50unattended-upgrades
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
    
    echo 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";' > /etc/apt/apt.conf.d/20auto-upgrades
}

#################################################################################
# NGINX ULTRA OPTIMIZADO
#################################################################################

configure_nginx_ultra() {
    print_ultra "========================================="
    print_ultra "NGINX ULTRA OPTIMIZADO PARA ALTA CARGA"
    print_ultra "========================================="
    
    # Instalar Nginx
    print_message "Instalando Nginx..."
    apt install -y nginx nginx-extras >> $LOG_FILE 2>&1
    check_result_with_retry "Instalación de Nginx"
    
    # Instalar Certbot
    print_message "Instalando Certbot..."
    apt install -y certbot python3-certbot-nginx >> $LOG_FILE 2>&1
    
    # Configuración ULTRA optimizada de Nginx
    print_message "Configurando Nginx ULTRA para $OPTIMAL_WORKERS workers..."
    
    cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes $OPTIMAL_WORKERS;
worker_cpu_affinity auto;
worker_priority -10;
worker_rlimit_nofile 1048576;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 8192;
    use epoll;
    multi_accept on;
    accept_mutex off;
}

http {
    ##
    # Configuración Ultra Optimizada
    ##
    sendfile on;
    sendfile_max_chunk 512k;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 30;
    keepalive_requests 10000;
    reset_timedout_connection on;
    
    types_hash_max_size 4096;
    server_names_hash_bucket_size 128;
    server_tokens off;
    
    # Buffers optimizados para imágenes grandes
    client_max_body_size ${MAX_IMAGE_SIZE_MB}M;
    client_body_buffer_size 128k;
    client_header_buffer_size 4k;
    large_client_header_buffers 8 16k;
    client_body_timeout 30;
    client_header_timeout 30;
    send_timeout 30;
    
    # Configuración de cache optimizada
    open_file_cache max=200000 inactive=20s;
    open_file_cache_valid 30s;
    open_file_cache_min_uses 2;
    open_file_cache_errors on;
    
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    ##
    # Logging optimizado
    ##
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                    '\$status \$body_bytes_sent "\$http_referer" '
                    '"\$http_user_agent" "\$http_x_forwarded_for" '
                    'rt=\$request_time uct="\$upstream_connect_time" '
                    'uht="\$upstream_header_time" urt="\$upstream_response_time"';
                    
    access_log /var/log/nginx/access.log main buffer=64k flush=5s;
    
    ##
    # Gzip ultra optimizado
    ##
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/rss+xml
        application/atom+xml
        image/svg+xml
        text/x-js
        text/x-cross-domain-policy;
        
    ##
    # Brotli compression (comentado - instalar nginx-module-brotli si se necesita)
    ##
    # brotli on;
    # brotli_comp_level 6;
    # brotli_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    ##
    # Rate limiting para protección
    ##
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone \$binary_remote_addr zone=uploads:10m rate=5r/s;
    
    ##
    # SSL Configuration ultra optimizada
    ##
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    ##
    # Virtual Host Configs
    ##
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF
    
    # Crear configuración de sitio por defecto optimizada
    cat << EOF > /etc/nginx/sites-available/image-optimizer
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/image-processor;
    index index.php index.html index.htm;
    
    server_name _;
    
    # Optimizaciones para archivos estáticos
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|webp|avif|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary Accept-Encoding;
    }
    
    # API endpoint para procesamiento
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        try_files \$uri \$uri/ /api/index.php?\$query_string;
    }
    
    # Upload endpoint
    location /upload {
        limit_req zone=uploads burst=10 nodelay;
        client_max_body_size ${MAX_IMAGE_SIZE_MB}M;
        try_files \$uri \$uri/ /upload.php?\$query_string;
    }
    
    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
        
        # Timeouts optimizados para procesamiento de imágenes
        fastcgi_read_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_connect_timeout 300;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
}
EOF
    
    # Habilitar el sitio
    ln -sf /etc/nginx/sites-available/image-optimizer /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Reiniciar Nginx
    nginx -t && systemctl restart nginx
    systemctl enable nginx
    print_success "Nginx ULTRA configurado con $OPTIMAL_WORKERS workers"
    
    # Configurar SSL si se proporcionó dominio
    if [ "$INSTALL_SSL" = true ] && [ ! -z "$DOMAIN" ]; then
        print_message "Preparando configuración SSL para $DOMAIN..."
        
        # Instalar dig si no está disponible
        if ! command -v dig >/dev/null 2>&1; then
            apt install -y dnsutils >> $LOG_FILE 2>&1
        fi
        
        # Validar que el dominio resuelve a este servidor
        SERVER_IP=$(curl -s http://checkip.amazonaws.com/ 2>/dev/null || curl -s http://icanhazip.com/ 2>/dev/null || echo "")
        DOMAIN_IP=$(dig +short $DOMAIN 2>/dev/null | tail -n1)
        
        if [ ! -z "$SERVER_IP" ] && [ ! -z "$DOMAIN_IP" ] && [ "$SERVER_IP" = "$DOMAIN_IP" ]; then
            print_message "Dominio verificado. Configurando SSL..."
            certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN --redirect >> $LOG_FILE 2>&1
            if [ $? -eq 0 ]; then
                print_success "SSL configurado exitosamente para $DOMAIN"
        else
            print_warning "SSL no configurado automáticamente. Ejecutar manualmente después."
            print_message "Para configurar SSL después, ejecuta: sudo certbot --nginx -d $DOMAIN"
            INSTALL_SSL=false
        fi
        
        if [ "$INSTALL_SSL" = true ]; then
            
            # Configurar renovación automática SSL
            print_message "Configurando renovación automática SSL..."
            
            # Crear script de renovación
            cat << 'SSL_RENEW_EOF' > /usr/local/bin/ssl-renew
#!/bin/bash
# Script de renovación automática SSL
LOG_FILE="/var/log/ssl-renewal.log"

echo "$(date): Iniciando renovación SSL..." >> $LOG_FILE
/usr/bin/certbot renew --quiet >> $LOG_FILE 2>&1

if [ $? -eq 0 ]; then
    echo "$(date): Renovación SSL exitosa" >> $LOG_FILE
    # Reiniciar nginx después de renovación exitosa
    systemctl reload nginx >> $LOG_FILE 2>&1
else
    echo "$(date): Error en renovación SSL" >> $LOG_FILE
fi
SSL_RENEW_EOF

            chmod +x /usr/local/bin/ssl-renew
            
            # Agregar al crontab para renovación automática
            # Verificar cada día a las 2:30 AM
            (crontab -l 2>/dev/null; echo "30 2 * * * /usr/local/bin/ssl-renew") | crontab -
            
            # Configurar systemd timer como respaldo
            cat << 'SSL_SERVICE_EOF' > /etc/systemd/system/ssl-renew.service
[Unit]
Description=Renovación automática SSL
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ssl-renew
User=root
SSL_SERVICE_EOF

            cat << 'SSL_TIMER_EOF' > /etc/systemd/system/ssl-renew.timer
[Unit]
Description=Ejecutar renovación SSL diariamente
Requires=ssl-renew.service

[Timer]
OnCalendar=daily
RandomizedDelaySec=3600
Persistent=true

[Install]
WantedBy=timers.target
SSL_TIMER_EOF

            # Habilitar timer
            systemctl daemon-reload
            systemctl enable ssl-renew.timer
            systemctl start ssl-renew.timer
            
            print_success "Renovación automática SSL configurada (cron + systemd timer)"
        fi
        fi
    else
        if [ "$INSTALL_SSL" = true ] && [ ! -z "$DOMAIN" ]; then
            print_warning "No se pudo verificar el dominio $DOMAIN"
            print_message "Configurar SSL manualmente después con: sudo certbot --nginx -d $DOMAIN"
        fi
    fi
}

#################################################################################
# HERRAMIENTAS DE DESARROLLO ULTRA
#################################################################################

install_dev_tools_ultra() {
    print_ultra "========================================="
    print_ultra "HERRAMIENTAS DE DESARROLLO ULTRA"
    print_ultra "========================================="
    
    # Actualizar lista de paquetes primero
    print_message "Actualizando lista de paquetes..."
    apt update >> $LOG_FILE 2>&1
    
    # Instalar herramientas de compilación y utilidades
    print_message "Instalando herramientas de desarrollo completas..."
    apt install -y \
        build-essential cmake git wget curl \
        autoconf automake libtool nasm yasm pkg-config \
        python3 python3-pip python3-dev python3-venv \
        nodejs npm \
        net-tools htop iotop nethogs ncdu tree \
        parallel bc jq unzip zip \
        software-properties-common apt-transport-https \
        ca-certificates gnupg lsb-release >> $LOG_FILE 2>&1
    check_result_with_retry "Instalación de herramientas de desarrollo"
    
    # Configurar GNU Parallel para máximo rendimiento
    print_message "Configurando GNU Parallel para $OPTIMAL_PARALLEL_JOBS jobs..."
    echo "will cite" | parallel --citation 2>/dev/null || true
    
    # Configurar variables de entorno para compilación optimizada
    cat << EOF >> /etc/environment
MAKEFLAGS="-j$CPU_CORES"
CFLAGS="-O3 -march=native"
CXXFLAGS="-O3 -march=native"
EOF
    
    export MAKEFLAGS="-j$CPU_CORES"
    export CFLAGS="-O3 -march=native"
    export CXXFLAGS="-O3 -march=native"
}

#################################################################################
# LIBRERÍAS DE IMÁGENES ULTRA COMPLETAS
#################################################################################

install_image_libraries_ultra() {
    print_ultra "========================================="
    print_ultra "LIBRERÍAS DE IMÁGENES ULTRA COMPLETAS"
    print_ultra "========================================="
    
    # Librerías base COMPLETAS
    print_message "Instalando librerías base completas..."
    apt install -y \
        libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev \
        libpng-dev libpng16-16 libpng-tools \
        libtiff-dev libtiff5-dev libtiff-tools \
        libwebp-dev libwebpmux3 libwebpdemux2 libwebp7 \
        libgif-dev libgif7 \
        libexif-dev libexif12 \
        librsvg2-dev librsvg2-bin librsvg2-2 \
        libmagickwand-dev libmagickcore-dev imagemagick-6-common \
        libvips-dev libvips42 \
        libgd-dev libgd3 \
        libheif-dev libheif1 \
        libaom-dev libaom3 \
        libdav1d-dev libdav1d6 \
        librav1e-dev \
        libsvtav1-dev \
        libyuv-dev \
        libopenjp2-7-dev \
        liblcms2-dev \
        libfftw3-dev \
        liborc-0.4-dev \
        libglib2.0-dev \
        libexpat1-dev \
        libgsf-1-dev \
        libpoppler-glib-dev \
        libopenslide-dev \
        libmatio-dev \
        libcfitsio-dev \
        libhdf5-dev >> $LOG_FILE 2>&1
    check_result_with_retry "Instalación de librerías de imágenes ultra completas"
}

#################################################################################
# HERRAMIENTAS DE OPTIMIZACIÓN PARALELA MASIVA
#################################################################################

install_optimization_tools_ultra() {
    print_ultra "========================================="
    print_ultra "HERRAMIENTAS DE OPTIMIZACIÓN PARALELA MASIVA"
    print_ultra "========================================="
    
    # JPEG - Múltiples optimizadores
    print_message "Instalando optimizadores JPEG completos..."
    apt install -y jpegoptim libjpeg-progs >> $LOG_FILE 2>&1
    
    # Compilar mozjpeg con fallback mejorado
    print_message "Evaluando recursos para mozjpeg..."
    
    MOZJPEG_SUCCESS=false
    
    # Para sistemas con 2GB o menos, no intentar compilar mozjpeg
    # Usar variable global si está disponible
    if [ -z "$TOTAL_RAM_MB" ]; then
        TOTAL_RAM_MB=$(free -m | awk 'NR==2{print $2}')
    fi
    
    if [ $TOTAL_RAM_MB -le 2048 ]; then
        print_message "Sistema con RAM limitada (${TOTAL_RAM_MB}MB). Usando jpegoptim optimizado."
        # Asegurar que jpegoptim esté bien configurado
        apt install -y jpegoptim libjpeg-turbo-progs >> $LOG_FILE 2>&1
        MOZJPEG_SUCCESS=false
    elif [ $CPU_CORES -ge 2 ]; then
        # Solo intentar compilar con más de 2GB RAM
        print_message "Preparando compilación de mozjpeg..."
        
        # Instalar dependencias de compilación para mozjpeg
        apt install -y cmake nasm libtool autoconf automake >> $LOG_FILE 2>&1
        
        cd /tmp
        rm -rf mozjpeg
        print_message "Compilando mozjpeg (puede tardar varios minutos)..."
        if git clone --depth 1 https://github.com/mozilla/mozjpeg.git >> $LOG_FILE 2>&1; then
            cd mozjpeg
            mkdir -p build && cd build
            
            # Usar menos cores para evitar problemas de memoria
            MAKE_CORES=$((CPU_CORES / 2))
            [ $MAKE_CORES -lt 1 ] && MAKE_CORES=1
            
            if cmake -G"Unix Makefiles" -DCMAKE_INSTALL_PREFIX=/opt/mozjpeg -DENABLE_STATIC=OFF ../ >> $LOG_FILE 2>&1; then
                if make -j$MAKE_CORES >> $LOG_FILE 2>&1; then
                    if make install >> $LOG_FILE 2>&1; then
                        # Crear enlaces simbólicos
                        for tool in cjpeg djpeg jpegtran; do
                            ln -sf /opt/mozjpeg/bin/$tool /usr/local/bin/mozjpeg-$tool 2>/dev/null
                        done
                        
                        # Actualizar LD_LIBRARY_PATH
                        echo '/opt/mozjpeg/lib' > /etc/ld.so.conf.d/mozjpeg.conf
                        ldconfig
                        
                        MOZJPEG_SUCCESS=true
                        print_success "mozjpeg compilado y configurado exitosamente"
                    fi
                fi
            fi
        fi
    else
        print_warning "Hardware insuficiente para compilar mozjpeg (requiere 2GB RAM + 2 cores)"
    fi
    
    if [ "$MOZJPEG_SUCCESS" = false ]; then
        print_message "Usando jpegoptim como alternativa optimizada"
        # Asegurar que jpegoptim esté bien configurado
        which jpegoptim >> $LOG_FILE 2>&1 && print_success "jpegoptim configurado como optimizador JPEG principal"
    fi
    
    # PNG - Optimizadores múltiples
    print_message "Instalando optimizadores PNG ultra..."
    apt install -y optipng pngquant pngcrush advancecomp >> $LOG_FILE 2>&1
    
    # Instalar oxipng con fallback
    print_message "Instalando oxipng..."
    cd /tmp
    OXIPNG_VERSION="9.1.2"
    OXIPNG_URL="https://github.com/shssoichiro/oxipng/releases/download/v${OXIPNG_VERSION}/oxipng-${OXIPNG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    
    if wget -q --timeout=30 "$OXIPNG_URL" -O oxipng.tar.gz; then
        if tar -xzf oxipng.tar.gz 2>/dev/null; then
            if [ -f "oxipng-${OXIPNG_VERSION}-x86_64-unknown-linux-musl/oxipng" ]; then
                cp "oxipng-${OXIPNG_VERSION}-x86_64-unknown-linux-musl/oxipng" /usr/local/bin/
                chmod +x /usr/local/bin/oxipng
                print_success "oxipng instalado"
            else
                print_warning "oxipng estructura inesperada, usando optimizadores estándar"
            fi
        else
            print_warning "oxipng extracción falló, usando optimizadores estándar"
        fi
    else
        print_warning "oxipng download falló, usando optimizadores estándar"
    fi
    
    # WebP - Herramientas completas
    print_message "Instalando herramientas WebP..."
    apt install -y webp >> $LOG_FILE 2>&1
    
    # AVIF - Instalación con fallback
    print_message "Instalando herramientas AVIF..."
    apt install -y libavif-bin >> $LOG_FILE 2>&1
    
    # Compilar libavif optimizado con fallback inteligente
    print_message "Evaluando recursos para libavif..."
    
    LIBAVIF_SUCCESS=false
    
    # Para sistemas con 2GB o menos, no intentar compilar libavif
    # Usar variable global si está disponible
    if [ -z "$TOTAL_RAM_MB" ]; then
        TOTAL_RAM_MB=$(free -m | awk 'NR==2{print $2}')
    fi
    
    if [ $TOTAL_RAM_MB -le 2048 ]; then
        print_message "Sistema con RAM limitada (${TOTAL_RAM_MB}MB). Instalando libavif estándar."
        # Instalar versión de repositorio directamente
        apt install -y libavif-bin libavif-dev >> $LOG_FILE 2>&1 || true
        which avifenc >> $LOG_FILE 2>&1 && LIBAVIF_SUCCESS=true
    elif [ $CPU_CORES -ge 2 ]; then
        # Solo intentar compilar con más de 2GB RAM
        print_message "Preparando compilación de libavif..."
        
        # Instalar dependencias necesarias para libavif
        apt install -y cmake ninja-build meson >> $LOG_FILE 2>&1
        
        cd /tmp
        rm -rf libavif
        print_message "Compilando libavif (puede tardar varios minutos)..."
        
        # Instalar dependencias de codecs primero
        apt install -y libaom-dev libdav1d-dev librav1e-dev libsvtav1-dev libyuv-dev >> $LOG_FILE 2>&1
        
        if git clone --depth 1 https://github.com/AOMediaCodec/libavif.git >> $LOG_FILE 2>&1; then
            cd libavif
            mkdir -p build && cd build
            
            # Usar menos cores para evitar problemas de memoria
            MAKE_CORES=$((CPU_CORES / 2))
            [ $MAKE_CORES -lt 1 ] && MAKE_CORES=1
            
            # Configuración simplificada para evitar errores
            CMAKE_CMD="cmake .. -DCMAKE_BUILD_TYPE=Release \
                -DCMAKE_INSTALL_PREFIX=/usr/local \
                -DAVIF_BUILD_APPS=ON"
                
            if $CMAKE_CMD >> $LOG_FILE 2>&1; then
                if make -j$MAKE_CORES >> $LOG_FILE 2>&1; then
                    if make install >> $LOG_FILE 2>&1; then
                        ldconfig
                        LIBAVIF_SUCCESS=true
                        print_success "libavif optimizado compilado exitosamente"
                    fi
                fi
            fi
        fi
    else
        print_warning "Hardware insuficiente para compilar libavif (requiere 2GB RAM + 2 cores)"
    fi
    
    if [ "$LIBAVIF_SUCCESS" = false ]; then
        print_message "Usando libavif-bin estándar como alternativa"
        # Verificar que la versión estándar esté instalada
        which avifenc >> $LOG_FILE 2>&1 && print_success "avifenc estándar configurado como codificador AVIF principal"
    fi
    
    # GIF, SVG, TIFF
    print_message "Instalando optimizadores adicionales..."
    apt install -y gifsicle libtiff-tools >> $LOG_FILE 2>&1
    
    # Node.js y SVGO para SVG
    if ! command -v node >/dev/null 2>&1; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >> $LOG_FILE 2>&1
        apt install -y nodejs >> $LOG_FILE 2>&1
    fi
    
    npm install -g svgo@latest >> $LOG_FILE 2>&1
    check_result_with_retry "Instalación de SVGO"
}

#################################################################################
# IMAGE PROCESSING SUITES ULTRA
#################################################################################

install_image_suites_ultra() {
    print_ultra "========================================="
    print_ultra "IMAGE PROCESSING SUITES ULTRA"
    print_ultra "========================================="
    
    # ImageMagick con configuración ultra
    print_message "Instalando ImageMagick ultra..."
    apt install -y imagemagick imagemagick-6-common libmagickcore-6.q16-6-extra >> $LOG_FILE 2>&1
    
    # Configurar políticas ultra optimizadas de ImageMagick
    print_message "Configurando políticas ultra de ImageMagick..."
    POLICY_FILES=("/etc/ImageMagick-6/policy.xml" "/usr/local/etc/ImageMagick-6/policy.xml")
    
    for POLICY_FILE in "${POLICY_FILES[@]}"; do
        if [ -f "$POLICY_FILE" ]; then
            # Backup del archivo original
            cp "$POLICY_FILE" "${POLICY_FILE}.backup"
            
            # Aplicar configuraciones ultra optimizadas
            # Usar valores enteros para operaciones aritméticas
            RAM_GB_INT=$TOTAL_RAM_GB
            MAP_SIZE=$((RAM_GB_INT * 2))
            
            sed -i 's/<policy domain="resource" name="memory" value="[^"]*"/<policy domain="resource" name="memory" value="'${RAM_GB_INT}'GiB"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="map" value="[^"]*"/<policy domain="resource" name="map" value="'${MAP_SIZE}'GiB"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="width" value="[^"]*"/<policy domain="resource" name="width" value="64KP"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="height" value="[^"]*"/<policy domain="resource" name="height" value="64KP"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="area" value="[^"]*"/<policy domain="resource" name="area" value="2GB"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="disk" value="[^"]*"/<policy domain="resource" name="disk" value="8GiB"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="file" value="[^"]*"/<policy domain="resource" name="file" value="768"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="thread" value="[^"]*"/<policy domain="resource" name="thread" value="'$CPU_CORES'"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="throttle" value="[^"]*"/<policy domain="resource" name="throttle" value="0"/g' "$POLICY_FILE"
            sed -i 's/<policy domain="resource" name="time" value="[^"]*"/<policy domain="resource" name="time" value="3600"/g' "$POLICY_FILE"
            
            print_success "Políticas ImageMagick configuradas en $POLICY_FILE"
        fi
    done
    
    # GraphicsMagick
    print_message "Instalando GraphicsMagick..."
    apt install -y graphicsmagick >> $LOG_FILE 2>&1
}

#################################################################################
# VIPS ULTRA OPTIMIZADO
#################################################################################

install_vips_ultra() {
    print_ultra "========================================="
    print_ultra "VIPS ULTRA OPTIMIZADO"
    print_ultra "========================================="
    
    # Instalar VIPS con todas las dependencias ultra
    print_message "Instalando VIPS ultra completo..."
    
    # Actualizar cache de paquetes primero
    apt update >> $LOG_FILE 2>&1
    
    # Intentar instalar VIPS y herramientas
    VIPS_INSTALLED=false
    if apt install -y libvips-tools libvips42 >> $LOG_FILE 2>&1; then
        VIPS_INSTALLED=true
        print_success "VIPS tools instalado exitosamente"
    else
        # Intentar con nombres alternativos de paquetes
        if apt install -y libvips libvips-tools >> $LOG_FILE 2>&1; then
            VIPS_INSTALLED=true
            print_success "VIPS instalado con paquetes alternativos"
        else
            print_warning "VIPS no disponible en repositorios, instalando alternativas"
            # Instalar ImageMagick como alternativa si VIPS falla
            apt install -y imagemagick >> $LOG_FILE 2>&1
        fi
    fi
    
    # Instalar dependencias adicionales si VIPS se instaló exitosamente
    if [ "$VIPS_INSTALLED" = true ]; then
        apt install -y libvips-dev gir1.2-vips-8.0 python3-pyvips >> $LOG_FILE 2>&1 || true
    fi
    
    # Configurar variables de entorno VIPS para máximo rendimiento
    cat << EOF >> /etc/environment
VIPS_CONCURRENCY=$OPTIMAL_PARALLEL_JOBS
VIPS_DISC_THRESHOLD=500M
VIPS_PROGRESS=true
VIPS_NOVECTOR=false
EOF
    
    export VIPS_CONCURRENCY=$OPTIMAL_PARALLEL_JOBS
    export VIPS_DISC_THRESHOLD=500M
    export VIPS_PROGRESS=true
    export VIPS_NOVECTOR=false
}

#################################################################################
# PHP ULTRA OPTIMIZADO PARA ALTO RENDIMIENTO
#################################################################################

configure_php_ultra() {
    print_ultra "========================================="
    print_ultra "PHP ULTRA OPTIMIZADO PARA ALTO RENDIMIENTO"
    print_ultra "========================================="
    
    # Instalar PHP 8.3 con todas las extensiones necesarias
    print_message "Instalando PHP 8.3 ultra completo..."
    apt install -y software-properties-common >> $LOG_FILE 2>&1
    add-apt-repository -y ppa:ondrej/php >> $LOG_FILE 2>&1
    apt update >> $LOG_FILE 2>&1
    
    apt install -y \
        php8.3-fpm php8.3-cli php8.3-common \
        php8.3-gd php8.3-imagick php8.3-vips \
        php8.3-mbstring php8.3-xml php8.3-zip \
        php8.3-curl php8.3-intl php8.3-bcmath \
        php8.3-mysql php8.3-pgsql php8.3-sqlite3 \
        php8.3-redis php8.3-memcached \
        php8.3-opcache php8.3-apcu \
        php8.3-dev php8.3-xdebug >> $LOG_FILE 2>&1
    check_result_with_retry "Instalación de PHP 8.3 ultra"
    
    # Configurar PHP-FPM ultra optimizado
    print_message "Configurando PHP-FPM ultra para $OPTIMAL_WORKERS workers..."
    
    # Calcular configuraciones dinámicas de PHP-FPM
    # Usar MB para comparaciones más precisas
    if [ $TOTAL_RAM_MB -le 2048 ]; then
        PM_MAX_CHILDREN=$((OPTIMAL_WORKERS * 2))
        PM_START_SERVERS=$OPTIMAL_WORKERS
        PM_MIN_SPARE_SERVERS=$OPTIMAL_WORKERS
        PM_MAX_SPARE_SERVERS=$((OPTIMAL_WORKERS * 2))
    elif [ $TOTAL_RAM_MB -le 4096 ]; then
        PM_MAX_CHILDREN=$((OPTIMAL_WORKERS * 4))
        PM_START_SERVERS=$((OPTIMAL_WORKERS * 2))
        PM_MIN_SPARE_SERVERS=$OPTIMAL_WORKERS
        PM_MAX_SPARE_SERVERS=$((OPTIMAL_WORKERS * 3))
    else
        PM_MAX_CHILDREN=$((OPTIMAL_WORKERS * 8))
        PM_START_SERVERS=$((OPTIMAL_WORKERS * 3))
        PM_MIN_SPARE_SERVERS=$((OPTIMAL_WORKERS * 2))
        PM_MAX_SPARE_SERVERS=$((OPTIMAL_WORKERS * 5))
    fi
    
    # Configurar pool ultra optimizado
    cat << EOF > /etc/php/8.3/fpm/pool.d/image-processor.conf
[image-processor]
user = www-data
group = www-data
listen = /var/run/php/php8.3-fpm-image.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Process management ultra optimizado
pm = dynamic
pm.max_children = $PM_MAX_CHILDREN
pm.start_servers = $PM_START_SERVERS
pm.min_spare_servers = $PM_MIN_SPARE_SERVERS
pm.max_spare_servers = $PM_MAX_SPARE_SERVERS
pm.max_requests = 1000
pm.process_idle_timeout = 30s

; Optimizaciones específicas para procesamiento de imágenes
request_slowlog_timeout = 300s
request_terminate_timeout = 600s
slowlog = /var/log/php8.3-fpm-slow.log

; Variables de entorno para procesamiento paralelo
env[VIPS_CONCURRENCY] = $OPTIMAL_PARALLEL_JOBS
env[PARALLEL] = $OPTIMAL_PARALLEL_JOBS
env[OMP_NUM_THREADS] = $CPU_CORES

; Configuraciones de memoria
php_admin_value[memory_limit] = ${MAX_IMAGE_SIZE_MB}0M
php_admin_value[upload_max_filesize] = ${MAX_IMAGE_SIZE_MB}M
php_admin_value[post_max_size] = ${MAX_IMAGE_SIZE_MB}M
php_admin_value[max_execution_time] = 600
php_admin_value[max_input_time] = 300
php_admin_value[default_socket_timeout] = 300

; Optimizaciones adicionales
php_admin_value[opcache.enable] = 1
php_admin_value[opcache.memory_consumption] = 256
php_admin_value[opcache.max_accelerated_files] = 10000
php_admin_value[opcache.revalidate_freq] = 60
php_admin_value[opcache.fast_shutdown] = 1
EOF
    
    # Configurar php.ini ultra optimizado
    PHP_INI="/etc/php/8.3/fpm/php.ini"
    if [ -f "$PHP_INI" ]; then
        cp "$PHP_INI" "${PHP_INI}.backup"
        
        # Aplicar configuraciones ultra
        sed -i "s/memory_limit = .*/memory_limit = ${MAX_IMAGE_SIZE_MB}0M/" "$PHP_INI"
        sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${MAX_IMAGE_SIZE_MB}M/" "$PHP_INI"
        sed -i "s/post_max_size = .*/post_max_size = ${MAX_IMAGE_SIZE_MB}M/" "$PHP_INI"
        sed -i 's/max_execution_time = .*/max_execution_time = 600/' "$PHP_INI"
        sed -i 's/max_input_time = .*/max_input_time = 300/' "$PHP_INI"
        sed -i 's/max_input_vars = .*/max_input_vars = 3000/' "$PHP_INI"
        sed -i 's/;realpath_cache_size = .*/realpath_cache_size = 4096K/' "$PHP_INI"
        sed -i 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 600/' "$PHP_INI"
    fi
    
    # Configurar OPcache ultra
    cat << EOF > /etc/php/8.3/mods-available/opcache-ultra.ini
; OPcache ultra optimizado
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=512
opcache.interned_strings_buffer=64
opcache.max_accelerated_files=20000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_file_override=1
opcache.huge_code_pages=1
opcache.jit_buffer_size=256M
opcache.jit=1255
EOF
    
    # Habilitar configuraciones
    phpenmod opcache-ultra
    
    # Deshabilitar JIT para CLI para evitar conflictos con api-key-manager
    cat << 'EOF' > /etc/php/8.3/cli/conf.d/99-disable-jit.ini
; Deshabilitar JIT para CLI - evita conflictos con extensiones
opcache.jit=0
opcache.jit_buffer_size=0
EOF
    
    # Reiniciar PHP-FPM
    systemctl restart php8.3-fpm
    systemctl enable php8.3-fpm
    print_success "PHP ultra configurado con $PM_MAX_CHILDREN workers máximos"
}

#################################################################################
# REDIS ULTRA PARA QUEUE SYSTEM MASIVO
#################################################################################

install_redis_ultra() {
    print_ultra "========================================="
    print_ultra "REDIS ULTRA PARA QUEUE SYSTEM MASIVO"
    print_ultra "========================================="
    
    # Instalar Redis usando la configuración de Ubuntu
    print_message "Instalando Redis con configuración nativa de Ubuntu..."
    apt update >> $LOG_FILE 2>&1
    apt install -y redis-server redis-tools >> $LOG_FILE 2>&1
    
    if [ $? -ne 0 ]; then
        print_error "Error al instalar Redis"
        return 1
    fi
    
    print_success "Redis instalado correctamente"
    
    # Esperar que Redis se instale completamente
    sleep 3
    
    # Hacer backup de la configuración original
    if [ -f /etc/redis/redis.conf ]; then
        cp /etc/redis/redis.conf /etc/redis/redis.conf.backup.$(date +%Y%m%d) >> $LOG_FILE 2>&1
        print_message "Backup de configuración creado"
    fi
    
    # Configurar Redis optimizado - MODIFICANDO la configuración existente, NO sobrescribiendo
    print_message "Optimizando configuración de Redis para tu sistema..."
    
    # Calcular memoria óptima para Redis basado en MB
    if [ $TOTAL_RAM_MB -le 2048 ]; then
        REDIS_MEMORY=256  # 256MB para sistemas de 2GB o menos
    elif [ $TOTAL_RAM_MB -le 4096 ]; then
        REDIS_MEMORY=512  # 512MB para sistemas de 4GB
    elif [ $TOTAL_RAM_MB -le 8192 ]; then
        REDIS_MEMORY=1024  # 1GB para sistemas de 8GB
    else
        REDIS_MEMORY=2048  # 2GB para sistemas grandes
    fi
    
    # Crear archivo de configuración adicional que NO sobrescribe el principal
    print_message "Aplicando optimizaciones para ${REDIS_MEMORY}MB de memoria..."
    
    # Usar sed para modificar parámetros específicos sin romper la configuración
    CONFIG_FILE="/etc/redis/redis.conf"
    
    # Detener Redis temporalmente para aplicar cambios
    systemctl stop redis-server >> $LOG_FILE 2>&1
    
    # Aplicar configuraciones optimizadas sin romper systemd
    # 1. Memoria máxima
    sed -i "s/^# maxmemory <bytes>/maxmemory ${REDIS_MEMORY}mb/g" $CONFIG_FILE
    sed -i "s/^maxmemory .*/maxmemory ${REDIS_MEMORY}mb/g" $CONFIG_FILE
    
    # Si no existe la línea, agregarla al final
    if ! grep -q "^maxmemory " $CONFIG_FILE; then
        echo "maxmemory ${REDIS_MEMORY}mb" >> $CONFIG_FILE
    fi
    
    # 2. Política de memoria
    sed -i "s/^# maxmemory-policy .*/maxmemory-policy allkeys-lru/g" $CONFIG_FILE
    sed -i "s/^maxmemory-policy .*/maxmemory-policy allkeys-lru/g" $CONFIG_FILE
    
    if ! grep -q "^maxmemory-policy " $CONFIG_FILE; then
        echo "maxmemory-policy allkeys-lru" >> $CONFIG_FILE
    fi
    
    # 3. TCP backlog para alta concurrencia
    sed -i "s/^tcp-backlog .*/tcp-backlog 511/g" $CONFIG_FILE
    
    # 4. Timeout para conexiones inactivas
    sed -i "s/^timeout .*/timeout 300/g" $CONFIG_FILE
    
    # 5. TCP keepalive
    sed -i "s/^tcp-keepalive .*/tcp-keepalive 300/g" $CONFIG_FILE
    
    # 6. Deshabilitar snapshotting para mejor rendimiento en colas
    sed -i 's/^save /# save /g' $CONFIG_FILE
    
    # 7. Asegurar que NO use daemonize con systemd
    sed -i "s/^daemonize yes/daemonize no/g" $CONFIG_FILE
    
    # 8. Asegurar supervisión systemd
    sed -i "s/^supervised no/supervised systemd/g" $CONFIG_FILE
    sed -i "s/^supervised auto/supervised systemd/g" $CONFIG_FILE
    
    # 9. Configurar directorio de trabajo
    sed -i "s|^dir .*|dir /var/lib/redis|g" $CONFIG_FILE
    
    # 10. Configurar log
    sed -i "s|^logfile .*|logfile /var/log/redis/redis-server.log|g" $CONFIG_FILE
    
    # Crear archivo de override para systemd con límites optimizados
    print_message "Configurando límites del sistema para Redis..."
    mkdir -p /etc/systemd/system/redis-server.service.d
    
    cat << EOF > /etc/systemd/system/redis-server.service.d/override.conf
[Service]
# Límites optimizados para Redis
LimitNOFILE=65535
LimitNPROC=32768

# Reiniciar automáticamente si falla
Restart=always
RestartSec=3s

# Tiempo de espera para iniciar
TimeoutStartSec=90s
TimeoutStopSec=90s
EOF
    
    # Asegurar permisos correctos
    print_message "Verificando permisos de Redis..."
    
    # Los directorios de Redis en Ubuntu se crean automáticamente con la instalación
    # Solo verificamos que existan y tengan los permisos correctos
    if [ -d "/var/lib/redis" ]; then
        chown -R redis:redis /var/lib/redis 2>/dev/null || true
    fi
    
    if [ -d "/var/log/redis" ]; then
        chown -R redis:redis /var/log/redis 2>/dev/null || true
    fi
    
    if [ -d "/run/redis" ] || [ -d "/var/run/redis" ]; then
        chown -R redis:redis /run/redis 2>/dev/null || true
        chown -R redis:redis /var/run/redis 2>/dev/null || true
    fi
    
    # Configuración del archivo principal
    if [ -f "/etc/redis/redis.conf" ]; then
        chown redis:redis /etc/redis/redis.conf
        chmod 640 /etc/redis/redis.conf
    fi
    
    # Recargar systemd y iniciar Redis
    print_message "Iniciando Redis con configuración optimizada..."
    systemctl daemon-reload
    systemctl enable redis-server >> $LOG_FILE 2>&1
    
    # Intentar iniciar Redis
    systemctl start redis-server >> $LOG_FILE 2>&1
    
    # Esperar y verificar que Redis esté funcionando
    sleep 5
    
    # Intentar iniciar Redis varias veces
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if systemctl is-active --quiet redis-server; then
            # Verificar que Redis realmente responde
            if redis-cli ping 2>/dev/null | grep -q "PONG"; then
                print_success "Redis ultra configurado con ${REDIS_MEMORY}MB de memoria y funcionando perfectamente"
                # Mostrar información de Redis
                REDIS_VERSION=$(redis-cli INFO server 2>/dev/null | grep redis_version | cut -d: -f2 | tr -d '\r')
                print_message "Redis versión: $REDIS_VERSION"
                print_message "Memoria máxima configurada: ${REDIS_MEMORY}MB"
                break
            else
                print_warning "Servicio Redis activo pero no responde a ping"
                if [ $attempt -lt $max_attempts ]; then
                    print_message "Intento $attempt: Reiniciando Redis..."
                    systemctl restart redis-server >> $LOG_FILE 2>&1
                    sleep 5
                    ((attempt++))
                else
                    break
                fi
            fi
        else
            if [ $attempt -lt $max_attempts ]; then
                print_message "Intento $attempt: Iniciando Redis..."
                systemctl start redis-server >> $LOG_FILE 2>&1
                sleep 5
                ((attempt++))
            else
                print_warning "Redis instalado pero no pudo iniciarse automáticamente"
                print_message "Esto puede ser normal en algunos sistemas. Para verificar manualmente:"
                print_message "  sudo systemctl status redis-server"
                print_message "  sudo journalctl -xeu redis-server"
                print_message "  sudo redis-cli ping"
                break  # IMPORTANTE: Salir del bucle después del último intento
            fi
        fi
    done
}

#################################################################################
# NETDATA ULTRA PARA MONITOREO MASIVO
#################################################################################

install_netdata_ultra() {
    print_ultra "========================================="
    print_ultra "NETDATA ULTRA PARA MONITOREO MASIVO"
    print_ultra "========================================="
    
    # Instalar dependencias para Netdata
    print_message "Instalando dependencias Netdata..."
    apt install -y curl wget software-properties-common >> $LOG_FILE 2>&1
    
    # Instalar Netdata con configuración automatizada
    print_message "Instalando Netdata ultra..."
    wget -O /tmp/netdata-kickstart.sh https://get.netdata.cloud/kickstart.sh >> $LOG_FILE 2>&1
    
    if [ -f /tmp/netdata-kickstart.sh ]; then
        bash /tmp/netdata-kickstart.sh --non-interactive --stable-channel >> $LOG_FILE 2>&1
        check_result_with_retry "Instalación de Netdata"
    else
        print_warning "Netdata kickstart no disponible, instalando desde repos..."
        apt install -y netdata >> $LOG_FILE 2>&1
    fi
    
    # Configurar Netdata ultra optimizado
    print_message "Configurando Netdata ultra..."
    
    # Esperar que Netdata se instale completamente
    sleep 5
    
    # Asegurar que los directorios existan
    mkdir -p /etc/netdata
    mkdir -p /var/cache/netdata
    mkdir -p /var/log/netdata
    
    # Permisos correctos para Netdata
    chown -R netdata:netdata /var/cache/netdata 2>/dev/null || true
    chown -R netdata:netdata /var/log/netdata 2>/dev/null || true
    
    cat << EOF > /etc/netdata/netdata.conf
[global]
    run as user = netdata
    web files owner = root
    web files group = root
    
    # Configuración de memoria optimizada para sistemas pequeños
    memory mode = dbengine
    page cache size = 32
    dbengine multihost disk space = 256
    history = 3600
    
    # Update every optimizado para alta carga
    update every = 2
    
    # Configuración de red ultra
    default port = 19999
    bind to = *
    allow connections from = *
    allow dashboard from = *
    
    # Performance optimizations
    enable web responses gzip compression = yes
    web compression strategy = gzip
    web compression level = 3

[web]
    bind to = *:19999
    allow connections from = *
    allow dashboard from = *
    allow badges from = *
    allow streaming from = *
    enable gzip compression = yes
    
[registry]
    enabled = yes
    
# Plugins específicos para imagen processing
[plugin:proc]
    enabled = yes
    
[plugin:diskspace]
    enabled = yes
    
[plugin:cgroups]
    enabled = yes
    
[plugin:proc:/proc/stat]
    enabled = yes
    
[plugin:proc:/proc/meminfo]
    enabled = yes
    
[plugin:proc:/proc/vmstat]
    enabled = yes

# Configuración específica para Redis monitoring
[plugin:python.d]
    enabled = yes
    
[plugin:python.d:redis]
    enabled = yes
    host = localhost
    port = 6379
    
# Configuración específica para PHP-FPM monitoring
[plugin:python.d:phpfpm]
    enabled = yes
    update_every = 3
    
# Configuración específica para Nginx monitoring
[plugin:python.d:nginx]
    enabled = yes
    update_every = 2
EOF
    
    # Configurar monitoreo específico para procesamiento de imágenes
    cat << EOF > /etc/netdata/python.d/image_processor.conf
# Custom image processor monitoring
update_every: 5
priority: 90000

jobs:
  local:
    name: 'image_processor'
    update_every: 5
EOF
    
    # Habilitar plugins necesarios
    if [ -d /etc/netdata ]; then
        # Habilitar collectors del sistema
        touch /etc/netdata/go.d.conf 2>/dev/null || true
        
        # Configurar go.d para monitoreo
        cat << 'GOCONF' > /etc/netdata/go.d.conf
jobs:
  - name: local
    update_every: 1
GOCONF
    fi
    
    # Reiniciar Netdata
    systemctl daemon-reload
    systemctl enable netdata >> $LOG_FILE 2>&1
    systemctl restart netdata >> $LOG_FILE 2>&1
    
    # Verificar que esté funcionando
    sleep 5
    if systemctl is-active --quiet netdata && netstat -tulpn 2>/dev/null | grep -q ":19999"; then
        print_success "Netdata ultra instalado y activo en puerto 19999"
        print_message "Acceder a: http://$(hostname -I | awk '{print $1}'):19999"
    else
        print_warning "Netdata instalado pero requiere verificación manual"
        print_message "Ejecutar: sudo systemctl status netdata para verificar"
    fi
}

#################################################################################
# ESTRUCTURA DE DIRECTORIOS ULTRA OPTIMIZADA
#################################################################################

create_directory_structure_ultra() {
    print_ultra "========================================="
    print_ultra "ESTRUCTURA DE DIRECTORIOS ULTRA OPTIMIZADA"
    print_ultra "========================================="
    
    # Crear estructura completa para procesamiento masivo
    print_message "Creando estructura ultra optimizada..."
    
    # Crear directorio base primero
    mkdir -p /var/www/image-processor
    
    # Crear subdirectorios de uploads
    mkdir -p /var/www/image-processor/uploads/{pending,processing,completed,failed}
    
    # Crear subdirectorios de processed
    mkdir -p /var/www/image-processor/processed/{jpg,png,webp,avif,gif,svg,tiff}
    
    # Crear subdirectorios de temp
    mkdir -p /var/www/image-processor/temp/{workers,batch,parallel}
    
    # Crear subdirectorios de logs
    mkdir -p /var/www/image-processor/logs/{nginx,php,redis,workers,optimization}
    
    # Crear subdirectorios de cache
    mkdir -p /var/www/image-processor/cache/{thumbnails,metadata,statistics}
    
    # Crear subdirectorios de queue
    mkdir -p /var/www/image-processor/queue/{high,normal,low,failed}
    
    # Crear subdirectorios de api
    mkdir -p /var/www/image-processor/api/{v1,v2,webhooks}
    
    # Crear subdirectorios de scripts
    mkdir -p /var/www/image-processor/scripts/{optimization,batch,monitoring}
    
    # Crear subdirectorios de backup
    mkdir -p /var/www/image-processor/backup/{daily,weekly,monthly}
    
    # Crear directorio config
    mkdir -p /var/www/image-processor/config
    
    # Verificar que los directorios se crearon antes de aplicar permisos
    if [ -d "/var/www/image-processor" ]; then
        # Establecer permisos optimizados
        chown -R www-data:www-data /var/www/image-processor
        chmod -R 755 /var/www/image-processor
        
        # Directorios con permisos especiales
        [ -d "/var/www/image-processor/temp" ] && chmod 777 /var/www/image-processor/temp
        [ -d "/var/www/image-processor/uploads" ] && chmod 777 /var/www/image-processor/uploads
        [ -d "/var/www/image-processor/cache" ] && chmod 777 /var/www/image-processor/cache
        [ -d "/var/www/image-processor/logs" ] && chmod 755 /var/www/image-processor/logs
        
        print_success "Estructura ultra optimizada creada en /var/www/image-processor/"
    else
        print_error "Error al crear la estructura de directorios"
        return 1
    fi
}

#################################################################################
# SCRIPTS DE OPTIMIZACIÓN PARALELA MASIVA
#################################################################################

create_parallel_optimization_scripts() {
    print_ultra "========================================="
    print_ultra "SCRIPTS DE OPTIMIZACIÓN PARALELA MASIVA"
    print_ultra "========================================="
    
    # Script principal de optimización paralela
    cat << EOF > /usr/local/bin/optimize-ultra
#!/bin/bash

# Configuración ultra optimizada
WORKERS=$OPTIMAL_PARALLEL_JOBS
MAX_JOBS=$OPTIMAL_PARALLEL_JOBS
TEMP_DIR="/var/www/image-processor/temp"
LOG_DIR="/var/www/image-processor/logs"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging
log_message() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - \$1" >> "\$LOG_DIR/optimization.log"
    echo -e "\${GREEN}[ULTRA]\${NC} \$1"
}

log_error() {
    echo "\$(date '+%Y-%m-%d %H:%M:%S') - ERROR: \$1" >> "\$LOG_DIR/errors.log"
    echo -e "\${RED}[ERROR]\${NC} \$1"
}

# Función de optimización ultra paralela
optimize_ultra_parallel() {
    local input_dir="\$1"
    local output_dir="\$2"
    local format="\$3"
    local quality="\${4:-85}"
    
    if [ ! -d "\$input_dir" ]; then
        log_error "Directorio de entrada no encontrado: \$input_dir"
        return 1
    fi
    
    mkdir -p "\$output_dir"
    
    case "\$format" in
        "jpg"|"jpeg")
            log_message "Optimizando JPEG con \$WORKERS workers paralelos..."
            find "\$input_dir" -name "*.jpg" -o -name "*.jpeg" | \\
            parallel -j\$WORKERS --progress \\
                'jpegoptim --strip-all --overwrite "{}" && echo "✓ {}"' 2>&1 | \\
                tee -a "\$LOG_DIR/jpeg-optimization.log"
            ;;
        "png")
            log_message "Optimizando PNG con \$WORKERS workers paralelos..."
            find "\$input_dir" -name "*.png" | \\
            parallel -j\$WORKERS --progress \\
                'optipng -o2 "{}" && pngquant --ext .png --force 256 "{}" 2>/dev/null && echo "✓ {}"' 2>&1 | \\
                tee -a "\$LOG_DIR/png-optimization.log"
            ;;
        "webp")
            log_message "Creando WebP con \$WORKERS workers paralelos..."
            find "\$input_dir" -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | \\
            parallel -j\$WORKERS --progress \\
                'cwebp -q '\$quality' "{}" -o "{.}.webp" && echo "✓ WebP: {.}.webp"' 2>&1 | \\
                tee -a "\$LOG_DIR/webp-optimization.log"
            ;;
        "avif")
            log_message "Creando AVIF con \$WORKERS workers paralelos..."
            find "\$input_dir" -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | \\
            parallel -j\$WORKERS --progress \\
                'avifenc "{}" "{.}.avif" --min 20 --max 30 2>/dev/null && echo "✓ AVIF: {.}.avif"' 2>&1 | \\
                tee -a "\$LOG_DIR/avif-optimization.log"
            ;;
        "gif")
            log_message "Optimizando GIF con \$WORKERS workers paralelos..."
            find "\$input_dir" -name "*.gif" | \\
            parallel -j\$WORKERS --progress \\
                'gifsicle --optimize=3 --output="{}" "{}" && echo "✓ {}"' 2>&1 | \\
                tee -a "\$LOG_DIR/gif-optimization.log"
            ;;
        "svg")
            log_message "Optimizando SVG con \$WORKERS workers paralelos..."
            find "\$input_dir" -name "*.svg" | \\
            parallel -j\$WORKERS --progress \\
                'svgo --input="{}" --output="{}" && echo "✓ {}"' 2>&1 | \\
                tee -a "\$LOG_DIR/svg-optimization.log"
            ;;
        "all")
            log_message "Optimizando TODOS los formatos con procesamiento masivo..."
            echo "🚀 Iniciando optimización masiva paralela..."
            
            # Procesar todos los formatos en paralelo con jobs separados
            {
                optimize_ultra_parallel "\$input_dir" "\$output_dir" "jpg" &
                optimize_ultra_parallel "\$input_dir" "\$output_dir" "png" &
                optimize_ultra_parallel "\$input_dir" "\$output_dir" "gif" &
                optimize_ultra_parallel "\$input_dir" "\$output_dir" "svg" &
                wait
                optimize_ultra_parallel "\$input_dir" "\$output_dir" "webp" &
                optimize_ultra_parallel "\$input_dir" "\$output_dir" "avif" &
                wait
            }
            log_message "✅ Optimización masiva completada"
            ;;
        *)
            log_error "Formato no soportado: \$format"
            echo "Formatos disponibles: jpg, png, webp, avif, gif, svg, all"
            return 1
            ;;
    esac
    
    # Estadísticas finales
    local total_files=\$(find "\$input_dir" -type f | wc -l)
    local processed_files=\$(find "\$output_dir" -type f | wc -l)
    log_message "📊 Estadísticas: \$processed_files/\$total_files archivos procesados"
}

# Ejecutar optimización
optimize_ultra_parallel "\$@"
EOF
    
    chmod +x /usr/local/bin/optimize-ultra
    
    # Script de optimización en lote ultra rápido
    cat << EOF > /usr/local/bin/batch-optimize-ultra
#!/bin/bash

# Configuración
BATCH_SIZE=50
WORKERS=$OPTIMAL_PARALLEL_JOBS
INPUT_DIR="/var/www/image-processor/uploads/pending"
OUTPUT_DIR="/var/www/image-processor/processed"
TEMP_DIR="/var/www/image-processor/temp/batch"

# Función de procesamiento en lotes
process_batch() {
    local batch_dir="\$1"
    local batch_id="\$2"
    
    echo "🔄 Procesando lote \$batch_id con \$WORKERS workers..."
    
    # Crear directorio temporal para este lote
    mkdir -p "\$TEMP_DIR/\$batch_id"
    
    # Optimizar todo el lote en paralelo
    optimize-ultra "\$batch_dir" "\$OUTPUT_DIR" "all"
    
    # Limpiar
    rm -rf "\$TEMP_DIR/\$batch_id"
    
    echo "✅ Lote \$batch_id completado"
}

# Procesar archivos en lotes
if [ -d "\$INPUT_DIR" ]; then
    cd "\$INPUT_DIR"
    
    # Crear lotes de archivos
    find . -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.svg" | \\
    split -l \$BATCH_SIZE --numeric-suffixes=1 --suffix-length=3 - batch-
    
    # Procesar cada lote en paralelo
    for batch_file in batch-*; do
        if [ -f "\$batch_file" ]; then
            batch_id=\$(basename "\$batch_file")
            mkdir -p "\$TEMP_DIR/\$batch_id"
            
            # Mover archivos del lote al directorio temporal
            while read -r file; do
                [ -f "\$file" ] && cp "\$file" "\$TEMP_DIR/\$batch_id/"
            done < "\$batch_file"
            
            # Procesar lote
            process_batch "\$TEMP_DIR/\$batch_id" "\$batch_id" &
            
            rm "\$batch_file"
        fi
    done
    
    # Esperar a que terminen todos los lotes
    wait
    
    echo "🎉 ¡Procesamiento en lotes completado!"
else
    echo "❌ Directorio de entrada no encontrado: \$INPUT_DIR"
fi
EOF
    
    chmod +x /usr/local/bin/batch-optimize-ultra
    
    # Script de monitoreo de rendimiento
    cat << EOF > /usr/local/bin/monitor-optimization
#!/bin/bash

echo "========================================="
echo "MONITOR DE OPTIMIZACIÓN ULTRA"
echo "========================================="
echo ""

# Estadísticas del sistema
echo "🖥️  SISTEMA:"
echo "   CPU Cores: $CPU_CORES"
echo "   RAM Total: ${TOTAL_RAM_GB}GB"
echo "   Workers Configurados: $OPTIMAL_PARALLEL_JOBS"
echo ""

# Estadísticas de archivos
echo "📁 ARCHIVOS:"
echo "   Pendientes: \$(find /var/www/image-processor/uploads/pending -type f 2>/dev/null | wc -l)"
echo "   Procesados: \$(find /var/www/image-processor/processed -type f 2>/dev/null | wc -l)"
echo "   En caché: \$(find /var/www/image-processor/cache -type f 2>/dev/null | wc -l)"
echo ""

# Estadísticas de rendimiento
echo "⚡ RENDIMIENTO:"
echo "   Procesos activos: \$(ps aux | grep -E '(jpegoptim|optipng|cwebp|avifenc|gifsicle|svgo)' | grep -v grep | wc -l)"
echo "   Uso de CPU: \$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "   Uso de RAM: \$(free | grep Mem | awk '{printf \"%.1f%%\", \$3/\$2 * 100.0}')"
echo ""

# Estadísticas de Redis
echo "🔴 REDIS:"
if command -v redis-cli >/dev/null 2>&1; then
    echo "   Conexiones activas: \$(redis-cli info clients | grep connected_clients | cut -d: -f2 | tr -d '\r')"
    echo "   Memoria usada: \$(redis-cli info memory | grep used_memory_human | cut -d: -f2 | tr -d '\r')"
    echo "   Items en cola: \$(redis-cli llen image_queue 2>/dev/null || echo 0)"
else
    echo "   Redis no disponible"
fi
echo ""

# Logs recientes
echo "📋 ACTIVIDAD RECIENTE:"
tail -5 /var/www/image-processor/logs/optimization.log 2>/dev/null || echo "   No hay logs disponibles"
echo ""

echo "========================================="
EOF
    
    chmod +x /usr/local/bin/monitor-optimization
    
    print_success "Scripts de optimización paralela masiva creados"
}

#################################################################################
# SCRIPT DE VERIFICACIÓN ULTRA COMPLETO
#################################################################################

create_verification_script_ultra() {
    print_ultra "========================================="
    print_ultra "SCRIPT DE VERIFICACIÓN ULTRA COMPLETO"
    print_ultra "========================================="
    
    cat << 'EOF' > /usr/local/bin/verify-ultra
#!/bin/bash

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${WHITE}===============================================${NC}"
echo -e "${WHITE}VERIFICACIÓN ULTRA COMPLETA - SERVIDOR v3.0${NC}"
echo -e "${WHITE}===============================================${NC}"
echo ""

# Contadores
TOTAL=0
INSTALLED=0
SERVICES_TOTAL=0
SERVICES_RUNNING=0

# Función para verificar comando
check_command() {
    ((TOTAL++))
    if command -v $1 &> /dev/null; then
        local version_cmd="$2"
        if [ -n "$version_cmd" ]; then
            VERSION=$($1 $version_cmd 2>&1 | head -n1 | cut -d' ' -f2-20 | head -c50)
            echo -e "${GREEN}✓${NC} $1 - ${VERSION}"
        else
            echo -e "${GREEN}✓${NC} $1 instalado"
        fi
        ((INSTALLED++))
        return 0
    else
        echo -e "${RED}✗${NC} $1 NO encontrado"
        return 1
    fi
}

# Función para verificar servicio con puerto opcional
check_service() {
    local service=$1
    local port=$2
    ((SERVICES_TOTAL++))
    
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✓${NC} $service activo"
        ((SERVICES_RUNNING++))
        
        # Verificar puerto si se proporciona
        if [ ! -z "$port" ]; then
            if netstat -tulpn 2>/dev/null | grep -q ":$port "; then
                echo -e "  ${GREEN}→${NC} Puerto $port abierto"
            else
                echo -e "  ${YELLOW}→${NC} Puerto $port no detectado"
            fi
        fi
        return 0
    else
        echo -e "${RED}✗${NC} $service inactivo"
        echo -e "  ${YELLOW}→${NC} Estado: $(systemctl is-active $service 2>/dev/null)"
        return 1
    fi
}

# Información del sistema
echo -e "${PURPLE}[INFORMACIÓN DEL SISTEMA]${NC}"
echo "  CPU Cores: $(nproc)"
echo "  RAM Total: $(free -h | awk 'NR==2{print $2}')"
echo "  RAM Libre: $(free -h | awk 'NR==2{print $7}')"
echo "  Espacio Disco: $(df -h / | awk 'NR==2{print $4}') libre"
echo "  Kernel: $(uname -r)"
echo "  Ubuntu: $(lsb_release -r | awk '{print $2}')"
echo ""

# Verificar herramientas JPEG
echo -e "${BLUE}[HERRAMIENTAS JPEG]${NC}"
check_command jpegoptim --version
check_command cjpeg
check_command djpeg  
check_command jpegtran
check_command mozjpeg-cjpeg
echo ""

# Verificar herramientas PNG
echo -e "${BLUE}[HERRAMIENTAS PNG]${NC}"
check_command optipng --version
check_command pngquant --version
check_command pngcrush -version
check_command oxipng --version
echo ""

# Verificar herramientas WebP
echo -e "${BLUE}[HERRAMIENTAS WEBP]${NC}"
check_command cwebp
check_command dwebp
check_command gif2webp
echo ""

# Verificar herramientas AVIF
echo -e "${BLUE}[HERRAMIENTAS AVIF]${NC}"
check_command avifenc
check_command avifdec
echo ""

# Verificar herramientas adicionales
echo -e "${BLUE}[HERRAMIENTAS ADICIONALES]${NC}"
check_command gifsicle --version
check_command svgo --version
check_command tiffcp
check_command parallel --version
echo ""

# Verificar suites de procesamiento
echo -e "${BLUE}[SUITES DE PROCESAMIENTO]${NC}"
check_command convert --version
check_command identify --version  
check_command gm version
check_command vips --version
check_command vipsthumbnail --version
echo ""

# Verificar servicios con puertos
echo -e "${PURPLE}[SERVICIOS DEL SISTEMA]${NC}"
check_service nginx 80
check_service php8.3-fpm
check_service redis-server 6379
check_service netdata 19999
echo ""

# Verificar Redis específicamente
echo -e "${BLUE}[VALIDACIÓN DE REDIS]${NC}"
if command -v redis-cli &> /dev/null; then
    if redis-cli ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓${NC} Redis respondiendo correctamente"
        REDIS_INFO=$(redis-cli INFO server 2>/dev/null | grep redis_version | cut -d: -f2 | tr -d '\r')
        echo -e "  ${GREEN}→${NC} Version: $REDIS_INFO"
        REDIS_MEM=$(redis-cli CONFIG GET maxmemory 2>/dev/null | tail -1)
        echo -e "  ${GREEN}→${NC} Memoria máxima: ${REDIS_MEM}bytes"
    else
        echo -e "${RED}✗${NC} Redis no responde a ping"
        echo -e "  ${YELLOW}→${NC} Verificar con: sudo systemctl status redis-server"
        echo -e "  ${YELLOW}→${NC} Logs: sudo journalctl -xeu redis-server"
    fi
else
    echo -e "${YELLOW}⚠${NC} redis-cli no disponible"
fi
echo ""

# Verificar puertos
echo -e "${PURPLE}[PUERTOS DE RED]${NC}"
netstat -tulpn 2>/dev/null | grep -q ":80 " && echo -e "${GREEN}✓${NC} Puerto 80 (HTTP) activo" || echo -e "${YELLOW}⚠${NC} Puerto 80 no detectado"
netstat -tulpn 2>/dev/null | grep -q ":443 " && echo -e "${GREEN}✓${NC} Puerto 443 (HTTPS) activo" || echo -e "${YELLOW}⚠${NC} Puerto 443 no detectado" 
netstat -tulpn 2>/dev/null | grep -q ":6379 " && echo -e "${GREEN}✓${NC} Puerto 6379 (Redis) activo" || echo -e "${YELLOW}⚠${NC} Puerto 6379 no detectado"
netstat -tulpn 2>/dev/null | grep -q ":19999 " && echo -e "${GREEN}✓${NC} Puerto 19999 (Netdata) activo" || echo -e "${YELLOW}⚠${NC} Puerto 19999 no detectado"
echo ""

# Verificar estructura de directorios
echo -e "${PURPLE}[ESTRUCTURA DE DIRECTORIOS]${NC}"
[ -d "/var/www/image-processor" ] && echo -e "${GREEN}✓${NC} Directorio principal creado" || echo -e "${RED}✗${NC} Directorio principal no encontrado"
[ -d "/var/www/image-processor/uploads" ] && echo -e "${GREEN}✓${NC} Directorio uploads" || echo -e "${RED}✗${NC} Directorio uploads"
[ -d "/var/www/image-processor/processed" ] && echo -e "${GREEN}✓${NC} Directorio processed" || echo -e "${RED}✗${NC} Directorio processed"
[ -d "/var/www/image-processor/temp" ] && echo -e "${GREEN}✓${NC} Directorio temp" || echo -e "${RED}✗${NC} Directorio temp"
[ -d "/var/www/image-processor/logs" ] && echo -e "${GREEN}✓${NC} Directorio logs" || echo -e "${RED}✗${NC} Directorio logs"
echo ""

# Verificar scripts creados
echo -e "${PURPLE}[SCRIPTS ULTRA]${NC}"
[ -x "/usr/local/bin/optimize-ultra" ] && echo -e "${GREEN}✓${NC} optimize-ultra" || echo -e "${RED}✗${NC} optimize-ultra"
[ -x "/usr/local/bin/batch-optimize-ultra" ] && echo -e "${GREEN}✓${NC} batch-optimize-ultra" || echo -e "${RED}✗${NC} batch-optimize-ultra"
[ -x "/usr/local/bin/monitor-optimization" ] && echo -e "${GREEN}✓${NC} monitor-optimization" || echo -e "${RED}✗${NC} monitor-optimization"
[ -x "/usr/local/bin/ssl-renew" ] && echo -e "${GREEN}✓${NC} ssl-renew (renovación automática)" || echo -e "${YELLOW}⚠${NC} ssl-renew (no configurado)"
echo ""

# Verificar SSL y renovación automática
echo -e "${PURPLE}[SSL Y CERTIFICADOS]${NC}"

# Primero verificar si hay SSL activo en el puerto 443
SSL_ACTIVE=false
if netstat -tulpn 2>/dev/null | grep -q ":443 "; then
    SSL_ACTIVE=true
    echo -e "${GREEN}✓${NC} Puerto 443 (HTTPS) activo - SSL funcionando"
fi

# Verificar certificados con certbot
if command -v certbot >/dev/null 2>&1; then
    # Intentar con sudo si es necesario para ver certificados
    cert_output=$(sudo certbot certificates 2>/dev/null || certbot certificates 2>/dev/null)
    cert_count=$(echo "$cert_output" | grep -c "Certificate Name" 2>/dev/null || echo "0")
    
    if [ $cert_count -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Certificados Let's Encrypt: $cert_count configurados"
        # Mostrar dominios con certificados
        echo "$cert_output" | grep "Domains:" | head -1 | sed 's/^/  /' 2>/dev/null || true
        # Mostrar fecha de expiración
        echo "$cert_output" | grep "Expiry Date:" | head -1 | sed 's/^/  /' 2>/dev/null || true
    elif [ "$SSL_ACTIVE" = true ]; then
        echo -e "${YELLOW}⚠${NC} SSL activo pero no gestionado por Certbot"
        echo "  (Puede ser certificado personalizado o de otro proveedor)"
    else
        echo -e "${YELLOW}⚠${NC} No se detectaron certificados SSL configurados"
    fi
    
    # Verificar renovación automática
    if crontab -l 2>/dev/null | grep -q "ssl-renew\|certbot"; then
        echo -e "${GREEN}✓${NC} Renovación automática: cron configurado"
    elif [ -f /etc/cron.d/certbot ]; then
        echo -e "${GREEN}✓${NC} Renovación automática: certbot cron detectado"
    else
        echo -e "${YELLOW}⚠${NC} Renovación automática: no detectada"
    fi
    
    if systemctl is-enabled ssl-renew.timer >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Renovación automática: systemd timer activo"
    else
            echo -e "${YELLOW}⚠${NC} Renovación automática: systemd timer no activo"
        fi
    else
        echo -e "${YELLOW}⚠${NC} No se detectaron certificados SSL"
    fi
else
    echo -e "${RED}✗${NC} Certbot no instalado"
fi
echo ""

# Estadísticas finales
echo -e "${WHITE}===============================================${NC}"
echo -e "Herramientas instaladas: ${GREEN}$INSTALLED${NC}/$TOTAL"
echo -e "Servicios activos: ${GREEN}$SERVICES_RUNNING${NC}/$SERVICES_TOTAL"

# Calcular porcentajes
TOOLS_PERCENTAGE=$((INSTALLED * 100 / TOTAL))
SERVICES_PERCENTAGE=$((SERVICES_RUNNING * 100 / SERVICES_TOTAL))

# Estado general
if [ $TOOLS_PERCENTAGE -ge 90 ] && [ $SERVICES_PERCENTAGE -ge 75 ]; then
    echo -e "Estado general: ${GREEN}EXCELENTE - LISTO PARA PRODUCCIÓN MASIVA${NC}"
    echo -e "Capacidad estimada: ${WHITE}$(($(nproc) * 1000))+ imágenes/día${NC}"
elif [ $TOOLS_PERCENTAGE -ge 75 ] && [ $SERVICES_PERCENTAGE -ge 50 ]; then
    echo -e "Estado general: ${YELLOW}BUENO - SISTEMA FUNCIONAL${NC}"
    echo -e "Capacidad estimada: ${WHITE}$(($(nproc) * 500))+ imágenes/día${NC}"
else
    echo -e "Estado general: ${RED}REQUIERE ATENCIÓN${NC}"
    echo -e "Revisar logs: ${YELLOW}/var/log/image-server-ultra-setup.log${NC}"
fi

echo -e "${WHITE}===============================================${NC}"
echo ""
echo -e "${YELLOW}Comandos disponibles:${NC}"
echo "  optimize-ultra <input> <output> <format>    - Optimización paralela"
echo "  batch-optimize-ultra                        - Procesamiento en lotes"
echo "  monitor-optimization                        - Monitor de rendimiento"
echo "  verify-ultra                                - Esta verificación"
echo "  ssl-renew                                   - Renovar SSL manualmente"
echo ""
EOF
    
    chmod +x /usr/local/bin/verify-ultra
    print_success "Script de verificación ultra completo creado"
}

#################################################################################
# BENCHMARK Y PRUEBAS DE RENDIMIENTO ULTRA
#################################################################################

create_benchmark_ultra() {
    print_ultra "========================================="
    print_ultra "BENCHMARK Y PRUEBAS ULTRA"
    print_ultra "========================================="
    
    cat << EOF > /usr/local/bin/benchmark-ultra
#!/bin/bash

# Configuración del benchmark
WORKERS=$OPTIMAL_PARALLEL_JOBS
TEST_IMAGES=20
TEMP_DIR="/tmp/benchmark-ultra"
LOG_FILE="/var/www/image-processor/logs/benchmark.log"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "\${WHITE}================================================="
echo -e "BENCHMARK ULTRA - SERVIDOR DE OPTIMIZACIÓN v3.0"
echo -e "=================================================\${NC}"
echo ""

# Crear directorio de prueba
mkdir -p "\$TEMP_DIR"
cd "\$TEMP_DIR"

# Información del sistema
echo -e "\${CYAN}[CONFIGURACIÓN DEL SISTEMA]\${NC}"
echo "  CPU Cores: $CPU_CORES"
echo "  Workers Paralelos: $WORKERS"
echo "  RAM Total: ${TOTAL_RAM_GB}GB"
echo "  VPS Tier: $VPS_TIER"
echo "  Imágenes de prueba: \$TEST_IMAGES"
echo ""

# Crear imágenes de prueba
echo -e "\${YELLOW}Generando imágenes de prueba...\${NC}"
for i in \$(seq 1 \$TEST_IMAGES); do
    convert -size 1920x1080 xc:red "test_\$i.jpg" 2>/dev/null
    convert -size 1920x1080 xc:blue "test_\$i.png" 2>/dev/null
done

echo "✓ \$TEST_IMAGES imágenes generadas"
echo ""

# Función de benchmark
run_benchmark() {
    local format="\$1"
    local description="\$2"
    local command="\$3"
    
    echo -e "\${CYAN}[BENCHMARK \$format]\${NC}"
    echo "Descripción: \$description"
    echo "Comando: \$command"
    
    # Medir tiempo y rendimiento
    start_time=\$(date +%s.%N)
    start_cpu=\$(cat /proc/stat | grep '^cpu ' | awk '{print \$2+\$3+\$4+\$5+\$6+\$7+\$8}')
    
    # Ejecutar comando
    eval "\$command" >/dev/null 2>&1
    local exit_code=\$?
    
    end_time=\$(date +%s.%N)
    end_cpu=\$(cat /proc/stat | grep '^cpu ' | awk '{print \$2+\$3+\$4+\$5+\$6+\$7+\$8}')
    
    # Calcular estadísticas
    duration=\$(echo "\$end_time - \$start_time" | bc -l)
    cpu_usage=\$(echo "scale=2; (\$end_cpu - \$start_cpu) / (\$duration * 100)" | bc -l)
    
    if [ \$exit_code -eq 0 ]; then
        local rate=\$(echo "scale=2; \$TEST_IMAGES / \$duration" | bc -l)
        local daily_capacity=\$(echo "scale=0; \$rate * 86400" | bc -l)
        
        echo -e "  Estado: \${GREEN}✓ EXITOSO\${NC}"
        echo "  Tiempo: \${duration}s"
        echo "  Velocidad: \${rate} imágenes/segundo"
        echo "  Capacidad diaria estimada: \${daily_capacity} imágenes"
        echo "  Uso de CPU: \${cpu_usage}%"
    else
        echo -e "  Estado: \${RED}✗ FALLÓ\${NC}"
    fi
    echo ""
    
    # Log results
    echo "\$(date): \$format - \$duration"s - \$rate" img/s - \$daily_capacity" daily" >> "\$LOG_FILE"
}

# Ejecutar benchmarks
echo -e "\${WHITE}INICIANDO BENCHMARKS...\${NC}"
echo ""

# JPEG Optimization
run_benchmark "JPEG" "Optimización paralela con jpegoptim" \\
    "find . -name 'test_*.jpg' | parallel -j$WORKERS jpegoptim --strip-all {}"

# PNG Optimization  
run_benchmark "PNG" "Optimización paralela con optipng + pngquant" \\
    "find . -name 'test_*.png' | parallel -j$WORKERS 'optipng -o2 {} && pngquant --ext .png --force 256 {} 2>/dev/null'"

# WebP Creation
run_benchmark "WEBP" "Conversión paralela a WebP" \\
    "find . -name 'test_*.jpg' | parallel -j$WORKERS 'cwebp -q 85 {} -o {.}.webp'"

# AVIF Creation (si está disponible)
if command -v avifenc >/dev/null 2>&1; then
    run_benchmark "AVIF" "Conversión paralela a AVIF" \\
        "find . -name 'test_*.jpg' | parallel -j$WORKERS 'avifenc {} {.}.avif --min 20 --max 25 2>/dev/null'"
fi

# Benchmark combinado (todos los formatos)
echo -e "\${CYAN}[BENCHMARK COMBINADO]\${NC}"
echo "Procesando todos los formatos simultáneamente..."

start_time=\$(date +%s.%N)
{
    find . -name 'test_*.jpg' | parallel -j\$((WORKERS/2)) jpegoptim --strip-all {} &
    find . -name 'test_*.png' | parallel -j\$((WORKERS/2)) 'optipng -o2 {} && pngquant --ext .png --force 256 {} 2>/dev/null' &
    wait
}
end_time=\$(date +%s.%N)

combined_duration=\$(echo "\$end_time - \$start_time" | bc -l)
combined_rate=\$(echo "scale=2; (\$TEST_IMAGES * 2) / \$combined_duration" | bc -l)
combined_daily=\$(echo "scale=0; \$combined_rate * 86400" | bc -l)

echo -e "  Estado: \${GREEN}✓ COMPLETADO\${NC}"
echo "  Tiempo total: \${combined_duration}s" 
echo "  Velocidad combinada: \${combined_rate} imágenes/segundo"
echo "  Capacidad diaria estimada: \${combined_daily} imágenes"
echo ""

# Resumen final
echo -e "\${WHITE}================================================="
echo -e "RESUMEN DEL BENCHMARK"
echo -e "=================================================\${NC}"
echo -e "Configuración: \${GREEN}$CPU_CORES cores, $WORKERS workers paralelos\${NC}"
echo -e "Rendimiento combinado: \${GREEN}\${combined_rate} imágenes/segundo\${NC}"
echo -e "Capacidad diaria estimada: \${GREEN}\${combined_daily} imágenes\${NC}"
echo ""

# Recomendaciones
if (( \$(echo "\$combined_rate > 5" | bc -l) )); then
    echo -e "\${GREEN}🚀 EXCELENTE: Tu servidor está listo para alta carga\${NC}"
elif (( \$(echo "\$combined_rate > 2" | bc -l) )); then
    echo -e "\${YELLOW}⚡ BUENO: Rendimiento sólido para carga media\${NC}"
else
    echo -e "\${YELLOW}⚠️  BÁSICO: Considera aumentar recursos para mayor carga\${NC}"
fi

echo ""
echo -e "Logs guardados en: \${CYAN}\$LOG_FILE\${NC}"
echo -e "\${WHITE}=================================================\${NC}"

# Limpiar archivos de prueba
rm -rf "\$TEMP_DIR"
EOF
    
    chmod +x /usr/local/bin/benchmark-ultra
    print_success "Script de benchmark ultra creado"
}

#################################################################################
# OPTIMIZACIONES EXTREMAS DEL KERNEL
#################################################################################

optimize_kernel_extreme() {
    print_ultra "========================================="
    print_ultra "OPTIMIZACIONES EXTREMAS DEL KERNEL"
    print_ultra "========================================="
    
    print_message "Aplicando optimizaciones extremas del kernel..."
    
    # Backup del archivo original
    cp /etc/sysctl.conf /etc/sysctl.conf.backup
    
    cat << EOF >> /etc/sysctl.conf

#################################################################################
# OPTIMIZACIONES ULTRA PARA PROCESAMIENTO MASIVO DE IMÁGENES v3.0
#################################################################################

# Network performance ultra
net.core.rmem_max = 268435456
net.core.wmem_max = 268435456
net.core.rmem_default = 262144
net.core.wmem_default = 262144
net.ipv4.tcp_rmem = 4096 87380 268435456
net.ipv4.tcp_wmem = 4096 65536 268435456
net.core.netdev_max_backlog = 30000
net.core.netdev_budget = 600
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15

# File system performance ultra
fs.file-max = 2097152
fs.nr_open = 2097152
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 256

# Memory management ultra
vm.max_map_count = 655360
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
vm.dirty_writeback_centisecs = 100
vm.dirty_expire_centisecs = 300
vm.vfs_cache_pressure = 50
vm.min_free_kbytes = $((TOTAL_RAM_MB * 64))

# Process scheduling ultra
kernel.sched_autogroup_enabled = 0
kernel.sched_migration_cost_ns = 5000000
kernel.sched_min_granularity_ns = 10000000
kernel.sched_wakeup_granularity_ns = 15000000

# Swapping optimizations
vm.swappiness = $SWAPPINESS
vm.overcommit_memory = 1
vm.overcommit_ratio = 80

# I/O scheduling ultra
vm.zone_reclaim_mode = 0
vm.page-cluster = 3

# Security optimizations that don't hurt performance
kernel.kptr_restrict = 1
kernel.dmesg_restrict = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Connection tracking optimizations
net.netfilter.nf_conntrack_max = 1000000
net.netfilter.nf_conntrack_tcp_timeout_established = 600
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 1
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 5
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 5
EOF
    
    # Aplicar configuraciones inmediatamente
    sysctl -p >> $LOG_FILE 2>&1
    
    # Configurar límites extremos en systemd
    mkdir -p /etc/systemd/system.conf.d
    cat << EOF > /etc/systemd/system.conf.d/limits-ultra.conf
[Manager]
DefaultLimitNOFILE=2097152
DefaultLimitNPROC=262144
DefaultLimitMEMLOCK=infinity
DefaultLimitCORE=infinity
EOF
    
    # Configurar grub para optimizaciones de arranque
    if [ -f /etc/default/grub ]; then
        cp /etc/default/grub /etc/default/grub.backup
        
        # Agregar parámetros de optimización al kernel
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& transparent_hugepage=madvise numa_balancing=disable elevator=mq-deadline/' /etc/default/grub
        
        update-grub >> $LOG_FILE 2>&1
    fi
    
    systemctl daemon-reload
    print_success "Optimizaciones extremas del kernel aplicadas"
}

#################################################################################
# LIMPIEZA Y MANTENIMIENTO AUTOMÁTICO
#################################################################################

create_maintenance_system() {
    print_ultra "========================================="
    print_ultra "SISTEMA DE MANTENIMIENTO AUTOMÁTICO"
    print_ultra "========================================="
    
    # Script de limpieza ultra
    cat << 'EOF' > /usr/local/bin/maintenance-ultra
#!/bin/bash

# Configuración
LOG_DIR="/var/www/image-processor/logs"
TEMP_DIR="/var/www/image-processor/temp"
CACHE_DIR="/var/www/image-processor/cache"
BACKUP_DIR="/var/www/image-processor/backup"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_DIR/maintenance.log"
    echo "$1"
}

log_message "🧹 Iniciando mantenimiento automático..."

# Limpiar archivos temporales antiguos
log_message "Limpiando archivos temporales..."
find "$TEMP_DIR" -type f -mtime +1 -delete 2>/dev/null
find "$TEMP_DIR" -type d -empty -delete 2>/dev/null

# Limpiar cache antiguo
log_message "Limpiando cache antiguo..."
find "$CACHE_DIR" -type f -mtime +7 -delete 2>/dev/null

# Rotar logs
log_message "Rotando logs..."
for log_file in "$LOG_DIR"/*.log; do
    if [ -f "$log_file" ] && [ $(stat -c%s "$log_file") -gt 10485760 ]; then  # 10MB
        mv "$log_file" "${log_file}.old"
        touch "$log_file"
        chown www-data:www-data "$log_file"
    fi
done

# Limpiar logs del sistema antiguos
journalctl --vacuum-time=7d >/dev/null 2>&1

# Optimizar Redis
log_message "Optimizando Redis..."
redis-cli BGSAVE >/dev/null 2>&1

# Verificar estado SSL y certificados
log_message "Verificando certificados SSL..."
if command -v certbot >/dev/null 2>&1; then
    cert_status=$(certbot certificates 2>/dev/null | grep "VALID" | wc -l)
    if [ $cert_status -gt 0 ]; then
        log_message "✅ Certificados SSL válidos: $cert_status"
    else
        log_message "⚠️  Verificar certificados SSL manualmente"
    fi
fi

# Estadísticas de limpieza
temp_freed=$(du -sh "$TEMP_DIR" 2>/dev/null | awk '{print $1}')
cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | awk '{print $1}')

log_message "✅ Mantenimiento completado"
log_message "📊 Espacio temp: $temp_freed, Cache: $cache_size"
EOF
    
    chmod +x /usr/local/bin/maintenance-ultra
    
    # Configurar logrotate
    cat << EOF > /etc/logrotate.d/image-processor
/var/www/image-processor/logs/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload nginx > /dev/null 2>&1 || true
        systemctl reload php8.3-fpm > /dev/null 2>&1 || true
    endscript
}
EOF
    
    # Configurar cron jobs para mantenimiento automático
    cat << EOF > /etc/cron.d/image-processor-maintenance
# Mantenimiento del servidor de imágenes ultra
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Limpieza cada 4 horas
0 */4 * * * root /usr/local/bin/maintenance-ultra >/dev/null 2>&1

# Backup de configuración diario  
0 2 * * * root rsync -a /etc/nginx/ /var/www/image-processor/backup/nginx-$(date +\%Y\%m\%d)/ >/dev/null 2>&1

# Estadísticas semanales
0 3 * * 1 root /usr/local/bin/monitor-optimization > /var/www/image-processor/logs/weekly-stats.log

# Limpieza profunda mensual
0 1 1 * * root apt autoremove -y && apt autoclean >/dev/null 2>&1
EOF
    
    print_success "Sistema de mantenimiento automático configurado"
}

#################################################################################
# RESUMEN FINAL ULTRA
#################################################################################

# Validación final de servicios críticos
validate_critical_services() {
    print_ultra "=================================================="
    print_ultra "VALIDACIÓN FINAL DE SERVICIOS"
    print_ultra "=================================================="
    
    local all_ok=true
    
    # Verificar Nginx
    if ! systemctl is-active --quiet nginx; then
        print_warning "Nginx no está activo. Intentando iniciar..."
        systemctl start nginx >> $LOG_FILE 2>&1 || all_ok=false
    fi
    
    # Verificar PHP-FPM
    if ! systemctl is-active --quiet php8.3-fpm; then
        print_warning "PHP-FPM no está activo. Intentando iniciar..."
        systemctl start php8.3-fpm >> $LOG_FILE 2>&1 || all_ok=false
    fi
    
    # Verificar Redis con reintentos (máximo 3 intentos)
    local redis_ok=false
    local max_redis_attempts=3
    local redis_attempt=1
    
    while [ $redis_attempt -le $max_redis_attempts ]; do
        if systemctl is-active --quiet redis-server; then
            redis_ok=true
            break
        else
            if [ $redis_attempt -lt $max_redis_attempts ]; then
                print_message "Intento $redis_attempt/$max_redis_attempts: Iniciando Redis..."
                systemctl restart redis-server >> $LOG_FILE 2>&1
                sleep 3
                ((redis_attempt++))
            else
                # Último intento fallido, salir del bucle
                break
            fi
        fi
    done
    
    if [ "$redis_ok" = false ]; then
        print_warning "Redis requiere configuración manual"
        all_ok=false
    fi
    
    # Verificar Netdata
    if ! systemctl is-active --quiet netdata; then
        print_warning "Netdata no está activo. Intentando iniciar..."
        systemctl start netdata >> $LOG_FILE 2>&1 || true
    fi
    
    if [ "$all_ok" = true ]; then
        print_success "Todos los servicios críticos están funcionando"
    else
        print_warning "Algunos servicios requieren atención manual"
    fi
    
    echo ""
}

show_summary_ultra() {
    print_ultra "=================================================="
    print_ultra "INSTALACIÓN ULTRA COMPLETADA CON ÉXITO"
    print_ultra "=================================================="
    
    echo ""
    echo -e "${CYAN}🎉 RESUMEN DE LA INSTALACIÓN ULTRA v3.0:${NC}"
    echo "════════════════════════════════════════════════"
    echo "✅ Sistema ultra optimizado para $VPS_TIER"
    echo "✅ Procesamiento paralelo con $OPTIMAL_PARALLEL_JOBS workers"
    echo "✅ Seguridad avanzada configurada"
    echo "✅ Nginx ultra optimizado ($OPTIMAL_WORKERS workers)"
    if [ "$INSTALL_SSL" = true ]; then
        echo "✅ SSL configurado para $DOMAIN con renovación automática"
    fi
    echo "✅ Todas las librerías de imágenes ultra completas"
    echo "✅ Herramientas de optimización paralela masiva:"
    echo "  📸 JPEG: jpegoptim, mozjpeg (compilado)"
    echo "  🎨 PNG: optipng, pngquant, oxipng, pngcrush"
    echo "  🌐 WebP: cwebp, dwebp, gif2webp"
    echo "  🚀 AVIF: avifenc optimizado con todos los codecs"
    echo "  🎬 GIF: gifsicle optimizado"
    echo "  🎯 SVG: svgo con Node.js"
    echo "  📄 TIFF: herramientas completas"
    echo "✅ Suites completas: ImageMagick + GraphicsMagick + VIPS"
    echo "✅ PHP 8.3 ultra optimizado ($PM_MAX_CHILDREN workers)"
    echo "✅ Redis ultra para colas masivas (${REDIS_MEMORY}MB)"
    echo "✅ Netdata para monitoreo en tiempo real"
    echo "✅ Optimizaciones extremas del kernel aplicadas"
    echo "✅ Sistema de mantenimiento automático"
    echo "✅ Renovación automática SSL (cron + systemd timer)"
    echo ""
    
    echo -e "${WHITE}🚀 COMANDOS ULTRA DISPONIBLES:${NC}"
    echo "──────────────────────────────────────────────"
    echo "• verify-ultra                    - Verificación completa del sistema"
    echo "• optimize-ultra <dir> <out> <fmt> - Optimización paralela masiva"
    echo "• batch-optimize-ultra            - Procesamiento en lotes ultra rápido"
    echo "• monitor-optimization            - Monitor de rendimiento en tiempo real"
    echo "• benchmark-ultra                 - Benchmark completo de rendimiento"
    echo "• maintenance-ultra               - Limpieza y mantenimiento manual"
    echo "• ssl-renew                       - Renovación manual SSL"
    echo ""
    
    echo -e "${YELLOW}💡 EJEMPLOS DE USO ULTRA:${NC}"
    echo "─────────────────────────────────────────"
    echo "# Optimizar todas las imágenes en paralelo:"
    echo "optimize-ultra /uploads /processed all"
    echo ""
    echo "# Procesar lotes masivos automáticamente:"
    echo "batch-optimize-ultra"
    echo ""
    echo "# Monitorear rendimiento en tiempo real:"
    echo "monitor-optimization"
    echo ""
    
    echo -e "${GREEN}🌐 URLs DE ACCESO:${NC}"
    echo "─────────────────────"
    if [ ! -z "$DOMAIN" ]; then
        echo "• Sitio web: https://$DOMAIN"
        echo "• Monitoreo: http://$DOMAIN:19999"
    else
        SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "tu-servidor")
        echo "• Sitio web: http://$SERVER_IP"
        echo "• Monitoreo: http://$SERVER_IP:19999"
    fi
    echo ""
    
    echo -e "${PURPLE}📊 CAPACIDAD ESTIMADA DEL SERVIDOR:${NC}"
    echo "─────────────────────────────────────────"
    
    # Calcular capacidad estimada basada en hardware
    if [ "$VPS_TIER" = "MICRO (Limitado)" ]; then
        DAILY_CAPACITY="500-1,000"
    elif [ "$VPS_TIER" = "SMALL (Básico)" ]; then
        DAILY_CAPACITY="1,000-3,000"
    elif [ "$VPS_TIER" = "MEDIUM (Estándar)" ]; then
        DAILY_CAPACITY="3,000-8,000"
    elif [ "$VPS_TIER" = "LARGE (Alto rendimiento)" ]; then
        DAILY_CAPACITY="8,000-20,000"
    elif [ "$VPS_TIER" = "XL (Muy alto rendimiento)" ]; then
        DAILY_CAPACITY="20,000-50,000"
    else
        DAILY_CAPACITY="50,000+"
    fi
    
    echo "• Tier del VPS: $VPS_TIER"
    echo "• Workers paralelos: $OPTIMAL_PARALLEL_JOBS"
    echo "• Capacidad diaria estimada: $DAILY_CAPACITY imágenes"
    echo "• Formatos simultáneos: TODOS (JPG, PNG, WebP, AVIF, GIF, SVG)"
    echo ""
    
    echo -e "${BLUE}📁 DIRECTORIOS DE TRABAJO:${NC}"
    echo "─────────────────────────────"
    echo "• /var/www/image-processor/uploads/    - Imágenes originales"
    echo "• /var/www/image-processor/processed/  - Imágenes optimizadas"
    echo "• /var/www/image-processor/temp/       - Archivos temporales"
    echo "• /var/www/image-processor/queue/      - Sistema de colas"
    echo "• /var/www/image-processor/logs/       - Logs del sistema"
    echo "• /var/www/image-processor/cache/      - Cache de resultados"
    echo ""
    
    echo -e "${YELLOW}📋 LOGS Y MONITOREO:${NC}"
    echo "────────────────────────"
    echo "• Instalación: $LOG_FILE"
    echo "• Nginx: /var/log/nginx/"
    echo "• PHP: /var/log/php8.3-fpm.log"
    echo "• Redis: /var/log/redis/"
    echo "• Optimización: /var/www/image-processor/logs/"
    echo "• Netdata: http://tu-servidor:19999"
    echo ""
    
    if [ ! -z "$DOMAIN" ]; then
        print_success "✅ Dominio configurado: $DOMAIN"
        print_success "✅ SSL con renovación automática configurado"
    else
        print_warning "⚠️  Para configurar SSL más tarde:"
        echo "   sudo certbot --nginx -d tu-dominio.com"
        echo "   Después ejecutar: ssl-renew (para probar renovación)"
    fi
    
    echo ""
    print_ultra "🔥 IMPORTANTE - PASOS FINALES:"
    echo -e "${WHITE}1.${NC} ${YELLOW}sudo reboot${NC} (Para aplicar optimizaciones del kernel)"
    echo -e "${WHITE}2.${NC} Después del reinicio: ${YELLOW}verify-ultra${NC}"
    echo -e "${WHITE}3.${NC} Probar rendimiento: ${YELLOW}benchmark-ultra${NC}"
    echo -e "${WHITE}4.${NC} Monitorear: ${YELLOW}monitor-optimization${NC}"
    echo ""
    
    print_ultra "🎊 ¡SERVIDOR ULTRA LISTO PARA PROCESAMIENTO MASIVO!"
    echo ""
    echo -e "${CYAN}Para soporte y actualizaciones, consulta la documentación.${NC}"
    echo -e "${WHITE}=================================================="
    
    # Log final
    echo "=================================================" >> $LOG_FILE
    echo "Instalación ULTRA completada: $(date)" >> $LOG_FILE
    echo "Configuración: $VPS_TIER - $OPTIMAL_PARALLEL_JOBS workers" >> $LOG_FILE
    echo "Capacidad estimada: $DAILY_CAPACITY imágenes/día" >> $LOG_FILE
    echo "=================================================" >> $LOG_FILE
}

#################################################################################
# FUNCIÓN PRINCIPAL ULTRA
#################################################################################


#################################################################################
# API WORDPRESS INTEGRATION - FUNCIONES ADICIONALES
#################################################################################

create_wordpress_api_system() {
    print_ultra "========================================="
    print_ultra "CREANDO SISTEMA API PARA WORDPRESS"
    print_ultra "========================================="
    
    # Crear estructura de directorios para la API
    print_message "Creando estructura de directorios API..."
    mkdir -p /var/www/image-processor/api/{v1,v2,webhooks,auth,docs}
    mkdir -p /var/www/image-processor/api/v1/{optimize,status,batch,health}
    mkdir -p /var/www/image-processor/config/api
    mkdir -p /var/www/image-processor/logs/api
    
    # Crear archivo de configuración de la API (NO TOCA REDIS CONFIG)
    print_message "Creando configuración de la API..."
    cat << 'APICONFIG' > /var/www/image-processor/config/api/config.php
<?php
return [
    'api' => [
        'version' => '1.0',
        'name' => 'Image Optimization API',
        'base_url' => '/api/v1',
        'auth' => [
            'type' => 'api_key',
            'header' => 'X-API-Key',
            'keys_file' => __DIR__ . '/api_keys.json'
        ],
        'cors' => [
            'enabled' => true,
            'allowed_origins' => ['*'],
            'allowed_methods' => ['GET', 'POST', 'OPTIONS'],
            'allowed_headers' => ['Content-Type', 'X-API-Key', 'X-Callback-URL']
        ],
        'limits' => [
            'max_file_size' => 104857600,
            'timeout' => 300
        ]
    ]
];
APICONFIG

    # Sistema de autenticación
    print_message "Creando sistema de autenticación API..."
    cat << 'APIAUTH' > /var/www/image-processor/api/auth/ApiAuth.php
<?php
class ApiAuth {
    private $config;
    private $apiKeys;
    
    public function __construct() {
        $this->config = require __DIR__ . '/../../config/api/config.php';
        $this->loadApiKeys();
    }
    
    private function loadApiKeys() {
        $keysFile = $this->config['api']['auth']['keys_file'];
        if (!file_exists($keysFile)) {
            $this->initializeApiKeys();
        }
        $this->apiKeys = json_decode(file_get_contents($keysFile), true);
    }
    
    private function initializeApiKeys() {
        $initialKeys = [
            'keys' => [
                [
                    'key' => $this->generateApiKey(),
                    'name' => 'master',
                    'created' => date('Y-m-d H:i:s'),
                    'active' => true
                ]
            ]
        ];
        file_put_contents(
            $this->config['api']['auth']['keys_file'],
            json_encode($initialKeys, JSON_PRETTY_PRINT)
        );
    }
    
    public function generateApiKey() {
        return bin2hex(random_bytes(32));
    }
    
    public function validateApiKey($key) {
        foreach ($this->apiKeys['keys'] as $apiKey) {
            if ($apiKey['key'] === $key && $apiKey['active']) {
                return $apiKey;
            }
        }
        return false;
    }
    
    public function authenticate($request) {
        $header = $this->config['api']['auth']['header'];
        $apiKey = $_SERVER['HTTP_' . str_replace('-', '_', strtoupper($header))] ?? null;
        
        if (!$apiKey) {
            return ['success' => false, 'error' => 'API key required'];
        }
        
        $keyData = $this->validateApiKey($apiKey);
        if (!$keyData) {
            return ['success' => false, 'error' => 'Invalid API key'];
        }
        
        return ['success' => true, 'key_data' => $keyData];
    }
    
    public function createApiKey($name = 'wordpress_plugin') {
        $newKey = [
            'key' => $this->generateApiKey(),
            'name' => $name,
            'created' => date('Y-m-d H:i:s'),
            'active' => true
        ];
        
        $this->apiKeys['keys'][] = $newKey;
        file_put_contents(
            $this->config['api']['auth']['keys_file'],
            json_encode($this->apiKeys, JSON_PRETTY_PRINT)
        );
        
        return $newKey;
    }
}
APIAUTH

    # Endpoint principal
    print_message "Creando endpoint principal de la API..."
    cat << 'APIENDPOINT' > /var/www/image-processor/api/v1/index.php
<?php
error_reporting(0);
ini_set('display_errors', 0);

header('Content-Type: application/json');
header('X-Powered-By: Image Optimization API v1.0');

require_once __DIR__ . '/../auth/ApiAuth.php';
$config = require __DIR__ . '/../../config/api/config.php';

// CORS
if ($config['api']['cors']['enabled']) {
    $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, X-API-Key, X-Callback-URL");
    
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }
}

class ImageOptimizationAPI {
    private $auth;
    private $config;
    private $redis;
    
    public function __construct() {
        $this->auth = new ApiAuth();
        $this->config = require __DIR__ . '/../../config/api/config.php';
        // Conectar a Redis existente sin modificar config
        try {
            $this->redis = new Redis();
            $this->redis->connect('127.0.0.1', 6379);
        } catch (Exception $e) {
            $this->redis = null;
        }
    }
    
    public function handleRequest() {
        $path = $_SERVER["PATH_INFO"] ?? $_SERVER["REQUEST_URI"] ?? "/";
        // Eliminar /api/v1 del path si está presente
        $path = preg_replace("#^/api/v1/?#", "", $path);
        // Eliminar query string si existe
        $path = strtok($path, "?");
        $path = trim($path, "/");
        $segments = explode("/", $path);
        
        // Rutas públicas
        $publicRoutes = ['health'];
        
        // Autenticación
        if (!in_array($segments[0] ?? '', $publicRoutes)) {
            $authResult = $this->auth->authenticate($_SERVER);
            if (!$authResult['success']) {
                $this->sendResponse(['error' => $authResult['error']], 401);
                return;
            }
        }
        
        // Router
        switch ($segments[0] ?? '') {
            case 'health':
                $this->handleHealth();
                break;
            case 'optimize':
                $this->handleOptimize();
                break;
            case 'status':
                if (isset($segments[1])) {
                    $this->handleJobStatus($segments[1]);
                }
                break;
            case 'download':
                if (isset($segments[1])) {
                    $this->handleDownload($segments[1]);
                }
                break;
            default:
                $this->sendResponse([
                    'api' => 'Image Optimization API',
                    'version' => '1.0',
                    'endpoints' => [
                        '/health' => 'Check API health',
                        '/optimize' => 'Optimize image',
                        '/status/{job_id}' => 'Check job status',
                        '/download/{job_id}' => 'Download optimized'
                    ]
                ]);
        }
    }
    
    private function handleHealth() {
        $this->sendResponse([
            'status' => 'healthy',
            'timestamp' => time(),
            'version' => '1.0'
        ]);
    }
    
    private function handleOptimize() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->sendResponse(['error' => 'Method not allowed'], 405);
            return;
        }
        
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($input['image'])) {
            $this->sendResponse(['error' => 'Image required'], 400);
            return;
        }
        
        $jobId = uniqid('job_', true);
        $tempFile = "/var/www/image-processor/uploads/pending/{$jobId}_original";
        
        // Procesar imagen
        if (filter_var($input['image'], FILTER_VALIDATE_URL)) {
            $imageData = file_get_contents($input['image']);
        } else {
            $imageData = base64_decode($input['image']);
        }
        
        file_put_contents($tempFile, $imageData);
        
        // Usar Redis si está disponible
        if ($this->redis) {
            $jobData = [
                'id' => $jobId,
                'status' => 'queued',
                'created' => time()
            ];
            $this->redis->setex("imgopt:{$jobId}", 86400, json_encode($jobData));
            $this->redis->lpush("imgopt:queue", json_encode([
                'job_id' => $jobId,
                'file' => $tempFile,
                'options' => $input
            ]));
        }
        
        $this->sendResponse([
            'job_id' => $jobId,
            'status' => 'queued',
            'status_url' => "/api/v1/status/{$jobId}",
            'download_url' => "/api/v1/download/{$jobId}"
        ], 202);
    }
    
    private function handleJobStatus($jobId) {
        if (!$this->redis) {
            $this->sendResponse(['error' => 'Status not available'], 503);
            return;
        }
        
        $jobData = $this->redis->get("imgopt:{$jobId}");
        
        if (!$jobData) {
            $this->sendResponse(['error' => 'Job not found'], 404);
            return;
        }
        
        $job = json_decode($jobData, true);
        
        // Añadir URLs de descarga si está completado
        if ($job['status'] === 'completed') {
            $job['download_url'] = "/api/v1/download/{$jobId}";
        }
        
        $this->sendResponse($job);
    }
    
    private function handleDownload($jobId) {
        // Obtener información del job desde Redis
        if ($this->redis) {
            $jobData = $this->redis->get("imgopt:{$jobId}");
            if ($jobData) {
                $job = json_decode($jobData, true);
                if (isset($job['output_file']) && file_exists($job['output_file'])) {
                    $file = $job['output_file'];
                } else {
                    // Fallback al path antiguo
                    $file = "/var/www/image-processor/processed/{$jobId}_optimized";
                }
            } else {
                $file = "/var/www/image-processor/processed/{$jobId}_optimized";
            }
        } else {
            $file = "/var/www/image-processor/processed/{$jobId}_optimized";
        }
        
        // Buscar también con el patrón correcto
        if (!file_exists($file)) {
            $file = "/var/www/image-processor/processed/{$jobId}_original_optimized.jpg";
        }
        
        if (!file_exists($file)) {
            $this->sendResponse(['error' => 'File not found', 'searched_path' => $file], 404);
            return;
        }
        
        // Detectar tipo de contenido
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file);
        finfo_close($finfo);
        
        // NO enviar JSON headers para descarga de archivos
        header('Content-Type: ' . $mimeType);
        header('Content-Length: ' . filesize($file));
        header('Content-Disposition: attachment; filename="' . basename($file) . '"');
        readfile($file);
        exit;
    }
    
    private function sendResponse($data, $code = 200) {
        http_response_code($code);
        echo json_encode($data);
        exit;
    }
}

try {
    $api = new ImageOptimizationAPI();
    $api->handleRequest();
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Internal server error']);
}
APIENDPOINT

    # Worker de procesamiento
    print_message "Creando worker de procesamiento API..."
    cat << 'APIWORKER' > /var/www/image-processor/scripts/api-worker.php
<?php
// Worker mejorado que usa Redis existente
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

function logMessage($message) {
    $logDir = '/var/www/image-processor/logs/api';
    if (!is_dir($logDir)) {
        mkdir($logDir, 0755, true);
    }
    file_put_contents(
        $logDir . '/worker.log',
        date('[Y-m-d H:i:s] ') . $message . "\n",
        FILE_APPEND
    );
}

logMessage("Worker iniciado (version mejorada v4.1)");

while (true) {
    $job = $redis->brpop('imgopt:queue', 5);
    
    if (!$job) continue;
    
    $jobData = json_decode($job[1], true);
    $jobId = $jobData['job_id'];
    
    logMessage("Procesando job: $jobId");
    
    // Actualizar estado
    $redis->setex("imgopt:{$jobId}", 86400, json_encode([
        'id' => $jobId,
        'status' => 'processing',
        'started' => time()
    ]));
    
    try {
        // Procesar imagen
        $inputFile = $jobData['file'];
        
        // CORREGIDO: Usar directorio /processed/ correcto
        $outputFile = str_replace('/uploads/pending/', '/processed/', $inputFile);
        $outputFile = str_replace('_original', '_original_optimized.jpg', $outputFile);
        
        // Crear directorio si no existe
        $outputDir = dirname($outputFile);
        if (!is_dir($outputDir)) {
            mkdir($outputDir, 0755, true);
        }
        
        logMessage("Input: $inputFile, Output: $outputFile");
        
        // Verificar que el archivo de entrada existe
        if (!file_exists($inputFile)) {
            throw new Exception("Input file not found: $inputFile");
        }
        
        // Optimizar imagen
        $cmd = "jpegoptim --strip-all --max=85 --stdout '$inputFile' > '$outputFile' 2>&1";
        exec($cmd, $output, $returnCode);
        
        if ($returnCode !== 0) {
            // Fallback: simplemente copiar el archivo si jpegoptim falla
            logMessage("jpegoptim falló, copiando archivo: " . implode(' ', $output));
            copy($inputFile, $outputFile);
        }
        
        // WebP si se solicita
        if (!empty($jobData['options']['webp'])) {
            $webpFile = str_replace('.jpg', '.webp', $outputFile);
            exec("cwebp -q 85 '$inputFile' -o '$webpFile' 2>/dev/null");
            logMessage("WebP generado: $webpFile");
        }
        
        // Verificar que el archivo de salida existe
        if (!file_exists($outputFile)) {
            throw new Exception("Output file was not created: $outputFile");
        }
        
        // Actualizar estado con información completa
        $redis->setex("imgopt:{$jobId}", 86400, json_encode([
            'id' => $jobId,
            'status' => 'completed',
            'output_file' => $outputFile,
            'file_size' => filesize($outputFile),
            'completed' => time()
        ]));
        
        logMessage("Job completado: $jobId -> $outputFile");
        
    } catch (Exception $e) {
        logMessage("Error procesando job $jobId: " . $e->getMessage());
        
        // Actualizar estado con error
        $redis->setex("imgopt:{$jobId}", 86400, json_encode([
            'id' => $jobId,
            'status' => 'error',
            'error' => $e->getMessage(),
            'failed' => time()
        ]));
    }
    
    // Callback si está definido
    if (!empty($jobData['options']['callback_url'])) {
        $ch = curl_init($jobData['options']['callback_url']);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
            'job_id' => $jobId, 
            'status' => 'completed',
            'download_url' => "/api/v1/download/{$jobId}"
        ]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        curl_close($ch);
        
        logMessage("Callback enviado para job $jobId");
    }
    
    // Limpiar archivo temporal después de un tiempo
    if (file_exists($inputFile)) {
        // No eliminar inmediatamente, darle tiempo al download
        sleep(1);
    }
}
APIWORKER

    # Servicio systemd
    print_message "Creando servicio systemd para el worker API..."
    cat << 'APISYSTEMD' > /etc/systemd/system/api-worker.service
[Unit]
Description=API Worker for Image Processing
After=network.target redis-server.service

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/bin/php /var/www/image-processor/scripts/api-worker.php
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
APISYSTEMD

    # Herramienta de gestión de API keys
    print_message "Creando herramienta de gestión de API keys..."
    cat << 'APIKEYS' > /usr/local/bin/api-key-manager
#!/usr/bin/php -d opcache.jit=0
<?php
require_once '/var/www/image-processor/api/auth/ApiAuth.php';

$auth = new ApiAuth();

if ($argc < 2) {
    echo "Uso: api-key-manager <comando>\n";
    echo "  create <nombre> - Crear API key\n";
    echo "  list           - Listar keys\n";
    echo "  show           - Mostrar key maestra\n";
    exit(1);
}

switch ($argv[1]) {
    case 'create':
        $name = $argv[2] ?? 'wordpress_plugin';
        $key = $auth->createApiKey($name);
        echo "API Key creada:\n";
        echo "Nombre: {$key['name']}\n";
        echo "Key: {$key['key']}\n";
        break;
    
    case 'list':
        $config = require '/var/www/image-processor/config/api/config.php';
        $keys = json_decode(file_get_contents($config['api']['auth']['keys_file']), true);
        foreach ($keys['keys'] as $key) {
            echo "Nombre: {$key['name']} | Estado: " . ($key['active'] ? 'ACTIVA' : 'INACTIVA') . "\n";
        }
        break;
    
    case 'show':
        $config = require '/var/www/image-processor/config/api/config.php';
        $keys = json_decode(file_get_contents($config['api']['auth']['keys_file']), true);
        foreach ($keys['keys'] as $key) {
            if ($key['name'] === 'master') {
                echo $key['key'] . "\n";
                break;
            }
        }
        break;
}
APIKEYS
    
    chmod +x /usr/local/bin/api-key-manager

    # Actualizar Nginx para la API
    print_message "Actualizando configuración de Nginx para la API..."
    
    # Agregar antes del último } en el archivo de configuración
    sed -i '/^}$/i\
    \
    # API WordPress Integration v4 - FIXED\
    location ~ ^/api/v1(/|\$) {\
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;\
        fastcgi_param SCRIPT_FILENAME \$document_root/api/v1/index.php;\
        fastcgi_param PATH_INFO \$uri;\
        include fastcgi_params;\
        fastcgi_read_timeout 600;\
    }' /etc/nginx/sites-available/image-optimizer

    # Permisos
    chown -R www-data:www-data /var/www/image-processor/api
    chown -R www-data:www-data /var/www/image-processor/config
    chmod -R 755 /var/www/image-processor/api

    # Arrancar el worker
    systemctl daemon-reload
    systemctl enable api-worker
    systemctl start api-worker

    # Reiniciar Nginx
    nginx -t && systemctl reload nginx

    # Generar API key inicial
    print_message "Generando API key maestra..."
    sleep 2
    API_KEY=$(sudo -u www-data /usr/local/bin/api-key-manager show 2>/dev/null || sudo -u www-data /usr/local/bin/api-key-manager create master | grep "Key:" | awk '{print $2}')
    
    echo ""
    print_ultra "========================================"
    print_ultra "API KEY MAESTRA GENERADA"
    print_ultra "========================================"
    echo "Key: $API_KEY"
    print_ultra "========================================"
    echo "IMPORTANTE: Guarda esta key de forma segura!"
    echo ""

    print_success "Sistema API para WordPress completamente configurado"
}

create_api_monitor_command() {
    print_message "Creando comando de monitoreo para la API..."
    cat << 'APIMON' > /usr/local/bin/monitor-api
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\${CYAN}========================================="
echo "MONITOR DE API - WORDPRESS INTEGRATION"
echo "=========================================\${NC}"

# Estado del worker
if systemctl is-active --quiet api-worker; then
    echo -e "\${GREEN}✓\${NC} Worker API: Activo"
else
    echo -e "\${RED}✗\${NC} Worker API: Inactivo"
fi

# Jobs en cola
if command -v redis-cli >/dev/null 2>&1; then
    QUEUE=\$(redis-cli llen imgopt:queue 2>/dev/null || echo 0)
    echo -e "\${CYAN}📊\${NC} Jobs en cola: \$QUEUE"
    
    TODAY=\$(redis-cli get imgopt:stats:\$(date +%Y-%m-%d) 2>/dev/null || echo 0)
    echo -e "\${CYAN}📈\${NC} Procesados hoy: \$TODAY"
fi

# Health check
HEALTH=\$(curl -s http://localhost/api/v1/health 2>/dev/null)
if [ \$? -eq 0 ]; then
    echo -e "\${GREEN}✓\${NC} API respondiendo correctamente"
else
    echo -e "\${RED}✗\${NC} API no responde"
fi

echo -e "\${CYAN}=========================================\${NC}"
APIMON
    
    chmod +x /usr/local/bin/monitor-api
    print_success "Monitor de API creado"
}

main_ultra() {
    # Inicializar log ultra
    echo "=====================================================" > $LOG_FILE
    echo "INICIO INSTALACIÓN ULTRA v3.0: $(date)" >> $LOG_FILE
    echo "=====================================================" >> $LOG_FILE
    
    # Mostrar banner con detección de hardware
    show_banner
    
    # Verificar root
    check_root
    
    # Configuración inicial
    initial_setup
    
    # Ejecutar todos los pasos ultra optimizados
    print_ultra "🚀 Iniciando instalación ULTRA con $OPTIMAL_PARALLEL_JOBS workers..."
    echo ""
    
    configure_system_ultra
    configure_security_enhanced
    configure_nginx_ultra
    install_dev_tools_ultra
    install_image_libraries_ultra
    install_optimization_tools_ultra
    install_image_suites_ultra
    install_vips_ultra
    configure_php_ultra
    install_redis_ultra
    install_netdata_ultra
    create_directory_structure_ultra
    create_parallel_optimization_scripts
    create_verification_script_ultra
    create_benchmark_ultra
    optimize_kernel_extreme
    create_maintenance_system

    # INTEGRACIÓN API WORDPRESS
    print_ultra "========================================="
    print_ultra "INSTALANDO API WORDPRESS INTEGRATION"
    print_ultra "========================================="
    create_wordpress_api_system
    create_api_monitor_command
    
    # Validar servicios antes del resumen
    validate_critical_services
    
    # Mostrar resumen ultra
    show_summary_ultra
}

# Ejecutar función principal ultra
main_ultra "$@"

