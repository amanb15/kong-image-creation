FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG KONG_VERSION=3.9.0.0

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Download Kong Enterprise package directly (IMPORTANT)
RUN curl -fL \
https://packages.konghq.com/public/gateway-39/deb/ubuntu/pool/jammy/main/k/ko/kong-enterprise-edition_${KONG_VERSION}_amd64.deb \
-o /tmp/kong.deb

# Install Kong from local package
RUN apt-get update \
    && apt-get install -y /tmp/kong.deb \
    && rm -rf /tmp/kong.deb \
    && rm -rf /var/lib/apt/lists/*

# Create kong user (if not exists)
RUN useradd -r -s /bin/false kong || true

# Fix permissions
RUN mkdir -p /usr/local/kong && chown -R kong:kong /usr/local/kong

# Switch user
USER kong

# Expose ports
EXPOSE 8000 8443 8001 8444

# Healthcheck
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health || exit 1

# Start Kong
CMD ["kong", "docker-start"]
