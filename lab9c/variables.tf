variable "subscription_id" {
  type = string
  description = "Azure subscription id"
}

variable "location" {
  type = string
  description = "Location for the resource group and policy assignment"
  default = "polandcentral"
}

variable "username" {
  type = string
  description = "Username"
}

variable "password" {
  type = string
  description = "Password"
}
