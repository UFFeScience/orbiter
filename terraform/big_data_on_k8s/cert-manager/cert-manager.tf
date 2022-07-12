#################### Kubernetes Provider ####################

provider "kubernetes" {
    host                   = var.host
    client_certificate     = var.client_certificate
    client_key             = var.client_key
    cluster_ca_certificate = var.cluster_ca_certificate
}

#################### Let's Encrypt Issuer ####################

resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "lets-encrypt-cluster-issuer"
    }

    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "big_data_on_k8s@gmail.com"
        privateKeySecretRef = {
          name = "lets-encrypt-cluster-issuer-key"
        }
        solvers = [{
          http01 = {
            ingress = {
              class = "nginx"
            }
          }
        }]
      }
    }
  }
}
