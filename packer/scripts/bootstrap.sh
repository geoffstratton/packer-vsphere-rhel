#!/bin/bash

#Run bootstrap to register
wget --no-check-certificate -q -O -  https://192.168.0.15/pub/bootstrap.sh | bash

#after bootstrap run reenable sudo access
echo -e "provisioner\tALL=(ALL)\tNOPASSWD: ALL" >> /etc/sudoers

# stop cron so we do not update sudoers
service crond stop

#Update the template OS
yum -y update --setopt tsflags=nodocs

#install the security cis rpm
yum install ansible-cis-redhat --enablerepo=custom-ansible-repo -y

#Run the cis role
ansible-playbook -i /etc/ansible/hosts /usr/bin/run_role.sh -e run_role=ansible-cis-redhat

#ensure sshd_config allows root logins for provisioning
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes' /etc/ssh/sshd_config
service sshd restart

#
echo "[main]" > /etc/NetworkManager/conf.d/90-dns-none.conf
echo "dns=none" >> /etc/NetworkManager/conf.d/90-dns-none.conf
