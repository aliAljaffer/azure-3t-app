terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  subscription_id = var.ARM_SUBSCRIPTION_ID
  features {

  }
}

locals {
  common_tags = {
    Author      = "Ali Aljaffer"
    Project     = "Project1-ih"
    Provisioner = "Terraform"
  }
}

