FROM docker.io/alpine:3.7

ARG CACHET_VERSION_ARG=""

USER root

ENV CACHET_VERSION=${CACHET_VERSION_ARG}                                                                                           \
    HOME=/opt                                                                                                                      \
    PATH=/opt/bin:/usr/local/bin:/usr/bin:$PATH

LABEL MAINTAINER="sebastian.molle@gmail.com"                                                                                       \
      application.name="CachetHQ"                                                                                                  \
      application.component="NGinx"                                                                                                \
      io.k8s.description="Platform for running NGinx Webserver"                                                                    \
      io.k8s.display-name="NGinx"                                                                                                  \
      application.version=${CACHET_VERSION}

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
