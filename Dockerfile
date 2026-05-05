FROM ubuntu:22.04

USER root

ARG KONG_VERSION=3.9.1
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl ca-certificates gnupg lsb-release && \
    rm -rf /var/lib/apt/lists/*

# Add Kong GPG key
RUN curl -fsSL https://download.konghq.com/gateway-3.x-ubuntu/gpg | \
    gpg --dearmor -o /usr/share/keyrings/kong.gpg

# Add Kong repo
RUN echo "deb [signed-by=/usr/share/keyrings/kong.gpg] https://download.konghq.com/gateway-3.x-ubuntu jammy main" \
    > /etc/apt/sources.list.d/kong.list

# Install Kong
RUN apt-get update && \
    apt-get install -y kong && \
    rm -rf /var/lib/apt/lists/*

# Verify
RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

CMD ["kong", "docker-start"]
