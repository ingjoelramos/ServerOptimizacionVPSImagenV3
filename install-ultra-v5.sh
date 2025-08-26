#!/bin/bash

# Script de instalación ultra-completo para servidor de optimización de imágenes V5
# Con corrección del procesamiento de múltiples formatos de imagen
# Versión: 5.0
# Fecha: 2025-08-25

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para imprimir mensajes con formato
print_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

# Verificar que se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script debe ejecutarse como root"
   exit 1
fi

# Detectar sistema operativo
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    print_error "No se puede detectar el sistema operativo"
    exit 1
fi

print_message "Sistema detectado: $OS $VER"

# Actualizar sistema
print_message "Actualizando sistema..."
apt update && apt upgrade -y

# Instalar dependencias base
print_message "Instalando dependencias base..."
apt install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    ufw \
    fail2ban \
    htop \
    iotop \
    net-tools \
    vim \
    nano

# Instalar ImageMagick y herramientas de optimización
print_message "Instalando ImageMagick y herramientas de optimización..."
apt install -y \
    imagemagick \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    webp \
    libmagickwand-dev

# Instalar PHP 8.2 y extensiones
print_message "Instalando PHP 8.2..."
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y \
    php8.2-fpm \
    php8.2-cli \
    php8.2-common \
    php8.2-mysql \
    php8.2-zip \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-curl \
    php8.2-xml \
    php8.2-bcmath \
    php8.2-imagick \
    php8.2-redis \
    php8.2-opcache \
    php8.2-intl

# Instalar Nginx
print_message "Instalando Nginx..."
apt install -y nginx

# Instalar Redis
print_message "Instalando Redis..."
apt install -y redis-server

# Configurar Redis
cat << 'EOF' > /etc/redis/redis.conf
bind 127.0.0.1
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize yes
supervised systemd
pidfile /var/run/redis/redis-server.pid
loglevel notice
logfile /var/log/redis/redis-server.log
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis
maxmemory 256mb
maxmemory-policy allkeys-lru
EOF

# Crear estructura de directorios
print_message "Creando estructura de directorios..."
mkdir -p /var/www/image-processor/{uploads,processed,cache,logs,config,scripts,api,temp}
mkdir -p /var/www/image-processor/uploads/{pending,completed,failed}
mkdir -p /var/www/image-processor/processed/{jpg,png,webp,avif,gif}
mkdir -p /var/www/image-processor/logs/{api,nginx,php}
mkdir -p /var/www/image-processor/api/{v1,auth}
mkdir -p /var/www/image-processor/config/api
mkdir -p /var/www/image-processor/scripts/{optimization,monitoring,batch}

# Configurar permisos
chown -R www-data:www-data /var/www/image-processor
chmod -R 755 /var/www/image-processor
chmod -R 777 /var/www/image-processor/uploads
chmod -R 777 /var/www/image-processor/processed
chmod -R 777 /var/www/image-processor/cache
chmod -R 777 /var/www/image-processor/logs

# Configurar PHP
print_message "Configurando PHP..."
cat << 'EOF' > /etc/php/8.2/fpm/conf.d/99-custom.ini
upload_max_filesize = 100M
post_max_size = 100M
memory_limit = 512M
max_execution_time = 300
max_input_time = 300
opcache.enable=1
opcache.memory_consumption=256
opcache.interned_strings_buffer=16
opcache.max_accelerated_files=10000
opcache.revalidate_freq=2
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF

# Configuración de API
print_message "Configurando API..."
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

# API Auth
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

# API Endpoint principal
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
        try {
            $this->redis = new Redis();
            $this->redis->connect('127.0.0.1', 6379);
        } catch (Exception $e) {
            $this->redis = null;
        }
    }
    
    public function handleRequest() {
        $path = $_SERVER["PATH_INFO"] ?? $_SERVER["REQUEST_URI"] ?? "/";  
        $path = preg_replace("#^/api/v1/?#", "", $path);
        $path = strtok($path, "?");
        $path = trim($path, "/");
        $segments = explode("/", $path);
        
        $publicRoutes = ['health'];
        
        if (!in_array($segments[0] ?? '', $publicRoutes)) {
            $authResult = $this->auth->authenticate($_SERVER);
            if (!$authResult['success']) {
                $this->sendResponse(['error' => $authResult['error']], 401);
                return;
            }
        }
        
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
        
        if (filter_var($input['image'], FILTER_VALIDATE_URL)) {
            $imageData = file_get_contents($input['image']);
        } else {
            $imageData = base64_decode($input['image']);
        }
        
        file_put_contents($tempFile, $imageData);
        
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
        
        if ($job['status'] === 'completed') {
            $job['download_url'] = "/api/v1/download/{$jobId}";
        }
        
        $this->sendResponse($job);
    }
    
    private function handleDownload($jobId) {
        if ($this->redis) {
            $jobData = $this->redis->get("imgopt:{$jobId}");
            if ($jobData) {
                $job = json_decode($jobData, true);
                if (isset($job['output_file']) && file_exists($job['output_file'])) {
                    $file = $job['output_file'];
                } else {
                    $file = "/var/www/image-processor/processed/{$jobId}_optimized";
                }
            } else {
                $file = "/var/www/image-processor/processed/{$jobId}_optimized";
            }
        } else {
            $file = "/var/www/image-processor/processed/{$jobId}_optimized";
        }
        
        if (!file_exists($file)) {
            $file = "/var/www/image-processor/processed/{$jobId}_original_optimized.jpg";
        }
        
        if (!file_exists($file)) {
            $this->sendResponse(['error' => 'File not found', 'searched_path' => $file], 404);
            return;
        }
        
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file);
        finfo_close($finfo);
        
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

