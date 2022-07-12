resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  filename   = var.kubeconfig_path
  content    = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}

#################### AKS data ####################

output "aks_cluster_host" {
  description = "The Ingress AKS Cluster IP"
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
}

output "aks_cluster_client_certificate" {
  description = "The Ingress AKS Cluster IP"
  value = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate)
}

output "aks_cluster_client_key" {
  description = "The Ingress AKS Cluster IP"
  value = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key)
}

output "aks_cluster_ca_certificate" {
  description = "The Ingress AKS Cluster IP"
  value = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate)
}

#################### Load Balancer IP data ####################

output "load_balancer_ip" {
  description = "The Ingress AKS Cluster IP"
  value = azurerm_public_ip.load_balancer_ip.ip_address
}