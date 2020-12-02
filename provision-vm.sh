#!/bin/bash

set -euo pipefail

set -x

apt-get update

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    make

sudo -i -u vagrant git clone https://github.com/EricMountain/moby

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# List available Docker CE versions
# apt-cache madison docker-ce
# apt-cache madison docker-ce-cli

# Use a specific version...
# DOCKER_VERSION=18.03.1~ce~3-0~ubuntu
# apt-get install -y docker-ce=${DOCKER_VERSION}
# ... or latest
apt-get install -y docker-ce
# ... or the Ubuntu-included version
# apt-get install -y docker.io

# If present, override dockerd with test binary
if [ -e /home/vagrant/dockerd ] ; then
  systemctl stop docker || true
  cp /home/vagrant/dockerd /usr/local/bin/dockerd
  chown root:root /usr/local/bin/dockerd
  chmod 0755 /usr/local/bin/dockerd

  [ ! -d /etc/systemd/system/docker.service.d ] && mkdir /etc/systemd/system/docker.service.d
  cat - <<EOF > /etc/systemd/system/docker.service.d/dropin.conf
[Service]
ExecStart=
ExecStart=/usr/local/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
EOF

else
  # Clear the drop-in in case we're re-provisioning
  rm -f /etc/systemd/system/docker.service.d/dropin.conf 2> /dev/null
fi

systemctl daemon-reload
systemctl start docker

# Grant vagrant access to the docker socket
usermod --append -G docker vagrant

# # Build image without user-namespaces
# rm -f /etc/docker/daemon.json 2> /dev/null
# systemctl reset-failed docker
# systemctl restart docker

# docker info

# sudo -i -u vagrant docker build --no-cache -t capabilities-built-with-no-userns:1.0 ~vagrant

# # Build image with user namespaces
# cat - <<EOF > /etc/docker/daemon.json
# {
#   "userns-remap": "default"
# }
# EOF

# systemctl restart docker

# docker info

# sudo -i -u vagrant docker build --no-cache -t capabilities-built-with-userns:1.0 ~vagrant
# docker save capabilities-built-with-userns:1.0 > /tmp/capabilities-built-with-userns-1.0.tar

# # Now run both images in a no-user-ns setup

# rm -f /etc/docker/daemon.json 2> /dev/null
# systemctl reset-failed docker
# systemctl restart docker

# docker load < /tmp/capabilities-built-with-userns-1.0.tar

# docker info
# docker images

# docker run --rm capabilities-built-with-no-userns:1.0 /bin/bash -c '(/usr/local/bin/sleep-test infinity & ); sleep 1; grep Cap /proc/$(pgrep sleep-test)/status'
# docker run --rm capabilities-built-with-userns:1.0 /bin/bash -c '(/usr/local/bin/sleep-test infinity & ); sleep 1; grep Cap /proc/$(pgrep sleep-test)/status'
