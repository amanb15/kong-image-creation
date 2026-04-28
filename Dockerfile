FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base deps
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Kong Cloudsmith repo (THIS is the correct step)
RUN curl -1sLf \
'https://dl.cloudsmith.io/public/kong/gateway-311/setup.deb.sh' \
| bash

# Install Kong
RUN apt-get update \
    && apt-get install -y kong-enterprise-edition \
    && kong version \
    && rm -rf /var/lib/apt/lists/*

# Add entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Fix permissions (optional safety)
RUN chown -R kong:0 /usr/local/kong || true

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
