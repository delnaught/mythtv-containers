ARG BUILDER_IMAGE=ubuntu:focal
# versions 10.4 and greater break import of user table
ARG RUNTIME_IMAGE=mariadb:10.3-focal

FROM $BUILDER_IMAGE as builder

ARG MYTHTV_VERSION

RUN apt-get update \
    && apt-get install -y --no-install-recommends mariadb-server gnupg \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 13551B881504888C \
    && echo 'deb http://ppa.launchpad.net/mythbuntu/32/ubuntu focal main' >> /etc/apt/sources.list \
    && echo 'deb-src http://ppa.launchpad.net/mythbuntu/32/ubuntu focal main' >> /etc/apt/sources.list \
    && apt-get update \
    && /etc/init.d/mysql start \
    && while [ ! -e /var/run/mysqld/mysqld.sock ]; do sleep 1; done; sleep 1 \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mythtv-database=$MYTHTV_VERSION \
    && mysqldump --all-databases -uroot > /tmp/all-databases.sql \
    && /etc/init.d/mysql stop

FROM $RUNTIME_IMAGE

COPY --from=builder /tmp/all-databases.sql /docker-entrypoint-initdb.d/

CMD ["mysqld", "--plugin-load-add", "auth_socket"]
