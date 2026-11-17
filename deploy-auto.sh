#!/bin/bash

# 🚀 SCRIPT DE DESPLIEGUE AUTOMÁTICO EN DIGITAL OCEAN
# Ejecutar como: bash deploy-auto.sh

set -e  # Salir si hay error

echo "======================================"
echo "🚀 DESPLIEGUE AUTOMÁTICO - PAGES QR"
echo "======================================"

# PASO 1: Actualizar sistema
echo "📦 [1/8] Actualizando sistema..."
apt update && apt upgrade -y

# PASO 2: Instalar dependencias
echo "📦 [2/8] Instalando dependencias..."
apt install -y python3-pip python3-venv git nginx wget curl

# PASO 3: Crear usuario (si no existe)
echo "👤 [3/8] Verificando usuario..."
if ! id "appuser" &>/dev/null; then
    adduser --disabled-password --gecos "" appuser
    usermod -aG sudo appuser
    echo "✅ Usuario 'appuser' creado"
else
    echo "✅ Usuario 'appuser' ya existe"
fi

# PASO 4: Clonar/actualizar proyecto
echo "📂 [4/8] Clonando proyecto..."
if [ ! -d "/home/appuser/pages_qr" ]; then
    cd /home/appuser
    # Cambiar a git@github.com si tienes SSH configurado
    sudo -u appuser git clone https://github.com/myke-aa12/pages_qr.git
else
    echo "📂 Proyecto ya existe, actualizando..."
    cd /home/appuser/pages_qr
    sudo -u appuser git pull
fi

# PASO 5: Crear venv e instalar paquetes
echo "🐍 [5/8] Configurando Python..."
cd /home/appuser/pages_qr
if [ ! -d "venv" ]; then
    sudo -u appuser python3 -m venv venv
fi
sudo -u appuser venv/bin/pip install --upgrade pip
sudo -u appuser venv/bin/pip install -r requirements.txt

# PASO 6: Configurar .env (SI NO EXISTE)
echo "🔐 [6/8] Configurando variables de entorno..."
if [ ! -f ".env" ]; then
    # IMPORTANTE: Reemplaza estos valores con tus credenciales reales
    cat > .env << 'EOF'
SECRET_KEY=tu_clave_secreta_aleatoria_aqui_minimo_32_caracteres
DATABASE_URL=mysql+pymysql://usuario:contraseña@host:puerto/database
DB_CA_CERT=app/core/ca.pem
FLASK_ENV=production
EOF
    chown appuser:appuser .env
    chmod 600 .env
    echo "✅ .env creado (IMPORTANTE: actualiza con tus credenciales reales)"
else
    echo "✅ .env ya existe"
fi

# PASO 7: Configurar Nginx
echo "🌐 [7/8] Configurando Nginx..."
cat > /etc/nginx/sites-available/pages_qr << 'EOF'
server {
    listen 80;
    server_name _;

    client_max_body_size 50M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
        proxy_connect_timeout 30s;
    }
}
EOF

# Habilitar sitio
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/pages_qr /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
echo "✅ Nginx configurado"

# PASO 8: Crear servicio systemd
echo "⚙️  [8/8] Configurando servicio systemd..."
cat > /etc/systemd/system/pages_qr.service << 'EOF'
[Unit]
Description=Pages QR Flask App
After=network.target

[Service]
User=appuser
WorkingDirectory=/home/appuser/pages_qr
Environment="PATH=/home/appuser/pages_qr/venv/bin"
ExecStart=/home/appuser/pages_qr/venv/bin/gunicorn --workers 4 --bind 127.0.0.1:5000 run:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable pages_qr
systemctl start pages_qr
systemctl status pages_qr
echo "✅ Servicio systemd configurado"

# FIREWALL (opcional)
echo "🔒 Configurando firewall..."
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
echo "✅ Firewall configurado"

echo ""
echo "======================================"
echo "✅ ¡DESPLIEGUE COMPLETADO!"
echo "======================================"
echo ""
echo "📊 INFORMACIÓN DEL SERVIDOR:"
echo "IP Pública: $(curl -s https://api.ipify.org)"
echo "Usuario: appuser"
echo "Ubicación proyecto: /home/appuser/pages_qr"
echo ""
echo "⚠️  IMPORTANTE: Edita .env con tus credenciales reales:"
echo "   nano /home/appuser/pages_qr/.env"
echo ""
echo "🔍 COMANDOS ÚTILES:"
echo "  Ver estado: sudo systemctl status pages_qr"
echo "  Ver logs: sudo journalctl -u pages_qr -f"
echo "  Reiniciar: sudo systemctl restart pages_qr"
echo "  Actualizar: cd /home/appuser/pages_qr && git pull && sudo systemctl restart pages_qr"
echo ""
echo "🌐 Accede a: http://TU_IP_PUBLICA"
echo ""

