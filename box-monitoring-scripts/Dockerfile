FROM alpine:3.8

# Build-time metadata as defined at http://label-schema.org
ARG VERSION_ARG=""
ARG BUILD_DATE_ARG=""
ARG VCS_REF_ARG=""

LABEL org.label-schema.build-date=$BUILD_DATE_ARG \
      org.label-schema.name="CachetHQ Monitoring Scripts" \
      org.label-schema.description="CachetHQ Monitoring Scripts write in Python which help to monitoring some things." \
      org.label-schema.url="" \
      org.label-schema.vcs-ref=$VCS_REF_ARG \
      org.label-schema.vcs-url="https://github.com/zebby76/cachethq-docker" \
      org.label-schema.vendor="sebastian.molle@gmail.com" \
      org.label-schema.version=$VERSION_ARG \
      org.label-schema.schema-version="1.0"

USER root

ENV PATH=/opt/bin:/usr/local/bin:/usr/bin:${PATH}                                                                                  \
    HOME=/opt/pip

RUN mkdir -p /opt/bin /opt/src /opt/etc                                                                                         && \
    echo "Add default user ..."                                                                                                 && \
    adduser -D -u 1001 -g default -s /sbin/nologin default                                                                      && \
    chown -R 1001:0 /opt                                                                                                        && \
    chmod -R ug+rw /opt                                                                                                         && \
    find /opt -type d -exec chmod ug+x {} \;                                                                                    && \
    echo "Install Alpine packages ..."                                                                                          && \
    apk --update add tzdata bash tar curl ca-certificates su-exec python3 libressl                                              && \
    echo "Configure Timezone ..."                                                                                               && \
    cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime                                                                       && \
    echo "Europe/Brussels" > /etc/timezone                                                                                      && \
    echo "Cleanup Alpine packages ..."                                                                                          && \
    apk del tzdata                                                                                                              && \
    rm -rf /var/cache/apk/*                                                                                                     && \
    echo "Install Python PIP ..."                                                                                               && \
    mkdir -p /opt/pip/.pip /opt/pip/.cache/pip/http /opt/pip/.cache/pip/log                                                     && \
    python3 -m ensurepip                                                                                                        && \
    rm -r /usr/lib/python3.6/ensurepip

COPY etc/pip/pip.conf /opt/pip/.pip/pip.conf
COPY src/ /opt/src
COPY bin/ /opt/bin

RUN echo "Configure Python PIP ..."                                                                                             && \
    pip3 install --upgrade pip setuptools                                                                                       && \
    chown 1001:0 -Rf /opt/pip /usr/lib/python3.6                                                                                && \
    chmod -R ug+rw /opt/pip /usr/lib/python3.6                                                                                  && \
    find /opt/pip -type d -exec chmod ug+x {} \;                                                                                && \
    find /usr/lib/python3.6 -type d -exec chmod ug+x {} \;                                                                      && \
    echo "Configure application ..."                                                                                            && \
    chown 1001:0 -Rf /opt/bin /opt/src                                                                                          && \
    chmod -Rf ug+rw /opt/bin /opt/src                                                                                           && \
    chmod -Rf +x /opt/bin                                                                                                       && \
    find /opt/pip -type d -exec chmod ug+x {} \;                                                                                && \
    find /opt/src -type d -exec chmod ug+x {} \;

USER 1001

RUN pip3 install --user python-cachetclient

ENTRYPOINT ["/opt/bin/entrypoint"]

CMD ["usage"]
