# OpenBao provider connection settings
variable "openbao_address" {
  description = "OpenBao server address"
  type        = string
  default     = "http://127.0.0.1:8200"
}

variable "openbao_token" {
  description = "OpenBao root token (dev only!)"
  type        = string
  sensitive   = true
  default     = "root"
}

variable "skip_tls_verify" {
  description = "Skip TLS certificate verification (dev only!)"
  type        = bool
  default     = true
}

# Userpass authentication settings
variable "admin_password" {
  description = "Password for admin user"
  type        = string
  sensitive   = true
  default     = "admin123"
}

# OIDC authentication settings
variable "oidc_discovery_url" {
  description = "Azure AD OIDC discovery endpoint URL"
  type        = string
}

variable "oidc_client_id" {
  description = "Azure AD application client ID"
  type        = string
  sensitive   = true
  default     = "895d5e07-fe09-4b8c-a25b-21a9a2739145"
}

variable "oidc_client_secret" {
  description = "Azure AD application client secret"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vault_addr" {
  description = "Vault external address for OIDC callback redirects"
  type        = string
}

# Resource path configurations
variable "additional_roles_path" {
  description = "Path to additional OIDC roles directory"
  type        = string
  default     = "./resources/oidc/roles"
}

variable "identity_group_path" {
  description = "Path to identity groups directory"
  type        = string
  default     = "./resources/oidc/identity_groups"
}

variable "tenant_path" {
  description = "Path to tenant definitions directory"
  type        = string
  default     = "./resources/tenant"
}

variable "config_path" {
  description = "Path to merged configuration file"
  type        = string
  default     = "./config.yaml"
}


# Auto-Unseal
variable "gcloud-project" {
  description = "Google project name"
}

variable "gcloud-region" {
  default = "us-east1"
}

variable "gcloud-zone" {
  default = "us-east1-b"
}

variable "account_file_path" {
  description = "Path to GCP account file"
}

variable "key_ring" {
  description = "Cloud KMS key ring name to create"
  default     = "test"
}

variable "crypto_key" {
  default     = "vault-test"
  description = "Crypto key name to create under the key ring"
}

variable "keyring_location" {
  default = "global"
}