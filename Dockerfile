FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends util-linux attr libcap2-bin

# RUN cp /usr/bin/sleep /usr/local/bin/sleep-test
# RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/sleep-test

# Works! (Unexpected)
# ADD sleep-test.tar /

# Doesn't work (as expected)
COPY sleep-test.tar /tmp
RUN tar --xattrs-include='*' -C / -xpf /tmp/sleep-test.tar

USER nobody
