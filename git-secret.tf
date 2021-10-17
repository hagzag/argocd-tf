resource "kubernetes_secret" "git-ssh-key" {
  count = var.git_enable ? 1 : 0
  metadata {
    name = var.git_key_name
    namespace = kubernetes_namespace.argocd.metadata.0.name
  }
  data = {
    "git-ssh-key" = var.git_ssh_key
    }
}