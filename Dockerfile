FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Kong Enterprise Repository Manually
# This ensures it works for amd64 specifically
RUN curl -1sLf 'https://dl.cloudsmith.io/public/kong/gateway/gpg.74AC50D4D2024D9A.key' | gpg --dearmor -o /usr/share/keyrings/kong-gateway.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kong-gateway.gpg arch=amd64] https://dl.cloudsmith.io/public/kong/gateway/deb/ubuntu jammy main" | tee /etc/apt/sources.list.d/kong-gateway.list

# Install Kong Enterprise
RUN apt-get update && apt-get install -y kong-enterprise-edition \
    && rm -rf /var/lib/apt/lists/*

# Create kong user and set up directory
RUN useradd -r -s /bin/false kong || true
RUN mkdir -p /usr/local/kong && chown -R kong:kong /usr/local/kong

# Switch to kong user
USER kong

# Expose standard Kong ports
EXPOSE 8000 8443 8001 8444

# Healthcheck
HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health || exit 1

# Standard startup command
CMD ["kong", "docker-start"]
