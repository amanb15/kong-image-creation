FROM public.ecr.aws/amazonlinux/amazonlinux:2023

USER root

# ===== Build Arguments =====
ARG KONG_VERSION
ENV KONG_VERSION=${KONG_VERSION}

# ===== Fail fast if version not passed =====
RUN test -n "$KONG_VERSION"

# ===== Install base dependencies =====
RUN yum update -y && \
    yum install -y unzip tar shadow-utils && \
    yum clean all

# ===== Add Kong repo dynamically =====
RUN set -ex; \
    KONG_VERSION_SHORT=$(echo "$KONG_VERSION" | cut -d '.' -f 1,2); \
    curl -fsSL https://download.konghq.com/gateway-${KONG_VERSION_SHORT}.x-amazonlinux-2023/config.repo \
      -o /etc/yum.repos.d/kong.repo

# ===== Install Kong Enterprise =====
RUN yum install -y kong-enterprise && \
    yum clean all

# ===== Verify installation =====
RUN kong version

# ===== Copy entrypoint =====
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# ===== Switch to kong user =====
USER kong

# ===== Runtime config =====
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=60s --timeout=10s --retries=10 CMD kong health

CMD ["kong", "docker-start"]
