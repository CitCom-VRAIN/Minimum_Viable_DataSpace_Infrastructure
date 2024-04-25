variable "cluster_name" {
  type        = string
  description = "The name of the kind cluster"
  default     = "ds-local-cluster"
}

variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config_DSLocal"
}

variable "ca_clusterissuer_name" {
  type        = string
  description = "The name of the CA module"
  default     = "ca-certificates"
}

variable "flags_deployment" {
  type = object({
    ca_configuration = bool
  })
  description = "Whether to deploy resources."
  default = {
    ca_configuration = true # check the value of flags_deployment.cert_trust_manager in conf/kind_cluster.tfvars
  }
}
