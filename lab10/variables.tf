variable "subscription_id" {
  type = string
  description = "Azure subscription id"
}

variable "loc1" {
  type = string
  description = "Location for the resource group and policy assignment"
  default = "westus"
}

variable "loc2" {
  type = string
  description = "Location for the resource group and policy assignment"
  default = "eastus"
}

variable "username" {
  type = string
  description = "Username"
}

variable "password" {
  type = string
  description = "Password"
}
