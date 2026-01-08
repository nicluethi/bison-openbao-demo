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