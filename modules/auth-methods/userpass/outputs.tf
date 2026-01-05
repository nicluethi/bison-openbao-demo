# Userpass authentication module outputs

output "auth_backend_path" {
  description = "Path of userpass auth backend"
  value       = vault_auth_backend.userpass.path
}

output "auth_backend_accessor" {
  description = "Accessor of userpass auth backend"
  value       = vault_auth_backend.userpass.accessor
}

output "user_names" {
  description = "List of all created usernames"
  value       = keys(vault_generic_endpoint.users)
}

output "login_commands" {
  description = "CLI commands for user login"
  value = {
    for name in keys(vault_generic_endpoint.users) :
    name => "bao login -method=userpass username=${name}"
  }
}
