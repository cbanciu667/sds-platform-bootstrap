#!/bin/bash

# DESCRIPTION
# This script contains the commands required to start a new platform configuration
# Run these commands on the primary or on the backup platform controller

# source main variables
source ./params

# Update OS on each controller
echo "Updating OS packages on controller system:"
sudo apt update && sudo apt full-upgrade -y && sudo apt dist-upgrade && sudo apt autoremove && sudo apt autoclean

# Install prereq on each controller
echo "Installing prerequisites on controller system:"
sudo apt install python3 python3-pip keepalived haproxy ansible -y
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

#
# If Hyper-V is used as virtualisation hosting please run hyper-v-patch.sh script
# ./hyper-v-patch.sh
#

# FIX for bug in R53 ansible module - "AttributeError: module 'lib' has no attribute 'OpenSSL_add_all_algorithms'"
sudo pip3 install --force-reinstall pyopenssl

# Install Helm Cli
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Clone base infrastructure code
git clone git@github.com:cbanciu667/sds-ansible.git ../sds-ansible

# Ansible automation
echo "Runing base ansible playbook:"
cd ../sds-ansible
CURENT_PATH=$(pwd)
echo "Manually create or update $CURENT_PATH/inventory/$PLATFORM_NAME according to existing examples."
read -p "Did you performed the manual step above ? (Yes/No) or (Y/N)" ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
    ./run-ansible.sh $PLATFORM_NAME all
    ./run-ansible.sh $PLATFORM_NAME controllers
    cd ../sds-platform-bootstrap
else
    echo "Manual inventory configuration is required. Please start over. Exiting..."
    exit 1
fi

# Controller services
echo "Starting controller services"
docker-compose up -d --build

# Terragrunt and Terraform for AWS, Azure or GCP
git clone git@github.com:cbanciu667/sds-terragrunt.git ../sds-terragrunt
cd ../sds-terragrunt
echo "Manually fillout the cloud infra required parameters."
read -p "Did you performed the manual step above ? (Yes/No) or (Y/N)" ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
    terragrunt plan-all
    terragrunt apply-all
    cd ../sds-platform-bootstrap
else
    echo "Terragrunt parameters configuration required. Exiting..."
    exit 1
fi

# Kubernetes and GitOps
git clone git@github.com:cbanciu667/sds-kubernetes.git ../sds-kubernetes
cd ../sds-kubernetes
echo "Manually fillout the Kubernetes and GitOps required parameters."
read -p "Did you performed the manual update for AWS terrgrunt bootstrap parameters ? (Yes/No) or (Y/N)" ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
    ./kubernetes-init.sh
    cd ../sds-platform-bootstrap
else
    echo "Kubernetes parameters configuration required. Exiting..."
    exit 1
fi

echo "SDS Platform initialised"