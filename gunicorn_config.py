"""
Configuración de Gunicorn para producción
Ubicación en Digital Ocean: /home/appuser/pages_qr/gunicorn_config.py

Uso: gunicorn --config gunicorn_config.py run:app
"""

import multiprocessing

# Configuración básica
bind = "127.0.0.1:5000"
workers = multiprocessing.cpu_count() * 2 + 1  # Fórmula recomendada
worker_class = "sync"  # O "gevent" si instalas gevent
worker_connections = 1000
timeout = 30
keepalive = 2

# Logs
accesslog = "/var/log/pages_qr/access.log"
errorlog = "/var/log/pages_qr/error.log"
loglevel = "info"

# Otros
max_requests = 1000
max_requests_jitter = 100
preload_app = False

# Desarrollo
# debug = True
# reload = True
