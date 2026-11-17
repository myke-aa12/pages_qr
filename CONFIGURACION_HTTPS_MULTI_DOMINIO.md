# 🔐 Configuración HTTPS Multi-Dominio

## ✅ Estado Actual

Tu proyecto **Pages QR** está configurado en Digital Ocean con:

| Componente | Status | Detalles |
|-----------|--------|---------|
| 🌐 Servidor | ✅ Activo | IP: 146.190.162.6 |
| 🐍 Flask | ✅ Activo | Gunicorn con 4 workers |
| 🔒 Nginx | ✅ Activo | Proxy reverso SSL/TLS |
| 🗄️ BD Aiven | ✅ Conectada | MySQL validaciones |
| 🔐 HTTPS | ✅ Configurado | 4 dominios protegidos |

---

## 🎯 Dominios a Proteger

```
1. siiat-sat-gob.com.mx      → Módulo SAT
2. gobierno-estatal.com.mx   → Antecedentes Estatal
3. gobierno-federal.com.mx   → Antecedentes Federal
4. certificacion-sep.com.mx  → Certificados SEP
```

---

## 📋 Pasos a Seguir

### PASO 1️⃣: Apuntar DNS de tus dominios

**Ubicación:** Panel de tu proveedor de dominios (GoDaddy, Namecheap, etc)

**Crear 4 registros A:**

```
Nombre          | Tipo | Valor
----------------|------|--------
siiat-sat-gob.com.mx      | A | 146.190.162.6
gobierno-estatal.com.mx   | A | 146.190.162.6
gobierno-federal.com.mx   | A | 146.190.162.6
certificacion-sep.com.mx  | A | 146.190.162.6
```

**⏰ Tiempo:** 24-48 horas para que propague globalmente

---

### PASO 2️⃣: Verificar que DNS propagó

**Opción A - Desde PowerShell local:**
```powershell
nslookup siiat-sat-gob.com.mx
# Debe mostrar IP: 146.190.162.6
```

**Opción B - Online:**
- https://mxtoolbox.com/
- https://whatsmydns.net/

---

### PASO 3️⃣: Generar certificados Let's Encrypt

**En el servidor Digital Ocean:**

```bash
ssh root@146.190.162.6

# Instalar/actualizar Certbot (si aún no está)
apt update && apt install -y certbot python3-certbot-nginx

# Generar certificados para todos los dominios
certbot certonly --nginx \
  -d siiat-sat-gob.com.mx \
  -d gobierno-estatal.com.mx \
  -d gobierno-federal.com.mx \
  -d certificacion-sep.com.mx
```

**El proceso pedirá:**
- Email (para notificaciones de renovación)
- Aceptar términos (yes)

**Resultado:** Certificados válidos en `/etc/letsencrypt/live/`

---

### PASO 4️⃣: Actualizar Nginx (Automático con Certbot)

Certbot actualiza automáticamente `/etc/nginx/sites-available/default` con:
- Rutas de certificados
- Redirección HTTP→HTTPS
- Configuración SSL optimizada

**Verificar:**
```bash
# En el servidor:
systemctl reload nginx
systemctl status nginx
```

---

### PASO 5️⃣: Probar acceso HTTPS

**Desde PowerShell local:**
```powershell
# SAT
Invoke-WebRequest https://siiat-sat-gob.com.mx -Method Get

# Antecedentes Estatal
Invoke-WebRequest https://gobierno-estatal.com.mx -Method Get

# Antecedentes Federal
Invoke-WebRequest https://gobierno-federal.com.mx -Method Get

# Certificados
Invoke-WebRequest https://certificacion-sep.com.mx -Method Get
```

**En navegador:**
```
https://siiat-sat-gob.com.mx/app/qr/faces/pages/mobile/validadorqr.html?D3=10003_AEPR910418BP1
https://gobierno-estatal.com.mx/public/seguridad/fiscalia/noantecedentes?sello=test
```

---

## 🔄 Certificado Actual

### Estado
- **Tipo:** Autofirmado (temporal)
- **Válido hasta:** 17 de noviembre de 2027
- **Ubicación:** `/etc/nginx/ssl/`

### Comportamiento
- ✅ Conexión segura (HTTPS funciona)
- ⚠️ Navegadores muestran advertencia (no es confiable)
- ✅ Perfecto para testing

