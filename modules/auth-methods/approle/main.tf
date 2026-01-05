# AppRole authentication module - for machine-to-machine authentication

# Enable AppRole authentication method
resource "vault_auth_backend" "approle" {
  type      = "approle"
  path      = var.mount_path
  namespace = var.namespace
}

# Load AppRole configurations from merged config
locals {
  config   = yamldecode(file(var.config_path))
  approles = lookup(local.config, "approles", {})
}

# Create AppRole roles with token and secret ID lifecycle settings
resource "vault_approle_auth_backend_role" "roles" {
  for_each               = local.approles
  backend                = vault_auth_backend.approle.path
  role_name              = each.key
  secret_id_num_uses     = lookup(each.value, "secret_id_num_uses", 0)
  token_num_uses         = lookup(each.value, "token_num_uses", 0)
  token_max_ttl          = lookup(each.value, "token_max_ttl", 0)
  secret_id_ttl          = lookup(each.value, "secret_id_ttl", 0)
  token_explicit_max_ttl = lookup(each.value, "token_explicit_max_ttl", 0)
  token_ttl              = lookup(each.value, "token_ttl", 0)
  token_policies         = each.value.policies
  namespace              = var.namespace
}
