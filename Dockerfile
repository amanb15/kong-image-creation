ARG KONG_VERSION=3.9.0
FROM kong/kong-gateway:${KONG_VERSION}
COPY start-kong.sh /usr/local/bin/start-kong.sh
USER root
RUN chmod +x /usr/local/bin/start-kong.sh
USER kong
ENTRYPOINT ["/usr/local/bin/start-kong.sh"]
