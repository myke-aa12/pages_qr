# 📋 Proyecto QR Validador - Mapeo y Documentación

## 🎯 Propósito del Proyecto

Sistema web de validación de documentos y constancias del gobierno mexicano mediante códigos QR. Permite verificar la autenticidad de:
- Constancias de Situación Fiscal (SAT)
- Certificados de Antecedentes No Penales (Estatal)
- Certificados de Antecedentes No Penales (Federal)
- Certificados de Educación (SEP)

---

## 📊 Arquitectura General

```
pages_qr/
├── run.py                          # Punto de entrada (inicia servidor Flask)
├── config.py                       # Configuración de variables de entorno
├── requirements.txt                # Dependencias Python
├── .env                            # Variables de entorno (credenciales BD)
├── app/
│   ├── __init__.py                 # Creación de app Flask y registro de blueprints
│   ├── database.py                 # Conexión a MySQL/Aiven
│   ├── core/
│   │   ├── domains.py              # Mapeo de dominios a módulos
│   │   └── ca.pem                  # Certificado SSL de Aiven
│   └── templates/
│       ├── sat/                    # Módulo SAT
│       │   ├── routes.py           # Rutas de SAT
│       │   ├── index.html          # Template de SAT
│       │   └── [css/js/img]/
│       ├── ant_estatal/            # Módulo Antecedentes Estatal
│       │   ├── routes.py           # Rutas de Antecedentes Estatal
│       │   ├── index.html          # Template de Antecedentes Estatal
│       │   └── [css/js/img]/
│       ├── ant_federal/            # Módulo Antecedentes Federal
│       │   ├── routes.py           # Rutas de Antecedentes Federal
│       │   ├── index.html          # Template de Antecedentes Federal
│       │   └── [css/js/img]/
│       └── certificados/           # Módulo Certificados
│           ├── routes.py           # Rutas de Certificados
│           ├── index.html          # Template de Certificados
│           └── [css/js/img]/
```

---

## 🗄️ Base de Datos

**Proveedor:** Aiven (MySQL Cloud)
**Base de Datos:** `validaciones`
**Certificado SSL:** `app/core/ca.pem`

### Tablas Utilizadas

| Tabla | Descripción | Campos Principales |
|-------|-------------|-------------------|
| `qrsat` | Constancias del SAT | ID, RFC, SELLO |
| `qr_antec_est` | Antecedentes Estatales | NOMBRE_COMPLETO, CURP, FECHA_EXPEDICION, VIGENCIA, FOLIO, SELLO |
| `qr_antec_fed` | Antecedentes Federales | NOMBRE_COMPLETO, CURP, FECHA_EXPEDICION, VIGENCIA, FOLIO, SELLO |
| `qr_certificados` | Certificados SEP | ID, RFC, SELLO |

---

## 🌐 Sistema de Dominios

El proyecto detecta el dominio accedido y sirve el módulo correspondiente:

| Dominio | Módulo | Template | Descripción |
|---------|--------|----------|-------------|
| `siiat-sat-gob.com.mx` | `sat` | `sat/index.html` | Validador SAT |
| `gobierno-estatal.com.mx` | `ant_estatal` | `ant_estatal/index.html` | Antecedentes Estatal |
| `gobierno-federal.com.mx` | `ant_federal` | `ant_federal/index.html` | Antecedentes Federal |
| `certificacion-sep.com.mx` | `certificados` | `certificados/index.html` | Certificados SEP |
| `localhost` | `sat` | `sat/index.html` | Desarrollo local |

---

## 🔄 Flujos de Validación

### 1️⃣ SAT (Constancias de Situación Fiscal)

**Ruta:** `/app/qr/faces/pages/mobile/validadorqr.html`

**Parámetro:** `D3=ID_RFC` (ej: `?D3=1793658099964896_AEPR910418BP1`)

**Proceso:**
1. Usuario accede a URL con parámetro `D3`
2. Backend valida formato `ID_RFC`
3. Consulta tabla `qrsat` por ID y RFC
4. Extrae campos: `RFC`, `SELLO`
5. Renderiza `index.html` con datos

**Datos Mostrados:**
- RFC
- Cadena Original (SELLO)

---

### 2️⃣ Antecedentes Estatal

**Ruta Página:** `/public/seguridad/fiscalia/noantecedentes`
**Ruta API:** `/api/validacionestatal/{sello}`

**Parámetro:** `?sello=valor_del_sello`

**Proceso:**
1. Usuario accede a página principal
2. JavaScript obtiene parámetro `sello` de URL
3. Fetch automático a `/api/validacionestatal/{sello}`
4. Backend consulta tabla `qr_antec_est` por SELLO
5. Devuelve JSON con datos
6. JavaScript llena formulario HTML

**Datos Mostrados:**
- Nombre Completo
- CURP
- Fecha de Expedición
- Vigencia
- Folio

---

### 3️⃣ Antecedentes Federal

**Ruta Página:** `/public/seguridad/fiscalia/noantecedentes`
**Ruta API:** `/api/validacionfederal/{sello}`

