#!/bin/bash -eux

# Add a provisioner account
useradd -M provisioner
echo ${PROV_PASS} | passwd provisioner --stdin;
echo -e "provisioner\tALL=(ALL)\tNOPASSWD: ALL" >> /etc/sudoers
echo "Provisioner account created successfully."
