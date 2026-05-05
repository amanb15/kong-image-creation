FROM ubuntu:22.04

USER root

ENV DEBIAN_FRONTEND=noninteractive

# Minimal dependencies only
RUN apt-get update && \
    apt-get install -y curl tar gzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download Kong (direct tarball — no repo, no gpg)
RUN curl -fL https://download.konghq.com/gateway-3.9.1/kong-3.9.1-linux-amd64.tar.gz \
    -o /tmp/kong.tar.gz && \
    tar -xzf /tmp/kong.tar.gz -C /usr/local && \
    mv /usr/local/kong-* /usr/local/kong && \
    ln -s /usr/local/kong/bin/kong /usr/local/bin/kong && \
    rm /tmp/kong.tar.gz

# Create kong user
RUN useradd -r -s /bin/false kong && \
    chown -R kong:kong /usr/local/kong

# Verify installation
RUN kong version

# Entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

CMD ["kong", "docker-start"]
