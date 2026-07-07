resource "azurerm_shared_image_gallery" "compute_gallery" {

  for_each = var.compute_galleries

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_groups[each.value.resource_group_key]
  description         = "AK Image Factory Gallery"
}

locals {

  flattened_image_definitions = merge([

    for gallery_key, gallery
    in var.compute_galleries :

    {

      for image_key, image_definition
      in gallery.image_definitions :

      "${gallery_key}-${image_key}" => {

        gallery_name        = gallery.name
        resource_group_name = var.resource_groups[gallery.resource_group_key]
        image_definition    = image_definition
      }
    }

  ]...)
}

resource "azurerm_shared_image" "image_definition" {

  for_each = local.flattened_image_definitions

  name                = each.value.image_definition.name
  gallery_name        = each.value.gallery_name
  location            = var.location
  resource_group_name = each.value.resource_group_name
  os_type             = each.value.image_definition.os_type
  hyper_v_generation  = each.value.image_definition.hyper_v_generation

  identifier {

    publisher = each.value.image_definition.publisher
    offer     = each.value.image_definition.offer
    sku       = each.value.image_definition.sku
  }
}