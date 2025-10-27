variable "domain_name" {
  description = "Azure AD domain name"
  type = string
}

variable "job_title" {
  description = "Default job title"
  type = string
  default = "IT Lab Administrator"
}

variable "department" {
  description = "Default department"
  type = string
  default = "IT"
}

variable "guest_email" {
  description = "Email address for guest"
  type = string
  default = ""
}

variable "guest_name" {
  description = "Guest name"
  type = string
  default = ""
}