# 🚀 DESPLIEGUE EN DIGITAL OCEAN - MANUAL COMPLETO

## ⚡ VERSIÓN RÁPIDA (3 pasos)

```bash
# 1. En tu máquina - verifica todo
bash pre-deploy-check.sh && git push origin main

# 2. En Digital Ocean - crea droplet Ubuntu 22.04 LTS

# 3. En el servidor - ejecuta
wget https://raw.githubusercontent.com/myke-aa12/pages_qr/main/deploy-auto.sh
bash deploy-auto.sh

# ¡Listo! Tu app está en http://IP_DEL_DROPLET
```

---

## 📋 VERSIÓN MANUAL (Paso a paso)

### PASO 1: Crear Droplet

1. Ve a: https://cloud.digitalocean.com/
2. Click **"Create"** → **"Droplets"**
3. Selecciona:
   - **Region**: Cercana a ti (ej: New York, Toronto)
   - **Image**: Ubuntu 22.04 LTS x64
   - **Size**: $5-6/mes (1GB RAM, 25GB SSD)
   - **Add SSH keys**: Agrega tu clave pública SSH
   - Click **"Create Droplet"**
4. Copia la **IP pública** (ej: `192.168.1.100`)

---

### PASO 2: Conectarse

```bash
ssh root@192.168.1.100
# Presiona "yes" si pregunta por fingerprint
```

---

### PASO 3: Instalar dependencias

```bash
apt update && apt upgrade -y
apt install -y python3-pip python3-venv git nginx

# Crear usuario no-root
adduser --disabled-password --gecos "" appuser
usermod -aG sudo appuser
su - appuser
```

---

### PASO 4: Clonar proyecto

```bash
cd /home/appuser
git clone https://github.com/myke-aa12/pages_qr.git
cd pages_qr
```

---

### PASO 5: Configurar Python

```bash
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

---

### PASO 6: Configurar variables de entorno

```bash
cat > .env << 'EOF'
SECRET_KEY=tu_clave_secreta_aleatoria_aqui_minimo_32_caracteres
DATABASE_URL=mysql+pymysql://usuario:contraseña@host:puerto/database
DB_CA_CERT=app/core/ca.pem
FLASK_ENV=production
EOF

chmod 600 .env

# IMPORTANTE: Edita con tus credenciales reales
nano .env
```
```

---

### PASO 7: Configurar Nginx

```bash
sudo tee /etc/nginx/sites-available/pages_qr > /dev/null << 'EOF'
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

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/pages_qr /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

### PASO 8: Crear servicio systemd

```bash
sudo tee /etc/systemd/system/pages_qr.service > /dev/null << 'EOF'
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

sudo systemctl daemon-reload
sudo systemctl enable pages_qr
sudo systemctl start pages_qr
```

---

### PASO 9: Configurar firewall

```bash
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

---

### PASO 10: Verificar

```bash
sudo systemctl status pages_qr
sudo journalctl -u pages_qr -n 20
```

Deberías ver: `active (running)` ✅

---

## 🌐 ACCEDER A LA APP

```
Desde tu navegador:
http://192.168.1.100
```

Deberías ver el index de SAT ✅

---

## 🔐 CONFIGURAR SSL (OPCIONAL pero RECOMENDADO)

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d tudominio.com
# Sigue las instrucciones
```

---

## 🛠️ COMANDOS ÚTILES

```bash
# Ver logs en tiempo real
sudo journalctl -u pages_qr -f

# Reiniciar app
sudo systemctl restart pages_qr

# Actualizar código
cd /home/appuser/pages_qr
git pull
sudo systemctl restart pages_qr

# Ver estado
sudo systemctl status pages_qr

# Ver recursos
free -h
ps aux | grep gunicorn
```

---

## ❓ TROUBLESHOOTING

| Problema | Solución |
|----------|----------|
| 502 Bad Gateway | `sudo systemctl restart pages_qr` |
| Conexión rechazada | Verifica: `sudo systemctl status pages_qr` |
| "Cannot connect to DB" | Verifica .env: `cat /home/appuser/pages_qr/.env` |
| Cambios no se ven | `cd /home/appuser/pages_qr && git pull && sudo systemctl restart pages_qr` |

---

## 📊 MONITOREO BÁSICO

```bash
# CPU y RAM
htop

# Conexiones de red
ss -tulpn

# Logs de errores
sudo tail -f /var/log/pages_qr/error.log
```

---

## ✅ CHECKLIST FINAL

- [ ] Droplet Ubuntu 22.04 LTS creado
- [ ] SSH accesible
- [ ] Paquetes instalados (pip, venv, git, nginx)
- [ ] Proyecto clonado
- [ ] .env configurado
- [ ] Servicio systemd activo
- [ ] Nginx corriendo
- [ ] Firewall configurado
- [ ] App accesible en http://IP
- [ ] Logs sin errores

---

¡Listo! 🎉 Tu proyecto está en producción.

**Próximo paso**: Agregar bot de WhatsApp sin interrupción
