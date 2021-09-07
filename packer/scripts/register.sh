#!/bin/bash -eux

# Configure repos
#subscription-manager register --username=${RHSM_USERNAME} --password=${RHSM_PASSWORD} --name=packer-rhel7-$(date +%Y%m%d)-${RANDOM}
#subscription-manager attach --pool=${RHSM_POOL}
#subscription-manager repos --disable=*
#subscription-manager repos --enable=${ANSIBLE_REPOS} --enable=rhel-7-server-rpms
OS_VER=`awk '{match($0, /[0-9]+/,version)}END{print version[0]}' /etc/system-release`
SERVER_ENV=nonprod
ORG='Default_Organization'

cat << EOF > /etc/resolv.conf
search google.com
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

rpm -Uvh http://satellite-server.com/pub/katello-ca-consumer-latest.noarch.rpm
#subscription-manager register --org=$ORG --activationkey=${OS_VER}-${SERVER_ENV}
#subscription-manager repos --enable=rhel*
#yum -y update --setopt tsflags=nodocs

# Update to last patches
#yum -y update --setopt tsflags=nodocs

# Install Ansible.
#yum -y install --setopt tsflags=nodocs ansible
#yum history package ansible|awk '/Install/ {print $1}' > /tmp/YUM_ID

# Configure /tmp on tmpfs
#systemctl enable tmp.mount
