output "resource_groups" {
  value = module.resource_groups.resource_group_names
}

output "virtual_network_names" {
  value = module.virtual_networks.virtual_network_names
}

output "compute_gallery_names" {
  value = module.compute_galleries.compute_gallery_names
}