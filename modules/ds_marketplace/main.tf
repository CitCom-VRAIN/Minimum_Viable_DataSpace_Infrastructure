#* DONE
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

#* DONE
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

#* DONE
resource "helm_release" "postgres" {
  # data base for Keycloak
  chart            = var.postgres.chart_name
  version          = var.postgres.version
  repository       = var.postgres.repository
  name             = var.services_names.postgres
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.postgres ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/postgres.yaml", {
      service_name  = var.services_names.postgres,
      root_password = var.postgres.root_password,
      username      = var.postgres.username,
      password      = var.postgres.user_password
      database_name = var.postgres.database_name
    })
  ]
}

#* DONE
resource "helm_release" "postgis" {
  # data base for Scorpio Broker
  chart            = var.postgis.chart_name
  version          = var.postgis.version
  repository       = var.postgis.repository
  name             = var.services_names.postgis
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.postgis ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/postgres.yaml", {
      service_name  = var.services_names.postgis,
      root_password = var.postgis.root_password,
      username      = var.postgis.username,
      password      = var.postgis.user_password
      database_name = var.postgis.database_name
    })
  ]
}

#? DONE Ingress is needed? configuration datasource?
#! Use a different image than the default one.
#! Ingress NOT WORKING
resource "helm_release" "walt_id" {
  depends_on = [kubernetes_manifest.certs_creation]

  chart            = var.walt_id.chart_name
  version          = var.walt_id.version
  repository       = var.walt_id.repository
  name             = var.services_names.walt_id
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  count            = var.flags_deployment.walt_id ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/waltid.yaml", {
      service_name    = var.services_names.walt_id,
      dns_names       = local.dns_dir[var.services_names.walt_id],
      secret_tls_name = local.secrets_tls[var.services_names.walt_id]
    })
  ]
}

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
