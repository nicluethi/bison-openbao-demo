# AppRole authentication module variables

variable "mount_path" {
  description = "Mount path for AppRole auth backend"
  type        = string
  default     = "approle"
}

variable "config_path" {
  description = "Path to merged config.yaml file"
  type        = string
  default     = "./config.yaml"
}

variable "namespace" {
  description = "Optional Vault namespace for AppRole backend"
  type        = string
  default     = null
}
