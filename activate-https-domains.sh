#!/bin/bash
# Script para activar HTTPS con Let's Encrypt en todos los dominios
# Uso: ./activate-https-domains.sh

set -e

echo "════════════════════════════════════════════════════════"
echo "🔐 ACTIVAR HTTPS CON LET'S ENCRYPT"
echo "════════════════════════════════════════════════════════"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Este script debe ejecutarse como root${NC}"
   echo "Uso: sudo bash activate-https-domains.sh"
   exit 1
fi

# Dominios
DOMAINS=(
    "siiat-sat-gob.com.mx"
    "gobierno-estatal.com.mx"
    "gobierno-federal.com.mx"
    "certificacion-sep.com.mx"
)

echo -e "${YELLOW}📋 Dominios a proteger:${NC}"
for domain in "${DOMAINS[@]}"; do
    echo "   • $domain"
done
echo ""

# Paso 1: Verificar que Certbot está instalado
echo -e "${YELLOW}1️⃣ Verificando Certbot...${NC}"
if ! command -v certbot &> /dev/null; then
    echo -e "${YELLOW}   Instalando Certbot...${NC}"
    apt update -qq
    apt install -y certbot python3-certbot-nginx -qq
    echo -e "${GREEN}   ✅ Certbot instalado${NC}"
else
    echo -e "${GREEN}   ✅ Certbot ya está instalado${NC}"
fi
echo ""

# Paso 2: Verificar DNS
echo -e "${YELLOW}2️⃣ Verificando que DNS está configurado...${NC}"
ERROR_COUNT=0

for domain in "${DOMAINS[@]}"; do
    if nslookup "$domain" 8.8.8.8 &> /dev/null; then
        DNS_IP=$(nslookup "$domain" 8.8.8.8 | grep "Address:" | tail -1 | awk '{print $2}')
        if [[ "$DNS_IP" == "146.190.162.6" ]]; then
            echo -e "${GREEN}   ✅ $domain → $DNS_IP${NC}"
        else
            echo -e "${RED}   ❌ $domain → $DNS_IP (esperado: 146.190.162.6)${NC}"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    else
        echo -e "${RED}   ❌ $domain no resuelve${NC}"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

if [[ $ERROR_COUNT -gt 0 ]]; then
    echo ""
    echo -e "${RED}⚠️ ADVERTENCIA: $ERROR_COUNT dominio(s) no está(n) correctamente apuntado(s)${NC}"
    echo -e "${YELLOW}Por favor, apunta los DNS antes de continuar.${NC}"
    echo -e "${YELLOW}Debes crear registros A para cada dominio:${NC}"
    echo "   Tipo: A"
    echo "   Valor: 146.190.162.6"
    echo ""
    read -p "¿Deseas continuar de todas formas? (s/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo -e "${RED}Abortado.${NC}"
        exit 1
    fi
fi
echo ""

# Paso 3: Generar certificados
echo -e "${YELLOW}3️⃣ Generando certificados Let's Encrypt...${NC}"
echo -e "${YELLOW}   (Se pedirá email y aceptar términos)${NC}"
echo ""

DOMAIN_ARGS=""
for domain in "${DOMAINS[@]}"; do
    DOMAIN_ARGS="$DOMAIN_ARGS -d $domain"
done

certbot certonly --nginx $DOMAIN_ARGS

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}   ✅ Certificados generados exitosamente${NC}"
else
    echo -e "${RED}   ❌ Error al generar certificados${NC}"
    exit 1
fi
echo ""

# Paso 4: Actualizar Nginx
echo -e "${YELLOW}4️⃣ Actualizando configuración Nginx...${NC}"

cat > /etc/nginx/sites-available/default << 'NGINX_CONFIG'
# Redirigir HTTP a HTTPS para todos los dominios
server {
    listen 80;
    server_name siiat-sat-gob.com.mx gobierno-estatal.com.mx gobierno-federal.com.mx certificacion-sep.com.mx _;
    return 301 https://$host$request_uri;
}

# Bloque HTTPS principal
server {
    listen 443 ssl http2;
    server_name siiat-sat-gob.com.mx gobierno-estatal.com.mx gobierno-federal.com.mx certificacion-sep.com.mx;

    # Certificados SSL de Let's Encrypt
    ssl_certificate /etc/letsencrypt/live/siiat-sat-gob.com.mx/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/siiat-sat-gob.com.mx/privkey.pem;
    
    # Configuración de seguridad SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    client_max_body_size 20M;

    # Logs
    access_log /var/log/nginx/pages_qr_access.log;
    error_log /var/log/nginx/pages_qr_error.log;

    # Proxy a Flask
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
    }

    # Static files
    location /static/ {
        alias /home/appuser/pages_qr/app/static/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
NGINX_CONFIG

echo -e "${GREEN}   ✅ Nginx configurado${NC}"
echo ""

# Paso 5: Verificar sintaxis
echo -e "${YELLOW}5️⃣ Verificando sintaxis Nginx...${NC}"
if nginx -t 2>&1 | grep -q "successful"; then
    echo -e "${GREEN}   ✅ Sintaxis correcta${NC}"
else
    echo -e "${RED}   ❌ Error de sintaxis${NC}"
    nginx -t
    exit 1
fi
echo ""

# Paso 6: Reiniciar Nginx
echo -e "${YELLOW}6️⃣ Reiniciando Nginx...${NC}"
systemctl reload nginx
sleep 2

if systemctl is-active --quiet nginx; then
    echo -e "${GREEN}   ✅ Nginx activo${NC}"
else
    echo -e "${RED}   ❌ Error al iniciar Nginx${NC}"
    exit 1
fi
echo ""

# Paso 7: Verificar estado final
echo -e "${YELLOW}7️⃣ Estado final:${NC}"
echo -e "${GREEN}   ✅ Nginx: $(systemctl is-active nginx)${NC}"
echo -e "${GREEN}   ✅ Flask: $(systemctl is-active pages_qr)${NC}"
echo ""

# Paso 8: Mostrar certificados
echo -e "${YELLOW}8️⃣ Certificados instalados:${NC}"
certbot certificates

echo ""
echo "════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ HTTPS COMPLETAMENTE FUNCIONAL${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}🌐 URLs disponibles:${NC}"
echo "   • https://siiat-sat-gob.com.mx"
echo "   • https://gobierno-estatal.com.mx"
echo "   • https://gobierno-federal.com.mx"
echo "   • https://certificacion-sep.com.mx"
echo ""
echo -e "${GREEN}🔄 Renovación automática:${NC}"
echo "   • Let's Encrypt renovará automáticamente"
echo "   • Próxima renovación: $(certbot certificates | grep -A2 'siiat-sat-gob' | grep Expiry || echo 'N/A')"
echo ""
echo -e "${YELLOW}📋 Para ver logs:${NC}"
echo "   journalctl -u pages_qr -f"
echo "   tail -f /var/log/nginx/error.log"
echo ""
