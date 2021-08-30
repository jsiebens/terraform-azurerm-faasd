output "ipv4_address" {
  description = "The public IP address of the faasd instance"
  value       = azurerm_public_ip.faasd.ip_address
}

output "gateway_url" {
  description = "The url of the faasd gateway"
  value       = var.domain == null || var.domain == "" ? format("http:/%s:8080", azurerm_public_ip.faasd.ip_address) : format("https://%s", var.domain)
}

output "basic_auth_user" {
  description = "The basic auth user name."
  value       = local.basic_auth_user
}

output "basic_auth_password" {
  description = "The basic auth password."
  value       = local.basic_auth_password
  sensitive   = true
}