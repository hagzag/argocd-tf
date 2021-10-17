# ArgoCD.tf on AWS, EKS

## :rocket: QuickStart

- expect existing cluster to exists and passed to module

```js
// data.tf

data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}
```

- create `argocd secret` and store in in `aws-secretsManager` + pass it as bcrypt to argocd `values.yaml` so argoCD initial passowrd is accessible via AWS secretsManager whilt who ever has access to the cluster has a `bcrypt` value whihc is useless ;).

```js
// argocd.tf
resource "aws_secretsmanager_secret" "argocd_password" {
  name                    = "${var.env-prefix}-${var.env}/argocd_password_${random_string.suffix-name.result}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "argocd_password_data" {
  secret_id = aws_secretsmanager_secret.argocd_password.id
  secret_string = jsonencode(
    {
      "admin.password"      = random_password.password.result
      "admin.passwordMtime" = var.argocd_admin_password_timestamp
  })
}

```

- create `git-ssk-key` which will be stored as a `kuberetens secret` (this is in cases where the extenal-secrets controller dosen't exist when argoCD is in boostrap mode)

```js
// git-secret.tf - when passed to module ! see ./modules/ssh-key
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
```