#!/bin/bash

set -euo pipefail

set -x

apt-get update

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

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

usermod --append -G docker vagrant

# Build image without user-namespaces
rm -f /etc/docker/daemon.json 2> /dev/null
systemctl restart docker

docker info

sudo -i -u vagrant docker build -t capabilities-built-with-no-userns:1.0 ~vagrant

# Build image with user namespaces
cat - <<EOF > /etc/docker/daemon.json
{
  "userns-remap": "default"
}
EOF

systemctl restart docker

docker info

sudo -i -u vagrant docker build -t capabilities-built-with-userns:1.0 ~vagrant
docker save capabilities-built-with-userns:1.0 > /tmp/capabilities-built-with-userns-1.0.tar

# Now run both images in a no-user-ns setup

rm -f /etc/docker/daemon.json 2> /dev/null
systemctl restart docker

docker load < /tmp/capabilities-built-with-userns-1.0.tar

docker info
docker images

docker run --rm capabilities-built-with-no-userns:1.0 /bin/bash -c '(/usr/local/bin/sleep-test infinity & ); sleep 1; grep Cap /proc/$(pgrep sleep-test)/status'
docker run --rm capabilities-built-with-userns:1.0 /bin/bash -c '(/usr/local/bin/sleep-test infinity & ); sleep 1; grep Cap /proc/$(pgrep sleep-test)/status'
