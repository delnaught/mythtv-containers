FROM ubuntu:focal


ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TZ="America/New_York"

ENV ZAP2XML_USER=
ENV ZAP2XML_PASSWD=
ENV XMLTV_FILE=
ENV EPG_DAYS=
ENV ICON_DIR=
ENV SOURCE_ID=

ADD scripts /usr/local/bin
ADD https://github.com/shuaiscott/zap2xml/raw/master/zap2xml.pl /usr/local/bin

RUN chmod 755 /usr/local/bin/* \
    && apt-get update \
    && apt-get -y install --no-install-recommends gnupg locales tzdata sudo rsync \
    && apt-get -y install --no-install-recommends tigervnc-standalone-server tigervnc-common \
    && apt-get -y install --no-install-recommends libjson-xs-perl xmltv xmltv-util \
    && locale-gen en_US.UTF-8 \
    && dpkg-reconfigure --frontend noninteractive locales \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 13551B881504888C \
    && echo 'deb http://ppa.launchpad.net/mythbuntu/32/ubuntu focal main' >> /etc/apt/sources.list \
    && echo 'deb-src http://ppa.launchpad.net/mythbuntu/32/ubuntu focal main' >> /etc/apt/sources.list \
    && apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -y --no-install-recommends install mythtv-backend \
    && apt-get -y dist-upgrade \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["mythbackend"]
