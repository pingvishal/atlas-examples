Docker + Consul + Apache
===================
This repository and walkthrough guides you through deploying an Apache web server monitored by a 3 node Consul cluster in Docker containers on AWS using Atlas.

General setup
-------------
1. Download and install [Virtualbox](https://www.virtualbox.org/wiki/Downloads) and [Vagrant](https://www.vagrantup.com/downloads.html).
2. Clone this repository.
3. Create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=docker_apache) and save your Atlas username as an environment variable in your `.bashrc` file.
   `export ATLAS_USERNAME=<your_atlas_username>`
4. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as an environment variable in your `.bashrc` file.
   `export ATLAS_TOKEN=<your_atlas_token>`
5. Get your [AWS access and secret keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) and save as environment variables in your `.bashrc` file.
   `export AWS_ACCESS_KEY=<your_aws_access_key>`
   `export AWS_SECRET_KEY=<your_aws_secret_key>`
6. Get your Docker credentials and save as environment variables in your `.bashrc` file.
   `export DOCKER_LOGIN_EMAIL=<your_docker_login_email>`
   `export DOCKER_USER_NAME=<your_docker_user_name>`
   `export DOCKER_PASSWORD=<your_docker_password>`
   `export DOCKER_LOGIN_SERVER=<your_docker_login_server>` (optional)
7. In the Packer files [ops/docker_app.json](ops/docker_app.json), and [ops/docker_base.json](ops/docker_base.json), and [ops/docker_consul.json](ops/docker_consul.json) you must replace `YOUR_ATLAS_USERNAME` with your Atlas username.
8. Generate the keys in [ops/terraform/ssh_keys](ops/terraform/ssh_keys). You can simply run `sh scripts/generate_key_pair.sh` from the [ops](ops) directory and it will generate new keys for you. If you have an existing private key you would like to use, pass in the private key file path as the first argument of the shell script and it will use your key rather than generating a new one (e.g. `sh scripts/generate_key_pair.sh ~/.ssh/my-private-key.pem`). If you don't run the script, you will likely see the error `Error import KeyPair: The request must contain the parameter PublicKeyMaterial` on a `terraform apply` or `terraform push`.
9. Create a Vagrant environment with the latest HashiCorp master builds. Because there is some Docker functionality that is not yet released in Packer 0.7.5, there is a Vagrant environment you can run these commands from that has Packer built from master with the proper patches applied, rather than having to compile and build it yourself manually. This will be an unnecessary step once Packer 0.8.0 is released, but until then this is a quick workaround. In your [ops](ops) directory run `vagrant init jb_hashicorp/hashi-master --provider virtualbox`, then `vagrant up` once that completes. You now have an environment with the latest Packer and Terraform built from source. `vagrant ssh` in from the [ops](ops) directory and run all of the below commands from that Vagrant environment.

Introduction and Configuring Docker + Apache
-----------------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for how the Atlas workflow fits in.