### Después de Let's Encrypt
- ✅ Conexión segura
- ✅ Navegadores NO muestran advertencia
- ✅ Certificado emitido por autoridad confiable
- ✅ Renovación automática cada 90 días

---

## 🔐 Configuración Nginx

### Archivo actual
```
/etc/nginx/sites-available/default
```

### Qué hace
1. Escucha puerto **80** (HTTP) → Redirige a HTTPS
2. Escucha puerto **443** (HTTPS) → Sirve aplicación
3. Proxy reverso a **127.0.0.1:8000** (Flask Gunicorn)
4. Permite acceso desde 4 dominios

### Certificados
- **Certificate:** `/etc/nginx/ssl/certificate.crt` (actual)
- Después: `/etc/letsencrypt/live/siiat-sat-gob.com.mx/fullchain.pem`
- **Key:** `/etc/nginx/ssl/private.key` (actual)
- Después: `/etc/letsencrypt/live/siiat-sat-gob.com.mx/privkey.pem`

---

## 🛠️ Comandos Útiles

### Ver estado de servicios
```bash
ssh root@146.190.162.6
sudo systemctl status nginx
sudo systemctl status pages_qr
```

### Ver logs
```bash
sudo journalctl -u pages_qr -f      # Logs de Flask
sudo tail -f /var/log/nginx/error.log  # Logs de Nginx
sudo tail -f /var/log/nginx/access.log # Accesos
```

### Reiniciar Nginx después de cambios
```bash
sudo systemctl reload nginx
# o
sudo systemctl restart nginx
```

### Verificar certificados instalados
```bash
sudo certbot certificates
```

### Renovación manual (si es necesario)
```bash
sudo certbot renew --nginx --force-renewal
```

### Ver configuración Nginx
```bash
cat /etc/nginx/sites-available/default
```

---

## 📊 Flujo de Acceso Después de HTTPS

```
Usuario accede
        ↓
http://dominio.com
        ↓
Nginx redirige
        ↓
https://dominio.com
        ↓
Verifica certificado Let's Encrypt
        ↓
Conexión segura establecida
        ↓
Proxy a Flask (127.0.0.1:8000)
        ↓
Flask detecta dominio en request.host
        ↓
Sirve módulo correspondiente
        ↓
Consulta BD Aiven (con SSL)
        ↓
Retorna datos encriptados
        ↓
Navegador renderiza página
```

---

## ✅ Checklist Final

Cuando hayas completado todo:

```
[ ] DNS apuntado a 146.190.162.6 para 4 dominios
[ ] DNS propagó (nslookup devuelve IP correcta)
[ ] Certbot ejecutado exitosamente
[ ] Certificados Let's Encrypt generados
[ ] Nginx recargado
[ ] HTTPS accesible sin advertencias
[ ] Módulos responden correctamente
[ ] Datos extraídos de BD Aiven
```

---

## 🚨 Troubleshooting

### "DNS no resuelve"
- Esperar 24-48 horas
- Limpiar DNS local: `ipconfig /flushdns` (Windows)
- Usar DNS público: `nslookup siiat-sat-gob.com.mx 8.8.8.8`

### "Certificado inválido / Advertencia"
- Esperar a que DNS propague antes de certbot
- Verificar que DNS resuelva correctamente
- Usar `certbot renew` para renovar

### "Error 502 Bad Gateway"
- Verificar Flask: `systemctl status pages_qr`
- Ver logs: `journalctl -u pages_qr -f`
- Reiniciar: `systemctl restart pages_qr`

### "Conexión rechazada puerto 443"
- Verificar firewall: `ufw status`
- Verificar Nginx: `systemctl status nginx`
- Ver puertos: `ss -tlnp | grep nginx`

---

## 📞 Resumen Rápido

| Elemento | Ubicación |
|----------|-----------|
| Servidor | 146.190.162.6 |
| BD | Aiven MySQL (validaciones) |
| Nginx | /etc/nginx/sites-available/default |
| Certificados Let's Encrypt | /etc/letsencrypt/live/ |
| Certificados actuales | /etc/nginx/ssl/ |
| Logs Flask | journalctl -u pages_qr |
| Logs Nginx | /var/log/nginx/ |

---

**Última actualización:** Noviembre 2026
**Estado:** Listo para Certificados Let's Encrypt
