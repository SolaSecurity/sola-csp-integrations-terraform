terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}
