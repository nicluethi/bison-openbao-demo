# OpenBao Terraform Configuration

Modular Terraform configuration for OpenBao with separate modules for authentication methods, secret engines, and namespaces.

## Project Structure

```
openbao/
├── main.tf                          # Main configuration
├── providers.tf                     # Provider configuration
├── variables.tf                     # Input variables
│
├── modules/                         # Reusable modules
│   ├── auth-methods/
│   │   ├── approle/                 # AppRole authentication
│   │   ├── userpass/                # Userpass authentication
│   │   └── oidc/                    # OIDC/Azure AD authentication
│   ├── namespaces/                  # Namespace management
│   ├── policies/                    # Policy management
│   └── secret-engines/
│       └── kv-v2/                   # KV Version 2 secret engine
│
├── approles/                        # AppRole configurations (YAML)
├── namespaces/                      # Namespace definitions (YAML)
├── oidc/
│   ├── roles/                       # OIDC role definitions (YAML)
│   └── identity_groups/             # Azure AD group mappings (YAML)
└── policy/                          # Policy definitions (YAML)
```

## Quick Start

### 1. Initialize Terraform

```bash
tofu init
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
openbao_address     = "http://127.0.0.1:8200"
openbao_token       = "root"
admin_password      = "secure-password"
oidc_discovery_url  = "https://login.microsoftonline.com/<tenant-id>/v2.0"
oidc_client_id      = "your-client-id"
oidc_client_secret  = "your-client-secret"
vault_addr          = "127.0.0.1:8200"
```

### 3. Deploy

```bash
tofu plan
tofu apply
```

### 4. Login

**Userpass:**
```bash
export VAULT_ADDR=http://127.0.0.1:8200
bao login -method=userpass username=admin
```

**OIDC:**
```bash
bao login -method=oidc role=default
```

## Modules

### Auth Methods

#### AppRole

Provides machine authentication for services and applications.

**Location:** [modules/auth-methods/approle/](modules/auth-methods/approle/)

**Configuration:** YAML files in [approles/](approles/)

```yaml
cert-manager-bison-ch:
  policies:
    - cert-manager-policy
  token_ttl: 3600
```

#### Userpass

Username/password authentication for human users.

**Location:** [modules/auth-methods/userpass/](modules/auth-methods/userpass/)

**Configuration:** Defined in [main.tf](main.tf)

#### OIDC

Azure Entra ID (Azure AD) integration with group-based policies.

**Location:** [modules/auth-methods/oidc/](modules/auth-methods/oidc/)

**Configuration:**
- Roles: YAML files in [oidc/roles/](oidc/roles/)
- Identity Groups: YAML files in [oidc/identity_groups/](oidc/identity_groups/)
- Namespaces: YAML files in [namespaces/](namespaces/)

### Namespaces

Hierarchical namespace management for multi-tenancy (e.g., K8s environments).

**Location:** [modules/namespaces/](modules/namespaces/)

**Configuration:** YAML files in [namespaces/](namespaces/)

```yaml
k8s-mt:
  parent: k8s-mt
  children:
    - name: "gke-infra-prod"
      description: "GKE Infrastructure Production"
```

**Features:**
- Parent/child namespace hierarchy
- Automatic KV v2 mount per namespace
- Initial test secrets

### Policies

Policy management from YAML definitions.

**Location:** [modules/policies/](modules/policies/)

**Configuration:** YAML files in [policy/](policy/)

```yaml
secops:
  namespaces:
    - ""
    - "k8s-mt"
  policies:
    - path: "secret/*"
      capabilities: ["create", "read", "update", "delete", "list"]
```

### Secret Engines

#### KV v2

Key-Value v2 secret engine with versioning.

**Location:** [modules/secret-engines/kv-v2/](modules/secret-engines/kv-v2/)

**Instances:**
- `dev-secrets` - Development secrets
- `kv` - General KV storage

## Configuration Files

### AppRole Configuration

**File:** `approles/<name>.yaml`

```yaml
my-service:
  policies:
    - my-policy
  token_ttl: 3600
  token_max_ttl: 7200
```

### OIDC Role Configuration

**File:** `oidc/roles/<name>.yaml`

```yaml
app-dev:
  policies:
    - kv-reader
  token_ttl: 3600
```

### Identity Group Configuration

**File:** `oidc/identity_groups/<name>.yaml`

```yaml
secops:
  azure_group_id: "4b2d49c0-734f-467d-8958-a4942b2cb4c1"
  policies:
    - secops
```

### Namespace Configuration

**File:** `namespaces/<name>.yaml`

```yaml
k8s-mt:
  parent: k8s-mt
  children:
    - name: "gke-infra-prod"
      description: "GKE Infrastructure Production"
```

### Policy Configuration

**File:** `policy/<name>.yaml`

```yaml
my-policy:
  namespaces:
    - ""
    - "k8s-mt"
  policies:
    - path: "secret/data/*"
      capabilities: ["read", "list"]
```

## Usage Examples

### Add New AppRole

1. Create YAML configuration:
```bash
cat > approles/my-service.yaml <<EOF
my-service:
  policies:
    - my-policy
EOF
```

2. Apply:
```bash
tofu apply
```

### Add New OIDC Identity Group

1. Create YAML configuration:
```bash
cat > oidc/identity_groups/developers.yaml <<EOF
developers:
  azure_group_id: "group-object-id"
  policies:
    - developer-policy
EOF
```

2. Apply:
```bash
tofu apply
```

### Add New Namespace

1. Create YAML configuration:
```bash
cat > namespaces/my-env.yaml <<EOF
my-env:
  parent: my-env
  children:
    - name: "prod"
      description: "Production Environment"
    - name: "dev"
      description: "Development Environment"
EOF
```

2. Apply:
```bash
tofu apply
```

## Resources

- [OpenBao Documentation](https://openbao.org/docs/)
- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Azure AD OIDC Setup](https://developer.hashicorp.com/vault/docs/auth/jwt/oidc-providers/azuread)
