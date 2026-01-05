# Policies Module
module "policies" {
  source      = "./modules/policies"
  config_path = var.config_path

  depends_on = [module.k8s_namespaces]
}

# Namespaces Module (K8s Multi-Tenancy)
module "k8s_namespaces" {
  source      = "./modules/namespaces"
  config_path = var.config_path
  mount_path  = "secrets"
}

# AppRole Auth Method
module "approle_auth" {
  source      = "./modules/auth-methods/approle"
  mount_path  = "approle"
  config_path = var.config_path
}

# Userpass Auth Method
module "userpass_auth" {
  source     = "./modules/auth-methods/userpass"
  mount_path = "userpass"

  users = {
    admin = {
      password = var.admin_password
      policies = ["admin"]
    }
  }
}

# OIDC Auth Method (Azure Entra ID)
module "oidc_auth" {
  source        = "./modules/auth-methods/oidc"
  mount_path    = "oidc"
  description   = "Azure Entra ID OIDC Authentication"
  discovery_url = var.oidc_discovery_url
  client_id     = var.oidc_client_id
  client_secret = var.oidc_client_secret
  default_role  = "kv-base"

  allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "http://${var.vault_addr}/ui/vault/auth/oidc/oidc/callback"
  ]

  oidc_scopes           = ["https://graph.microsoft.com/.default"]
  default_role_policies = ["kv-base"]
  additional_roles_path = var.additional_roles_path
  identity_groups_path  = var.identity_group_path
  config_path           = var.config_path

  depends_on = [module.k8s_namespaces]
}
