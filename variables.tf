variable "name" {
  description = "The name of the faasd instance. All resources will be namespaced by this value."
  type        = string
}

variable "basic_auth_user" {
  description = "The basic auth user name."
  type        = string
  default     = "admin"
}

variable "basic_auth_password" {
  description = "The basic auth password, if left empty, a random password is generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "domain" {
  description = "A public domain for the faasd instance. This will the use of Caddy and a Let's Encrypt certificate"
  type        = string
  default     = ""
}

variable "email" {
  description = "Email used to order a certificate from Let's Encrypt"
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "Specifies the supported Azure location in which to create the resources."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the Subnet where the Network Interface should be located in."
  type        = string
}

variable "size" {
  description = "The SKU which should be used for this Virtual Machine, such as `Standard_B1ms`."
  type        = string
  default     = "Standard_B1ms"
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  type        = string
  default     = "adminuser"
}

variable "public_key" {
  description = "The Public Key which should be used for authentication, which needs to be at least 2048-bit and in `ssh-rsa` format."
  type        = string
}

variable "tags" {
  description = "A mapping of tags which should be assigned to the resources."
  type        = map(string)
  default     = {}
}
