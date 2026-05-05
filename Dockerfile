FROM public.ecr.aws/amazonlinux/amazonlinux:2023

ARG KONG_VERSION
ENV KONG_VERSION=${KONG_VERSION}

# Install dependencies
RUN yum update -y && \
    yum install -y curl unzip tar shadow-utils

# Install Kong Enterprise RPM
RUN set -ex; \
    KONG_VERSION_SHORT=$(echo "$KONG_VERSION" | cut -d '.' -f 1,2 | tr -d '.'); \
    DOWNLOAD_URL="https://packages.konghq.com/public/gateway-${KONG_VERSION_SHORT}/rpm/amzn/2023/x86_64/kong-enterprise-edition-${KONG_VERSION}.rpm"; \
    curl -fL $DOWNLOAD_URL -o /tmp/kong.rpm; \
    yum install -y /tmp/kong.rpm; \
    rm /tmp/kong.rpm

# Verify
RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

CMD ["kong", "docker-start"]
