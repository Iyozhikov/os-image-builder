#!/bin/bash
SSH_OPTS=' -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
SSH_ADM_IP="${1}"
SSH_ADM_USER="${2}"
SSH_ADM_PASS="${3}"
# Wait for initial installation
echo 'Waiting for fuel node admin iface up after reboot'
while true
do
  if sshpass -p 'r00tme' ssh $SSH_OPTS root@10.20.0.2 'whoami'; then
    break
  fi
  echo "Still in anaconda stage..."
  sleep 30
done
# Inject iptables ssh access
sshpass -p "${SSH_ADM_PASS}" ssh ${SSH_OPTS} ${SSH_ADM_USER}@${SSH_ADM_IP} 'iptables -I INPUT 1 -p tcp -m multiport --dports 22 -m comment --comment "001 ssh all" -m state --state NEW -j ACCEPT'
# Remove build time interface definition
sshpass -p "${SSH_ADM_PASS}" ssh ${SSH_OPTS} ${SSH_ADM_USER}@${SSH_ADM_IP} 'rm -f /etc/sysconfig/network-scripts/ifcg-eth2'
sshpass -p "${SSH_ADM_PASS}" ssh ${SSH_OPTS} ${SSH_ADM_USER}@${SSH_ADM_IP} 'sleep 5'
