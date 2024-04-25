variable "kubernetes_local_path" {
  type        = string
  description = "The path to the kubeconfig file"
  default     = "~/.kube/config"
}

################################################################################
# Certs Configuration Module                                                   #
################################################################################
variable "ca_clusterissuer_name" {
  type        = string
  description = "The name of the clusterissuer"
  default     = "ca-certificates"
}

################################################################################
# Cluster Configuration                                                        #
################################################################################

variable "namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-operator"
}

variable "service_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-operator.io"
}

################################################################################
# Services Configuration                                                       #
################################################################################

variable "flags_deployment" {
  type = object({
    mongodb                       = bool
    mysql                         = bool
    walt_id                       = bool
    orion_ld                      = bool
    credentials_config_service    = bool
    trusted_issuers_list          = bool
    trusted_participants_registry = bool
    verifier                      = bool
    portal                        = bool
    pdp                           = bool
    kong                          = bool
    keyrock                       = bool
  })
  description = "Whether to deploy resources."
  default = {
    mongodb = true
    mysql   = true
    walt_id = true
    # depends on: mongodb
    orion_ld = true
    # depends on: mysql
    credentials_config_service = true
    trusted_issuers_list       = true
    # depends on: orion_ld
    trusted_participants_registry = true
    # depends on: walt_id, credentials_config_service, trusted_issuers_list
    verifier = true
    # depends on: credentials_config_service, kong, verifier
    portal = true
    # depends on: walt_id, verifier
    pdp = true
    # depends on: orion_ld, pdp
    kong = true
    # depends on: walt_id, mysql, pdp
    keyrock = true
  }
}

variable "services_names" {
  type = object({
    mongo    = string
    mysql    = string
    walt_id  = string
    orion_ld = string
    ccs      = string
    til      = string
    tir      = string
    tpr      = string
    verifier = string
    pdp      = string
    portal   = string
    kong     = string
    keyrock  = string
  })
  description = "values for the namespace of the services"
  default = {
    mongo    = "mongodb"
    mysql    = "mysql"
    walt_id  = "waltid"
    orion_ld = "orionld"
    ccs      = "cred-conf-service"
    til      = "trusted-issuers-list"
    tir      = "trusted-issuers-registry" # this is include in the TIL service
    tpr      = "trusted-participants-registry"
    verifier = "verifier"
    pdp      = "pdp"
    portal   = "portal"
    kong     = "proxy-kong"
    keyrock  = "keyrock"
  }
}

variable "did_option" {
  type        = string
  description = "DID option for the services"
  default     = "web"
}

################################################################################
# Helm Configuration                                                           #
################################################################################

variable "mongodb" {
  type = object({
    version       = string
    chart_name    = string
    repository    = string
    root_password = string
  })
  description = "MongoDB service"
  default = {
    version       = "11.0.4"
    chart_name    = "mongodb"
    repository    = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
    root_password = "admin"
  }
}

variable "mysql" {
  type = object({
    version       = string
    chart_name    = string
    repository    = string
    root_password = string
    # Trusted Issuer List (TIL) database name | Credential Config Service (CCS) 
    # database name
    til_db = string
    ccs_db = string
  })
  description = "MySQL service"
  default = {
    version       = "9.4.4"
    chart_name    = "mysql"
    repository    = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
    root_password = "admin"
    til_db        = "til"
    ccs_db        = "ccs"
  }
}

variable "walt_id" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Walt-ID Service"
  default = {
    version    = "0.0.17"
    chart_name = "vcwaltid"
    repository = "https://i4Trust.github.io/helm-charts"
  }
}

variable "orion_ld" {
  type = object({
    version     = string
    chart_name  = string
    repository  = string
    broker_port = number
    db_name     = string
  })
  description = "Orion-LD service"
  default = {
    version     = "1.2.6"
    chart_name  = "orion"
    repository  = "https://fiware.github.io/helm-charts"
    broker_port = 1026
    db_name     = "orion-oper" #! maximum 10 characters
  }
}

variable "credentials_config_service" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Credentials Config Service"
  default = {
    version    = "0.0.4"
    chart_name = "credentials-config-service"
    repository = "https://fiware.github.io/helm-charts"
  }
}

variable "trusted_issuers_list" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Trusted Issuers List service"
  default = {
    version    = "0.5.3"
    chart_name = "trusted-issuers-list"
    repository = "https://fiware.github.io/helm-charts"
  }
}

variable "trusted_participants_registry" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Trusted Participants Registry Service"
  default = {
    version    = "0.0.3"
    chart_name = "trusted-issuers-registry"
    repository = "https://fiware.github.io/helm-charts"
  }
}

variable "portal" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Portal Service"
  default = {
    version    = "2.2.5"
    chart_name = "pdc-portal"
    repository = "https://i4Trust.github.io/helm-charts"
  }
}

variable "verifier" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Verifier Service"
  default = {
    version    = "1.0.23"
    chart_name = "vcverifier"
    repository = "https://i4Trust.github.io/helm-charts"
  }
}

variable "pdp" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "PDP Service"
  default = {
    version    = "0.0.16"
    chart_name = "dsba-pdp"
    repository = "https://fiware.github.io/helm-charts"
  }

}

variable "kong" {
  type = object({
    version    = string
    chart_name = string
    repository = string
  })
  description = "Kong Service"
  default = {
    version    = "2.8.0"
    chart_name = "kong"
    repository = "https://charts.konghq.com"
  }
}

variable "keyrock" {
  type = object({
    version        = string
    chart_name     = string
    repository     = string
    admin_password = string
    admin_email    = string
  })
  description = "Keyrock"
  default = {
    version        = "0.7.5" # latest version 0.7.7
    chart_name     = "keyrock"
    repository     = "https://fiware.github.io/helm-charts"
    admin_password = "admin"
    admin_email    = "admin@ds-operator.org"
  }
}