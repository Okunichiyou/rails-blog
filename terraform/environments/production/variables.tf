# ConoHa API Credentials
variable "conoha_username" {
  description = "ConoHa API username"
  type        = string
  sensitive   = true
}

variable "conoha_password" {
  description = "ConoHa API password"
  type        = string
  sensitive   = true
}

variable "conoha_tenant_name" {
  description = "ConoHa tenant name (same as tenant ID)"
  type        = string
  sensitive   = true
}

# Cloudflare
variable "cloudflare_api_token" {
  description = "Cloudflare API token with Zone:DNS:Edit permission"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for okunichiyou.com"
  type        = string
}

