FROM ubuntu:22.04

USER root

ARG KONG_VERSION
ENV KONG_VERSION=${KONG_VERSION}

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Add Cloudsmith repo (REPLACE this)
RUN curl -1sLf 'https://dl.cloudsmith.io/public/YOUR_ORG/YOUR_REPO/setup.deb.sh' | bash

# Debug (optional)
RUN apt-get update && apt-cache search kong || true

# Install Kong (OSS for POC)
RUN apt-get update && apt-get install -y kong

# Fix permissions
RUN chown kong:0 /usr/local/bin/kong \
    && chown -R kong:0 /usr/local/kong \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit \
    && ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua \
    && ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

# Verify install
RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && chown kong:kong /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
