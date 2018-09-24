FROM docker.io/alpine:3.7

ARG CACHET_VERSION_ARG=""

USER root

ENV CACHET_VERSION=${CACHET_VERSION_ARG:-2.3.15}                                                                                   \
    CACHET_DOWNLOAD_URL="https://github.com/cachethq/Cachet/archive"                                                               \
    COMPOSER_INSTALLER_SHA384SUM=""                                                                                                \
    MAIL_SMTP_SERVER=""                                                                                                            \
    MAIL_FROM_DOMAIN=""                                                                                                            \
    PHP_FPM_MAX_CHILDREN=${PHP_FPM_MAX_CHILDREN:-5}                                                                                \
    PHP_FPM_REQUEST_MAX_MEMORY_IN_MEGABYTES=${PHP_FPM_REQUEST_MAX_MEMORY_IN_MEGABYTES:-64}                                         \
    CONTAINER_HEAP_PERCENT=${CONTAINER_HEAP_PERCENT:-0.80}                                                                         \
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
COPY bin/dynamic_resources /usr/local/bin/dynamic_resources
COPY bin/func_fill_in_template_file_using_env /usr/local/bin/func_fill_in_template_file_using_env
COPY bin/run-php /usr/local/bin/run-php
COPY bin/setup_postgres_db /usr/local/bin/setup_postgres_db
COPY bin/wait-for-it /usr/local/bin/wait-for-it

RUN echo "Install PHP Alpine packages ..."                                                                                      && \
    apk --update add curl tzdata bash tar gettext ssmtp mailx coreutils php7-intl php7-openssl php7-dba php7-sqlite3 php7-pear     \
                     php7-phpdbg php7-litespeed php7-gmp php7-pdo_mysql php7-pcntl php7-common php7-xsl php7-mysqlnd php7-enchant  \
                     php7-pspell php7-snmp php7-doc php7-mbstring php7-xmlrpc php7-embed php7-xmlreader php7-pdo_sqlite            \
                     php7-exif php7-opcache php7-ldap php7-posix php7-session php7-gd php7-gettext php7-json                       \
                     php7-xml php7 php7-iconv php7-sysvshm php7-curl php7-shmop php7-odbc php7-phar php7-imap                      \
                     php7-pdo_pgsql php7-pdo_dblib php7-pgsql php7-pdo_odbc php7-zip php7-ctype php7-mcrypt                        \
                     php7-wddx php7-bcmath php7-calendar php7-tidy php7-dom php7-sockets php7-soap php7-apcu                       \
                     php7-sysvmsg php7-zlib php7-ftp php7-sysvsem php7-pdo php7-bz2 php7-mysqli php7-fileinfo mysql-client         \
                     php7-simplexml php7-tokenizer php7-xmlwriter php7-fpm postgresql-client postgresql php7-redis              && \
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
    echo "Download and install Composer ..."                                                                                    && \
    curl -sSfLk https://getcomposer.org/installer -o /tmp/composer-setup.php                                                    && \
    curl -sSfLk https://composer.github.io/installer.sig -o /tmp/composer-setup.sig                                             && \
    COMPOSER_INSTALLER_SHA384SUM=$(cat /tmp/composer-setup.sig)                                                                 && \
    echo "$COMPOSER_INSTALLER_SHA384SUM /tmp/composer-setup.php" | sha384sum -c                                                 && \
    php /tmp/composer-setup.php --disable-tls --install-dir=/usr/local/bin                                                      && \
    rm /tmp/composer-setup.php /tmp/composer-setup.sig                                                                          && \
    ln -s /usr/local/bin/composer.phar /usr/local/bin/composer                                                                  && \
    chmod +x /usr/local/bin/composer.phar /usr/local/bin/composer                                                               && \
    mkdir /home/default/.composer                                                                                               && \
    echo "Download and install CachetHQ ..."                                                                                    && \
    mkdir -p /opt/src/cachet                                                                                                    && \
    curl -sSfLk ${CACHET_DOWNLOAD_URL}/v${CACHET_VERSION}.tar.gz                                                                 | \
    tar -xzC /opt/src/cachet --strip-components=1                                                                               && \
    cd /opt/src/cachet                                                                                                          && \
    composer global require "hirak/prestissimo:^0.3"                                                                            && \
    composer -vvvv install --no-interaction --no-suggest --no-dev --working-dir /opt/src/cachet -o                              && \
    rm -rf /opt/src/cachet/bootstrap/cache/*                                                                                    && \
    chown -Rf 1001:0 /opt/src/cachet                                                                                            && \
    chmod -R ug+rw /opt/src/cachet                                                                                              && \
    find /opt/src/cachet -type d -exec chmod ug+x {} \;                                                                         && \
    echo "Setup permissions on filesystem for non-privileged user ..."                                                          && \
    mkdir -p /opt/bin /opt/etc /var/log/php-fpm /var/run/php-fpm /var/php/session /var/php/wsdlcache                            && \
    chown -Rf 1001:0 /opt /etc/ssmtp /etc/php7 /var/log/php-fpm /var/run/php-fpm /var/php/session /var/php/wsdlcache            && \
    chmod -R ug+rw /opt /etc/ssmtp /etc/php7 /var/log/php-fpm /var/run/php-fpm /var/php/session /var/php/wsdlcache              && \
    find /etc/ssmtp -type d -exec chmod ug+x {} \;                                                                              && \
    find /opt -type d -exec chmod ug+x {} \;                                                                                    && \
    find /etc/php7 -type d -exec chmod ug+x {} \;                                                                               && \
    chmod +x /usr/local/bin/apk-list                                                                                               \
             /usr/local/bin/container-entrypoint                                                                                   \
             /usr/local/bin/run-php                                                                                                \
             /usr/local/bin/wait-for-it                                                                                            \
             /usr/local/bin/usage                                                                                               && \
    ln -s /etc/php7 /etc/php                                                                                                    && \
    touch /var/log/php-fpm/fpm-error.log                                                                                        && \
    touch /var/log/php-fpm/fpm-access.log                                                                                       && \
    ln -sf /dev/stdout /var/log/php-fpm/fpm-access.log                                                                          && \
    ln -sf /dev/stderr /var/log/php-fpm/fpm-error.log

COPY etc/cachet/.env.docker /opt/src/cachet/.env

USER 1001

# VOLUME ["/var/run/php-fpm", "/opt/src", "/opt/src/cachet/database/", "/opt/src/cachet/storage"]
VOLUME ["/var/run/php-fpm", "/opt/src"]

ENTRYPOINT ["container-entrypoint"]

CMD ["run-php"]
