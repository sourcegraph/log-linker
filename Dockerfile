FROM debian

RUN apt-get update && \
    apt-get install -y \
            jq

ADD log-linker.sh /
