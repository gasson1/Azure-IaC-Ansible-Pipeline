# Konfiguracja Terraforma i dostawcy (providera) Azure.
# Provider to "wtyczka", która tłumaczy kod Terraforma na wywołania API Azure.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
    # Provider "local" zapisuje pliki na dysku - używamy go do
    # automatycznego wygenerowania inwentarza Ansible (ansible.tf).
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "azurerm" {
  features {}
}
