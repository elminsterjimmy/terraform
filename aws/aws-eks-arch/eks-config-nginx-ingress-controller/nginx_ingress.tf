# Deploy Nginx Ingress Controller using Helm
resource "helm_release" "nginx_ingress" {
    name       = "nginx-ingress"
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart      = "ingress-nginx"
    namespace  = "ingress-nginx"
    create_namespace = true
    version    = "4.7.0"

    values = [
        file("helm_values/nginx-ingress-values.yaml")
    ]
}

data "kubernetes_service" "nginx" {
  depends_on = [helm_release.nginx_ingress]
  metadata {
    name = "nginx"
  }
}