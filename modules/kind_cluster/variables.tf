variable "path_module" {
  type        = string
  description = "The path to the kind directory"
  default     = "./"
}

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

variable "kindest_version" {
  type        = string
  description = "The version of the kind cluster to be created"
  default     = "kindest/node:v1.29.2"
}

variable "add_extra_ports" {
  description = "Extra ports to be added to control-plane node"
  type = list(object({
    container_port = number
    host_port      = number
    protocol       = string
  }))

  default = [
    {
      container_port = 80
      host_port      = 80
      protocol       = "TCP"
    },
    {
      container_port = 443
      host_port      = 443
      protocol       = "TCP"
    }
  ]

}

variable "add_extra_mounts" {
  description = "Extra mounts to be added to all nodes"
  type = list(object({
    host_path      = string
    container_path = string
  }))

  default = []
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
