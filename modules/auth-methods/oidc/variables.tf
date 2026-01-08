# OIDC authentication module variables
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

variable "config_path" {
  description = "Path to merged configuration file"
  type        = string
  default     = ""
}
