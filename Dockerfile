# Use the official OpenResty image
FROM openresty/openresty:alpine

# Install required packages
RUN apk add --no-cache \
    git \
    build-base \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    perl \
    curl \
    openssl

# Install OPM (OpenResty Package Manager)
RUN opm get ledgetech/lua-resty-http \
    && opm get bungle/lua-resty-session

# Create log directory and set permissions
RUN mkdir -p /var/log/nginx \
    && chown -R nobody:nobody /var/log/nginx

# Set up the working directory
WORKDIR /usr/local/openresty/nginx

# Copy Nginx configuration
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

# Copy Lua scripts
COPY wait.lua /usr/local/openresty/lualib/wait.lua
COPY captcha.lua /usr/local/openresty/lualib/captcha.lua

# Generate self-signed SSL certificate
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Expose ports 80 and 443
EXPOSE 80 443

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]