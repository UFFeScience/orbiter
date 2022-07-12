#################### Kubernetes Provider ####################

provider "kubernetes" {
    host                   = var.host
    client_certificate     = var.client_certificate
    client_key             = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate
}

#################### ArgoCD Ingress ####################

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name = "argocd-server-ingress"
    namespace = "cicd"
    annotations = {
      "cert-manager.io/cluster-issuer" = "lets-encrypt-cluster-issuer"
      "kubernetes.io/ingress.class" = "nginx"
      "kubernetes.io/tls-acme" = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }
  }
  spec {
    rule {
      host = "argocd.tcc.bigdataonk8s.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
    tls {
      hosts = [
        "argocd.tcc.bigdataonk8s.com"
      ]
      secret_name = "argocd-secret"
    }
  }
}

#################### ArgoCD Project ####################

resource "kubernetes_manifest" "big_data_on_k8s_project" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      name      = "big-data-on-k8s"
      namespace = "cicd"
    }

    spec = {
      description = "Big Data on k8s"

      sourceRepos = [
        "https://github.com/JPedro-loureiro/big_data_k8s",
        "https://strimzi.io/charts",
        "https://charts.bitnami.com/bitnami",
        "https://prometheus-community.github.io/helm-charts",
        "https://googlecloudplatform.github.io/spark-on-k8s-operator",
        "https://airflow.apache.org/",
        "https://valeriano-manassero.github.io/helm-charts",
        "https://apache.github.io/superset",
      ]

      destinations = [{
        namespace = "*"
        server    = "https://kubernetes.default.svc"
      }]

      clusterResourceWhitelist = [{
        group = "*"
        kind  = "*"
      }]

      orphanedResources = {
        warn = true
      }
    }
  }
}

#################### ArgoCD Applications ####################

resource "kubernetes_manifest" "argocd_applications" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "argocd-applications"
      namespace = "cicd"
    }

    spec = {
      project = "big-data-on-k8s"

      source = {
        repoURL        = "https://github.com/JPedro-loureiro/big_data_k8s"
        targetRevision = "HEAD"
        path           = "apps/argocd_applications"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "cicd"
      }

      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }

        syncOptions = [
          "Validate=false",
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]

        retry = {
          limit = 3
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "1m"
          }
        }
      }
    }
  }
}