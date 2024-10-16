variable "namespace" {
  type        = string
  description = "The namespace to install cert-manager"
  default     = "cert-manager"
}

variable "cert_manager_version" {
  type        = string
  description = "The version of cert-manager"
  default     = "v1.14.3"
}

variable "trust_manager_version" {
  type        = string
  description = "The version of trust-manager"
  default     = "v0.8.0"
  
}