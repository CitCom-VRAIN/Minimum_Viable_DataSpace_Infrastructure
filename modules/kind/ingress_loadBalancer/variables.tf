variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "kind-cluster"
}

variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "ingress_config_file" {
  type        = string
  description = "The path to the ingress config file"
  default     = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"
}

variable "loadbalancer_config_file" {
  type        = string
  description = "The path to the loadbalancer config file"
  default     = "https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml"
}
