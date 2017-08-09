#!/bin/bash -x

readonly DEB_PACKAGES PY_PACKAGES \
  DISTRO_DIR="$(mktemp -d)"
export DEBIAN_FRONTEND=noninteractive

function update-packages()
{
  sed 's/us.archive.ubuntu.com/mirrors.aliyun.com/g' -i /etc/apt/sources.list
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y ${DEB_PACKAGES}
}

# main
update-packages
