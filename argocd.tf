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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    annotations = {
      created-by = "terraform"
    }

    labels = {
      purpose = "ArgoCD-IAC"
    }

    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "3.11.2"
  namespace  = kubernetes_namespace.argocd.metadata.0.name
  
  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.acm_cert_arn
    type  = "string"
  }

  set {
    name  = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
    value = var.argocd_fqdn
    type  = "string"
  }

  set {
    name  = "configs.secret.argocdServerAdminPassword"
    value = local.password
  }
  
  set {
    name  = "configs.secret.argocdServerAdminPasswordMtime"
    value = var.argocd_admin_password_timestamp
  }

  set {
    name  = "server.config.url"
    value = "https://${var.argocd_fqdn}"
  }

  values = [var.helm_values]
  
  /* values = [
    file("${path.module}/argocd-values.yaml"),
  ] */


}
