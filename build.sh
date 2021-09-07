#!/bin/ksh

#set -vx
#Default
ANSIBLE_PLAYBOOK='/opt/ansible/playbook.yml'
ANSIBLE_PYTHON_INTERPRETER='/usr/bin/python'
ANSIBLE_ROLE="${PWD}/vmware-guest"
#builds="rhel7 rhel8"
builds="rhel7 rhel8"
_packer='/usr/local/bin/packer'
_ksvalidator='/usr/bin/ksvalidator'
_terraform='/usr/local/bin/terraform'
network='192.168.0'
oct='10'

MyProgname=$(basename $0)
MyHost=`uname -n`
MyDate=`date '+%m.%d.%y'`

PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH



######################################
#Functions
######################################
log(){
    message="$@"
    printf '\e[1;32m %s\e[0m\n' "$MyHost $message"  1>&2
}

cleanup(){
        for file in "$@"
        do
                if [ -f "$file" ] ; then
                rm "$file"
                fi
        done
}

error_exit(){
        message="$@"
        printf '\e[1;31m %s\e[0m\n' "$MyHost ERROR: $message" 1>&2
        exit 1
}

exit_state(){
  returnCode=$?
  message="$@"
  if [ "$returnCode" -eq "0" ] ; then
      printf '\e[1;32m %s\e[0m\n' "$MyHost $message OK. "
    else
      printf '\e[1;31m %s\e[0m\n' "$MyHost ERROR: $message FAILED. "
      exit 1
  fi
  lastExit=$returnCode
}

usage(){
   cat << EOF
Usage: build.sh
 -c <clean templates>
 -p <build packer>
 -t <build terraform>
EOF
   exit 1
}
######################################
#Main
######################################
if [ "$#" -ne '1' ]; then
  usage;
fi

if [ -z ${SECRET_USER_PASS+x} ]; then
  error_exit "var SECRET_USER_PASS is not set";
fi

if [ -z ${SECRET_VM_PASS+x} ]; then
  error_exit "var SECRET_VM_PASS is not set";
fi


while getopts ':cpt' opt; do
  case $opt in
    c)
      build='clean' >&2
      ;;
    p)
      build='packer' >&2
      ;;
    t)
      build='terraform' >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage;
      exit 1
      ;;
  esac
done


if [ "$build" == 'clean' ] ; then
  if  [ -f ${ANSIBLE_PLAYBOOK} ] ; then
    source scl_source enable rh-python36
    ansible-playbook -v -i ${PWD}/hosts ${ANSIBLE_PLAYBOOK} -e run_role=${ANSIBLE_ROLE} -e ansible_python_interpreter=${ANSIBLE_PYTHON_INTERPRETER}
  fi
fi

if [ "$build" == 'packer' ] ; then
  for OS in ${builds[@]}; do
    PACKER_KEY_INTERVAL=100ms PACKER_LOG=1 $_packer build -force -var-file=./packer/vars/${OS}.json packer/rhel.json
    exit_state "Packer ${OS} template build "
    find ./packer_cache -type f -name "*.iso" -exec /bin/rm -f {} \;
    find ./packer_cache -type f -name "*.iso.lock" -exec /bin/rm -f {} \;
  done
fi

if [ "$build" == 'terraform' ] ; then
  cd terraform
  for OS in ${builds[@]}; do
    vmhostname=${OS}
    vmtemplate=`echo ${OS} | tr '[:lower:]' '[:upper:]'`
    if [ ! -f terraform.tfstate.d/${OS} ] ; then
      $_terraform workspace new "${OS}"
    fi
    $_terraform init
    $_terraform workspace select "${OS}"
    $_terraform apply -var vm_hostname="rc-lx${vmhostname}" -var vm_template="${vmtemplate}" -var vsphere_password="${SECRET_VM_PASS}" -var ssh_password="${SECRET_USER_PASS}" -var vm_ip_addr="${network}.${oct}" -var "cots=1" --auto-approve
  oct=`expr $oct + 1`
  done
fi
