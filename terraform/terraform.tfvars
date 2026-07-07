location = "Central India"

resource_groups = {

  identity     = "AK-RG-Identity"
  network      = "AK-RG-Network"
  runner       = "AK-RG-Runner"
  imagefactory = "AK-RG-ImageFactory"
  images       = "AK-RG-Images"
}

virtual_networks = {

  primary = {

    name               = "AK-VNET"
    resource_group_key = "network"
    address_space      = ["10.0.0.0/16"]

    subnets = {

      runner = {
        name = "AK-Runner-Subnet"
        cidr = "10.0.1.0/24"
      }

      build = {
        name = "AK-Build-Subnet"
        cidr = "10.0.2.0/24"
      }
    }
  }
}

compute_galleries = {

  primary = {

    name               = "AK-ACG-Images"
    resource_group_key = "images"
    image_definitions = {

      win2022 = {

        name               = "Win2022-Gen2"
        publisher          = "AK"
        offer              = "ImageFactory"
        sku                = "Win2022Gen2"
        os_type            = "Windows"
        hyper_v_generation = "V2"
      }
    }
  }
}