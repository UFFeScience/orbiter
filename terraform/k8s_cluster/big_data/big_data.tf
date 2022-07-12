#################### Helm Provider ####################

provider "helm" {
  kubernetes {
    host                   = var.host
    client_certificate     = var.client_certificate
    client_key             = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate
  }
}

#################### K8s Provider ####################

provider "kubernetes" {
    host                   = var.host
    client_certificate     = var.client_certificate
    client_key             = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate
}

#################### Docker config ####################

resource "kubernetes_namespace" "ingestion" {
  metadata {
    annotations = {
      name = "ingestion"
    }

    labels = {
      mylabel = "ingestion"
    }

    name = "ingestion"
  }
}

resource "kubernetes_secret" "docker_private_repo_auth" {
  metadata {
    name = "docker-cfg"
    namespace = "ingestion"
  }

  data = {
    ".dockerconfigjson" = "${file("${var.dockerconfig_path}")}"
  }

  type = "kubernetes.io/dockerconfigjson"
  
  depends_on = [
    kubernetes_namespace.ingestion,
  ]
}

#################### Nginx Ingress Controller ####################

resource "helm_release" "nginx_ingress_controller" {
  name             = "nginx-ingress-controller"
  namespace        = "nginx-ingress-controller"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  set {
    name  = "controller.service.loadBalancerIP"
    value = var.load_balancer_ip
  }

  # To get de FQDN run:
  # az network public-ip list --resource-group bigDataOnK8s-nodeResourceGroup --query "[?name=='aks-ingress-ip'].[dnsSettings.fqdn]" -o tsv
  set {
    name  = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-dns-label-name\""
    value = "k8s-${var.env}"
  }

  set {
    name  = "controller.enableTLSPassthrough"
    value = "true"
  }
}

#################### Cert-manager ####################

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"

  set {
    name  = "installCRDs"
    value = true
  }
}

#################### ArgoCD ####################

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "cicd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"

  set {
    name = "configs.secret.argocdServerAdminPassword"
    value = "$2a$10$kJvzpt.mYUvldwvk6YA4qeV7c1sa0nUPgOZLiff95H2fI76HNo4A2" #bigdataonk8s
  }

  set {
    name = "configs.secret.argocdServerAdminPasswordMtime"
    value = "${timestamp()}"
  }
}
