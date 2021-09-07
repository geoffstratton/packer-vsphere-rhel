@Library('jenkins_library')_

pipeline {
  environment {
    PROJECT_NAME = sh(returnStdout: true, script: "echo $JOB_NAME | awk -F/ '{print \$1}'").trim()
    DEBUG = "true"
    YR = sh(returnStdout: true, script: "date +%y").trim()
    VERSION_ID = sh(returnStdout: true, script: "git rev-list HEAD --count").trim()
    SECRET_USER_PASS = credentials('[provisioner]')
    SECRET_VM_PASS = credentials('[vcenter_account]')
    SERVER_NODE = "template"
    VCENTER_SERVER = "my-vmware-cluster.com"
    VM_CPUS = "2"
    VM_DNS_SERVERS = "8.8.8.8"
    VM_DNS_SUFFIXES = "dev.mydomain.com"
    VM_DOMAIN = "dev.mydomain.com"
    VM_ENV = "LAB"
    VM_HOSTNAME = "rhel7"
    VM_IP_ADDR = "192.168.0.10"
    VM_IP_V4_GATEWAY = "192.168.0.1"
    VM_MEM = 4096
    VM_OS = "rhel7_64Guest"
    VM_TEMPLATE = "RHEL7"
    VSPHERE_DATACENTER = "MYDC"
    VSPHERE_DATASTORE = "BIG-SAN"
    VSPHERE_DS_CLUSTER = "MYDC-DEV"
    VSPHERE_SERVER = "my-vmware-cluster.com"
    VSPHERE_USERNAME = "[vcenter_account]"
    VSPHERE_VLAN = "vlandev" 
  }

  agent {
    node {
      label 'jenkins-agents'
      customWorkspace "/opt/jenkins/workspace/prod/" + "$JOB_NAME".replaceAll('/.*', '')
    }
  }

  // BEGIN: Stages
  stages {
    // BEGIN: ENV
    stage('Environment') {
      steps {
        sh '''
          env |  sort
        '''
      }
    }
    // END: ENV

    // BEGIN: Rhel Template Build
    stage('Template Build') {
      steps {
        sh '''
          ./build.sh -p
        '''
      }
    } // END: Rhel Template Build

    // BEGIN: Terraform Build
    stage('Terraform Build') {
      steps {
      build job: 'terraform-build'
      }
    }
    // END: Terraform Build

  } // END: Stages
  // BEGIN: Post Pipeline
   post {
    success { 
      // BEGIN: Jira ticket for success
      script {
        summary = "Jenkins Packer VM Template Build Succeeded"
        details = "Build Objects: RHEL7, RHEL8 on ${VCENTER_SERVER}"	
        jiraUtils_v2.createITAlert(summary, details)
      }
    } // END: JIRA ticket for success
    failure { 
      // BEGIN: Jira Ticket for failure
      script {
        summary = "Jenkins Packer VM Template Failure"
        details = "Build Object = ${VM_HOSTNAME} on ${VCENTER_SERVER}"
        jiraUtils_v2.createITAlert(summary, details)
      }
      // END: Failed Jira Ticket
    }
  } // END: Post Pipeline
} // END: Pipeline
