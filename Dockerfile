FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    KONG_DATABASE=off

# Install required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    openssl \
    libpcre3 \
    perl \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy Kong .deb (from repo)
COPY deps/kong.deb /tmp/kong.deb

# Install Kong properly
RUN dpkg -i /tmp/kong.deb || true && \
    apt-get update && \
    apt-get -f install -y && \
    dpkg -i /tmp/kong.deb

# Verify installation
RUN kong version

# Fix permissions
RUN chown kong:0 /usr/local/bin/kong && \
    chown -R kong:0 /usr/local/kong

# Create required directories
RUN mkdir -p /etc/kong /var/log/kong /var/run/kong && \
    chown -R kong:kong /etc/kong /var/log/kong /var/run/kong

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Switch user
USER kong

# Expose ports
EXPOSE 8000 8443 8001 8444

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8001/status || exit 1

# Start container
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["kong", "docker-start"]
