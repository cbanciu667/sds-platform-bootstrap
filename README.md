# sds-platform-bootstrap
Automation for sds platform installation which will deploy   
initial components: Docker Registry, Vault, Nginx and Docker images sync.   
This automation will also create the initial infrastructure like networking or the Kubernetes cluster.   

The SDS platform is an automated infrastructure delivery platform based on services like:   
- Kubernetes hosted in cloud or on-prem   
- Terraform and Terragrunt   
- Ansible   
- Bash   
- Python   
- Docker Registry   
- Hashicorp Vault   
- Nginx load balancing   
- ArgoCD or FluxCD   


Before using this, check sds-platform-intro.   
The platform is meant the be hosting agnostic and can be deployed to any potential customer.   
The platform is meant the be deployed in fully airgaped environments too by doing docker images sync and using local vault store for secrets.   

Diagram: 
![alt text](https://github.com/[username]/[reponame]/blob/[branch]/image.jpg?raw=true)
