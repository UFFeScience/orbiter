variable "region" {
  description = "Azure region"
  type = string
}

variable "env" {
  description = "dev | qa | prod"
  type = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  type = string
}

variable "default_node_type" {
  description = "Default node type"
  type = string
}

variable "kubeconfig_path" {
  description = "Default node type"
  type = string
}
