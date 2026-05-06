FROM ubuntu:24.04

# Set build arguments and environment
ARG KONG_VERSION=3.9.1
ENV DEBIAN_FRONTEND=noninteractive \
    KONG_VERSION=${KONG_VERSION}

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Add Kong GPG key for signature verification
RUN mkdir -p /usr/share/keyrings && \
    curl -fsSL https://download.konghq.com/gateway-3.x-ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/kong.gpg

# Add Kong repository with signature verification
RUN echo "deb [signed-by=/usr/share/keyrings/kong.gpg] https://download.konghq.com/gateway-3.x-ubuntu jammy main" | \
    tee /etc/apt/sources.list.d/kong.list > /dev/null

# Install Kong with specific version pinning
RUN apt-get update && \
    apt-get install -y --no-install-recommends kong=${KONG_VERSION}-1 && \
    rm -rf /var/lib/apt/lists/* && \
    kong version

# Fix permissions
RUN chown kong:0 /usr/local/bin/kong && \
    chown -R kong:0 /usr/local/kong

# Create symlinks for tools
RUN ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit && \
    ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua && \
    ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

# Create necessary directories
RUN mkdir -p /etc/kong /var/log/kong /var/run/kong && \
    chown -R kong:kong /etc/kong /var/log/kong /var/run/kong

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh && \
    chown kong:kong /docker-entrypoint.sh

# Switch to non-root user
USER kong

# Expose ports
EXPOSE 8000 8443 8001 8444

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8001/status || exit 1

# Signal handling
STOPSIGNAL SIGQUIT

# Entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# Default command
CMD ["kong", "docker-start"]
