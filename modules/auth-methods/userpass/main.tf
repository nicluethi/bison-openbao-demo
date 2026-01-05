# Userpass authentication module - for human user authentication

# Enable username/password authentication method
resource "vault_auth_backend" "userpass" {
  type      = "userpass"
  path      = var.mount_path
  namespace = var.namespace
}

# Create user accounts with assigned policies
resource "vault_generic_endpoint" "users" {
  for_each             = var.users
  path                 = "auth/${vault_auth_backend.userpass.path}/users/${each.key}"
  ignore_absent_fields = true
  namespace            = var.namespace

  data_json = jsonencode({
    token_policies = each.value.policies
    password       = each.value.password
  })
}
