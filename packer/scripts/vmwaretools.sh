#!/bin/bash -eux


#Install open-vmware-tools

OSVER=`awk '{match($0, /[0-9]+/,version)}END{print version[0]}' /etc/system-release`

case "${OSVER}" in
  7) yum install -y open-vm-tools --enablerepo=rhel*
     ;;
  8) dnf install -y open-vm-tools --enablerepo=rhel*
     ;;
esac
