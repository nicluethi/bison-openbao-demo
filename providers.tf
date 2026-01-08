# Terraform provider configuration for OpenBao/Vault

terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">=5.5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">=7.13.0"
    }
  }
}

# Configure Vault provider with OpenBao server
provider "vault" {
  address         = var.openbao_address
  token           = var.openbao_token
  skip_tls_verify = var.skip_tls_verify
}
