variable "ARM_SUBSCRIPTION_ID" {
  type        = string
  description = "Azure RM sub ID"
}
variable "db_password" {
  type        = string
  sensitive   = true
  description = "Password for the MSSQL Database"
}