**Parámetro:** `?sello=valor_del_sello`

**Proceso:** Idéntico a Antecedentes Estatal pero consulta tabla `qr_antec_fed`

**Datos Mostrados:** Idénticos a Antecedentes Estatal

---

### 4️⃣ Certificados SEP

**Ruta:** `/`

**Parámetro:** `D3=ID_RFC` (ej: `?D3=1793658099964896_AEPR910418BP1`)

**Proceso:** Idéntico a SAT pero consulta tabla `qr_certificados`

**Datos Mostrados:**
- RFC
- Cadena Original (SELLO)

---

## 📁 Archivos Clave

### `run.py`
```python
# Inicia el servidor Flask en puerto 5000
# Host: 0.0.0.0 (accesible desde cualquier IP)
# Debug: True (solo en desarrollo)
```

### `config.py`
```python
# Lee variables del .env:
# - SECRET_KEY: Clave secreta de Flask
# - SQLALCHEMY_DATABASE_URI: URL conexión MySQL
# - DB_CA_CERT: Ruta del certificado SSL
```

### `app/__init__.py`
```python
# Crea la aplicación Flask
# Registra blueprints de cada módulo
# Mapea dominios a templates
# Inicializa conexión a BD
```

### `app/database.py`
```python
# Gestiona conexión a MySQL
# Configura SSL con certificado Aiven
# Pool de conexiones para optimizar
# Retorna sesiones para queries
```

### `app/templates/*/routes.py`
```python
# Cada módulo tiene sus propias rutas
# SAT y Certificados: búsqueda por ID + RFC
# Antecedentes: búsqueda por SELLO + API JSON
```

---

## 🚀 Cómo Ejecutar

### Requisitos
- Python 3.8+
- MySQL (Aiven)
- Acceso a dominio personalizado o modificar hosts

### Instalación
```bash
# Activar venv
.venv\Scripts\Activate.ps1

# Instalar dependencias
pip install -r requirements.txt

# Ejecutar
python run.py
```

### URLs de Prueba

**SAT:**
```
http://localhost:5000/app/qr/faces/pages/mobile/validadorqr.html?D3=10003_AEPR910418BP1
```

**Antecedentes Estatal:**
```
http://localhost:5000/public/seguridad/fiscalia/noantecedentes?sello=valor_sello
```

**Antecedentes Federal:**
```
http://localhost:5000/public/seguridad/fiscalia/noantecedentes?sello=valor_sello
```

**Certificados:**
```
http://localhost:5000/?D3=10003_AEPR910418BP1
```

---

## 🔐 Configuración Seguridad

### Variables de Entorno (.env)
```
SECRET_KEY=tu_clave_secreta
DATABASE_URL=mysql+pymysql://usuario:contraseña@host:puerto/bd
DB_CA_CERT=app/core/ca.pem
```

### Conexión SSL
- Verificación de certificado activada
- Pool de conexiones con timeout
- Reciclaje automático de conexiones

---

## 📊 Flujo de Datos

```
Usuario
   ↓
[Dominio/URL]
   ↓
[app/__init__.py - Router de Dominios]
   ↓
[app/templates/*/routes.py - Rutas Específicas]
   ↓
[app/database.py - Conexión MySQL]
   ↓
[Tablas en Aiven: qrsat/qr_antec_est/qr_antec_fed/qr_certificados]
   ↓
[JSON o HTML con datos]
   ↓
[Cliente - Muestra datos en página]
```

---

## ✅ Estados de Respuesta

| Código | Significado |
|--------|-------------|
| 200 | ✅ Datos encontrados y mostrados |
| 400 | ❌ Parámetros inválidos |
| 404 | ❌ Registro no encontrado en BD |
| 500 | ❌ Error en consulta a BD |

---

## 🔧 Tecnologías Utilizadas

| Componente | Tecnología |
|-----------|-----------|
| Backend | Flask (Python) |
| BD | MySQL (Aiven) |
| ORM | SQLAlchemy |
| Frontend | HTML5, CSS3, JavaScript (Vanilla) |
| Framework CSS | GOB.MX (Gobierno de México) |
| SSL | Certificado CA Aiven |

---

## 📝 Notas Importantes

1. **Dominios Falsos:** El proyecto usa dominios que simulan ser oficiales para demostración. **No usar en producción sin cambios.**

2. **Tablas Esperadas:** Todas las tablas deben existir en la BD `validaciones` con los campos especificados.

3. **Parámetros de URL:**
   - SAT/Certificados: `D3=ID_RFC` (separado por guion bajo)
   - Antecedentes: `sello=SELLO` (valor directo)

4. **Certificado SSL:** Debe existir en `app/core/ca.pem` para conexión segura a Aiven.

5. **Desarrollo Local:** Para pruebas sin dominios personalizados, usar `localhost` (ya configurado).

---

## 📧 Contacto y Soporte

Para preguntas o issues sobre el proyecto, revisar los comentarios en el código o la estructura del proyecto.

**Última actualización:** Noviembre 2026
**Estado:** En desarrollo/Producción
