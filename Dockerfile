### 2. Core Logic of the Kong 3.9 Dockerfile
The official Dockerfile is modular, but the functional equivalent of what is happening inside `kong/kong-gateway:3.9` looks like this:
```dockerfile
# Simplified version of the official Kong 3.9 Dockerfile
FROM ubuntu:24.04

# 1. Setup environment
ENV KONG_VERSION=3.9.0
ENV ASSET=remote

# 2. Install dependencies (OpenResty, Luajit, etc.)
RUN set -ex; \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    curl ca-certificates libssl3 perl \
    # ... other system deps ...
    && rm -rf /var/lib/apt/lists/*

# 3. Install Kong package
# Kong downloads the .deb package directly from their package repo
RUN curl -fsSL [https://packages.konghq.com/public/gateway-39/debian/any-version/main/binary-amd64/kong-gateway_$](https://packages.konghq.com/public/gateway-39/debian/any-version/main/binary-amd64/kong-gateway_$){KONG_VERSION}_amd64.deb -o /tmp/kong.deb \
    && apt-get update && apt-get install -y /tmp/kong.deb \
    && rm -rf /tmp/kong.deb

# 4. Set permissions and symlinks
RUN chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/bin/resty /usr/local/bin/resty

# 5. Configuration
EXPOSE 8000 8443 8001 8444 8002 8445
STOPSIGNAL SIGQUIT
USER kong

# 6. Entrypoint (Points to a script included in the repo)
COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kong", "docker-start"]
