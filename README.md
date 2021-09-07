Role Name
=========
packer-vsphere-rhel

Description
---------------
Jenkins-driven Packer scripts to build Red Hat 7 and 8 templates in a VMware vSphere environment. Uses Red Hat Satellite as the image source and performs assorted cleanup and post-processing, then calls a Terraform builder to construct running VMware VMs from the Packer templates.

* Packer (https://www.packer.io/)
* Packer vSphere-ISO builder (https://www.packer.io/docs/builders/vmware/vsphere-iso)
* Jenkins (https://www.jenkins.io/)
* Terraform (https://www.terraform.io/)
* VMWare (https://www.vmware.com/)

License
-------
Apache 2.0

Author Information
------------------
Geoff Stratton
