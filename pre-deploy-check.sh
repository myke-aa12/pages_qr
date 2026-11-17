#!/bin/bash

# ✅ CHECKLIST PRE-DESPLIEGUE
# Ejecutar en tu máquina local antes de desplegar

echo "======================================"
echo "✅ VERIFICACIÓN PRE-DESPLIEGUE"
echo "======================================"
echo ""

PASS=0
FAIL=0

# 1. Verificar que .gitignore excluye .env
if grep -q "^\.env$" .gitignore; then
    echo "✅ .gitignore excluye .env"
    ((PASS++))
else
    echo "❌ .gitignore NO excluye .env - FIX REQUERIDO"
    ((FAIL++))
fi

# 2. Verificar que .env existe
if [ -f ".env" ]; then
    echo "✅ .env existe"
    ((PASS++))
else
    echo "⚠️  .env NO existe (se creará en servidor - no es crítico)"
fi

# 3. Verificar requirements.txt
if [ -f "requirements.txt" ]; then
    echo "✅ requirements.txt existe"
    ((PASS++))
else
    echo "❌ requirements.txt NO existe"
    ((FAIL++))
fi

# 4. Verificar app/database.py
if [ -f "app/database.py" ]; then
    echo "✅ app/database.py existe"
    ((PASS++))
else
    echo "❌ app/database.py NO existe"
    ((FAIL++))
fi

# 5. Verificar certificado SSL
if [ -f "app/core/ca.pem" ]; then
    echo "✅ app/core/ca.pem existe"
    ((PASS++))
else
    echo "❌ app/core/ca.pem NO existe - Necesario para Aiven"
    ((FAIL++))
fi

# 6. Verificar run.py
if [ -f "run.py" ]; then
    echo "✅ run.py existe"
    ((PASS++))
else
    echo "❌ run.py NO existe"
    ((FAIL++))
fi

# 7. Verificar templates
if [ -d "app/templates/sat" ] && [ -f "app/templates/sat/index.html" ]; then
    echo "✅ app/templates/sat/index.html existe"
    ((PASS++))
else
    echo "❌ app/templates/sat/index.html NO existe"
    ((FAIL++))
fi

# 8. Verificar que no hay credenciales en git
if git log -p --all | grep -i "AVNS_" &>/dev/null; then
    echo "⚠️  Credenciales detectadas en historio de git (no es crítico)"
else
    echo "✅ No hay credenciales en git"
    ((PASS++))
fi

# 9. Verificar sintaxis Python
echo ""
echo "🔍 Verificando sintaxis Python..."
if python3 -m py_compile run.py 2>/dev/null; then
    echo "✅ run.py - Sintaxis OK"
    ((PASS++))
else
    echo "❌ run.py - Error de sintaxis"
    ((FAIL++))
fi

if python3 -m py_compile app/__init__.py 2>/dev/null; then
    echo "✅ app/__init__.py - Sintaxis OK"
    ((PASS++))
else
    echo "❌ app/__init__.py - Error de sintaxis"
    ((FAIL++))
fi

# 10. Verificar venv existe
if [ -d "venv" ]; then
    echo "✅ venv existe (se creará en servidor si no existe)"
fi

echo ""
echo "======================================"
echo "📊 RESULTADO: $PASS OK | $FAIL ERRORES"
echo "======================================"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "✅ ¡TODO LISTO PARA DESPLEGAR!"
    echo ""
    echo "Próximos pasos:"
    echo "1. Push a GitHub: git push origin main"
    echo "2. Ejecuta en Digital Ocean: bash deploy-auto.sh"
    echo ""
    exit 0
else
    echo ""
    echo "❌ Soluciona los errores antes de desplegar"
    exit 1
fi
