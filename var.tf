/**** tfvars **/
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_account_id" {}

variable "aws_key_pair_key_name" {}
variable "aws_key_pair_public_key" {}

variable "ecs_key_pair_name" {}
variable "service_name" {}

variable "github_owner" {}
variable "github_token" {}
variable "github_repo" {}
variable "github_branch" {}
variable "domain_name" {}
/**** end of tfvars **/

variable "container_port" { default = "8080" }
variable "memory_reserv" { default = 100 }

locals {
  target_groups = ["primary", "secondary"]
  domain_name=var.domain_name
  hosts_name = [var.domain_name] #example : fill your information
  github_owner = var.github_owner
  github_token = var.github_token
  github_repo = var.github_repo
  github_branch = var.github_branch
}

variable "region" {
  default = "us-east-2"
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

resource "aws_key_pair" "mykey" {
  key_name    = var.aws_key_pair_key_name
  public_key  = var.aws_key_pair_public_key
}

