terraform {
  backend "azurerm" {
    resource_group_name  = "rg-backend-dev"
    storage_account_name = "stdevopslab1234"
    container_name       = "tfstate-dev"
    key                  = "dev.terraform.tfstate"
  }
}