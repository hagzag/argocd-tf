data "aws_region" "current_region" {}

data "aws_caller_identity" "current_account" {}


data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}