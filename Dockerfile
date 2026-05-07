FROM ubuntu:24.04

COPY deps/kong.deb /tmp/kong.deb

RUN set -ex; \
    apt-get update && \
    apt-get install --yes curl /tmp/kong.deb && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /tmp/kong.deb && \
    chown kong:0 /usr/local/bin/kong && \
    chown -R kong:0 /usr/local/kong && \
    ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/luajit && \
    ln -s /usr/local/openresty/luajit/bin/luajit /usr/local/bin/lua && \
    ln -s /usr/local/openresty/nginx/sbin/nginx /usr/local/bin/nginx && \
    kong version

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh && \
    chown kong:kong /docker-entrypoint.sh

COPY kong.yml /etc/kong/kong.yml

ENV KONG_DATABASE=off
ENV KONG_DECLARATIVE_CONFIG=/etc/kong/kong.yml
ENV KONG_ADMIN_LISTEN=0.0.0.0:8001
ENV KONG_PROXY_LISTEN=0.0.0.0:8000
ENV KONG_NGINX_DAEMON=off

USER kong

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444

STOPSIGNAL SIGQUIT

HEALTHCHECK --interval=10s --timeout=10s --retries=10 \
  CMD curl -f http://localhost:8001/status || exit 1

CMD ["kong", "start"]
