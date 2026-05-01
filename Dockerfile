FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add Kong Cloudsmith repository (Enterprise)
RUN curl -1sLf https://dl.cloudsmith.io/public/kong/gateway/setup.deb.sh | bash

# Install Kong Enterprise
RUN apt-get update && apt-get install -y kong-enterprise-edition \
    && rm -rf /var/lib/apt/lists/*

# Create kong user (sometimes needed explicitly)
RUN useradd -r -s /bin/false kong || true

# Set permissions (important to avoid runtime issues)
RUN mkdir -p /usr/local/kong \
    && chown -R kong:kong /usr/local/kong

# Switch to kong user
USER kong

# Expose ports
EXPOSE 8000 8443 8001 8444

# Healthcheck
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health || exit 1

# Start Kong (IMPORTANT: use same as official image)
CMD ["kong", "docker-start"]
