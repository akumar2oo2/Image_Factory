resource "azurerm_resource_group" "resource_group" {

  for_each = var.resource_groups

  name     = each.value
  location = var.location
}