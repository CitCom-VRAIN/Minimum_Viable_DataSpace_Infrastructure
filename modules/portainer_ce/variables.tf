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

variable "img_version" {
  type        = string
  description = "Portainer docker image version"
  default     = "2.19.4"
}

variable "add_ports" {
  type = list(
    object(
      {
        internal = number
        external = number
      }
    )
  )
  description = "Extra ports to be added to control-plane node"
  default = [
    # {
    #   internal = 8000
    #   external = 8000
    # },
    # {
    #   internal = 9443
    #   external = 9443
    # }
  ]
}

variable "portainer_k8s_file_config" {
  type        = string
  description = "Portainer k8s file config"
  default     = "https://downloads.portainer.io/ce2-19/portainer-agent-k8s-lb.yaml"
}
