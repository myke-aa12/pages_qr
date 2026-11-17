# ⚡ DESPLIEGUE RÁPIDO EN DIGITAL OCEAN

## 📋 CHECKLIST RÁPIDO (5 minutos)

### 1. Crear Droplet
```
✅ Ve a: https://cloud.digitalocean.com/
✅ Crea droplet con Ubuntu 22.04 LTS
✅ Copia la IP pública (ej: 192.168.1.100)
```

### 2. Conectarse (en tu terminal)
```bash
ssh root@192.168.1.100
# Presiona "yes" si pregunta por fingerprint
```

### 3. Ejecutar script de despliegue automático
```bash
cd /tmp
wget https://raw.githubusercontent.com/myke-aa12/pages_qr/main/deploy-auto.sh
bash deploy-auto.sh
# Espera ~3-5 minutos mientras se instala todo
```

### 4. ¡Listo! 
```
Accede a: http://192.168.1.100
La app está corriendo en: http://192.168.1.100/
```

---

## 🔧 SI ALGO FALLA

### Ver logs en tiempo real
```bash
sudo journalctl -u pages_qr -f
```

### Ver estado de servicios
```bash
sudo systemctl status pages_qr
sudo systemctl status nginx
```

### Reiniciar app
```bash
sudo systemctl restart pages_qr
```

### Actualizar código
```bash
cd /home/appuser/pages_qr
git pull
sudo systemctl restart pages_qr
```

---

## 📊 INFORMACIÓN ÚTIL

### Acceder al servidor
```bash
ssh appuser@192.168.1.100
cd /home/appuser/pages_qr
source venv/bin/activate
```

### Logs de acceso
```bash
tail -f /var/log/pages_qr/access.log
tail -f /var/log/pages_qr/error.log
```

### Monitoreo
```bash
# Ver procesos Python
ps aux | grep python

# Ver uso de RAM
free -h

# Ver conexiones
netstat -tulpn | grep -E "(5000|80|443)"
```

---

## 🌐 CONFIGURAR DOMINIO (Opcional)

### Si tienes dominio, apunta a la IP:
1. Ve a tu proveedor DNS (Godaddy, Namecheap, etc.)
2. Crea un registro A:
   - Nombre: `@` o `www`
   - Valor: `192.168.1.100` (tu IP)
3. Espera 10-30 minutos para propagación

### Luego configura SSL:
```bash
ssh appuser@192.168.1.100
sudo certbot --nginx -d tudominio.com
# Sigue las instrucciones
```

---

## 📱 PRÓXIMO PASO: BOT DE WHATSAPP

Cuando el proyecto esté en el aire, podemos agregar:
- Routes para WhatsApp
- Webhook para recibir mensajes
- Integración con la BD

Simplemente regresa cuando esté todo funcionando 🚀

---

## 🆘 SOPORTE RÁPIDO

**Problema**: 502 Bad Gateway
**Solución**: `sudo systemctl restart pages_qr && sudo systemctl restart nginx`

**Problema**: "Connection refused"
**Solución**: `sudo systemctl status pages_qr` (verifica que esté corriendo)

**Problema**: Cambios en código no se ven
**Solución**: `cd /home/appuser/pages_qr && git pull && sudo systemctl restart pages_qr`

---

¡Listo para lanzar! 🚀
