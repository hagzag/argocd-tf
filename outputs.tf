output "cleartext_argocd_password" {
  value     = random_password.password.result
  sensitive = true
}

# output "cleartext_argocd_password_mtime" {
#   value     = local.timestamp
#   sensitive = false
# }
