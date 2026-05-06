FROM ubuntu:24.04

# Set environment
ENV DEBIAN_FRONTEND=noninteractive

# Install required base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    openssl \
    libpcre3 \
    perl \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy Kong .deb package (from repo)
COPY deps/kong.deb /tmp/kong.deb

# Install Kong
RUN dpkg -i /tmp/kong.deb || apt-get update && apt-get -f install -y

# Verify installation
RUN kong version

# Fix permissions
RUN chown kong:0 /usr/local/bin/kong && \
    chown -R kong:0 /usr/local/kong

# Create symlinks
RUN ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit && \
    ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua && \
    ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx

# Create required directories
RUN mkdir -p /etc/kong /var/log/kong /var/run/kong && \
    chown -R kong:kong /etc/kong /var/log/kong /var/run/kong

# Copy entrypoint
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
