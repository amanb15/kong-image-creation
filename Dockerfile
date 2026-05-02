FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Kong Cloudsmith repo (OFFICIAL WAY)
RUN curl -1sLf https://dl.cloudsmith.io/public/kong/gateway/setup.deb.sh | bash

# Install Kong Enterprise
RUN apt-get update && apt-get install -y kong-enterprise-edition \
    && rm -rf /var/lib/apt/lists/*

# Create kong user
RUN useradd -r -s /bin/false kong || true

# Fix permissions
RUN mkdir -p /usr/local/kong && chown -R kong:kong /usr/local/kong

# Switch user
USER kong

# Ports
EXPOSE 8000 8443 8001 8444

# Healthcheck
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health || exit 1

# Start Kong
CMD ["kong", "docker-start"]
