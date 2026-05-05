FROM public.ecr.aws/amazonlinux/amazonlinux:2023

ARG KONG_VERSION
ENV KONG_VERSION=${KONG_VERSION}

# Install dependencies
RUN yum update -y && \
    yum install -y unzip tar shadow-utils

# Install Kong Enterprise RPM
RUN set -ex; \
    KONG_VERSION_SHORT=$(echo "$KONG_VERSION" | cut -d '.' -f 1,2); \
    curl -fsSL https://download.konghq.com/gateway-${KONG_VERSION_SHORT}.x-amazonlinux-2023/config.repo \
      -o /etc/yum.repos.d/kong.repo; \
    yum install -y kong-enterprise-${KONG_VERSION}

# Verify
RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

CMD ["kong", "docker-start"]
