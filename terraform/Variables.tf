variable "location" {
  type = string
}

variable "resource_groups" {
  type = map(string)
}

variable "virtual_networks" {
  type = any
}

variable "compute_galleries" {
  type = any
}