# Konfiguracja Terraforma i dostawcy (providera) Azure.
# Provider to "wtyczka", która tłumaczy kod Terraforma na wywołania API Azure.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
  }
}

provider "azurerm" {
  features {}
}
