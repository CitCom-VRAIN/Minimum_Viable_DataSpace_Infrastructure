locals {
  services_names = [
    var.services_names.walt_id,
    var.services_names.walt_id_core,
    var.services_names.walt_id_signatory,
    var.services_names.walt_id_auditor,
    var.services_names.walt_id_custodian,
    var.services_names.walt_id_custodian,
    var.services_names.walt_id_essif,
    var.services_names.til,
    var.services_names.tir,
    var.services_names.tpr,
    var.services_names.portal,
    var.services_names.verifier,
    var.services_names.kong,
    var.services_names.keyrock
  ]

  cert_properties = [
    { # walt_id
      id               = var.services_names.walt_id
      metadata_name    = "${var.services_names.walt_id}-certificate"
      spec_secret_name = "${var.services_names.walt_id}-tls-secret"
      dns_names        = "${var.services_names.walt_id}.${var.ds_domain}"
    },
    { # walt_id
      id               = var.services_names.walt_id_core
      metadata_name    = "${var.services_names.walt_id_core}-certificate"
      spec_secret_name = "${var.services_names.walt_id_core}-tls-secret"
      dns_names        = "${var.services_names.walt_id_core}.${var.ds_domain}"
    },
    { # walt_id
      id               = var.services_names.walt_id_signatory
      metadata_name    = "${var.services_names.walt_id_signatory}-certificate"
      spec_secret_name = "${var.services_names.walt_id_signatory}-tls-secret"
      dns_names        = "${var.services_names.walt_id_signatory}.${var.ds_domain}"
    },
    { # walt_id
      id               = var.services_names.walt_id_auditor
      metadata_name    = "${var.services_names.walt_id_auditor}-certificate"
      spec_secret_name = "${var.services_names.walt_id_auditor}-tls-secret"
      dns_names        = "${var.services_names.walt_id_auditor}.${var.ds_domain}"
    },
    { # walt_id
      id               = var.services_names.walt_id_custodian
      metadata_name    = "${var.services_names.walt_id_custodian}-certificate"
      spec_secret_name = "${var.services_names.walt_id_custodian}-tls-secret"
      dns_names        = "${var.services_names.walt_id_custodian}.${var.ds_domain}"
    },
    { # walt_id
      id               = var.services_names.walt_id_essif
      metadata_name    = "${var.services_names.walt_id_essif}-certificate"
      spec_secret_name = "${var.services_names.walt_id_essif}-tls-secret"
      dns_names        = "${var.services_names.walt_id_essif}.${var.ds_domain}"
    },
    { # til
      id               = var.services_names.til
      metadata_name    = "${var.services_names.til}-certificate"
      spec_secret_name = "${var.services_names.til}-tls-secret"
      dns_names        = "${var.services_names.til}.${var.ds_domain}"
    },
    { # tir
      id               = var.services_names.tir
      metadata_name    = "${var.services_names.tir}-certificate"
      spec_secret_name = "${var.services_names.tir}-tls-secret"
      dns_names        = "${var.services_names.tir}.${var.ds_domain}"
    },
    { # tpr
      id               = var.services_names.tpr
      metadata_name    = "${var.services_names.tpr}-certificate"
      spec_secret_name = "${var.services_names.tpr}-tls-secret"
      dns_names        = "${var.services_names.tpr}.${var.ds_domain}"
    },
    { # portal
      id               = var.services_names.portal
      metadata_name    = "${var.services_names.portal}-certificate"
      spec_secret_name = "${var.services_names.portal}-tls-secret"
      dns_names        = "${var.services_names.portal}.${var.ds_domain}"
    },
    { # verifier
      id               = var.services_names.verifier
      metadata_name    = "${var.services_names.verifier}-certificate"
      spec_secret_name = "${var.services_names.verifier}-tls-secret"
      dns_names        = "${var.services_names.verifier}.${var.ds_domain}"
    },
    { # kong
      id               = var.services_names.kong
      metadata_name    = "${var.services_names.kong}-certificate"
      spec_secret_name = "${var.services_names.kong}-tls-secret"
      dns_names        = "${var.services_names.kong}.${var.ds_domain}"
    },
    { # keyrock
      id               = var.services_names.keyrock
      metadata_name    = "${var.services_names.keyrock}-certificate"
      spec_secret_name = "${var.services_names.keyrock}-tls-secret"
      dns_names        = "${var.services_names.keyrock}.${var.ds_domain}"
    }
  ]

  #! Do not edit.
  helm_config_map_path = "${path.module}/config/configmaps"
  helm_conf_yaml_path  = "${path.module}/config/helm_values"
  dns_dir              = { for prop in local.cert_properties : prop.id => prop.dns_names if contains(local.services_names, prop.id) }
  secrets_tls          = { for prop in local.cert_properties : prop.id => prop.spec_secret_name if contains(local.services_names, prop.id) }
  cert_properties_map = {
    for cert in local.cert_properties : cert.metadata_name => {
      spec_secret_name = cert.spec_secret_name
      dns_names        = cert.dns_names
    }
  }
}
