FROM ubuntu:22.04

USER root

# Install base dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Add Kong GPG key
RUN curl -fsSL https://download.konghq.com/gateway-3.x-ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/kong.gpg

# Add Kong repository
RUN echo "deb [signed-by=/usr/share/keyrings/kong.gpg] https://download.konghq.com/gateway-3.x-ubuntu jammy main" \
    > /etc/apt/sources.list.d/kong.list

# Install Kong
RUN apt-get update && \
    apt-get install -y kong && \
    rm -rf /var/lib/apt/lists/*

# Verify installation
RUN kong version

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Use kong user (created by package)
USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
