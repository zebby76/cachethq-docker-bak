FROM docker.io/alpine:3.7

# Build-time metadata as defined at http://label-schema.org
ARG VERSION_ARG=""
ARG BUILD_DATE_ARG=""
ARG VCS_REF_ARG=""

LABEL org.label-schema.build-date=$BUILD_DATE_ARG \
      org.label-schema.name="CachetHQ Webserver" \
      org.label-schema.description="CachetHQ NGinx Webserver" \
      org.label-schema.url="" \
      org.label-schema.vcs-ref=$VCS_REF_ARG \
      org.label-schema.vcs-url="https://github.com/zebby76/cachethq-docker" \
      org.label-schema.vendor="sebastian.molle@gmail.com" \
      org.label-schema.version=$VERSION_ARG \
      org.label-schema.schema-version="1.0"

USER root

ENV CACHET_VERSION=${VERSION_ARG}                                                                                                  \
    HOME=/opt                                                                                                                      \
    PATH=/opt/bin:/usr/local/bin:/usr/bin:$PATH

WORKDIR ${HOME}

COPY etc/nginx /etc/nginx
COPY bin/apk-list /usr/local/bin/apk-list
COPY bin/usage /usr/local/bin/usage
COPY bin/container-entrypoint-web /usr/local/bin/container-entrypoint
COPY bin/run-web /usr/local/bin/run-web

RUN apk add --update tzdata bash coreutils nginx curl                                                                           && \
    echo "Setup timezone ..."                                                                                                   && \
    cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime                                                                       && \
    echo "Europe/Brussels" > /etc/timezone                                                                                      && \
    echo "Cleanup Alpine packages ..."                                                                                          && \
    apk del tzdata                                                                                                              && \
    rm -rf /var/cache/apk/*                                                                                                     && \
    echo "Add non-privileged user ..."                                                                                          && \
    adduser -D -u 1001 -g default -s /sbin/nologin default                                                                      && \
    echo "Setup permissions on filesystem for non-privileged user ..."                                                          && \
    rm /etc/nginx/conf.d/default.conf                                                                                           && \
    mkdir -p /etc/nginx/sites-enabled                                                                                              \
             /var/log/nginx                                                                                                        \
             /var/cache/nginx                                                                                                      \
             /var/run/nginx                                                                                                        \
             /var/lib/nginx                                                                                                        \
             /usr/share/nginx/cache/fcgi                                                                                           \
             /var/tmp/nginx                                                                                                        \
             /opt/src                                                                                                           && \
    chown -R 1001:0 /etc/nginx                                                                                                     \
                    /var/log/nginx                                                                                                 \
                    /var/run/nginx                                                                                                 \
                    /var/cache/nginx                                                                                               \
                    /var/lib/nginx                                                                                                 \
                    /usr/share/nginx                                                                                               \
                    /var/tmp/nginx                                                                                                 \
                    /opt/src                                                                                                    && \
    chmod -R ug+rw /etc/nginx                                                                                                      \
                   /var/log/nginx                                                                                                  \
                   /var/run/nginx                                                                                                  \
                   /var/cache/nginx                                                                                                \
                   /var/lib/nginx                                                                                                  \
                   /usr/share/nginx                                                                                                \
                   /var/tmp/nginx                                                                                                  \
                   /opt/src                                                                                                     && \
    chmod +x /usr/local/bin/apk-list                                                                                               \
             /usr/local/bin/container-entrypoint                                                                                   \
             /usr/local/bin/run-web                                                                                                \
             /usr/local/bin/usage                                                                                               && \
    find /etc/nginx -type d -exec chmod ug+x {} \;                                                                              && \
    find /var/log/nginx -type d -exec chmod ug+x {} \;                                                                          && \
    find /var/run/nginx -type d -exec chmod ug+x {} \;                                                                          && \
    find /var/lib/nginx -type d -exec chmod ug+x {} \;                                                                          && \
    find /var/tmp/nginx -type d -exec chmod ug+x {} \;                                                                          && \
    find /usr/share/nginx -type d -exec chmod ug+x {} \;                                                                        && \
    find /opt/src -type d -exec chmod ug+x {} \;                                                                                && \
    touch /var/log/nginx/access.log                                                                                             && \
    touch /var/log/nginx/error.log                                                                                              && \
    ln -sf /dev/stdout /var/log/nginx/access.log                                                                                && \
    ln -sf /dev/stderr /var/log/nginx/error.log

USER 1001

ENTRYPOINT ["container-entrypoint"]

EXPOSE 8080

CMD ["run-web"]
