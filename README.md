# OpenBao Terraform Configuration

Modular Terraform configuration for OpenBao with centralized YAML-based configuration supporting multi-tenancy, RBAC, and multiple authentication methods.

## Project Structure

```
bison-openbao-demo/
├── main.tf                          # Main Terraform configuration
├── providers.tf                     # Vault provider configuration
├── variables.tf                     # Input variables
├── terraform.tfvars                 # Variable values (do not commit with real secrets!)
├── config.yaml                      # Central configuration file
│
└── modules/                         # Reusable Terraform modules
    ├── auth-methods/
    │   ├── approle/                 # AppRole authentication
    │   └── oidc/                    # OIDC/Azure Entra ID authentication
    ├── namespaces/                  # Namespace & tenant management
    └── policies/                    # Policy management
        └── default-policies.yaml    # Default policy definitions
```

## Quick Start

### 1. Initialize Terraform

```bash
tofu init
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
# OpenBao connection
openbao_address     = "localhost:8200"
openbao_token       = ""  # Set your token here
skip_tls_verify     = true

# OIDC Configuration (Azure Entra ID)
oidc_discovery_url  = "https://login.microsoftonline.com/<tenant-id>/v2.0"
oidc_client_id      = ""
oidc_client_secret  = ""
```

**Important:** Never commit `terraform.tfvars` with real credentials to version control!

### 3. Deploy

```bash
tofu plan
tofu apply
```

### 4. Configure OpenBao

Edit [config.yaml](config.yaml) to define your infrastructure:

```yaml
# Define namespaces
namespaces:
  k8s-mt:
    - "gke-infra-prod"
    - "gke-infra-non-prod"

# Map Azure AD groups to Vault
identity_groups:
  secops:
    azure_group_id: "your-azure-group-id"
    namespace:
      - "k8s-mt"
    policies:
      - "kv-base"

# Define tenants with RBAC
tenants:
  tenant-1:
    cluster:
      - "gke-infra-prod"
    owner: []
    contributor: []
    reader:
      - "secops"

# Define AppRoles
approles:
  my-service:
    policies:
      - "my-policy"
```

### 5. Login to OpenBao

**OIDC (Azure Entra ID):**
```bash
export VAULT_ADDR=http://localhost:8200
bao login -method=oidc role=kv-base
```

**AppRole (for services):**
```bash
bao write auth/approle/login role_id=<role-id> secret_id=<secret-id>
```

## Configuration Structure

All configuration is centralized in [config.yaml](config.yaml) with four main sections:

### 1. Namespaces

Define hierarchical namespaces for multi-tenancy (e.g., K8s clusters):

```yaml
namespaces:
  k8s-mt:  # Parent namespace
    - "gke-infra-prod"      # Child namespace
    - "gke-infra-non-prod"
    - "gke-workload-prod"
```

**Features:**
- Automatic KV v2 secret engine mounted at `secrets/` in each namespace
- Hierarchical structure for logical separation
- Support for multiple parent namespaces

### 2. Identity Groups

Map Azure AD groups to Vault identity groups with policies:

```yaml
identity_groups:
  secops:
    azure_group_id: "azure-ad-group-object-id"
    namespace:
      - "k8s-mt"  # Can be applied to multiple namespaces
    policies:
      - "kv-base"
```

**Features:**
- Azure Entra ID (Azure AD) group integration
- External group aliases for SSO
- Multi-namespace policy assignment

### 3. Tenants

Define tenants with role-based access control (owner/contributor/reader):

```yaml
tenants:
  tenant-1:
    cluster:  # List of clusters tenant can access
      - "gke-infra-prod"
      - "gke-infra-non-prod"
    owner:        # Full access
      - "app-dev"
    contributor:  # Read-write access
      - "secops"
    reader:       # Read-only access
      - "support-team"
```

**Features:**
- Automatic policy generation per tenant-cluster-role combination
- Three-tier RBAC (owner/contributor/reader)
- Cluster-level access policies

### 4. AppRoles

Define AppRoles for machine authentication:

```yaml
approles:
  cert-manager:
    policies:
      - "pki-issue"
  my-service:
    policies:
      - "kv-read"
      - "transit-encrypt"
```

**Features:**
- Policy-based access for services
- Role ID and Secret ID authentication
- Suitable for CI/CD and service accounts

## Terraform Modules

