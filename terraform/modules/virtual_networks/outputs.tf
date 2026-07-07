output "virtual_network_names" {

  value = {

    for key, virtual_network
    in azurerm_virtual_network.virtual_network :

    key => virtual_network.name
  }
}

output "subnet_ids" {

  value = {

    for key, subnet
    in azurerm_subnet.subnet :

    key => subnet.id
  }
}