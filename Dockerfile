FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal tools
RUN apt-get update && \
    apt-get install -y curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download Kong .deb directly (NO GPG / repo)
RUN curl -fL https://packages.konghq.com/public/gateway-3.x/deb/ubuntu/pool/jammy/main/k/kong/kong_3.9.1_amd64.deb \
    -o /tmp/kong.deb && \
    apt-get update && \
    apt-get install -y /tmp/kong.deb && \
    rm /tmp/kong.deb && \
    rm -rf /var/lib/apt/lists/*

# Verify installation
RUN kong version

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch user
USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

CMD ["kong", "docker-start"]
