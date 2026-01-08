# Load merged configuration file
locals {
  config = yamldecode(file(var.config_path))
  namespaces = lookup(local.config, "namespaces", {})
}

# Configure OIDC auth method in root namespace
resource "vault_jwt_auth_backend" "oidc_root_ns" {
  path               = "oidc"
  type               = "oidc"
  description        = "Azure Entra ID OIDC Authentication"
  oidc_discovery_url = var.discovery_url
  oidc_client_id     = var.client_id
  oidc_client_secret = var.client_secret
  default_role       = var.default_role

  tune {
    listing_visibility = "unauth"
  }
}

# Configure OIDC auth method per namespace
resource "vault_jwt_auth_backend" "oidc" {
  for_each           = local.namespaces
  path               = "oidc"
  type               = "oidc"
  description        = "Azure Entra ID OIDC Authentication"
  oidc_discovery_url = var.discovery_url
  oidc_client_id     = var.client_id
  oidc_client_secret = var.client_secret
  default_role       = var.default_role
  namespace          = each.key

  tune {
    listing_visibility = "unauth"
  }
}

# Create default OIDC role per namespace
resource "vault_jwt_auth_backend_role" "default" {
  for_each       = local.namespaces
  backend        = vault_jwt_auth_backend.oidc[each.key].path
  role_name      = var.default_role
  token_policies = var.default_role_policies
  namespace      = each.key

  user_claim            = var.user_claim
  groups_claim          = var.groups_claim
  allowed_redirect_uris = var.allowed_redirect_uris
  oidc_scopes           = var.oidc_scopes

  token_ttl     = 3600
  token_max_ttl = 7200
}

# Map identity groups to tenant policies
locals {
  tenants = lookup(local.config, "tenants", {})
  # Build mapping: identity_group_name -> list of policies from tenant roles
  identity_group_to_tenant_policies = {
    for group_name in distinct(flatten([
      for tenant_name, tenant_config in local.tenants : [
        for role in ["owner", "contributor", "reader"] : [
          for identity_group in lookup(tenant_config, role, []) : identity_group
        ]
      ]
    ])) : group_name => distinct(flatten([
      for tenant_name, tenant_config in local.tenants : [
        for cluster in lookup(tenant_config, "cluster", []) : concat(
          [
            # Role-specific tenant policies
            for role in ["owner", "contributor", "reader"] : [
              for identity_group in lookup(tenant_config, role, []) :
              "fenaco-${cluster}-${tenant_name}-${role}" if identity_group == group_name
            ]
          ],
          [
            # Cluster access policy for any role
            for role in ["owner", "contributor", "reader"] :
            "fenaco-${cluster}-access" if contains(lookup(tenant_config, role, []), group_name)
          ]
        )
      ]
    ]))
  }
}

# Flatten identity groups across namespaces
locals {
  identity_groups = lookup(local.config, "identity_groups", {})
  # Create one entry per group-namespace combination
  identity_group_per_namespace = {
    for pair in flatten([
      for group_name, group_config in local.identity_groups : [
        for namespace in group_config.namespace : {
          key          = "${namespace}/${group_name}"
          namespace    = namespace
          group_name   = group_name
          group_config = group_config
          # Combine explicit policies with tenant-derived policies
          policies     = concat(
            lookup(group_config, "policies", []),
            lookup(local.identity_group_to_tenant_policies, group_name, [])
          )
        }
      ]
    ]) : pair.key => pair
  }
}


# Create Vault identity groups
resource "vault_identity_group" "groups" {
  for_each  = local.identity_group_per_namespace
  name      = each.value.group_name
  type      = "external"
  policies  = each.value.policies
  namespace = each.value.namespace != "" ? each.value.namespace : null
}

# Link Azure AD groups to Vault identity groups via aliases
resource "vault_identity_group_alias" "group_aliases" {
  for_each       = local.identity_group_per_namespace
  name           = each.value.group_config.azure_group_id
  mount_accessor = each.value.namespace != "" ? vault_jwt_auth_backend.oidc[each.value.namespace].accessor : vault_jwt_auth_backend.oidc_root_ns.accessor
  canonical_id   = vault_identity_group.groups[each.key].id
  namespace      = each.value.namespace != "" ? each.value.namespace : null
}
