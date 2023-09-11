#!/bin/bash

# source main variables
source ./params

# Update OS on each controller
echo "Updating OS packages on controller system:"
sudo apt update && sudo apt-add-repository ppa:ansible/ansible -y && sudo apt full-upgrade -y && sudo apt dist-upgrade && sudo apt autoremove && sudo apt autoclean

# Install prereq on each controller
echo "Installing prerequisites on controller system:"
sudo apt install python3 python3-pip keepalived haproxy ansible -y
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# FIX for bug in R53 ansible module - "AttributeError: module 'lib' has no attribute 'OpenSSL_add_all_algorithms'"
sudo pip3 install --force-reinstall pyopenssl

# Clone base infrastructure code
git clone git@github.com:cbanciu667/sds-ansible.git ../sds-ansible

# Kubespray init for on-prem Kubernetes clusters
if [[ $PLATFORM_HOSTING != 'ONPREM' ]]; then
    git clone git@github.com:kubernetes-sigs/kubespray.git ../kubespray
    cd ../kubespray
    sudo pip install -r requirements.txt
    cp -rfp inventory/sample inventory/$PLATFORM_NAME
    declare -a IPS=($PLATFORM_NAME-cp1,$K8S_ONPREM_MASTER_NODE1_IP $PLATFORM_NAME-cp2,$K8S_ONPREM_MASTER_NODE2_IP $PLATFORM_NAME-k8s-node1,$K8S_ONPREM_WORKER_NODE1_IP $PLATFORM_NAME-k8s-node2,$K8S_ONPREM_WORKER_NODE2_IP $PLATFORM_NAME-k8s-node3,$K8S_ONPREM_WORKER_NODE3_IP $PLATFORM_NAME-k8s-node4,$K8S_ONPREM_WORKER_NODE4_IP)
    CONFIG_FILE=inventory/$PLATFORM_NAME/hosts.yaml python contrib/inventory_builder/inventory.py "${IPS[@]}"
    CURENT_PATH=$(pwd)
    echo "Manually check $CURENT_PATH/inventory/$PLATFORM_NAME/hosts.yaml"
    read -p "Did you performed the manual step above ? (Yes/No) or (Y/N)" ANSWER
    if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
        echo "Kubespray configs ready."
    else
        echo "Manual Kubespray configs double check is mandatory. Exiting..."
        exit 1
    fi
fi

# Run sds ansible for generic configuration
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

# Fail2ban manual configuration for controllers - controllers must be highly secure!
FILE=/etc/resolv.conf
if [[ -f "/etc/fail2ban/jail.local" ]]; then
    echo "Fail2ban already configured. Proceeding with next step."
else
    sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    CURENT_PATH=$(pwd)
    echo "Manually configure Fil2ban by updating: /etc/fail2ban/jail.local"
    read -p "Did you performed the manual step above ? (Yes/No) or (Y/N)" ANSWER
    if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
        echo "Fail2ban configured manually. Proceeding with next step."
        sudo systemctl enable fail2ban
        sudo systemctl start fail2ban
        sudo systemctl status fail2ban
    else
    echo "Fail2ban manual configuration is required. Please start over. Exiting..."
        exit 1
    fi
fi

# Controller services
echo "Starting controller services"
docker-compose up -d --build

# Vault
echo "Manually initialise vault and secure ROOT TOKEN."
read -p "Did you  performed vault initialisation ? (Yes/No) or (Y/N)" ANSWER
if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
    echo "Vault initialised and TOKEN secured."
else
    echo "Vault initialisation is required for next steps. Please start over. Exiting..."
fi

# Kubespray deployment for Kubernetes clusters
if [[ $PLATFORM_HOSTING != 'ONPREM' ]]; then
    cd ../kubespray
    ansible-playbook -b -v -i inventory/$PLATFORM_NAME/hosts.yaml --become --become-user=root cluster.yml -u $PLATFORM_USERNAME
    mkdir -p $HOME/.kube && cp inventory/$PLATFORM_NAME/artifacts/admin.conf $HOME/.kube/config && sudo chown $(id -u):$(id -g) $HOME/.kube/config && export KUBECONFIG=$HOME/.kube/config
    cd ../sds-platform-bootstrap
fi


# WIP WIP WIP WIP WIP WIP ....
# Terragrunt for AWS based platforms
if [[ $PLATFORM_HOSTING != 'AWS' ]]; then
    git clone git@github.com:cbanciu667/sds-terragrunt.git ../sds-terragrunt
    cd ../sds-terragrunt
    echo "Manually check $CURENT_PATH/params/aws/$PLATFORM_NAME"
    read -p "Did you performed the manual update for AWS terrgrunt bootstrap parameters according to example ? (Yes/No) or (Y/N)" ANSWER
    if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
        terragrunt init
        ....
    else
        echo "Terragrunt AWS init params required. Exiting..."
        exit 1
    fi    
fi

# Terragrunt for Azure based platforms
if [[ $PLATFORM_HOSTING != 'AZURE' ]]; then
    git clone git@github.com:cbanciu667/sds-terragrunt.git ../sds-terragrunt
    cd ../sds-terragrunt
    echo "Manually check $CURENT_PATH/params/azure/$PLATFORM_NAME"
    read -p "Did you performed the manual update for Azure terrgrunt bootstrap parameters according to example ? (Yes/No) or (Y/N)" ANSWER
    if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
        terragrunt init
        ....
    else
        echo "Terragrunt AZURE init params required. Exiting..."
        exit 1
    fi    
fi

# Terragrunt for Gcp based platforms
if [[ $PLATFORM_HOSTING != 'GCP' ]]; then
    git clone git@github.com:cbanciu667/sds-terragrunt.git ../sds-terragrunt
    cd ../sds-terragrunt
    echo "Manually check $CURENT_PATH/params/google/$PLATFORM_NAME"
    read -p "Did you performed the manual update for Google cloud terrgrunt bootstrap parameters according to example ? (Yes/No) or (Y/N)" ANSWER
    if [[ $ANSWER == "y" || $ANSWER == "Y" || $ANSWER == "Yes" ]]; then
        terragrunt init
        ....
    else
        echo "Terragrunt GCP init params required. Exiting..."
        exit 1
    fi    
fi
# WIP WIP WIP WIP WIP WIP ....