variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "example-cluster"
}

variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config_example"
}

variable "flags_deployment" {
  type = object({
    portainer          = bool
    cert_trust_manager = bool
  })
  description = "Whether to deploy resources."
  default = {
    cert_trust_manager = true
    portainer          = true
  }
}
