terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#Provider for route 53 Domains
provider "aws" {
  region = "us-east-1"  # For Route 53 Domains(this is because route53 domain service 
                           #is only available in us-east-1)
  alias  = "route53-domains"
}
# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}