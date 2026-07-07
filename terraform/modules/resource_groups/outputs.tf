output "resource_group_names" {

  value = {

    for key, resource_group
    in azurerm_resource_group.resource_group :

    key => resource_group.name
  }
}