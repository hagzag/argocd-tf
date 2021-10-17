variable "env-prefix" {
  type        = string
  description = "Environment name for secret prefix"
  default     = "saas"
}

variable "env" {
  type        = string
  description = "Environment name for secret prefix"
}

variable "argocd_fqdn" {
  description = "The Fully qualified domain name e.g argocd.dev.example.com"
  type        = string
}

variable "argocd_admin_password_timestamp" {
  description = "the date of the argocd password to use, without this date set argocd will default to timestamp()"
  default = "2021-01-01T01:01:01Z"
}

variable "cluster_id" {
  type        = string
  description = "The Cluster id to assign this role to"
}

variable "acm_cert_arn" {
  type        = string
  description = "The Cluster id to assign this role to"
}

variable "helm_values" {
  default     = {}
  description = "Additional settings which will be passed to the Helm chart values"
}

variable "git_enable" {
  description = "enable or git_key"
  type = bool
  default = false
}

variable "git_ssh_key" {
  type        = string
  description = "Only effective if git_enable"
}

variable "git_key_name" {
  type        = string
  description = "The common name of the secret holding ssh-git-key"
}