#################### Generic variables ####################

variable "region" {
  description = "Cloud region"
  type        = string
  #   nullable    = false
}

variable "env" {
  description = "dev | qa | prod"
  type        = string
  #   nullable    = false
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  #   nullable    = false
}

variable "main_node_type" {
  description = "Main node type"
  type        = string
  #   nullable    = false
}

variable "kubeconfig_path" {
  description = "Kubeconfig path"
  type = string
}

variable "dockerconfig_path" {
  description = "Dockerconfig path"
  type = string
}

#################### AKS Variables ####################

variable "aks" {
  description = "Main node type"
  type        = bool
  #   nullable    = false
}

#################### EKS Variables ####################

variable "eks" {
  description = "Main node type"
  type        = bool
  #   nullable    = false
}

#################### GKE Variables ####################

variable "gke" {
  description = "Main node type"
  type        = bool
  #   nullable    = false
}