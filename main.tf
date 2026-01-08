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

# OIDC Auth Method (Azure Entra ID)
module "oidc_auth" {
  source        = "./modules/auth-methods/oidc"
  discovery_url = var.oidc_discovery_url
  client_id     = var.oidc_client_id
  client_secret = var.oidc_client_secret
  default_role  = "kv-base"

  allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "http://${var.openbao_address}/ui/vault/auth/oidc/oidc/callback"
  ]

  oidc_scopes           = ["https://graph.microsoft.com/.default"]
  default_role_policies = ["kv-base"]
  config_path           = var.config_path

  depends_on = [module.k8s_namespaces]
}
