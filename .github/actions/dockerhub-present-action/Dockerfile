FROM debian:testing-slim

ADD entrypoint.sh /entrypoint.sh

RUN apt-get update \
    && apt-get -y install --no-install-recommends curl jq ca-certificates \
    && chmod 555 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
