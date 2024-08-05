# sds-platform-bootstrap
This automation will perform the initial configurations required and will deploy/initialise the SDS Kubernetes cluster.   

This Automation is using tools like:   
- Terraform and Terragrunt for cloud deployments   
- Ansible for basic hosts configuration    
- Docker Registry for air-gaped envs   
- Hashicorp Vault for secrets   
- Nginx for controller services   
- ArgoCD or FluxCD for K8s configuration   

Notes:   
Before using this, check sds-platform-intro.   
The platform is meant the be hosting agnostic and can be deployed to any potential customer.   
The platform is meant the be deployed in fully airgaped environments too by doing docker images sync and using local vault store for secrets.   

Usage:   
1. Follow the initial manual steps from sds-platform-intro repository.   
2. Clone this repository in the platform user home folder on the first controller host.   
3. Update/Create params file as per example.   
4. Check and run ./bootstrap.sh   


Solid Distributed Systems