FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    ca-certificates \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Add Kong repo and install
RUN curl -fsSL https://download.konghq.com/gateway-3.x-ubuntu-$(lsb_release -cs)/kong-3.x-ubuntu-$(lsb_release -cs).gpg | gpg --dearmor -o /usr/share/keyrings/kong.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/kong.gpg] https://download.konghq.com/gateway-3.x-ubuntu-$(lsb_release -cs) default all" > /etc/apt/sources.list.d/kong.list \
    && apt-get update \
    && apt-get install -y kong \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Run as kong user
USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
