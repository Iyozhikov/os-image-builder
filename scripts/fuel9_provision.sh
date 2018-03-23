#!/bin/bash -x

readonly RPM_PACKAGES UPDATE2_92 NTP_POOL

# Update NTP upstream servers if necessary
if [ ! -z "${NTP_POOL}" ];then
  sed "s|fuel.pool.ntp.org|${NTP_POOL}|" -i /etc/fuel/astute.yaml
  sed "s|fuel.pool.ntp.org|${NTP_POOL}|" -i /etc/ntp.conf
  systemctl restart ntpd
  systemctl status ntpd
fi

# Wait for fuel and image bootstrap complete
while true
do
  tail -n 2 /var/log/puppet/bootstrap_admin_node.log | grep 'Fuel node deployment complete!' && break
  sleep 60
done

# Upgrade fuel master node
if [ "${UPDATE2_92}" -eq "1" ]; then
  UPD_PKG="http://mirror.fuel-infra.org/mos-repos/centos/mos9.0-centos7/9.2-updates/x86_64/Packages/mos-release-9.2-1.el7.x86_64.rpm"
  echo "Installating updates using $(basename ${UPD_PKG})"
  yum install -y ${UPD_PKG}
  yum clean all
  yum makecache
  yum install -y mos-updates
  echo "Running upgrade of master node"
  cd /root/mos_playbooks/mos_mu/ || exit 1
  ansible-playbook playbooks/mos9_prepare_fuel.yml
  ansible-playbook playbooks/update_fuel.yml -e '{"rebuild_bootstrap":false}'
  ansible-playbook playbooks/update_fuel.yml
  ansible-playbook playbooks/mos9_fuel_upgrade_kernel_4.4.yml
  cd /root && fuel2 fuel-version
fi

# Install additional packages
if [ ! -z $"${RPM_PACKAGES}" ];then
  yum makecache
  yum install -y ${RPM_PACKAGES}
fi
