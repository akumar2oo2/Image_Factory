resource "azurerm_virtual_network" "virtual_network" {

  for_each = var.virtual_networks

  name                = each.value.name
  resource_group_name = var.resource_groups[each.value.resource_group_key]
  location            = var.location
  address_space       = each.value.address_space
}

locals {

  flattened_subnets = merge([

    for network_key, network
    in var.virtual_networks : {

      for subnet_key, subnet in network.subnets : "${network_key}-${subnet_key}" => {

        subnet_name         = subnet.name
        subnet_cidr         = subnet.cidr
        virtual_network_key = network_key
        resource_group_name = var.resource_groups[network.resource_group_key]
      }
    }
  ]...)
}

resource "azurerm_subnet" "subnet" {

  for_each = local.flattened_subnets

  name                 = each.value.subnet_name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network[each.value.virtual_network_key].name
  address_prefixes     = [each.value.subnet_cidr]
}