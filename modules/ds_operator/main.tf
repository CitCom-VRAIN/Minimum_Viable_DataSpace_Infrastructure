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

#? DONE Ingress is needed? configuration datasource?
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
      service_name         = var.services_names.walt_id,
      didweb_domain        = var.ds_domain,
      dns_name             = local.dns_dir[var.services_names.walt_id],
      secret_tls_name      = local.secrets_tls[var.services_names.walt_id],
      dns_core             = local.dns_dir[var.services_names.walt_id_core],
      secret_tls_core      = local.secrets_tls[var.services_names.walt_id_core],
      dns_signatory        = local.dns_dir[var.services_names.walt_id_signatory],
      secret_tls_signatory = local.secrets_tls[var.services_names.walt_id_signatory],
      dns_auditor          = local.dns_dir[var.services_names.walt_id_auditor],
      secret_tls_auditor   = local.secrets_tls[var.services_names.walt_id_auditor],
      dns_custodian        = local.dns_dir[var.services_names.walt_id_custodian],
      secret_tls_custodian = local.secrets_tls[var.services_names.walt_id_custodian],
      dns_essif            = local.dns_dir[var.services_names.walt_id_essif],
      secret_tls_essif     = local.secrets_tls[var.services_names.walt_id_essif]
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
      service_name  = var.services_names.mongo,
      root_password = var.mongodb.root_password,
      orion_db_name = "orion-oper" #! maximum 10 characters
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
      ds_domain          = local.dns_dir[var.services_names.tpr],
      secret_tls_name    = local.secrets_tls[var.services_names.tpr],
      orion_service_name = var.services_names.orion_ld
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
      didweb_domain      = var.ds_domain,
      ds_domain          = local.dns_dir[var.services_names.portal],
      secret_tls_name    = local.secrets_tls[var.services_names.portal],
      ds_domain_tpr      = local.dns_dir[var.services_names.tpr],
      ds_domain_verifier = local.dns_dir[var.services_names.verifier],
      ds_domain_kong     = local.dns_dir[var.services_names.kong],
      til_service        = var.services_names.til,
      css_service        = var.services_names.ccs,
      client_id          = "ds-operator-local" #TODO: Set as variable
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
    helm_release.walt_id
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
      ds_domain        = local.dns_dir[var.services_names.verifier],
      didweb_domain    = var.ds_domain,
      secret_tls_name  = local.secrets_tls[var.services_names.verifier],
      waltid_service   = var.services_names.walt_id,
      tir_service      = local.dns_dir[var.services_names.tir],
      ccs_service      = var.services_names.ccs,
      verifier_service = var.services_names.verifier
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
      didweb_domain          = var.ds_domain,
      verifier_service       = local.dns_dir[var.services_names.verifier],
      keyrock_service        = local.dns_dir[var.services_names.keyrock],
      secret_tls_name_waltid = local.secrets_tls[var.services_names.walt_id]
    })
  ]
}

################################################################################
# Depends on: OrionLD, pdp                                                     #
################################################################################

resource "kubernetes_config_map" "kong_dbless" {
  metadata {
    name = "${var.services_names.kong}-dbless"
  }

  data = {
    "kong.yml" = file("${local.helm_config_map_path}/kong_dbless.yaml")
  }
}


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
      namespace       = var.namespace,
      service_name    = var.services_names.kong,
      ds_domain       = local.dns_dir[var.services_names.kong],
      secret_tls_name = local.secrets_tls[var.services_names.kong],
    })
  ]
}

################################################################################
# Depends on: walt-id, mysql, pdp                                              #
################################################################################

#FIXME: Error deployment
# > fiware-idm@8.3.0 start /opt/fiware-idm
# > node --max-http-header-size=${IDM_SERVER_MAX_HEADER_SIZE:-8192} ./bin/www

# Connection has been established successfully
# Database created
# Database migrated
# Unable to seed database:  Error: Command failed: npm run seed_db --silent
# ERROR: Validation error

#     at ChildProcess.exithandler (child_process.js:383:12)
#     at ChildProcess.emit (events.js:400:28)
#     at maybeClose (internal/child_process.js:1088:16)
#     at Process.ChildProcess._handle.onexit (internal/child_process.js:296:5) {
#   killed: false,
#   code: 1,
#   signal: null,
#   cmd: 'npm run seed_db --silent'
# }
# internal/fs/watchers.js:251
#     throw error;
#     ^

# Error: EMFILE: too many open files, watch '/opt/fiware-idm/etc/translations/'
#     at FSWatcher.<computed> (internal/fs/watchers.js:243:19)
#     at Object.watch (fs.js:1587:34)
#     at module.exports (/opt/fiware-idm/node_modules/i18n-express/index.js:68:6)
#     at Object.<anonymous> (/opt/fiware-idm/app.js:177:5)
#     at Module._compile (internal/modules/cjs/loader.js:1085:14)
#     at Object.Module._extensions..js (internal/modules/cjs/loader.js:1114:10)
#     at Module.load (internal/modules/cjs/loader.js:950:32)
#     at Function.Module._load (internal/modules/cjs/loader.js:790:12)
#     at Module.require (internal/modules/cjs/loader.js:974:19)
#     at require (internal/modules/cjs/helpers.js:101:18)
#     at start_server (/opt/fiware-idm/bin/www:106:15)
#     at /opt/fiware-idm/bin/www:140:7
#     at /opt/fiware-idm/lib/database.js:112:11
#     at /opt/fiware-idm/lib/database.js:39:18
#     at ChildProcess.exithandler (child_process.js:390:5)
#     at ChildProcess.emit (events.js:400:28)
#     at maybeClose (internal/child_process.js:1088:16)
#     at Process.ChildProcess._handle.onexit (internal/child_process.js:296:5) {
#   errno: -24,
#   syscall: 'watch',
#   code: 'EMFILE',
#   path: '/opt/fiware-idm/etc/translations/',
#   filename: '/opt/fiware-idm/etc/translations/'
# }
# npm ERR! code ELIFECYCLE
# npm ERR! errno 1
# npm ERR! fiware-idm@8.3.0 start: `node --max-http-header-size=${IDM_SERVER_MAX_HEADER_SIZE:-8192} ./bin/www`
# npm ERR! Exit status 1
# npm ERR! 
# npm ERR! Failed at the fiware-idm@8.3.0 start script.
# npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

# npm ERR! A complete log of this run can be found in:
# npm ERR!     /root/.npm/_logs/2024-03-14T13_19_08_227Z-debug.log


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
