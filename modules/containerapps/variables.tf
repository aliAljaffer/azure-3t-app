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


variable "fe_port" {
  type        = number
  description = "Port number of the frontend"
}
variable "be_port" {
  type        = number
  description = "Port number of the backend"
}

variable "db_server" {
  type        = string
  description = "Database server FQDN"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_user" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}
