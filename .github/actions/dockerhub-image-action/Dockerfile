FROM debian:slim

ADD entrypoint.sh /entrypoint.sh

RUN apt-get update \
    && apt-get install --no-install-recommends --no-cache curl jq

ENTRYPOINT ["/entrypoint.sh"]
