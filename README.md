# L2TP/IPSec

Ansible and Terraform configs to set up L2TP/IPSec VPN from the scratch on AWS

### The overall logic
At the vary beginning terraform is used to create new EC2 instance, Security Group and key pair. 
[Important!] SSH public and private keys, AWS keys and other configurations are stored in GitLab CI/CD variables. 
When ifrustructure is up and running annsible is used to install and configure VPN software.