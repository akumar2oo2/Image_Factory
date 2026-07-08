packer {
  required_version = ">= 1.14.0"

  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = "~> 2"
    }

    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = ">= 1.1.0"
    }
  }
}

# Azure Authentication / Subscription

variable "subscription_id" {
  type = string
}

variable "location" {
  type    = string
  default = "Central India"
}

# Azure Resource Groups

variable "build_resource_group_name" {
  type    = string
  default = "AK-RG-ImageFactory"
}

variable "network_resource_group_name" {
  type    = string
  default = "AK-RG-Network"
}

variable "gallery_resource_group_name" {
  type    = string
  default = "AK-RG-Images"
}

# Azure Network

variable "virtual_network_name" {
  type    = string
  default = "AK-VNET"
}

variable "build_subnet_name" {
  type    = string
  default = "AK-Build-Subnet"
}

# Azure Compute Gallery

variable "gallery_name" {
  type    = string
  default = "AKACGImages"
}

variable "image_definition_name" {
  type    = string
  default = "Win2022-Gen2"
}

variable "image_version" {
  type    = string
  default = "1.0.0"
}

# Build VM

variable "build_vm_size" {
  type    = string
  default = "Standard_D2ads_v5"
}

# Installer URLs
# These will be generated dynamically in GitHub Actions.
# They should be short-lived SAS URLs generated at pipeline runtime.

variable "fslogix_url" {
  type      = string
  sensitive = true
}

variable "citrix_url" {
  type      = string
  sensitive = true
}

# WinRM

variable "winrm_username" {
  type    = string
  default = "packeruser"
}

variable "winrm_password" {
  type      = string
  sensitive = true
}

variable "pause_seconds" {
  type    = number
  default = 30
}

# SOURCE IMAGE

source "azure-arm" "windows_server_2022" {

  # GitHub Actions logs in to Azure using OIDC.
  # Packer reuses that Azure CLI session.
  use_azure_cli_auth = true

  subscription_id = var.subscription_id

  # Temporary Packer build resources
  build_resource_group_name = var.build_resource_group_name

  # Private networking
  virtual_network_name                = var.virtual_network_name
  virtual_network_subnet_name         = var.build_subnet_name
  virtual_network_resource_group_name = var.network_resource_group_name

  # Since AK-GH-Runner is inside AK-VNET, the Packer build VM should not need a public IP.
  private_virtual_network_with_public_ip = false

  # Build VM size
  vm_size = var.build_vm_size

  # Marketplace image
  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2022-datacenter-g2"

  # WinRM communicator
  communicator   = "winrm"
  winrm_username = var.winrm_username
  winrm_password = var.winrm_password

  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = "10m"

  # Publish image to Azure Compute Gallery
  shared_image_gallery_destination {
    subscription        = var.subscription_id
    resource_group      = var.gallery_resource_group_name
    gallery_name        = var.gallery_name
    image_name          = var.image_definition_name
    image_version       = var.image_version
    replication_regions = [var.location]
  }
}

# BUILD

build {

  name = "ak-image-factory-win2022"

  sources = [
    "source.azure-arm.windows_server_2022"
  ]

  # Main Provisioning Using Ansible
  provisioner "ansible" {
    playbook_file = "${path.root}/../ansible/playbook.yml"

    user      = var.winrm_username
    use_proxy = false

    extra_arguments = [
      "-e", "ansible_connection=winrm",
      "-e", "ansible_user=${var.winrm_username}",
      "-e", "ansible_password=${var.winrm_password}",
      "-e", "ansible_port=5986",
      "-e", "ansible_winrm_scheme=https",
      "-e", "ansible_winrm_transport=ntlm",
      "-e", "ansible_winrm_server_cert_validation=ignore",
      "-e", "ansible_shell_type=cmd",
      "-e", "ansible_winrm_operation_timeout_sec=60",
      "-e", "ansible_winrm_read_timeout_sec=90",

      "-e", "fslogix_url=${var.fslogix_url}",
      "-e", "citrix_url=${var.citrix_url}",

      "-e", "pause_seconds=${var.pause_seconds}"
    ]
  }

  # FINAL SYSPREP
  
  provisioner "powershell" {
    inline = [
      "Write-Host 'Running Sysprep...'",
      "& C:\\Windows\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /mode:vm"
    ]
  }
}