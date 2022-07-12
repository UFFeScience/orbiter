terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.95.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

#################### AKS ####################

provider "azurerm" {
  features {}
}

module "aks_cluster" {
  count             = var.aks == true ? 1 : 0
  source            = "./aks"
  region            = var.region
  env               = var.env
  k8s_version       = var.k8s_version
  kubeconfig_path = var.kubeconfig_path
  default_node_type = var.main_node_type
}

#################### EKS ####################



#################### GKE ####################



#################### Cluster Configs ####################

locals {
  # Host
  host = var.aks == true ? module.aks_cluster[0].aks_cluster_host : (
    var.eks == true ? "eks_host" : "gke_host"
  )

  # Client Certificate
  client_certificate = var.aks == true ? module.aks_cluster[0].aks_cluster_client_certificate : (
    var.eks == true ? "eks_client_certificate" : "gke_client_certificate"
  )

  # Client Key
  client_key = var.aks == true ? module.aks_cluster[0].aks_cluster_client_key : (
    var.eks == true ? "eks_client_key" : "gke_client_key"
  )

  # Cluster CA Certificate
  cluster_ca_certificate = var.aks == true ? module.aks_cluster[0].aks_cluster_ca_certificate : (
    var.eks == true ? "eks_cluster_ca_certificate" : "gke_cluster_ca_certificate"
  )

  # Load Balancer IP
  load_balancer_ip = var.aks == true ? module.aks_cluster[0].load_balancer_ip : (
    var.eks == true ? "eks_load_balancer_ip" : "gke_load_balancer_ip"
  )
}

#################### Big Data ####################

module "big_data" {
  source                 = "./big_data"
  host                   = local.host
  client_certificate     = local.client_certificate
  client_key             = local.client_key
  cluster_ca_certificate = local.cluster_ca_certificate
  load_balancer_ip       = local.load_balancer_ip
  env                    = var.env
  dockerconfig_path      = var.dockerconfig_path
}
