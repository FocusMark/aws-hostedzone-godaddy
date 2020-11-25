# AWS GoDaddy Hosted Zone

The FocusMark AWS GoDaddy Hosted Zone repository contains all of resources needed to use the GoDaddy API for setting NameServers on a Domain to those of a Route 53 Hosted Zone. This repository assumes you own a Domain in GoDaddy that you are going to use in AWS Route 53 for DNS management.

The repository consists of bash scripts, a JavaScript Lambda and CloudFormation templates. It has been built and tested in a Linux environment. There should be very little work needed to deploy from macOS; deploying from Windows is not supported at this time but could be done with a little effort.

# Deploy

## Requirements

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html)
- [SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)

## Optional
- [cfn-lint](https://github.com/aws-cloudformation/cfn-python-lint)

## Environment Variables
In order to run the deployment script you must have your environment set up with a few environment variables. The following table outlines the environment variables required with example values.

| Key                  | Value Type | Description | Examples                                           |
|----------------------|------------|-------------|----------------------------------------------------|
| deployed_environment | string     | The name of the environment you are deploying into | dev or prod |
| focusmark_productname | string | The name of the product. You _must_ use the name of a Domain that you own. | SuperTodo |
| target_domain | string | The Domain you own in GoDaddy. THis will be used to create a Hosted Zone and set nameservers on the domain. | supertodo.com |
| target_api_url | string | The GoDaddy API url for setting DNS nameservers on your domain. | https://api.godaddy.com/v1/domains/supertodo.com/records |
| target_api_key | string | The API key issued by GoDaddy to manage domains via API calls | abcdefg12345abcdefg |
| target_api_secret | string | The API secret issued by GoDaddy to manage domains via API calls | abcdefg12345abcdefg |


In Linux or macOS environments you can set this in your `.bash_profile` file.

```
export deployed_environment=dev
export focusmark_productname=supertodo
export target_domain=supertodo.com
export target_api_url=https://api.godaddy.com/v1/domains/supertodo.com/records
export target_api_key=abcdefg12345abcdefg
export target_api_secret=abcdefg12345abcdefg

PATH=$PATH:$HOME/.local/bin:$HOME/bin
```

once your `.bash_profile` is set you can refresh the environment

```
$ source ~/.bash_profile
```

The `deployed_environment` and `focusmark_productname` environment variables will be used in all of the names of the resources provisioned during deployment. Using the `prod` environment and `supertodo` as the product name for example, the Lambda deployed will be created as `supertodo-prod-lambda-hostedzone_godaddy`.

## Infrastructure

The core infrastructure in this repository consists of the following:

- Hosted Zone for Domain and Nameservers, including a Lambda for assigning AWS Route 53 Nameservers to GoDaddy Domains.

![Architecture](/docs/aws-hostedzone-godaddy-resources.jpeg)

## Deployment

In order to deploy the infrastructure you just need to execute the bash script included in the root directory from a terminal:

```
$ sh deploy.sh
```

This will kick off the process and deploy the Secrets into Parameter Store as a Secure String for GoDaddy API Keys. Once those are deployed the process wil deploy a Hosted Zone and a Lambda. The Lambda will assign GoDaddy domain nameservers to the Route 53 Hosted Zone deployed in this stack.

![Deployment](/docs/aws-hostedzone-godaddy-resources.jpeg)

# Usage

Once the deployment is completed you will now have an AWS Route 53 Hosted Zone created. The Hosted Zone has it's Hosted Zone ID exported in CloudFormation for use in other Stacks. You can get this value by importing the `${ProductName}-route53-dotAppZone` value.