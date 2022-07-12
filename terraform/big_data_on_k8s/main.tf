terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.48.0"
    }
  }
}

#################### AKS ####################

provider "azurerm" {
  features {}
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  count               = var.aks == true ? 1 : 0
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}

#################### EKS ####################



#################### GKE ####################



#################### Cluster Configs ####################

locals {
  # Host
  host = var.aks == true ? data.azurerm_kubernetes_cluster.aks_cluster[0].kube_config.0.host : (
    var.eks == true ? "eks_host" : "gke_host"
  )

  # Client Certificate
  client_certificate = var.aks == true ? base64decode(data.azurerm_kubernetes_cluster.aks_cluster[0].kube_config.0.client_certificate) : (
    var.eks == true ? "eks_client_certificate" : "gke_client_certificate"
  )

  # Client Key
  client_key = var.aks == true ? base64decode(data.azurerm_kubernetes_cluster.aks_cluster[0].kube_config.0.client_key) : (
    var.eks == true ? "eks_client_key" : "gke_client_key"
  )

  # Cluster CA Certificate
  cluster_ca_certificate = var.aks == true ? base64decode(data.azurerm_kubernetes_cluster.aks_cluster[0].kube_config.0.cluster_ca_certificate) : (
    var.eks == true ? "eks_cluster_ca_certificate" : "gke_cluster_ca_certificate"
  )
}

#################### Cert Manager | Let's Encrypt Issuer ####################

module "cert_manager" {
  source                 = "./cert-manager"
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}

#################### ArgoCD ####################

module "argocd" {
  source                 = "./argocd"
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
}