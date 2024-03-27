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
  type = list(
    object(
      {
        container_port = number
        host_port      = number
        protocol       = string
      }
    )
  )
  description = "Extra ports to be added to control-plane node"
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
  type = list(
    object(
      {
        host_path      = string
        container_path = string
      }
    )
  )
  description = "Extra mounts to be added to all nodes"
  default = []
}
