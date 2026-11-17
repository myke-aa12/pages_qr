#!/usr/bin/env python3
"""
Script para probar el routing de dominios localmente
"""

import requests

BASE_URL = "http://localhost:5000"

TESTS = [
    {
        "nombre": "SAT",
        "ruta": "/app/qr/faces/pages/mobile/validadorqr.html?D3=10003_AEPR910418BP1",
        "buscar": "RFC",
    },
    {
        "nombre": "Antecedentes Estatal",
        "ruta": "/public/seguridad/fiscalia/noantecedentes?sello=test",
        "buscar": "Informacion de la Constancia",
    },
    {
        "nombre": "Antecedentes Federal",
        "ruta": "/public/seguridad/fiscalia/noantecedentes-federal?sello=test",
        "buscar": "Informacion de la Constancia",
    },
    {
        "nombre": "Certificados",
        "ruta": "/sep?D3=10003_AEPR910418BP1",
        "buscar": "RFC",
    }
]

for test in TESTS:
    url = f"{BASE_URL}{test['ruta']}"
    try:
        resp = requests.get(url, timeout=3)
        if resp.status_code == 200:
            if test['buscar'] in resp.text:
                print(f"[OK] {test['nombre']}: {resp.status_code} - Contiene '{test['buscar']}'")
            else:
                print(f"[FAIL] {test['nombre']}: No contiene '{test['buscar']}'")
        else:
            print(f"[FAIL] {test['nombre']}: HTTP {resp.status_code}")
    except Exception as e:
        print(f"[ERROR] {test['nombre']}: {str(e)}")

