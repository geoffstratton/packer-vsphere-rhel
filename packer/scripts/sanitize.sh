#!/bin/bash -eux

# Remove ansible packages
yum erase *ansible* -y

# Unregister template from RHSM
subscription-manager unsubscribe --all
subscription-manager unregister
subscription-manager clean

# Remove katello-ca-consumer
yum erase katello-ca-consumer-* -y
yum -y clean all
rpm --rebuilddb

# Some additional cleaning
rm -rf /.designator
rmdir /etc/.configured*
rm -rf /var/log/rhsm/*
rm -rf /etc/ansible
rm -rf /opt/ansible
rm -rf /etc/yum.repos.d/*.repo
rm -rf /tmp/*
rm -rf /root/*.cfg
rm -rf /etc/resolv.conf
rm -rf /etc/pki/rpm-gpg/RPM*
rm -rf /var/cache/yum/*
rm -rf /etc/ssh/ssh_host_*
if [ -f /etc/chrony.conf ] ; then
  rm /etc/chrony.conf
fi

# Zero out the rest of the free space using dd, then delete the written file.
#dd if=/dev/zero of=/EMPTY bs=1M
#rm -f /EMPTY

# Add double `sync` so Packer doesn't quit too early, before the large file is deleted.
sync && sync