### Namespaces Module

**Location:** [modules/namespaces/](modules/namespaces/)

Manages namespace hierarchy and automatically:
- Creates parent and child namespaces from `config.yaml`
- Mounts KV v2 secret engine at `secrets/` in each namespace
- Sets up OIDC auth backend per namespace
- Creates identity groups with tenant-derived policies

### Policies Module

**Location:** [modules/policies/](modules/policies/)

Automatically generates policies:
- Default policies from [modules/policies/default-policies.yaml](modules/policies/default-policies.yaml)
- Tenant-specific policies (e.g., `fenaco-gke-infra-prod-tenant1-owner`)
- Cluster access policies (e.g., `fenaco-gke-infra-prod-access`)

### OIDC Auth Module

**Location:** [modules/auth-methods/oidc/](modules/auth-methods/oidc/)

Configures Azure Entra ID authentication:
- OIDC backend in root and child namespaces
- Default role (`kv-base`) with base policies
- Identity group aliases linked to Azure AD groups

### AppRole Auth Module

**Location:** [modules/auth-methods/approle/](modules/auth-methods/approle/)

Creates AppRoles from `config.yaml` for machine authentication.

## Usage Examples

### Add a New Tenant

Edit [config.yaml](config.yaml):

```yaml
tenants:
  my-new-tenant:
    cluster:
      - "gke-infra-prod"
    owner:
      - "platform-team"
    reader:
      - "secops"
```

Apply changes:
```bash
tofu apply
```

This automatically creates policies:
- `fenaco-gke-infra-prod-my-new-tenant-owner`
- `fenaco-gke-infra-prod-my-new-tenant-reader`
- `fenaco-gke-infra-prod-access`

### Add a New Identity Group

Edit [config.yaml](config.yaml):

```yaml
identity_groups:
  developers:
    azure_group_id: "your-azure-ad-group-id"
    namespace:
      - "k8s-mt"
    policies:
      - "kv-base"
```

Apply changes:
```bash
tofu apply
```

### Add a New Namespace

Edit [config.yaml](config.yaml):

```yaml
namespaces:
  platform:  # New parent namespace
    - "prod"
    - "staging"
    - "dev"
```

Apply changes:
```bash
tofu apply
```

This creates:
- Parent namespace `platform`
- Child namespaces `prod`, `staging`, `dev`
- KV v2 engine at `secrets/` in each
- OIDC auth backend in each namespace

### Add a New AppRole

Edit [config.yaml](config.yaml):

```yaml
approles:
  gitlab-ci:
    policies:
      - "ci-deploy"
```

Apply and retrieve credentials:
```bash
tofu apply
bao read auth/approle/role/gitlab-ci/role-id
bao write -f auth/approle/role/gitlab-ci/secret-id
```

## Architecture Highlights

### Multi-Tenancy Model

The configuration supports a hierarchical multi-tenancy model:

1. **Namespaces** - Logical separation (e.g., per K8s cluster)
2. **Tenants** - Business units or teams with cluster access
3. **Roles** - Three-tier RBAC (owner/contributor/reader)
4. **Policies** - Auto-generated per tenant-cluster-role combination

### Policy Naming Convention

Policies follow the pattern: `fenaco-{cluster}-{tenant}-{role}`

Examples:
- `fenaco-gke-infra-prod-tenant1-owner`
- `fenaco-gke-workload-prod-tenant2-reader`
- `fenaco-gke-infra-prod-access` (cluster-level access)

### Identity Group Mapping

Identity groups combine:
1. **Explicit policies** - Defined in `config.yaml`
2. **Tenant-derived policies** - Auto-generated from tenant roles

Example: A user in `secops` group assigned as reader for `tenant-1` automatically receives both the `kv-base` policy and tenant-specific reader policies.

## Security Best Practices

1. **Never commit secrets** - Use `.gitignore` for `terraform.tfvars`
2. **Use separate environments** - Different `config.yaml` per environment
3. **Rotate credentials** - Regularly rotate root tokens and client secrets
4. **Principle of least privilege** - Assign minimal required policies
5. **Audit logging** - Enable OpenBao audit logs
6. **TLS in production** - Never use `skip_tls_verify = true` in production

## Resources

- [OpenBao Documentation](https://openbao.org/docs/)
- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Azure AD OIDC Setup](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread)

## License

This project is for demonstration purposes.
