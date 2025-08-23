#!/bin/bash

# Script de despliegue de OptimizerJR Server API al VPS
# Este script copia e instala la API en el servidor VPS

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuración
VPS_HOST="optimizer01.optimserver.com"
VPS_USER="root"
VPS_PATH="/var/www/image-processor"

echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}OptimizerJR VPS Deployment Script${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Verificar que el archivo install-server.sh existe
if [ ! -f "server/install-server.sh" ]; then
    echo -e "${RED}Error: server/install-server.sh not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Step 1: Copying installation script to VPS...${NC}"
scp server/install-server.sh ${VPS_USER}@${VPS_HOST}:/tmp/install-server.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to copy script to VPS${NC}"
    echo "Make sure you can connect to ${VPS_USER}@${VPS_HOST}"
    exit 1
fi

echo -e "${GREEN}✓ Script copied successfully${NC}"
echo ""

echo -e "${YELLOW}Step 2: Running installation on VPS...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
chmod +x /tmp/install-server.sh
cd /tmp
./install-server.sh
ENDSSH

if [ $? -ne 0 ]; then
    echo -e "${RED}Installation failed on VPS${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Installation completed${NC}"
echo ""

echo -e "${YELLOW}Step 3: Testing API endpoint...${NC}"
sleep 2

# Test connection
response=$(curl -s -o /dev/null -w "%{http_code}" http://${VPS_HOST}/api/test)

if [ "$response" = "200" ]; then
    echo -e "${GREEN}✓ API is working correctly!${NC}"
    echo ""
    
    # Show API details
    curl -s http://${VPS_HOST}/api/test | python3 -m json.tool 2>/dev/null || curl -s http://${VPS_HOST}/api/test
    echo ""
else
    echo -e "${RED}✗ API test failed (HTTP ${response})${NC}"
    echo "Check nginx logs on the VPS: ssh ${VPS_USER}@${VPS_HOST} 'tail -n 50 /var/log/nginx/error.log'"
fi

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo "API Endpoints available at:"
echo "  - http://${VPS_HOST}/api/test"
echo "  - http://${VPS_HOST}/api/status"
echo "  - http://${VPS_HOST}/api/optimize/direct"
echo "  - http://${VPS_HOST}/api/optimize/pull"
echo ""
echo "Next steps:"
echo "1. Activate the plugin in WordPress"
echo "2. Go to OptimizerJR → Settings"
echo "3. Verify server URL is set to: http://${VPS_HOST}"
echo "4. Test optimization with some images"