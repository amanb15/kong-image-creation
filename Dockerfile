FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Add Kong repository (stable method)
RUN curl -fsSL https://download.konghq.com/gateway-3.x-ubuntu-noble/kong-3.x-ubuntu-noble.gpg -o /tmp/kong.gpg \
    && gpg --dearmor -o /usr/share/keyrings/kong.gpg /tmp/kong.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kong.gpg] https://download.konghq.com/gateway-3.x-ubuntu-noble default all" \
    > /etc/apt/sources.list.d/kong.list \
    && apt-get update \
    && apt-get install -y kong \
    && kong version \
    && rm -rf /var/lib/apt/lists/* /tmp/kong.gpg

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Ensure correct permissions
RUN chown -R kong:0 /usr/local/kong || true

# Switch user
USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
