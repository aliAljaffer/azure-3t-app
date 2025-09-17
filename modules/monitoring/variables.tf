variable "rg_name" {
  type        = string
  description = "resource group name"
}
variable "rg_location" {
  type        = string
  description = "resource group location"
}

variable "vnet_name" {
  type        = string
  description = "Name of the VNet"
}

variable "fe_app_id" {
  type        = string
  description = "ID of the frontend container app"
}
variable "be_app_id" {
  type        = string
  description = "ID of the backend container app"
}
variable "db_id" {
  type        = string
  description = "ID of the database"
}
