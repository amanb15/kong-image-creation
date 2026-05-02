FROM ubuntu:24.04

USER root

RUN set -ex; \
    apt-get update; \
    apt-get install -y curl gnupg ca-certificates lsb-release; \
    rm -rf /var/lib/apt/lists/*

# Add Cloudsmith repo (REPLACE with your actual org/repo)
RUN curl -1sLf 'https://dl.cloudsmith.io/public/your-org/your-repo/setup.deb.sh' | bash

# Install Kong Enterprise from Cloudsmith
RUN set -ex; \
    apt-get update; \
    apt-get install -y kong-enterprise-edition; \
    rm -rf /var/lib/apt/lists/*

# Ensure proper permissions (same as your original intent)
RUN chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

# Verify installation
RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 8002 8445 8003 8446 8004 8447

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
