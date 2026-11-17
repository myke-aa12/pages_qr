# 📚 ÍNDICE DE DESPLIEGUE - PAGES_QR

## 🎯 ¿POR DÓNDE EMPIEZO?

### Opción A: Quiero seguir paso a paso (Recomendado)
👉 **[GUIA_DESPLIEGUE_PASO_A_PASO.md](GUIA_DESPLIEGUE_PASO_A_PASO.md)**
- Instrucciones completas en español
- Paso a paso desde crear Droplet hasta verificar
- Incluye troubleshooting

### Opción B: Solo quiero ejecutar un script
👉 **[deploy-auto.sh](deploy-auto.sh)**
- Script que automatiza TODO
- Ejecutar: `bash deploy-auto.sh`
- 3-5 minutos

### Opción C: Quiero entender cada paso
👉 **[deploy.md](deploy.md)**
- Manual detallado y explicado
- Alternativa manual al script

### Opción D: Resumen rápido
👉 **[DESPLIEGUE_INICIO.txt](DESPLIEGUE_INICIO.txt)**
- Referencia visual rápida
- Checklist de comandos

---

## 📁 ARCHIVOS POR CATEGORÍA

### 🚀 DESPLIEGUE (PRINCIPAL)

| Archivo | Propósito | Cuándo usarlo |
|---------|-----------|--------------|
| **GUIA_DESPLIEGUE_PASO_A_PASO.md** ⭐ | Guía completa en español | Comienza aquí |
| **deploy-auto.sh** | Script automático | Si prefieres automatizar |
| **deploy.md** | Manual detallado | Si prefieres paso a paso |
| **pre-deploy-check.sh** | Verifica tu máquina | Antes de desplegar |
| **DESPLIEGUE_LISTO.md** | Resumen ejecutivo | Visión general rápida |
| **DESPLIEGUE_RAPIDO.md** | Versión rápida | Si tienes prisa |
| **DESPLIEGUE_INICIO.txt** | Referencia visual | Recordatorio rápido |
| **RESUMEN_DESPLIEGUE.md** | Resumen visual | Entender el proceso |

### ⚙️ CONFIGURACIÓN

| Archivo | Propósito |
|---------|-----------|
| **.env.example** | Plantilla de variables de entorno |
| **gunicorn_config.py** | Configuración del servidor Flask |
| **.gitignore** | Excluye .env de GitHub |

### 📖 DOCUMENTACIÓN DEL PROYECTO

| Archivo | Propósito |
|---------|-----------|
| **PROJECT_README.md** | Documentación del proyecto original |
| **requirements.txt** | Dependencias Python |
| **config.py** | Configuración de la app |
| **run.py** | Punto de entrada de Flask |

### 📂 ESTRUCTURA DEL CÓDIGO

```
pages_qr/
├── app/
│   ├── templates/
│   │   ├── sat/              ← Validador SAT
│   │   ├── ant_estatal/      ← Antecedentes Estatal
│   │   ├── ant_federal/      ← Antecedentes Federal
│   │   └── certificados/     ← Certificados SEP
│   ├── __init__.py
│   ├── database.py
│   └── core/
│       └── ca.pem
├── run.py
├── config.py
└── requirements.txt
```

---

## 🎓 CÓMO USAR ESTOS ARCHIVOS

### Escenario 1: Primer despliegue
```
1. Lee: GUIA_DESPLIEGUE_PASO_A_PASO.md
2. Crea Droplet en Digital Ocean
3. Ejecuta: bash deploy-auto.sh
4. Verifica en: http://TU_IP
```

### Escenario 2: Despliegue manual (aprender)
```
1. Lee: deploy.md
2. Sigue cada paso del PASO 1 al PASO 11
3. Verifica cada sección
```

### Escenario 3: Despliegue rápido (prisa)
```
1. Lee: DESPLIEGUE_RAPIDO.md
2. Ejecuta: bash deploy-auto.sh
3. Ve a: http://TU_IP
```

---

## ✅ CHECKLIST PRE-DESPLIEGUE

Antes de empezar, verifica:

- [ ] Tu código funciona localmente
- [ ] Tienes credenciales de Aiven
- [ ] Tienes cuenta de Digital Ocean
- [ ] Tu SSH key está en Digital Ocean
- [ ] Has leído GUIA_DESPLIEGUE_PASO_A_PASO.md

---

## 🚀 COMANDOS RÁPIDOS

### Ver documentación completa
```bash
# Paso a paso
cat GUIA_DESPLIEGUE_PASO_A_PASO.md

# Resumen ejecutivo
cat DESPLIEGUE_LISTO.md

# Referencia visual
cat DESPLIEGUE_INICIO.txt
```

### Desplegar
```bash
# Opción 1: Script automático
bash deploy-auto.sh

# Opción 2: Verificar primero
bash pre-deploy-check.sh
bash deploy-auto.sh
```

---

## 📊 FLUJO RECOMENDADO

```
1. Preparación Local
   └─ Leer GUIA_DESPLIEGUE_PASO_A_PASO.md

2. Crear Infraestructura
   └─ Crear Droplet en Digital Ocean

3. Desplegar Proyecto
   └─ Ejecutar: bash deploy-auto.sh

4. Verificar
   └─ Acceder a http://TU_IP

5. Configurar Credenciales
   └─ Editar .env en servidor

6. Monitorear
   └─ Ver logs: sudo journalctl -u pages_qr -f
```

---

## 🔐 SEGURIDAD

✅ Implementado:
- .env excluido de GitHub (.gitignore)
- Credenciales como placeholders en scripts
- Firewall auto-configurado
- Conexión SSL/TLS a BD

❓ Por agregar (opcional):
- SSL/TLS con Let's Encrypt
- Cambiar puerto SSH
- Monitoreo con Netdata
- Backups automáticos

---

## 💡 TIPS

### Después del despliegue
```bash
# Ver estado
sudo systemctl status pages_qr

# Ver logs
sudo journalctl -u pages_qr -f

# Reiniciar
sudo systemctl restart pages_qr

# Actualizar código
cd /home/appuser/pages_qr && git pull && sudo systemctl restart pages_qr
```

### Troubleshooting
```bash
# 502 Bad Gateway
sudo systemctl restart pages_qr

# Connection refused
sudo systemctl status pages_qr

# DB no responde
cat /home/appuser/pages_qr/.env
```

---

## 📱 PRÓXIMO PASO: BOT WHATSAPP

Cuando tengas el proyecto en Digital Ocean:
1. Obtienes credenciales de Meta WhatsApp
2. Creamos carpeta `app/whatsapp/`
3. Agregamos rutas y handlers
4. Sin interrupción al resto de servicios

---

## 🎯 RESUMEN

| Aspecto | Archivo |
|--------|---------|
| **Empezar aquí** | GUIA_DESPLIEGUE_PASO_A_PASO.md |
| **Automatizar** | deploy-auto.sh |
| **Manual paso a paso** | deploy.md |
| **Resumen rápido** | DESPLIEGUE_LISTO.md |
| **Referencia visual** | DESPLIEGUE_INICIO.txt |
| **Configuración** | .env.example |
| **Info del proyecto** | PROJECT_README.md |

---

**¿Listo? Comienza con [GUIA_DESPLIEGUE_PASO_A_PASO.md](GUIA_DESPLIEGUE_PASO_A_PASO.md)** 🚀
