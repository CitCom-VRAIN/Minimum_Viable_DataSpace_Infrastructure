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
#FIXME: Ingress NOT WORKING
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
# Depends on: MySQL                                                            #
################################################################################

#* DONE
resource "helm_release" "credentials_config_service" {
  depends_on = [helm_release.mysql]

  chart      = var.credentials_config_service.chart_name
  version    = var.credentials_config_service.version
  repository = var.credentials_config_service.repository
  name       = var.services_names.ccs
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.credentials_config_service ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/credentials_config_service.yaml", {
      service_name  = var.services_names.ccs,
      mysql_service = var.services_names.mysql,
      ccs_db        = var.mysql.ccs_db,
      root_password = var.mysql.root_password
    })
  ]
}

#? DONE Ingress is needed?
resource "helm_release" "trusted_issuers_list" {
  depends_on = [kubernetes_manifest.certs_creation, helm_release.mysql]

  chart      = var.trusted_issuers_list.chart_name
  version    = var.trusted_issuers_list.version
  repository = var.trusted_issuers_list.repository
  name       = var.services_names.til
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.trusted_issuers_list ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/trusted_issuers_list.yaml", {
      service_name        = var.services_names.til,
      ds_domain_til       = local.dns_dir[var.services_names.til], #til.ds-operator.io
      secret_tls_name_til = local.secrets_tls[var.services_names.til],
      ds_domain_tir       = local.dns_dir[var.services_names.tir], #tir.ds-operator.io
      secret_tls_name_tir = local.secrets_tls[var.services_names.tir],
      mysql_service       = var.services_names.mysql,
      root_password       = var.mysql.root_password,
      til_db              = var.mysql.til_db
    })
  ]
}

################################################################################
# Depends on: MySQL, Walt-ID
################################################################################

#FIXME: Ingress NOT WORKING
resource "helm_release" "keyrock" {
  depends_on = [
    kubernetes_manifest.certs_creation,
    helm_release.mysql,
    helm_release.walt_id
  ]

  chart      = var.keyrock.chart_name
  version    = var.keyrock.version
  repository = var.keyrock.repository
  name       = var.services_names.keyrock
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.keyrock ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP" # LoadBalancer for external access.
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/keyrock.yaml", {
      service_name        = var.services_names.keyrock,
      didweb_domain       = var.ds_domain,
      dns_names           = local.dns_dir[var.services_names.keyrock],
      secret_tls_name     = local.secrets_tls[var.services_names.keyrock],
      admin_email         = var.keyrock.admin_email,
      admin_password      = var.keyrock.admin_password,
      waltid_secret_tls   = local.secrets_tls[var.services_names.walt_id],
      mysql_root_password = var.mysql.root_password,
      mysql_service       = var.services_names.mysql
    })
  ]
}

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
