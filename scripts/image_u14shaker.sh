#!/bin/bash -x

readonly DEB_PACKAGES PY_PACKAGES \
  DISTRO_DIR="$(mktemp -d)"
export DEBIAN_FRONTEND=noninteractive

function add-repo()
{
  apt-add-repository "deb http://nova.clouds.archive.ubuntu.com/ubuntu/ trusty-backports universe"
}

function update-packages()
{
  apt-get update -y
  apt-get upgrade -y
  apt-get install -y ${DEB_PACKAGES}
}

function update-py()
{
  echo "Installing PY"
  pip install --upgrade pip
  pip install ${PY_PACKAGES}
}

function modify_iperf()
{
  echo -e 'start on startup\ntask\nexec /usr/bin/screen -dmS sudo nice -n -20 /usr/bin/iperf -s' | sudo tee /etc/init/iperf-tcp.conf
  echo -e 'start on startup\ntask\nexec /usr/bin/screen -dmS sudo nice -n -20 /usr/bin/iperf -s --udp' | sudo tee /etc/init/iperf-udp.conf
  echo -e 'start on startup\ntask\nexec /usr/bin/screen -dmS sudo nice -n -20 /usr/bin/iperf3 -s' | sudo tee /etc/init/iperf3.conf
}
# main
add-repo
update-packages
update-py
shaker-agent -h || (echo "[critical] Failed to run pyshaker-agent. Check if it is installed in the image"; sleep 20)
modify_iperf
