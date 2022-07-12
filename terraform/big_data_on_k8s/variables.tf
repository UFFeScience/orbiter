#################### AKS Variables ####################

variable "aks" {
  description = "Cluster provider"
  type        = bool
}


variable "aks_cluster_name" {

}

variable "aks_resource_group_name" {

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