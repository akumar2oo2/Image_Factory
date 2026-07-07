output "compute_gallery_names" {

  value = {

    for key, compute_gallery
    in azurerm_shared_image_gallery.compute_gallery :

    key => compute_gallery.name
  }
}