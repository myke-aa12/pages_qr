# 🚀 GUÍA PASO A PASO - DESPLIEGUE EN DIGITAL OCEAN

## 📌 ÍNDICE
1. [Preparación](#preparación)
2. [Crear Droplet](#crear-droplet)
3. [Desplegar con Script Automático](#desplegar-con-script-automático)
4. [Desplegar Manualmente](#desplegar-manualmente)
5. [Verificar que funciona](#verificar-que-funciona)
6. [Troubleshooting](#troubleshooting)

---

## ✅ PREPARACIÓN

### En tu máquina local (Windows/Mac/Linux)

1. **Verifica que todo está listo:**
   ```bash
   cd C:\Users\Studio\Desktop\pages_qr
   git status
   # Debe mostrar: "On branch main" y "nothing to commit"
   ```

2. **Verifica que tienes tus credenciales Aiven:**
   ```
   DATABASE_URL = mysql+pymysql://usuario:contraseña@host:puerto/database
   DB_CA_CERT = app/core/ca.pem (archivo que debe existir)
   ```

3. **Push a GitHub:**
   ```bash
   git push origin main
   ```

---

## 📱 CREAR DROPLET

### Paso 1: Acceder a Digital Ocean

1. Ve a: https://cloud.digitalocean.com/
2. Inicia sesión (crea cuenta si no tienes)
3. Agrega tarjeta de crédito (si es necesario)

### Paso 2: Crear Droplet

1. Click en **"Create"** (arriba a la derecha)
2. Selecciona **"Droplets"**
3. Rellena los datos:

| Campo | Valor |
|-------|-------|
| **Image** | Ubuntu 22.04 LTS x64 |
| **Region** | Cercana a ti (ej: NYC, Toronto) |
| **Size** | $5-6/mes (Shared CPU, 1GB RAM, 25GB SSD) |
| **Authentication** | SSH keys (si las tienes) o Password |
| **Hostname** | `pages-qr` |
| **Enable Backups** | ✓ (opcional, $1/mes) |

4. Click **"Create Droplet"**

5. Espera ~1 minuto a que se cree
6. **Copia la IP pública** que ves (ej: `192.168.1.100`)

---

## 🤖 DESPLEGAR CON SCRIPT AUTOMÁTICO

### Opción A: Automática (Recomendado)

Este script automatiza TODO en 3-5 minutos.

1. **Conectarse al servidor:**
   ```bash
   ssh root@192.168.1.100
   # Presiona "yes" si pregunta por fingerprint
   ```

2. **Descargar y ejecutar script:**
   ```bash
   cd /tmp
   wget https://raw.githubusercontent.com/myke-aa12/pages_qr/main/deploy-auto.sh
   bash deploy-auto.sh
   
   # Espera 3-5 minutos
   ```

3. **El script hace automáticamente:**
   - ✅ Actualiza el sistema
   - ✅ Instala Python, Nginx, Git
   - ✅ Clona tu proyecto desde GitHub
   - ✅ Crea venv e instala dependencias
   - ✅ Configura Nginx como proxy
   - ✅ Crea servicio systemd para Flask
   - ✅ Configura firewall

4. **Después del script:**
   ```bash
   # El script te dirá que edites .env
   # Edita con tus credenciales REALES
   nano /home/appuser/pages_qr/.env
   
   # Luego reinicia:
   sudo systemctl restart pages_qr
   ```

---

## 🔧 DESPLEGAR MANUALMENTE

### Si prefieres entender cada paso

**[Ve al archivo deploy.md para instrucciones paso a paso]**

---

## ✅ VERIFICAR QUE FUNCIONA

### Prueba 1: Acceder desde navegador

1. Abre navegador
2. Ve a: `http://192.168.1.100`
3. Deberías ver el index de SAT ✅

### Prueba 2: Ver logs

```bash
ssh appuser@192.168.1.100

# Ver logs en tiempo real
sudo journalctl -u pages_qr -f

# Deberías ver: "INFO: Application startup complete"
```

### Prueba 3: Verificar servicios

```bash
# Verificar que Flask está corriendo
sudo systemctl status pages_qr
# Debe mostrar: "active (running)"

# Verificar que Nginx está corriendo
sudo systemctl status nginx
# Debe mostrar: "active (running)"
```

---

## 🌐 (OPCIONAL) CONFIGURAR DOMINIO + SSL

Si tienes dominio y quieres HTTPS:

### Paso 1: Apuntar dominio a tu Droplet

1. Ve a tu proveedor DNS (Godaddy, Namecheap, etc.)
2. Edita el registro A:
   - **Nombre**: `@` o `www`
   - **Valor**: Tu IP de Digital Ocean (ej: `192.168.1.100`)
3. Espera 10-30 minutos (propagación DNS)

### Paso 2: Configurar SSL con Let's Encrypt

```bash
ssh appuser@192.168.1.100

# Instala certbot
sudo apt install -y certbot python3-certbot-nginx

# Configura SSL
sudo certbot --nginx -d tudominio.com

# Sigue las instrucciones y presiona "y" cuando pregunte
```

Listo! Ahora accede a: `https://tudominio.com` ✅

---

## 🛠️ COMANDOS ÚTILES DESPUÉS DEL DESPLIEGUE

### Ver estado de la app
```bash
ssh appuser@192.168.1.100
sudo systemctl status pages_qr
```

### Ver logs en tiempo real
```bash
sudo journalctl -u pages_qr -f
```

### Reiniciar la app
```bash
sudo systemctl restart pages_qr
```

### Actualizar código desde GitHub
```bash
cd /home/appuser/pages_qr
git pull
sudo systemctl restart pages_qr
```

### Ver uso de recursos
```bash
free -h    # RAM
df -h      # Disco
top        # CPU (Ctrl+C para salir)
```

---

## 🆘 TROUBLESHOOTING

### Error: "502 Bad Gateway"

**Solución:**
```bash
# Reinicia la app
sudo systemctl restart pages_qr

# Si sigue fallando, ve logs:
sudo journalctl -u pages_qr -n 50
```

### Error: "Connection refused"

**Solución:**
```bash
# Verifica que Flask está corriendo
sudo systemctl status pages_qr

# Si está down, inicia:
sudo systemctl start pages_qr
```

### Error: "Cannot connect to database"

**Solución:**
1. Verifica .env tiene credenciales correctas:
   ```bash
   cat /home/appuser/pages_qr/.env
   ```

2. Verifica que el archivo ca.pem existe:
   ```bash
   ls -la /home/appuser/pages_qr/app/core/ca.pem
   ```

3. Verifica que Aiven está accesible:
   ```bash
   telnet studio-112-st-112.k.aivencloud.com 13447
   # Presiona Ctrl+] y luego Ctrl+D para salir
   ```

### Error: "git: command not found"

**Solución:**
```bash
sudo apt install -y git
```

### Script deploy-auto.sh falla

**Solución:**
1. Ejecuta manualmente paso a paso (ver deploy.md)
2. O intenta de nuevo:
   ```bash
   bash deploy-auto.sh 2>&1 | tee deploy.log
   # Lee el archivo deploy.log para ver el error
   ```

---

## 📊 ESTRUCTURA FINAL EN DIGITAL OCEAN

```
Droplet Ubuntu 22.04
│
├── Nginx (puerto 80)
│   ↓ proxy reverso
├── Flask (puerto 5000, localhost)
│   │  
│   ├── app/
│   │   ├── templates/
│   │   │   ├── sat/
│   │   │   ├── ant_estatal/
│   │   │   ├── ant_federal/
│   │   │   └── certificados/
│   │   ├── database.py
│   │   └── __init__.py
│   │
│   └── run.py
│
├── .env (credenciales)
├── requirements.txt
└── venv/ (ambiente virtual)

BD: Aiven MySQL (en la nube)
```

---

## ✅ CHECKLIST FINAL

Después del despliegue, verifica:

- [ ] App accesible en http://IP
- [ ] Logs sin errores: `sudo journalctl -u pages_qr -f`
- [ ] Flask status: `sudo systemctl status pages_qr`
- [ ] Nginx status: `sudo systemctl status nginx`
- [ ] .env configurado con credenciales REALES
- [ ] SSL/TLS configurado (opcional)

---

## 🎉 ¡LISTO!

Tu app está en producción. 

**Próximos pasos:**
- Monitorea logs diariamente
- Actualiza código: `git pull && sudo systemctl restart pages_qr`
- Configura backups en Digital Ocean
- Cuando estés listo, agrega el bot de WhatsApp

---

## 📞 SOPORTE

Si algo falla:
1. Revisa los logs: `sudo journalctl -u pages_qr -f`
2. Verifica .env tiene datos correctos
3. Prueba reiniciar: `sudo systemctl restart pages_qr`
4. Consulta TROUBLESHOOTING arriba

¡Listo! 🚀
