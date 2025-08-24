resource "kubernetes_deployment_v1" "nginx_app" {
  metadata {
    name      = "nginx-app"
    namespace = "default"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx-app"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Service to expose the Nginx application
resource "kubernetes_service_v1" "nginx_service" {
    metadata {
        name      = "nginx-service"
        namespace = "default"
        labels = {
            app = "nginx-app"
        }
    }

    spec {
        selector = {
            app = "nginx-app"
        }

        port {
            port        = 80
            target_port = 80
        }
    }
}

# Ingress to route traffic to the Nginx service
resource "kubernetes_ingress_v1" "nginx_ingress" {
    metadata {
        name      = "nginx-ingress"
        namespace = "default"
        annotations = {
            "kubernetes.io/ingress.class" : "nginx"
        }
    }
    spec {
        rule {
            # host = data.kubernetes_service.nginx_ingress_controller.status[0].load_balancer[0].ingress[0].hostname
            host = "ab35499fd39e94a5fbbc8b83d02b2caf-776526729.ap-southeast-1.elb.amazonaws.com"
            http {
                path {
                    path = "/"
                    path_type = "Prefix"

                    backend {
                        service {
                            name = kubernetes_service_v1.nginx_service.metadata[0].name
                            port {
                                number = 80
                            }
                        }
                    }
                }
            }
        }
    }
}