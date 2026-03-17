# ============================================================
# Dockerfile — webapp-podman (Nginx + HTTPS + autenticación básica)
# Caso Práctico 2 — UNIR DevOps Azure
# ============================================================

FROM docker.io/nginx:stable-alpine

# Instalación de herramientas necesarias para TLS y autenticación
RUN apk add --no-cache openssl apache2-utils

# Generación del certificado TLS autofirmado
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out    /etc/nginx/ssl/server.crt \
        -subj   "/C=ES/ST=Madrid/L=Madrid/O=UNIR/OU=DevOps/CN=casopractico2"

# Creación del fichero de credenciales (usuario: admin / contraseña: admin123)
RUN htpasswd -bc /etc/nginx/.htpasswd admin admin123

# Configuración de Nginx y contenido HTML
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/ /usr/share/nginx/html/

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
