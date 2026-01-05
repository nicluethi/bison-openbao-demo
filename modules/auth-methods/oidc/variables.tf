# OIDC authentication module variables

# OIDC backend configuration
variable "mount_path" {
  description = "Mount path for OIDC auth backend"
  type        = string
  default     = "oidc"
}

variable "description" {
  description = "Description for OIDC auth backend"
  type        = string
  default     = "OIDC Authentication"
}

variable "discovery_url" {
  description = "OIDC discovery URL (e.g., Azure AD endpoint)"
  type        = string
}

variable "client_id" {
  description = "OIDC client ID"
  type        = string
}

variable "client_secret" {
  description = "OIDC client secret"
  type        = string
  sensitive   = true
}

variable "listing_visibility" {
  description = "Listing visibility setting for auth backend"
  type        = string
  default     = "unauth"
}

# OIDC role configuration
variable "default_role" {
  description = "Name of default OIDC role"
  type        = string
  default     = "default"
}

variable "default_role_policies" {
  description = "Policies assigned to default role"
  type        = list(string)
  default     = ["default"]
}

variable "user_claim" {
  description = "JWT claim for user identifier"
  type        = string
  default     = "email"
}

variable "groups_claim" {
  description = "JWT claim for group membership"
  type        = string
  default     = "groups"
}

variable "allowed_redirect_uris" {
  description = "List of allowed redirect URIs"
  type        = list(string)
}

variable "oidc_scopes" {
  description = "OIDC scopes to request"
  type        = list(string)
  default     = ["https://graph.microsoft.com/.default"]
}

# Token lifecycle configuration
variable "token_ttl" {
  description = "Token TTL in seconds"
  type        = number
  default     = 3600
}

variable "token_max_ttl" {
  description = "Token max TTL in seconds"
  type        = number
  default     = 7200
}

# Configuration file paths
variable "namespaces_path" {
  description = "Path to namespace YAML definitions"
  type        = string
  default     = null
}

variable "additional_roles_path" {
  description = "Path to additional OIDC role YAML definitions"
  type        = string
}

variable "identity_groups_path" {
  description = "Path to identity group YAML definitions for Azure AD integration"
  type        = string
}

variable "config_path" {
  description = "Path to merged configuration file"
  type        = string
  default     = ""
}
