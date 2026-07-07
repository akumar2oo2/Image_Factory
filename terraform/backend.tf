terraform {

  backend "azurerm" {

    resource_group_name  = "AK-RG-TFState"

    storage_account_name = "aksttfstate"

    container_name = "tfstate"

    key = "imagefactory.tfstate"
  }
}