# Namespace module - creates Vault namespaces with KV v2 engines and access policies

# Load configuration and prepare namespace structure
locals {
  config     = yamldecode(file(var.config_path))
  namespaces = lookup(local.config, "namespaces", {})

  # Create flattened structure: parent/child -> policy mapping
  flattened_namespaces = merge([
    for parent_key, child_list in local.namespaces : {
      for child in child_list :
      "${parent_key}/${child}" => {
        namespace        = parent_key
        child_identifier = child
        full_path        = "${parent_key}/${child}"
        policy           = <<-EOT
            path "secrets/metadata/${child}" {
              capabilities = ["list", "read"]
            }
            path "secrets/data/${child}" {
              capabilities = ["read"]
            }
            EOT
      }
    }
  ]...)
}

# Create parent namespaces
resource "vault_namespace" "parent" {
  for_each = local.namespaces
  path     = each.key
}

# Enable KV v2 secrets engine in each namespace
resource "vault_mount" "kv" {
  for_each              = local.namespaces
  path                  = var.mount_path
  type                  = "kv"
  description           = "KV Version 2 secrets engine"
  namespace             = vault_namespace.parent[each.key].path
  max_lease_ttl_seconds = 0

  options = {
    version = "2"
  }

  depends_on = [vault_namespace.parent]
}

# Create placeholder secrets to initialize cluster structure
resource "vault_generic_secret" "namespace_path" {
  for_each  = local.flattened_namespaces
  namespace = vault_namespace.parent[each.value.namespace].path
  path      = "${var.mount_path}/${each.value.child_identifier}/secret"

  data_json = jsonencode({
    ".placeholder" = "asdf"
  })

  depends_on = [vault_mount.kv]
}

# Create read-only access policy per cluster namespace
resource "vault_policy" "namespace-policies" {
  for_each  = local.flattened_namespaces
  name      = "fenaco-${each.value.child_identifier}-access"
  policy    = each.value.policy
  namespace = vault_namespace.parent[each.value.namespace].path
}

# Load tenant definitions and create tenant structure
locals {
  tenants = lookup(local.config, "tenants", {})

  # Create flattened structure: tenant/cluster -> config mapping
  flattened_tenants = merge([
    for tenant_name, tenant_config in local.tenants : {
      for cluster in tenant_config.cluster :
      "${tenant_name}/${cluster}" => {
        tenant_name = tenant_name
        cluster     = cluster
        owner       = tenant_config.owner
        contributor = tenant_config.contributor
        reader      = tenant_config.reader
        full_path   = "${cluster}/${tenant_name}"
      }
    }
  ]...)
}

# Create placeholder secrets to initialize tenant paths
resource "vault_generic_secret" "tenant" {
  for_each  = local.flattened_tenants
  namespace = "k8s-mt"
  path      = "${var.mount_path}/${each.value.full_path}/.placeholder"

  data_json = jsonencode({
    ".placeholder" = "asdf"
  })

  depends_on = [vault_mount.kv]
}
