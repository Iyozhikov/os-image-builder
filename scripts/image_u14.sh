#!/bin/bash -x

readonly DEB_PACKAGES PY_PACKAGES \
  DISTRO_DIR="$(mktemp -d)"
export DEBIAN_FRONTEND=noninteractive

function update-packages()
{
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y ${DEB_PACKAGES}
}

# main
update-packages
poweroff
