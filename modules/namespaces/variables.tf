# Namespace module variables

variable "config_path" {
  description = "Path to merged config.yaml file"
  type        = string
  default     = "./config.yaml"
}

variable "namespace_secret_path" {
  description = "Path for initial test secret"
  type        = string
  default     = "secret"
}

variable "mount_path" {
  description = "Mount path for KV v2 secret engine"
  type        = string
}

variable "description" {
  description = "Description for secret engine"
  type        = string
  default     = "KV Version 2 secrets engine"
}

variable "namespace" {
  description = "Optional Vault namespace for KV engine"
  type        = string
  default     = null
}

# KV engine settings
variable "max_lease_ttl_seconds" {
  description = "Maximum lease TTL in seconds"
  type        = number
  default     = 0
}

variable "configure_backend" {
  description = "Enable backend configuration"
  type        = bool
  default     = false
}

variable "max_versions" {
  description = "Maximum number of versions per secret"
  type        = number
  default     = 10
}

variable "cas_required" {
  description = "Require check-and-set for all writes"
  type        = bool
  default     = false
}

variable "delete_version_after" {
  description = "Time until versions are automatically deleted (e.g. '3h', '1d')"
  type        = string
  default     = "0s"
}
