FROM --platform=linux/amd64 kong:3.9

#USER root

# Copy your custom entrypoint (if needed)
#COPY docker-entrypoint.sh /docker-entrypoint.sh
#RUN chmod +x /docker-entrypoint.sh

# (Optional) If you need plugins or configs, add here
# COPY my-plugin /usr/local/kong/plugins/

#USER kong

#ENTRYPOINT ["/docker-entrypoint.sh"]
#CMD ["kong", "docker-start"]

#EXPOSE 8000 8443 8001 8444

#STOPSIGNAL SIGQUIT

#HEALTHCHECK --interval=10s --timeout=10s --retries=10 CMD kong health
