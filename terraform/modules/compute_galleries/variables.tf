variable "location" {
  type = string
}

variable "resource_groups" {
  type = map(string)
}

variable "compute_galleries" {
  type = any
}