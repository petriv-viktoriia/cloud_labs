variable "subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant id"
}

variable "location" {
  type        = string
  description = "Location for the resource group and policy assignment"
  default     = "eastus"
}