[Docker](https://www.docker.com/whatisdocker/) allows you to build, ship, and run distributed applications. The concept of containers is great, but to use these in practice has proven to be difficult. Using Atlas to manage Docker containers makes it very simple to combine the benefits of using containers with the simple and reliable Atlas workflow.

The files in this repository are designed to make it just as simple to move from development to production by safely deploying and managing your infrastructure on AWS with Docker containers using the Atlas workflow. If you haven't deployed an app with [Atlas](https://atlas.hashicorp.com) before, we recommend you start with the [introductory tutorial](https://atlas.hashicorp.com/help/getting-started/getting-started-overview). Atlas by [HashiCorp](https://hashicorp.com) is a platform to develop, deploy, and maintain applications on any infrastructure provider.

In this example we will provision an Amazon EC2 instance and configure it with a Docker container running an Apache web server that is being monitored by a 3 node Consul cluster - each running in their own Docker container. We will build a bare bones base AMI for the EC2 instance, a Docker image for the Apache web server, and a Docker image for the Consul server instance configured using Packer. We will then deploy these resources using Terraform and monitor them using Consul.

Step 1: Build a bare bones AMI to run Docker containers on
-------------------------
1. Navigate to the [ops](ops) directory on the command line in your Vagrant environment.
2. We first need to create a bare bones AMI that will be used to run our Docker containers on. To do this, run `packer push -create docker_base.json` in the [ops](ops) directory. This will send the build configuration to Atlas so it can build your AMI remotely.
3. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "docker_base" build configuration. You will notice that the "docker_base" build errored immediately with the following error `Build 'amazon-ebs' errored: No valid AWS authentication found`. This is because we need to add our `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` environment variables to the build configuration.
   ![Docker Base Build Configuration - Variables Error](screenshots/builds_docker_base_error_variables.png?raw=true)
4. Navigate to "Variables" on the left side panel of the "consul" build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
   ![Docker Base Build Configuration - Variables](screenshots/builds_variables.png?raw=true)
5. Navigate back to "Versions" on the left side panel of the "docker_base" build configuration, then click "Rebuild" on the "docker_base" build configuration that errored. This one should succeed.
   ![Docker Base Build Configuration - Success](screenshots/builds_docker_base_success.png?raw=true)
6. This creates a fully-baked Docker base AMI that will be used for your Docker containers.

Step 2: Build a Docker image for our Consul server
-------------------------
1. Make sure you are in the [ops](ops) directory in your Vagrant environment.
2. For Consul to work with this setup, we first need to create a Consul server Docker image that will be used to build our Consul cluster. To do this, run `packer build docker_consul.json` in the [ops](ops) directory. This will run the proper Docker commands to configure a Docker image with everything necessary to run a Consul cluster and store it in your [Docker Hub](https://hub.docker.com/).
3. Once this completes you'll be able to view your newly created Docker image in [Docker Hub](https://hub.docker.com/). If you login to [Docker Hub](https://hub.docker.com/) and navigate to the newly created `consul_image` repository, under "Tags" you will see your new image!
   ![Docker Hub - Consul Image](screenshots/builds_docker_hub_consul_image.png?raw=true)

Step 3: Build a Docker image for our Apache web server
-------------------------
1. Make sure you are in the [ops](ops) directory in your Vagrant environment.
2. To create an Apache web server, we first need to create an Apache server Docker image. To do this, run `packer build docker_apache.json` in the [ops](ops) directory. This will run the proper Docker commands to configure a Docker image with everything necessary to run an Apache web server and store it in your [Docker Hub](https://hub.docker.com/).
3. Once this completes you'll be able to view your newly created Docker image in [Docker Hub](https://hub.docker.com/). If you login to [Docker Hub](https://hub.docker.com/) and navigate to the newly created `apache_image` repository, under "Tags" you will see your new image!
   ![Docker Hub - Apache Image](screenshots/builds_docker_hub_apache_image.png?raw=true)

Step 4: Deploy Apache web server and Consul Cluster using Docker containers
--------------------------
1. Wait for both the “consul_image” and “apache_image” builds to complete without errors.
2. Navigate to the [ops/terraform](ops/terraform) directory on the command line in your Vagrant environment.
3. Run `terraform remote config -backend-config="name=<your_atlas_username>/docker_apache"` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username to configure [remote state storage](https://www.terraform.io/docs/commands/remote-config.html) for this infrastructure. Now when you run Terraform, the infrastructure state will be saved in Atlas, keeping a versioned history of your infrastructure.
4. Get the latest modules by running `terraform get` in the [ops/terraform](ops/terraform) directory.
5. Run `terraform push -name <your_atlas_username>/docker_apache` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username. We will deploy only the AWS resources at first as we need the "public ip" of our host box to deploy the Docker infrastructure.
   * Note - When running `terraform` you can either pass environment variables into each call as noted in [ops/terraform/variables.tf#L7](ops/terraform/variables.tf#L7), or replace `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, `YOUR_ATLAS_USERNAME`, and `YOUR_ATLAS_TOKEN` with your Atlas username, Atlas token, [AWS Access Key Id, and AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) in [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars). If you use terraform.tfvars, you don't need to pass in environment variables for each `terraform` call, just be sure not to check this into a public repository.
6. Go to the [Environments tab](https://atlas.hashicorp.com/environments) in your Atlas account and click on the "docker_apache" environment. Navigate to "Changes" on the left side panel of the environment, click on the latest "Run" and wait for the "plan" to finish, then click "Confirm & Apply" to deploy your Apache web server and Consul cluster.
   ![Confirm & Apply](screenshots/environments_changes_confirm.png?raw=true)
7. You should see 1 new box spinning up in EC2 name "docker_base_1", which is where your Docker containers will be run on.
   ![AWS - Success](screenshots/aws_success.png?raw=true)
8. Once the "docker_base" instance is provisioned, grab the "public ip" address of that box.
   ![AWS - Public Ip](screenshots/aws_public_ip.png?raw=true)
9. Paste that public ip into your [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars#L26) file as the value in the ["docker_host_ip" variable](ops/terraform/terraform.tfvars#L26).
10. Uncomment the Docker section of your [ops/terraform/main.tf](ops/terraform/main.tf#L70-L97) file by removing lines [70](ops/terraform/main.tf#L70) and [97](ops/terraform/main.tf#L97) in [ops/terraform/main.tf](ops/terraform/main.tf#L70-L97).
   ```
   /* <-- Remove this line
   provider "docker" {
      host = "tcp://${var.docker_host_ip}:2375/"
      cert_path = "${var.docker_cert_path}"
   }

   module "docker_consul" {
      source = "./docker_consul"
      docker_image = "${var.docker_consul_image}"
      count = "${var.consul_count}"
      atlas_username = "${var.atlas_username}"
      atlas_token = "${var.atlas_token}"
      atlas_environment = "${var.atlas_environment}"
      key_file = "${var.private_key}"
      host = "${module.docker_base.ip_address}"
   }

   module "docker_app" {
      source = "./docker_app"
      docker_image = "${var.docker_apache_image}"
      count = "${var.app_count}"
      atlas_username = "${var.atlas_username}"
      atlas_token = "${var.atlas_token}"
      atlas_environment = "${var.atlas_environment}"
      key_file = "${var.private_key}"
      host = "${module.docker_base.ip_address}"
   }
   */ <-- Remove this line
   ```
11. Run `terraform push -name <your_atlas_username>/docker_apache` in the [ops/terraform](ops/terraform) directory one more time to now deploy the Docker infrastructure, replacing `<your_atlas_username>` with your Atlas username.
12. That's it! You just deployed an Apache web server and Consul cluster.

Final Step: Verify it Worked!
------------------------
1. Once the Docker infrastructure finishes deploying, go to its public ip and you should see a website that reads "Hello, Atlas!"
   ![Hello, Atlas!](screenshots/hello_atlas.png?raw=true)
2. Go to the [Environments tab](https://atlas.hashicorp.com/environments)  If you navigate to "Status" on the left side panel, you will see the real-time health of all your nodes and services. If click on "Changes" you can view all of your configuration and state changes, as well as deployments.
   ![Infrastructure Status](screenshots/environments_status.png?raw=true)

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform push -name <your_atlas_username>/docker_apache` and it will bring your infrastructure back to the state it was last at.