# Worker de procesamiento MEJORADO V5 con soporte multi-formato
print_message "Creando worker de procesamiento API V5..."
cat << 'APIWORKER' > /var/www/image-processor/scripts/api-worker.php
<?php
// Worker mejorado V5 con soporte para múltiples formatos de imagen
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

logMessage("Worker iniciado (version mejorada V5.0 - Multi-formato)");

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
        
        // Detectar tipo de imagen
        $imageInfo = getimagesize($inputFile);
        if (!$imageInfo) {
            throw new Exception("Invalid image file: $inputFile");
        }
        
        $mimeType = $imageInfo['mime'];
        logMessage("Image type detected: $mimeType");
        
        // Procesar según el tipo de imagen
        switch ($mimeType) {
            case 'image/jpeg':
                // Optimizar JPEG directamente
                $cmd = "jpegoptim --strip-all --max=85 --stdout '$inputFile' > '$outputFile' 2>&1";
                exec($cmd, $output, $returnCode);
                
                if ($returnCode !== 0) {
                    logMessage("jpegoptim failed, using fallback: " . implode(' ', $output));
                    // Fallback: usar convert para optimizar
                    $cmd = "convert '$inputFile' -strip -quality 85 -sampling-factor 4:2:0 -interlace JPEG -colorspace sRGB '$outputFile' 2>&1";
                    exec($cmd, $output, $returnCode);
                    
                    if ($returnCode !== 0) {
                        logMessage("Convert also failed: " . implode(' ', $output));
                        copy($inputFile, $outputFile);
                    }
                }
                break;
                
            case 'image/png':
                // Convertir PNG a JPEG optimizado
                logMessage("Converting PNG to optimized JPEG");
                $cmd = "convert '$inputFile' -strip -quality 85 -background white -alpha remove -alpha off -sampling-factor 4:2:0 -interlace JPEG -colorspace sRGB '$outputFile' 2>&1";
                exec($cmd, $output, $returnCode);
                
                if ($returnCode !== 0) {
                    logMessage("PNG conversion failed: " . implode(' ', $output));
                    // Fallback: intentar sin alpha
                    $cmd = "convert '$inputFile' -strip -quality 85 '$outputFile' 2>&1";
                    exec($cmd, $output, $returnCode);
                    
                    if ($returnCode !== 0) {
                        logMessage("Fallback conversion also failed: " . implode(' ', $output));
                        copy($inputFile, $outputFile);
                    }
                }
                break;
                
            case 'image/gif':
            case 'image/webp':
            case 'image/bmp':
                // Convertir otros formatos a JPEG optimizado
                logMessage("Converting $mimeType to optimized JPEG");
                $cmd = "convert '$inputFile' -strip -quality 85 -sampling-factor 4:2:0 -interlace JPEG -colorspace sRGB '$outputFile' 2>&1";
                exec($cmd, $output, $returnCode);
                
                if ($returnCode !== 0) {
                    logMessage("Image conversion failed: " . implode(' ', $output));
                    copy($inputFile, $outputFile);
                }
                break;
                
            default:
                logMessage("Unsupported image type: $mimeType, copying original");
                copy($inputFile, $outputFile);
                break;
        }
        
        // WebP si se solicita
        if (!empty($jobData['options']['webp'])) {
            $webpFile = str_replace('.jpg', '.webp', $outputFile);
            exec("cwebp -q 85 '$outputFile' -o '$webpFile' 2>/dev/null");
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

# Servicio systemd para el worker
cat << 'APISYSTEMD' > /etc/systemd/system/api-worker.service
[Unit]
Description=API Worker for Image Processing
After=network.target redis.service

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

# Configurar Nginx
print_message "Configurando Nginx..."
cat << 'NGINX' > /etc/nginx/sites-available/image-processor
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/image-processor;
    index index.php index.html;
    
    server_name _;
    
    client_max_body_size 100M;
    client_body_timeout 300s;
    
    # Logs
    access_log /var/www/image-processor/logs/nginx/access.log;
    error_log /var/www/image-processor/logs/nginx/error.log;
    
    # API endpoint
    location /api/v1 {
        try_files $uri $uri/ /api/v1/index.php?$query_string;
    }
    
    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_read_timeout 300;
    }
    
    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
    
    # Cache static files
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|webp|avif)$ {
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX

# Habilitar sitio
ln -sf /etc/nginx/sites-available/image-processor /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Herramienta de gestión de API keys
print_message "Creando herramienta de gestión de API keys..."
cat << 'APIKEYS' > /usr/local/bin/api-key-manager
#!/usr/bin/php
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
        echo "Creada: {$key['created']}\n";
        break;
        
    case 'list':
        $config = require '/var/www/image-processor/config/api/config.php';
        $keys = json_decode(file_get_contents($config['api']['auth']['keys_file']), true);
        echo "API Keys registradas:\n";
        foreach ($keys['keys'] as $key) {
            echo "- {$key['name']}: " . substr($key['key'], 0, 20) . "... (Activa: " . ($key['active'] ? 'Sí' : 'No') . ")\n";
        }
        break;
        
    case 'show':
        $config = require '/var/www/image-processor/config/api/config.php';
        $keys = json_decode(file_get_contents($config['api']['auth']['keys_file']), true);
        foreach ($keys['keys'] as $key) {
            if ($key['name'] === 'master') {
                echo "Master API Key: {$key['key']}\n";
                break;
            }
        }
        break;
        
    default:
        echo "Comando no reconocido: {$argv[1]}\n";
        exit(1);
}
APIKEYS

