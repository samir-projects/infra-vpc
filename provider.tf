terraform {
  backend "s3" {
    bucket = "terraform-s3-state-710413"
    region = "ca-central-1"
  }
}

provider "aws" {
  region = "ca-central-1"
}

