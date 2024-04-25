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
    value = "LoadBalancer" # ClusterIP for internal access only.
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

#! Ingress not working!
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
      service_domain  = local.dns_dir[local.dns_domains.walt_id],
      secret_tls_name = local.secrets_tls[local.dns_domains.walt_id],
      did_domain      = local.did_methods[var.did_option]
    })
  ]
}

################################################################################
# Depends on: MongoDB                                                          #
################################################################################

#* DONE
resource "helm_release" "orion_ld" {
  depends_on = [helm_release.mongodb]

  chart      = var.orion_ld.chart_name
  version    = var.orion_ld.version
  repository = var.orion_ld.repository
  name       = var.services_names.orion_ld
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.orion_ld ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/orionld.yaml", {
      service_name  = var.services_names.orion_ld,
      mongo_service = var.services_names.mongo,
      root_password = var.mongodb.root_password,
      orion_port    = var.orion_ld.broker_port,
      orion_db_name = var.orion_ld.db_name
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

#* DONE
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
      service_domain_til  = local.dns_dir[local.dns_domains.til], #til-operator.dataspace.deployment.local
      secret_tls_name_til = local.secrets_tls[local.dns_domains.til],
      service_domain_tir  = local.dns_dir[local.dns_domains.tir], #tir-operator.dataspace.deployment.local
      secret_tls_name_tir = local.secrets_tls[local.dns_domains.tir],
      mysql_service       = var.services_names.mysql,
      root_password       = var.mysql.root_password,
      til_db              = var.mysql.til_db
    })
  ]
}

################################################################################
# Depends on: OrionLD                                                          #
################################################################################

#? SATELLITE ???
resource "helm_release" "trusted_participants_registry" {
  depends_on = [kubernetes_manifest.certs_creation, helm_release.orion_ld]

  chart      = var.trusted_participants_registry.chart_name
  version    = var.trusted_participants_registry.version
  repository = var.trusted_participants_registry.repository
  name       = var.services_names.tpr
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.trusted_participants_registry ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
  set {
    name  = "service.port"
    value = 8080
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/trusted_participants_registry.yaml", {
      service_name       = var.services_names.tpr,
      service_domain     = local.dns_dir[local.dns_domains.tpr],
      secret_tls_name    = local.secrets_tls[local.dns_domains.tpr],
      did_domain         = local.did_methods[var.did_option],
      orion_service_name = var.services_names.orion_ld
    })
  ]
}

################################################################################
# Depends on: WaltID, Credentials Config Service, Trusted Issuers List         #
################################################################################

#? DONE m2m?? initContainers??
resource "helm_release" "verifier" {
  depends_on = [
    kubernetes_manifest.certs_creation,
    helm_release.credentials_config_service,
    helm_release.trusted_issuers_list,
    helm_release.walt_id,
    kubernetes_config_map.did_config,
    kubernetes_config_map.vc_config
  ]

  chart      = var.verifier.chart_name
  version    = var.verifier.version
  repository = var.verifier.repository
  name       = var.services_names.verifier
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.verifier ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/verifier.yaml", {
      namespace        = var.namespace,
      service_name     = var.services_names.verifier,
      service_domain   = local.dns_dir[local.dns_domains.verifier],
      secret_tls_name  = local.secrets_tls[local.dns_domains.verifier],
      waltid_service   = var.services_names.walt_id,
      tir_service      = local.dns_dir[local.dns_domains.tir],
      did_domain       = local.did_methods[var.did_option],
      ccs_service      = var.services_names.ccs,
      verifier_service = local.dns_domains.verifier
    })
  ]
}

################################################################################
# Depends on: walt-id, verifier                                                #
################################################################################

#? DONE ishare?? did??
resource "helm_release" "pdp" {
  depends_on = [
    kubernetes_manifest.certs_creation,
    helm_release.walt_id,
    helm_release.verifier
  ]

  chart      = var.pdp.chart_name
  version    = var.pdp.version
  repository = var.pdp.repository
  name       = var.services_names.pdp
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.pdp ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/pdp.yaml", {
      service_name           = var.services_names.pdp,
      secret_tls_name_waltid = local.secrets_tls[local.dns_domains.walt_id],
      did_domain             = local.did_methods[var.did_option],
      keyrock_domain         = local.dns_dir[local.dns_domains.keyrock], #TODO: Review this variable
      tpr_domain             = local.dns_dir[local.dns_domains.tpr],
      verifier_domain        = local.dns_dir[local.dns_domains.verifier]
    })
  ]
}

################################################################################
# Depends on: OrionLD, pdp                                                     #
################################################################################

#? DONE dblessConfig??
resource "helm_release" "kong" {
  depends_on = [
    kubernetes_manifest.certs_creation,
    helm_release.orion_ld,
    helm_release.pdp
  ]

  chart      = var.kong.chart_name
  version    = var.kong.version
  repository = var.kong.repository
  name       = var.services_names.kong
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.kong ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/kong_conf.yaml", {
      namespace        = var.namespace,
      service_name     = var.services_names.kong,
      service_domain   = local.dns_dir[local.dns_domains.kong],
      secret_tls_name  = local.secrets_tls[local.dns_domains.kong],
      dbless_configmap = local.kong_configmap.db_less.name,
    })
  ]
}

################################################################################
# Depends on: Credentials Config Service, Kong, Verifier                       #
################################################################################

#* DONE
resource "helm_release" "portal" {
  depends_on = [
    kubernetes_manifest.certs_creation,
    helm_release.credentials_config_service,
    helm_release.kong,
    helm_release.verifier,
  ]

  chart      = var.portal.chart_name
  version    = var.portal.version
  repository = var.portal.repository
  name       = var.services_names.portal
  namespace  = var.namespace
  wait       = true
  count      = var.flags_deployment.portal ? 1 : 0

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  values = [
    templatefile("${local.helm_conf_yaml_path}/portal.yaml", {
      service_name       = var.services_names.portal,
      did_domain         = local.did_methods[var.did_option],
      service_domain     = local.dns_dir[local.dns_domains.portal],
      secret_tls_name    = local.secrets_tls[local.dns_domains.portal],
      ds_domain_tpr      = local.dns_dir[local.dns_domains.tpr],
      ds_domain_verifier = local.dns_dir[local.dns_domains.verifier],
      ds_domain_kong     = local.dns_dir[local.dns_domains.kong],
      til_service        = var.services_names.til,
      css_service        = var.services_names.ccs,
      client_id          = "ds-operator-local" #TODO: Set as variable
    })
  ]
}

################################################################################
# Depends on: walt-id, mysql, pdp                                              #
################################################################################

#! Error deployment
resource "helm_release" "keyrock" {
  depends_on = [
    kubernetes_manifest.certs_creation,
    helm_release.walt_id,
    helm_release.mysql,
    helm_release.pdp
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
      service_domain      = local.dns_dir[local.dns_domains.keyrock],
      secret_tls_name     = local.secrets_tls[local.dns_domains.keyrock],
      mysql_service       = var.services_names.mysql,
      mysql_root_password = var.mysql.root_password,
      admin_email         = var.keyrock.admin_email,
      admin_password      = var.keyrock.admin_password,
      waltid_secret_tls   = local.secrets_tls[local.dns_domains.walt_id],
      tpr_domain          = local.dns_dir[local.dns_domains.tpr],
      did_domain          = local.did_methods[var.did_option]
    })
  ]
}
