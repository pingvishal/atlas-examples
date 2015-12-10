#
# Atlas Examples

This repository contains application and infrastructure examples
for [Atlas](https://atlas.hashicorp.com/) by HashiCorp.

## Examples

| Example | Description | Tools Used |
| ------- | ----------- | ---------- |
| [HAProxy-Nodejs](HAProxy-Nodejs) | Deploy a HAProxy and Node.js application on AWS. | Atlas, Consul, Packer, and Terraform |
| [consul-cluster](consul-cluster) | Deploy and bootstrap a consul-cluster in various configurations. | Atlas, Consul, Packer, and Terraform |
| [google-hyperspace](google-hyperspace) | Deploy a real-time multiplayer space shooter game to Google Compute Engine. | Atlas, Packer, and Terraform |
| [infrastructures](infrastructures) | Deploy full application architectures including database, cache, and messaging servers. | Atlas, Consul, Packer, Terraform, and Vault |
| [metamon](metamon) | Deploy a python web app to AWS using Ansible for configuration. | Atlas, Packer, and Terraform |
| [nomad-cluster](nomad-cluster) | Deploy and bootstrap a Nomad cluster on AWS. | Atlas, Nomad, and Terraform |
| [spark](spark) | Deploy a Spark cluster to AWS. | Atlas, Consul, consul-template, and Terraform |

## Setup

Examples should use common inputs and structures as much as possible.
The most commonly used environment variables for the examples are listed
and explained below.

### Environment Variables

```
# For Atlas
ATLAS_TOKEN
ATLAS_USERNAME

# For AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION
```

See the  [Environment variable](https://en.wikipedia.org/wiki/Environment_variable)
article on Wikipedia for an explanation of how to set and use
environment variables.

### Atlas Variables

To generate an _Atlas Token_, visit your account page in [Atlas](https://atlas.hashicorp.com/settings/tokens?utm_source=github&utm_medium=examples&utm_campaign=readme).

_Atlas Username_ can be either your personal username in Atlas (e.g., clstokes) or
the name of the organization you belong to within Atlas (e.g., hashicorp).

### Amazon Web Services Credentials

Visit the [IAM Management Console](https://console.aws.amazon.com/iam/home?region=us-east-1#home) and follow th instructions at [Managing Access Keys for IAM Users](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html).

### Google Cloud Platform Credentials

Visit the [Google Developers Console](https://console.developers.google.com/) and follow the instructions at  [Service accounts](https://developers.google.com/console/help/new/#serviceaccounts).

## Writing Examples

Pretty simple - create a folder named after the example. Add a README if
setup is required, and add supporting files.

> Please try to adhere to the above environment variables to keep
projects consistent and easy to adopt.

## Issues

To report issues (such as typographical errors or confusion) in these examples,
please open a GitHub issue. **For Atlas-specific support, please email
[support@hashicorp.com](mailto:support@hashicorp.com).**


## Documentation

Additional documentation on Atlas, Vagrant, Packer, Terraform, and Consul
can be [read here](https://atlas.hashicorp.com/help#documentation).
