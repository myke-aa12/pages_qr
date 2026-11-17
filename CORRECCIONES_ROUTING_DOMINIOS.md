# 🔧 Correcciones de Routing por Dominios

## Problemas Encontrados

### PROBLEMA 1️⃣: Certificados consultaba tabla equivocada
**Archivo:** `app/templates/certificados/routes.py`

**Antes:**
```python
# ❌ Consultaba tabla de ANTECEDENTES ESTATAL
consulta = text("""
    SELECT RFC, SELLO
    FROM qr_antec_est  # ← EQUIVOCADO
    WHERE ID = :id AND RFC = :rfc
""")
```

**Después:**
```python
# ✅ Consulta tabla correcta de CERTIFICADOS
consulta = text("""
    SELECT RFC, SELLO
    FROM qr_certificados  # ← CORRECTO
    WHERE ID = :id AND RFC = :rfc
""")
```

**Impacto:** Certificados SEP ahora consulta su tabla correcta, no la de Antecedentes.

---

### PROBLEMA 2️⃣: Rutas duplicadas causan conflicto
**Archivo:** `app/templates/ant_estatal/routes.py` y `app/templates/ant_federal/routes.py`

**Antes:**
```python
# ❌ AMBOS módulos usan LA MISMA RUTA
@ant_estatal.route("/public/seguridad/fiscalia/noantecedentes")
def inicio():
    return render_template("index.html")

@ant_federal.route("/public/seguridad/fiscalia/noantecedentes")  # ← DUPLICADA
def inicio():
    return render_template("index.html")
```

**Resultado:** Flask sirve el primero registrado (ant_estatal) siempre.

**Después:**
```python
# ✅ AMBAS rutas aceptadas en cada módulo
@ant_estatal.route("/public/seguridad/fiscalia/noantecedentes")
@ant_estatal.route("/public/seguridad/fiscalia/noantecedentes-estatal")
def inicio():
    return render_template("index.html")

@ant_federal.route("/public/seguridad/fiscalia/noantecedentes-federal")
def inicio():
    return render_template("index.html")
```

**Impacto:** 
- Acceso a `/public/seguridad/fiscalia/noantecedentes` desde dominio correcto funciona
- Ruta específica `-estatal` y `-federal` permite acceso directo para testing

---

### PROBLEMA 3️⃣: Domain routing mejorado en `__init__.py`
**Archivo:** `app/__init__.py`

**Antes:**
```python
# ⚠️ Domain routing básico sin context
@app.route("/")
def inicio():
    dominio = request.host.split(":")[0].lower()
    sitio = SITIOS.get(dominio)
    if sitio is None:
        abort(404)
    return render_template(sitio["plantilla"])
```

**Después:**
```python
# ✅ Domain routing con contexto para usar en templates y rutas
@app.before_request
def detectar_dominio():
    """Detecta el dominio y lo almacena en g para usar en rutas y templates"""
    dominio = request.host.split(":")[0].lower()
    sitio = SITIOS.get(dominio)
    
    if sitio is None:
        g.dominio = dominio
        g.sitio_nombre = "sat"
        g.sitio_plantilla = "sat/index.html"
    else:
        g.dominio = dominio
        g.sitio_nombre = sitio["nombre"]
        g.sitio_plantilla = sitio["plantilla"]
```

**Impacto:**
- Información del dominio disponible en `g.dominio` y `g.sitio_nombre` durante toda la request
- Permite lógica condicional en templates y blueprints
- Fallback a SAT si dominio es desconocido

---

## 🧪 Plan de Testing Local

### Test 1: Validar SAT
```bash
# Terminal 1: Iniciar servidor
python run.py

# Terminal 2: Realizar requests
curl "http://localhost:5000/app/qr/faces/pages/mobile/validadorqr.html?D3=10003_AEPR910418BP1"
# Esperado: Muestra index.html de SAT con datos
```

### Test 2: Validar Antecedentes Estatal
```bash
curl "http://localhost:5000/public/seguridad/fiscalia/noantecedentes?sello=test_sello"
# Esperado: Muestra index.html de Antecedentes Estatal

# O con ruta específica
curl "http://localhost:5000/public/seguridad/fiscalia/noantecedentes-estatal?sello=test_sello"
# Esperado: Mismo resultado
```

### Test 3: Validar Antecedentes Federal
```bash
curl "http://localhost:5000/public/seguridad/fiscalia/noantecedentes-federal?sello=test_sello"
# Esperado: Muestra index.html de Antecedentes Federal (distinto a Estatal)
```

### Test 4: Validar API Estatal
```bash
curl "http://localhost:5000/api/validacionestatal/sello_test"
# Esperado: JSON con datos de qr_antec_est o error 404
```

### Test 5: Validar API Federal
```bash
curl "http://localhost:5000/api/validacionfederal/sello_test"
# Esperado: JSON con datos de qr_antec_fed o error 404
```

### Test 6: Validar Certificados
```bash
curl "http://localhost:5000/?D3=10003_AEPR910418BP1"
# Esperado: Muestra index.html de Certificados con datos de qr_certificados
```

---

## 📝 Cambios Realizados

| Archivo | Cambio | Línea |
|---------|--------|-------|
| `app/__init__.py` | Agregado `@app.before_request` para detectar dominio | 54-70 |
| `app/templates/certificados/routes.py` | Cambiar tabla de `qr_antec_est` → `qr_certificados` | 59 |
| `app/templates/certificados/routes.py` | Cambiar log de `qr_antec_est` → `qr_certificados` | 100 |
| `app/templates/ant_estatal/routes.py` | Agregar segunda ruta `-estatal` | 12 |
| `app/templates/ant_federal/routes.py` | Ruta específica `-federal` | 12 |

---

## ✅ Validación Post-Cambios

### Local (antes de deploy)
- [ ] `python run.py` inicia sin errores
- [ ] SAT responde correctamente
- [ ] Antecedentes Estatal responde correctamente
- [ ] Antecedentes Federal responde correctamente
- [ ] Certificados responde correctamente
- [ ] APIs retornan datos correctos de cada tabla

### Después del Deploy
- [ ] `https://siiat-sat-gob.com.mx` → Módulo SAT
- [ ] `https://gobierno-estatal.com.mx` → Módulo Antecedentes Estatal
- [ ] `https://gobierno-federal.com.mx` → Módulo Antecedentes Federal
- [ ] `https://certificacion-sep.com.mx` → Módulo Certificados

---

## 🚀 Próximos Pasos

1. ✅ Cambios realizados localmente
2. 🧪 Testing local completo
3. 📤 Commit y push a GitHub
4. 🚀 Deploy en Digital Ocean
5. 📊 Verificación en producción

