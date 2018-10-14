FROM docker.io/alpine:3.7

# Build-time metadata as defined at http://label-schema.org
ARG VERSION_ARG=""
ARG BUILD_DATE_ARG=""
ARG VCS_REF_ARG=""

LABEL org.label-schema.build-date=$BUILD_DATE_ARG \
      org.label-schema.name="CachetHQ Queue Worker" \
      org.label-schema.description="CachetHQ PHP Queue Worker" \
      org.label-schema.url="" \
      org.label-schema.vcs-ref=$VCS_REF_ARG \
      org.label-schema.vcs-url="https://github.com/zebby76/cachethq-docker" \
      org.label-schema.vendor="sebastian.molle@gmail.com" \
      org.label-schema.version=$VERSION_ARG \
      org.label-schema.schema-version="1.0"

USER root

ENV CACHET_VERSION=${VERSION_ARG:-2.3.15}                                                                                          \
    CACHET_DOWNLOAD_URL="https://github.com/cachethq/Cachet/archive"                                                               \
    COMPOSER_INSTALLER_SHA384SUM=""                                                                                                \
    MAIL_SMTP_SERVER=""                                                                                                            \
    MAIL_FROM_DOMAIN=""                                                                                                            \
    HOME=/home/default                                                                                                             \
    PATH=/opt/bin:/usr/local/bin:/usr/bin:$PATH

LABEL MAINTAINER="sebastian.molle@gmail.com"                                                                                       \
      application.name="CachetHQ"                                                                                                  \
      application.component="php-fpm"                                                                                              \
      io.k8s.description="Platform for running PHP-FPM 7 Processor"                                                                \
      io.k8s.display-name="PHP7-FPM"                                                                                               \
      io.openshift.tags="php7-fpm"                                                                                                 \
      application.version=${CACHET_VERSION}

WORKDIR /opt/src/cachet

COPY etc/php7 /etc/php7
COPY etc/ssmtp /etc/ssmtp
COPY bin/apk-list /usr/local/bin/apk-list
COPY bin/usage /usr/local/bin/usage
COPY bin/container-entrypoint-php /usr/local/bin/container-entrypoint
COPY bin/func_fill_in_template_file_using_env /usr/local/bin/func_fill_in_template_file_using_env
COPY bin/run-queue-worker /usr/local/bin/run-queue-worker
COPY bin/setup_postgres_db /usr/local/bin/setup_postgres_db
COPY bin/wait-for-it /usr/local/bin/wait-for-it
COPY bin/generate-cachet-appkey /usr/local/bin/generate-cachet-appkey

RUN echo "Install PHP Alpine packages ..."                                                                                      && \
    apk --update add curl tzdata bash tar gettext ssmtp mailx coreutils php7-intl php7-openssl php7-dba php7-sqlite3 php7-pear     \
                     php7-phpdbg php7-litespeed php7-gmp php7-pdo_mysql php7-pcntl php7-common php7-xsl php7-mysqlnd php7-enchant  \
                     php7-pspell php7-snmp php7-doc php7-mbstring php7-xmlrpc php7-embed php7-xmlreader php7-pdo_sqlite            \
                     php7-exif php7-opcache php7-ldap php7-posix php7-session php7-gd php7-gettext php7-json                       \
                     php7-xml php7 php7-iconv php7-sysvshm php7-curl php7-shmop php7-odbc php7-phar php7-imap                      \
                     php7-pdo_pgsql php7-pdo_dblib php7-pgsql php7-pdo_odbc php7-zip php7-ctype php7-mcrypt                        \
                     php7-wddx php7-bcmath php7-calendar php7-tidy php7-dom php7-sockets php7-soap php7-apcu                       \
                     php7-sysvmsg php7-zlib php7-ftp php7-sysvsem php7-pdo php7-bz2 php7-mysqli php7-fileinfo                      \
                     php7-simplexml php7-tokenizer php7-xmlwriter php7-redis                                                    && \
    echo "Install CachetHQ dependencies Alpine packages ..."                                                                    && \
    apk add --update postgresql                                                                                                    \
                     postgresql-client                                                                                             \
                     mysql-client                                                                                                  \
                     wget                                                                                                          \
                     grep                                                                                                          \
                     sqlite                                                                                                        \
                     git                                                                                                        && \
    echo "Setup timezone ..."                                                                                                   && \
    cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime                                                                       && \
    echo "Europe/Brussels" > /etc/timezone                                                                                      && \
    echo "Cleanup Alpine packages ..."                                                                                          && \
    rm -rf /var/cache/apk/*                                                                                                     && \
    echo "Add non-privileged user ..."                                                                                          && \
    adduser -D -u 1001 -g default -s /sbin/nologin default                                                                      && \
    echo "Setup permissions on filesystem for non-privileged user ..."                                                          && \
    mkdir -p /opt/bin /opt/etc                                                                                                  && \
    chown -Rf 1001:0 /opt /etc/ssmtp /etc/php7                                                                                  && \
    chmod -R ug+rw /opt /etc/ssmtp /etc/php7                                                                                    && \
    find /etc/ssmtp -type d -exec chmod ug+x {} \;                                                                              && \
    find /opt -type d -exec chmod ug+x {} \;                                                                                    && \
    find /etc/php7 -type d -exec chmod ug+x {} \;                                                                               && \
    chmod +x /usr/local/bin/apk-list                                                                                               \
             /usr/local/bin/generate-cachet-appkey                                                                                 \
             /usr/local/bin/container-entrypoint                                                                                   \
             /usr/local/bin/run-queue-worker                                                                                       \
             /usr/local/bin/wait-for-it                                                                                            \
             /usr/local/bin/usage                                                                                               && \
    ln -s /etc/php7 /etc/php

COPY etc/cachet/.env.docker /opt/src/cachet/.env

USER 1001

ENTRYPOINT ["container-entrypoint"]

CMD ["run-queue-worker"]
