FROM ubuntu:latest

RUN apt-get update && apt-get install -y --no-install-recommends util-linux attr libcap2-bin

#RUN setcap CAP_NET_BIND_SERVICE=+ep /usr/sbin/capsh

USER nobody

CMD /usr/sbin/capsh --print | grep Current
