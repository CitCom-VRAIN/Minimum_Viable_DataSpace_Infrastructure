# MongoDB

resource "helm_release" "mongodb" {
  chart            = var.mongodb.chart_name
  version          = var.mongodb.version
  repository       = var.mongodb.repository
  name             = var.services_names.mongo
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.mongodb ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP" # ClusterIP for internal access only.
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/mongodb.yaml", {
      service_name  = var.services_names.mongo,
      root_password = var.mongodb.root_password
    })
  ]
}

# MySQL

resource "helm_release" "mysql" {
  chart            = var.mysql.chart_name
  version          = var.mysql.version
  repository       = var.mysql.repository
  name             = var.services_names.mysql
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.mysql ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/mysql.yaml", {
      service_name  = var.services_names.mysql,
      root_password = var.mysql.root_password,
      til_db        = var.mysql.til_db,
      ccs_db        = var.mysql.ccs_db
    })
  ]
}

# PostgreSQL-BAE (data base for Keycloak)
# TODO: Needs more detailed configuration.

# PostGIS (data base for scorpio, scorpio uses postgis)
# TODO: Needs more detailed configuration.

# Walt-ID
# TODO: Needs more detailed configuration.

################################################################################
# depends on: MySQL

# TODO: Easy to configure
# Credential Config Service

# Trusted Issuer List

################################################################################
# depends on: MySQL, Walt-ID

# KeyRock

################################################################################
# depends on: Credential Config Service

# TODO: Easy to configure
# Verifier

################################################################################
# depends on: postgis, internal Kafka

# Scorpio

################################################################################
# depends on: Scorpio

# TMForum-API

################################################################################
# depends on: Walt-ID, Postgres-BAE, OrionLD??

# KeyCloak

################################################################################
# depends on: Verifier, Credential Config Service, Trusted Issuer List, TMForum-API,
# MongoDB, Elasticsearch??

# Business API ecosystem
