#################### Resource Group ####################

resource "azurerm_resource_group" "rg" {
  name     = "bigDataOnK8s"
  location = var.region
}

#################### AKS ####################

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${var.env}_aks_cluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.env}-aks-cluster"
  kubernetes_version  = var.k8s_version

  node_resource_group = "bigDataOnK8s-nodeResourceGroup"

  default_node_pool {
    name       = "${var.env}master"
    node_count = "1"
    vm_size    = var.default_node_type
  }

  identity {
    type = "SystemAssigned"
  }
}

#################### Node Pools ####################

resource "azurerm_kubernetes_cluster_node_pool" "memory_optimized" {
 kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_cluster.id
 name                  = "${var.env}memopt"
 node_count            = "2"
 vm_size               = "standard_b4ms"
}

#################### Public IP ####################

resource "azurerm_public_ip" "load_balancer_ip" {
  name                = "aks-ingress-ip"
  resource_group_name = azurerm_kubernetes_cluster.aks_cluster.node_resource_group
  location            = var.region
  allocation_method   = "Static"
  sku                 = "Standard"
}

#################### DNS Zone ####################

resource "azurerm_dns_zone" "dns_zone" {
  name                = "bigdataonk8s.com"
  resource_group_name = azurerm_resource_group.rg.name
}

#################### DNS Records ####################

resource "azurerm_dns_a_record" "app_test" {
  name                = "app-test.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "argocd" {
  name                = "argocd.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "grafana" {
  name                = "grafana.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "postgres_data_generator" {
  name                = "postgres.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "kafka_bootstrap" {
  name                = "kafka-bootstrap.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "kafka_broker_0" {
  name                = "kafka-broker-0.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "trino" {
  name                = "trino.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "minio" {
  name                = "minio.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "airflow" {
  name                = "airflow.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}

resource "azurerm_dns_a_record" "superset" {
  name                = "superset.${var.env}"
  zone_name           = azurerm_dns_zone.dns_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.load_balancer_ip.id
}