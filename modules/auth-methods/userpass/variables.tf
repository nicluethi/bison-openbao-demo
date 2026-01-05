# Userpass authentication module variables

variable "mount_path" {
  description = "Mount path for userpass auth backend"
  type        = string
  default     = "userpass"
}

variable "users" {
  description = "Map of users with passwords and policies"
  type = map(object({
    password = string
    policies = list(string)
  }))
  default = {}
}

variable "namespace" {
  description = "Optional Vault namespace for userpass backend"
  type        = string
  default     = null
}
