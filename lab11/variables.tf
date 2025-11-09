variable "subscription_id" {
  type = string
  description = "Azure subscription id"
}

variable "loc" {
  type = string
  description = "Location for the resource group and policy assignment"
  default = "westus"
}

variable "username" {
  type = string
  description = "Username"
}

variable "password" {
  type = string
  description = "Password"
}

variable "email" {
  type = string
  description = "Email"
}
