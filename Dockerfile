FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends util-linux attr libcap2-bin

RUN cp /usr/bin/sleep /usr/local/bin/sleep-test
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/sleep-test

USER nobody
