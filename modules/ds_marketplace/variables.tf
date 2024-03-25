################################################################################
# Cluster Configuration                                                        #
################################################################################

variable "namespace" {
  type        = string
  description = "Namespace for the DS operator deployment"
  default     = "ds-marketplace"
}

variable "ds_domain" {
  type        = string
  description = "Data Space domain"
  default     = "ds-marketplace.io"
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
# Services Configuration                                                       #
################################################################################

variable "flags_deployment" {
  type = object({
    mongodb  = bool
    mysql    = bool
    postgres = bool
    postgis  = bool
    walt_id  = bool
    credentials_config_service    = bool
    # orion_ld                      = bool
    # trusted_issuers_list          = bool
    # trusted_participants_registry = bool
    # portal                        = bool
    # verifier                      = bool
    # pdp                           = bool
    # kong                          = bool
    # keyrock                       = bool
  })
  description = "Whether to deploy resources."
  default = {
    mongodb  = true
    mysql    = true
    postgres = true
    postgis  = true
    walt_id  = true
    # depends on: mysql
    credentials_config_service = true
    # # depends on: mongodb
    # orion_ld = true
    # trusted_issuers_list       = true
    # # depends on: orion_ld
    # trusted_participants_registry = true
    # # depends on: credentials_config_service, kong, verifier
    # portal = true
    # # depends on: walt_id, credentials_config_service, trusted_issuers_list
    # verifier = true
    # # depends on: walt_id, verifier
    # pdp = true
    # # depends on: orion_ld, pdp
    # kong = true
    # # depends on: walt_id, mysql, pdp
    # keyrock = true
  }
}

variable "services_names" {
  type = object({
    mongo    = string
    mysql    = string
    postgres = string
    postgis  = string
    walt_id  = string
    ccs      = string
    # orion_ld = string
    # til      = string
    # tir      = string
    # tpr      = string
    # portal   = string
    # verifier = string
    # pdp      = string
    # kong     = string
    # keyrock  = string
  })
  description = "values for the namespace of the services"
  default = {
    mongo    = "mongodb"
    mysql    = "mysql"
    postgres = "postgres"
    postgis  = "postgis"
    walt_id  = "waltid"
    ccs      = "cred-conf-service"
    # orion_ld = "orionld"
    # til      = "trusted-issuers-list"
    # tir      = "trusted-issuers-registry" # this is include in the TIL service
    # tpr      = "trusted-participants-registry"
    # portal   = "portal"
    # verifier = "verifier"
    # pdp      = "pdp"
    # kong     = "proxy-kong"
    # keyrock  = "keyrock"
  }

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

variable "postgres" {
  type = object({
    version       = string
    chart_name    = string
    repository    = string
    root_password = string
    username      = string
    user_password = string
    database_name = string
  })
  description = "Postgres service"
  default = {
    version       = "12.1.13"
    chart_name    = "postgresql"
    repository    = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
    root_password = "admin"
    username      = "keycloak"
    user_password = "keycloak_pass"
    database_name = "keycloak_bae"
  }
}

variable "postgis" {
  type = object({
    version       = string
    chart_name    = string
    repository    = string
    root_password = string
    username      = string
    user_password = string
    database_name = string
  })
  description = "PostGIS service"
  default = {
    version       = "12.1.13"
    chart_name    = "postgresql"
    repository    = "https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami"
    root_password = "admin"
    username      = "scorpio"
    user_password = "scorpio_pass"
    database_name = "ngb"
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