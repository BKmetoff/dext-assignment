# Overview

This repository contains Infrastructure as Code (IaC) and tools to assist in the deployment of a Wordpress service and an SQL database for it using [Terraform](https://www.terraform.io/), [Ansible](https://www.ansible.com/) and [AWS](https://aws.amazon.com/), and [Docker](https://www.docker.com/).

## Project requirements

- Provision a semi-distributed [WordPress](https://wordpress.com/) installation:
  - two web servers
  - separate database on a third server
- The full flow of the provisioning must be triggered by a single command
- The provisioning flow must be idempotent - triggering the deployment should not tear anything down if there's something already provisioned
- Tearing down the entire infrastructure must be possible by executing a single command
- The provisioning flow could be executed as many times as necessary
- The wordpress installation must be accessible from a common hostname
- Wordpress should be installed
- Wordpress should display a custom blog post, i.e. not the generic "Hello World"-equivalent
- A scheduled job that runs every Sunday should:
  - run `OPTIMIZE` on all DB tables;
  - store the size of the tables before and after the operation in the log file.
- No credentials should be hardcoded anywhere.

---

## The "Why" -s:

- **Why use Terraform?** - Terraform allows deploying, keeping track, and maintaining, cloud infrastructure and infrastructure resources.
- **Why AWS?** - AWS offers a vast array of cloud infrastructure resources that supports the deployment of applications. It's one of the most used cloud service providers. For the purpose of this exercise, AWS provides all the necessary resources, as well as resources that can be used on expanding the security, scalability, and flexibility of the project.
- **Why Ansible?** - Ansible is an open-source set of provisioning, configuration management, and application deployment functionality tools aimed at easing the development and maintenance of infrastructure-as-code projects.
- **Why Docker?** - Docker is a software platform that allows building, testing, and deploying applications quickly. Docker packages software into standardized units called containers that have everything the software needs to run including libraries, system tools, code, and runtime .

## Prerequisites:

0. Install `tfenv` at the latest version
1. Install Terraform version `1.2.3` with tfenv `tfenv install 1.2.3`
2. Configure AWS credentials and confirm access to a remote state

## Workflow:

0. Clone this repo & cd into it
1. Generate a pair of SSH keys using `ssh-keygen` and place them in `[path/to/repo]/ssh`
2. Create an AWS S3 bucket that's going to be used for storing the Terraform state
3. Fill the following:

   - the environment variables in the `[path/to/repo].env` file
   - the AWS profile and region in the [`locals` block in `[path/to/repo]/main.tf`](https://github.com/BKmetoff/dext-assignment/blob/master/main.tf#L1)
   - the bucket name and the AWS region in the [terraform backend block in `[path/to/repo]/main.tf`](https://github.com/BKmetoff/dext-assignment/blob/4ef350a1cd0a8ad5669963630eac76aedda86c05/main.tf#L29)

4. Run `terraform init`
5. Run `./entrypoint.sh`
6. _(optional)_ Copy the IP address from the terminal and open it in your browser.

# Repo structure & concept:

```
├── ansible
│   ├── playbooks
│   │   ├── install_docker.yaml
│   │   ├── schedule_cronjob.yaml
│   │   ├── seed_db.yaml
│   │   └── set_up_ec2.yaml
│   └── playbook.yaml
├── bin
│   ├── add_to_known_hosts.sh
│   ├── export_db_size.sh
│   ├── run_ansible.sh
│   ├── run_terraform.sh
│   └── ssh_into_ec2.sh
├── docker
│   └── docker-compose.yaml
├── modules
│   ├── EC2
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── VPC
│       ├── external
│       │   └── ssh_key.sh
│       ├── key_pair.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── security-group.tf
│       └── variables.tf
├── mysql_db_backup
│   └── seed.sql
├── ssh
├── Readme.md
├── entrypoint.sh
├── main.tf
└── outputs.tf
```

The infrastructure consists entirely of AWS resources - VPC and EC2. The state and contents of the EC2 instance is set up and managed entirely by Ansible. Docker is used to run Wordpress and MySQL in the EC2 instance.

## Deployment flow

The deployment of the project is triggered by `/entrypoint.sh`. The execution is divided into three stages, executed by stand-alone scripts:

| Provisioning stage                                        | Script                       |
| :-------------------------------------------------------- | :--------------------------- |
| Deploy AWS infrastructure                                 | `/bin/run_terraform.sh`      |
| Add the EC2 public IP to `/Users/[user]/.ssh/known_hosts` | `/bin/add_to_known_hosts.sh` |
| Install, set up, and run Wordpress & MySQL                | `/bin/run_ansible.sh`        |

---

Once Terraform is done provisioning the infrastructure, it will output the public IP of the provisioned EC2 instance and store it into an Ansible [`hosts.ini`](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ini_inventory.html) file using the [`local_file`](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file.html) resource.

The deployment of services in the EC2 instance is managed by the main Ansible playbook - `/ansible/playbook.yaml`. The actual execution of the deployment of the services is divided into logical steps into separate sub-playbooks, located in `/ansible/playbooks`:

| Service deployment step         | Playbook                               |
| :------------------------------ | :------------------------------------- |
| Set up EC2 instance             | /[...]/playbooks/set_up_ec2.yaml       |
| Install Docker & start services | /[...]/playbooks/install_docker.yaml   |
| Schedule DB size export cronjob | /[...]/playbooks/schedule_cronjob.yaml |
| Seed database                   | /[...]/playbooks/seed_db.yaml          |

---

## Authentication

The authentication to EC2 is done by injecting a pre-generated, local SSH key into the provisioned EC2 instance using the Terraform [`external`](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) data source in conjunction with `/modules/VPC/external/ssh_key.sh`.

The benefits of this approach are that it:

- makes it possible to run the provisioning flow using an SSH key that's local to the machine that's triggering it;
- allows Ansible to authenticate during executing its playbooks.

## Environment variables

All the necessary environment variables should be stored in the `.env` file at the root of this repository. The file is copied onto the EC2 instance during the execution of the `ansible/playbooks/install_docker.yaml` playbook and fed into the docker containers via the `--env-file` docker-compose CLI parameter.

## Seeding the database

To achieve the requirement of having Wordpress display a custom blog post, the database has to be seeded with the respective blog post. This is done by the `ansible/playbooks/seed_db.yaml` playbook. It copies a pre-made, local database dump onto the MySQL docker container and uses it to seed the DB. The local DB dump resides in `mysql_db_backup/seed.sql`\*

\*_) In a production environment, database dumps/backups should **always** be stored in a secure location! A database dump is stored in this repository for demonstration purposes only._

## Provisioning two Wordpress servers

The two Wordpress servers, mentioned in the project requirements, are deployed by Docker using the following specification in `/docker/docker-compose.yaml`:

```
services:
  wordpress:
    [...]
    deploy:
      mode: replicated
      replicas: 2
    ports:
      - 80-81:80
```

## Exposing Wordpress to the world

The EC2 instance that runs the Wordpress servers is exposed by an [AWS Elastic IP](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html) via the [`aws_eip`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) Terraform resource.

Since two Wordpress services are running in a single EC2 instance, and they both listen on port 80, the ingress rules of the security group attached to the EC2 instance exposes two HTTP ports - 80 and 81 - as per the `docker-compose.yaml` mentioned above.

## Exporting metadata about the database

Since the current MySQL version does not include built-in support for `OPTIMIZE`, the cron job that's set up by Ansible only exports the size of the MySQL databases and stores them on the EC2 machine, in the home directory of the ec2-user - `/home/ec2-user/` - in `DB_size.log`.

The cron job itself is set to run every Sunday - as per the requirements - but at a random time. A good practice when scheduling recurring operations is to have them execute at a random time of the day to avoid stressing the system

## Tearing down the infrastructure

Since Terraform is used for infrastructure provisioning, tearing everything down can be done by running one of the following commands at the root level of this repository:

- `terraform destroy` - Wait for the confirmation prompt, type `yes`, and press Enter;
- `terraform apply -destroy -auto-approve`, if you don't feel like waiting for confirmation. **Warning: This will destroy all provisioned resources without waiting for approval!**

---

## Misc:

- `/bin/ssh_into_ec2.sh` allows quick and easy access into an EC2 instance via SSH. Run by passing the outputted IP address as an argument - `/bin/ssh_into_ec2.sh 11.22.33.44`
- Run `terraform state list` at the root level of this repo to check the current state of the infrastructure deployed by Terraform.
