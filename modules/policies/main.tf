# Policy module - creates Vault policies from YAML definitions and tenant configurations

# Load default policies from YAML and generate policy documents
locals {
  policies = yamldecode(file("./modules/policies/default-policies.yaml"))

  # Convert YAML policy definitions to HCL policy documents
  policy_documents = {
    for policy_name, policy_config in local.policies : policy_name => join("\n\n", [
      for rule in policy_config.policies :
      <<-EOT
      path "${rule.path}" {
        capabilities = ${jsonencode(rule.capabilities)}
      }
      EOT
    ])
  }

  # Flatten policy-namespace combinations for resource creation
  policy_namespace_map = merge([
    for policy_name, policy_config in local.policies : {
      for namespace in policy_config.namespaces :
      "${policy_name}/${namespace}" => {
        policy_name = policy_name
        namespace   = namespace
      }
    }
  ]...)
}

# Create default policies in their respective namespaces
resource "vault_policy" "policies" {
  for_each  = local.policy_namespace_map
  name      = each.value.policy_name
  policy    = local.policy_documents[each.value.policy_name]
  namespace = each.value.namespace != "" ? each.value.namespace : null
}

# Generate role-based policies for tenants
locals {
  config  = yamldecode(file(var.config_path))
  tenants = lookup(local.config, "tenants", {})

  # Define capabilities per role level
  role_capabilities = {
    owner       = ["create", "read", "update", "delete", "list", "sudo"]
    contributor = ["create", "read", "update", "list"]
    reader      = ["read", "list"]
  }

  # Flatten tenant structure to create one policy per role assignment
  flattened_with_roles = merge([
    for tenant_name, tenant_config in local.tenants : merge([
      for cluster in tenant_config.cluster : merge([
        for role in ["owner", "contributor", "reader"] : {
          for user in tenant_config[role] :
          "${tenant_name}/${cluster}/${role}/${user}" => {
            tenant_name  = tenant_name
            cluster      = cluster
            role         = role
            user         = user
            full_path    = "${cluster}/${tenant_name}"
            capabilities = local.role_capabilities[role]
            # Generate policy document with role-based permissions
            policy = <<-EOT
            path "secrets/data/${cluster}/${tenant_name}/*" {
              capabilities = ${jsonencode(local.role_capabilities[role])}
            }
            path "secrets/metadata/${cluster}/${tenant_name}/*" {
              capabilities = ["list", "read", "delete"]
            }
            EOT
          }
        }
      ]...)
    ]...)
  ]...)
}

# Create tenant role-based policies
resource "vault_policy" "tenant-policies" {
  for_each  = local.flattened_with_roles
  name      = "fenaco-${each.value.cluster}-${each.value.tenant_name}-${each.value.role}"
  policy    = each.value.policy
  namespace = "k8s-mt"
}
