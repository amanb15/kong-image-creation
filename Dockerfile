FROM public.ecr.aws/amazonlinux/amazonlinux:2023

USER root

ARG KONG_VERSION
ENV KONG_VERSION=${KONG_VERSION}

RUN yum update -y && \
    yum install -y unzip tar shadow-utils && \
    yum clean all

# Add Kong OSS repo
RUN curl -fsSL https://download.konghq.com/gateway-3.x-amazonlinux-2023/config.repo \
    -o /etc/yum.repos.d/kong.repo

# Install Kong OSS
RUN yum install -y kong && \
    yum clean all

RUN kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

CMD ["kong", "docker-start"]