chmod +x /usr/local/bin/api-key-manager

# Script de monitoreo
print_message "Creando script de monitoreo..."
cat << 'MONITOR' > /usr/local/bin/image-processor-status
#!/bin/bash

echo "=== Estado del Sistema de Procesamiento de Imágenes ==="
echo ""

# Estado de servicios
echo "SERVICIOS:"
systemctl is-active --quiet nginx && echo "✓ Nginx: Activo" || echo "✗ Nginx: Inactivo"
systemctl is-active --quiet php8.2-fpm && echo "✓ PHP-FPM: Activo" || echo "✗ PHP-FPM: Inactivo"
systemctl is-active --quiet redis && echo "✓ Redis: Activo" || echo "✗ Redis: Inactivo"
systemctl is-active --quiet api-worker && echo "✓ API Worker: Activo" || echo "✗ API Worker: Inactivo"

echo ""
echo "ESTADÍSTICAS:"
echo "Imágenes procesadas: $(find /var/www/image-processor/processed -type f 2>/dev/null | wc -l)"
echo "Imágenes pendientes: $(find /var/www/image-processor/uploads/pending -type f 2>/dev/null | wc -l)"

echo ""
echo "USO DE DISCO:"
df -h /var/www/image-processor | tail -1

echo ""
echo "MEMORIA:"
free -m | grep Mem | awk '{printf "Total: %sMB | Usado: %sMB | Libre: %sMB\n", $2, $3, $4}'

echo ""
echo "API KEY MAESTRA:"
/usr/local/bin/api-key-manager show

echo ""
echo "ÚLTIMAS LÍNEAS DEL LOG:"
tail -5 /var/www/image-processor/logs/api/worker.log 2>/dev/null || echo "No hay logs disponibles"
MONITOR

chmod +x /usr/local/bin/image-processor-status

# Configurar firewall
print_message "Configurando firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Configurar logrotate
cat << 'LOGROTATE' > /etc/logrotate.d/image-processor
/var/www/image-processor/logs/*/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload nginx > /dev/null
        systemctl reload php8.2-fpm > /dev/null
    endscript
}
LOGROTATE

# Reiniciar servicios
print_message "Reiniciando servicios..."
systemctl daemon-reload
systemctl restart redis
systemctl restart php8.2-fpm
systemctl restart nginx
systemctl enable api-worker
systemctl start api-worker

# Verificar instalación
print_message "Verificando instalación..."
sleep 3

echo ""
/usr/local/bin/image-processor-status

echo ""
print_message "¡Instalación completada exitosamente!"
print_message "El servidor de optimización de imágenes está listo."
print_message ""
print_message "INFORMACIÓN IMPORTANTE:"
print_message "========================"
print_message "API Endpoint: http://$(hostname -I | awk '{print $1}')/api/v1"
print_message ""
print_message "Para ver el estado del sistema: image-processor-status"
print_message "Para gestionar API keys: api-key-manager"
print_message ""
print_message "La API key maestra se muestra arriba. Guárdela en un lugar seguro."
print_message ""
print_message "Endpoints disponibles:"
print_message "  POST /api/v1/optimize - Optimizar imagen"
print_message "  GET  /api/v1/status/{job_id} - Estado del trabajo"
print_message "  GET  /api/v1/download/{job_id} - Descargar imagen optimizada"
print_message "  GET  /api/v1/health - Estado del servicio"