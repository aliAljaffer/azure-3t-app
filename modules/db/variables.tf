variable "rg_name" {
  type        = string
  description = "resource group name"
}
variable "rg_location" {
  type        = string
  description = "resource group location"
}
variable "db_password" {
  type        = string
  sensitive   = true
  description = "resource group location"
}
variable "vnet_id" {
  type        = string
  description = "ID of the virtual network"
}
variable "private_endpoint_subnet_id" {
  type        = string
  description = "ID of the subnet"
}
