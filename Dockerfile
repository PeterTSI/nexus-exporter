FROM alpine:latest

# Adds testing package to repositories
# Install needed packages. Notes:
#   * build-base: used so we include the basic development packages (gcc)
#   * python-dev: are used for gevent e.g.
#   * bash: so we can access /bin/bash
RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk add --update \
              musl \
              build-base \
              bash \
              git \
              python \
              python-dev \
              py-pip \
  && pip install --upgrade pip \
  && rm /var/cache/apk/*

# make some useful symlinks that are expected to exist
RUN cd /usr/bin \
  && ln -sf easy_install-2.7 easy_install \
  && ln -sf python2.7 python \
  && ln -sf python2.7-config python-config \
  && ln -sf pip2.7 pip

RUN pip install prometheus-client==0.0.14

EXPOSE 9184
WORKDIR /opt
WORKDIR nexus
COPY nexus_exporter.py nexus_exporter.py

RUN addgroup -g 1000 -S nexus && adduser -u 1000 -S nexus -G nexus \
    && chown -R nexus:nexus /opt/nexus \
    && chmod a+x /opt/nexus/nexus_exporter.py

USER nexus

ENTRYPOINT ["/opt/nexus/nexus_exporter.py"]
