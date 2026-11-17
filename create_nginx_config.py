#!/usr/bin/env python3
import sys

config = """server {
    listen 80;
    server_name gobierno-estatal.com.mx gobierno-federal.com.mx siiat-sat-gob.com.mx;
    client_max_body_size 50M;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
    }
}"""

with open('/etc/nginx/sites-available/pages_qr', 'w') as f:
    f.write(config)
print("Config written successfully")
