#!/usr/bin/env python3

config = """server {
    listen 80;
    server_name gobierno-estatal.com.mx gobierno-federal.com.mx siiat-sat-gob.com.mx;
    client_max_body_size 50M;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name gobierno-estatal.com.mx gobierno-federal.com.mx siiat-sat-gob.com.mx;
    client_max_body_size 50M;
    
    ssl_certificate /etc/letsencrypt/live/gobierno-estatal.com.mx/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/gobierno-estatal.com.mx/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
    }
}
"""

with open('/etc/nginx/sites-available/pages_qr', 'w') as f:
    f.write(config)
print("HTTPS config written successfully")
