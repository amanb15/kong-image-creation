FROM ubuntu:24.04

USER root

# Install prerequisites
RUN set -ex; \
    apt-get update; \
    apt-get install -y curl gnupg ca-certificates lsb-release; \
    rm -rf /var/lib/apt/lists/*

# Add Cloudsmith repository (REPLACE with your actual repo)
RUN curl -1sLf 'https://dl.cloudsmith.io/public/YOUR_ORG/YOUR_REPO/setup.deb.sh' | bash

# Debug: verify repo added
RUN ls -l /etc/apt/sources.list.d/ && cat /etc/apt/sources.list.d/* || true

# Update and check available Kong packages
RUN set -ex; \
    apt-get update; \
    apt-cache search kong || true

# Install Kong (UPDATE package name if needed based on above output)
RUN set -ex; \
    apt-get update; \
    apt-get install -y kong-enterprise-edition; \
    rm -rf /var/lib/apt/lists/*

# Fix permissions and paths
RUN chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

# Verify installation
RUN kong version

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444 8002 8445 8003 8446 8004 8447

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
