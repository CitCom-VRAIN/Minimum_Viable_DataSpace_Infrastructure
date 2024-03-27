module "local_k8s_cluster" {
  source = "../../modules/kind/cluster"

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
}

module "cluster_config" {
  source     = "../../modules/kind/ingress_loadBalancer"
  depends_on = [module.local_k8s_cluster]

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
  providers = {
    kubectl = kubectl
  }
}
module "portainer" {
  source     = "../../modules/portainer_ce"
  depends_on = [module.local_k8s_cluster]
  count      = var.flags_deployment.portainer ? 1 : 0 # count =: number of instances to create

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
  img_version           = "2.19.4"
  providers = {
    kubectl = kubectl
  }
}

module "cert_trust_manager" {
  source     = "../../modules/cert_trust_manager"
  depends_on = [module.local_k8s_cluster]
  count      = var.flags_deployment.cert_trust_manager ? 1 : 0 # count =: number of instances to create

  cluster_name          = var.cluster_name
  kubernetes_local_path = pathexpand(var.kubernetes_local_path)
  providers = {
    kubectl    = kubectl
    kubernetes = kubernetes
    helm       = helm
  }
}
