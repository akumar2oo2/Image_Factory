module "resource_groups" {

  source = "./modules/resource_groups"

  location        = var.location

  resource_groups = var.resource_groups
}

module "virtual_networks" {

  source = "./modules/virtual_networks"

  location = var.location

  resource_groups = var.resource_groups

  virtual_networks = var.virtual_networks

  depends_on = [
    module.resource_groups
  ]
}

module "compute_galleries" {

  source = "./modules/compute_galleries"

  location = var.location

  resource_groups = var.resource_groups

  compute_galleries = var.compute_galleries

  depends_on = [
    module.resource_groups
  ]
}
