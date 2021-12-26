FROM debian:testing-slim

ADD entrypoint.sh /entrypoint.sh

RUN apt-get update \
    && apt-get install --no-install-recommends curl jq

ENTRYPOINT ["/entrypoint.sh"]
