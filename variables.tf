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
}

variable "oidc_client_secret" {
  description = "Azure AD application client secret"
  type        = string
  sensitive   = true
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