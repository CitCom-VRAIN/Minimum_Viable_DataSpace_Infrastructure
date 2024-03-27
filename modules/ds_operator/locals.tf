locals {
  dns_domains = merge(var.services_names, {
    til = "til"
    tir = "tir"
    tpr = "tpr"
  })

  cert_properties = [
    { # walt_id
      id               = local.dns_domains.walt_id
      metadata_name    = "${var.services_names.walt_id}-certificate"
      spec_secret_name = "${var.services_names.walt_id}-tls-secret"
      dns_name         = "${local.dns_domains.walt_id}.${var.service_domain}"
    },
    { # til
      id               = local.dns_domains.til
      metadata_name    = "${var.services_names.til}-certificate"
      spec_secret_name = "${var.services_names.til}-tls-secret"
      dns_name         = "${local.dns_domains.til}.${var.service_domain}"
    },
    { # tir
      id               = local.dns_domains.tir
      metadata_name    = "${var.services_names.tir}-certificate"
      spec_secret_name = "${var.services_names.tir}-tls-secret"
      dns_name         = "${local.dns_domains.tir}.${var.service_domain}"
    },
    { # tpr
      id               = local.dns_domains.tpr
      metadata_name    = "${var.services_names.tpr}-certificate"
      spec_secret_name = "${var.services_names.tpr}-tls-secret"
      dns_name         = "${local.dns_domains.tpr}.${var.service_domain}"
    },
    { # portal
      id               = local.dns_domains.portal
      metadata_name    = "${var.services_names.portal}-certificate"
      spec_secret_name = "${var.services_names.portal}-tls-secret"
      dns_name         = "${local.dns_domains.portal}.${var.service_domain}"
    },
    { # verifier
      id               = local.dns_domains.verifier
      metadata_name    = "${var.services_names.verifier}-certificate"
      spec_secret_name = "${var.services_names.verifier}-tls-secret"
      dns_name         = "${local.dns_domains.verifier}.${var.service_domain}"
    },
    { # kong
      id               = local.dns_domains.kong
      metadata_name    = "${var.services_names.kong}-certificate"
      spec_secret_name = "${var.services_names.kong}-tls-secret"
      dns_name         = "${local.dns_domains.kong}.${var.service_domain}"
    },
    { # keyrock
      id               = local.dns_domains.keyrock
      metadata_name    = "${var.services_names.keyrock}-certificate"
      spec_secret_name = "${var.services_names.keyrock}-tls-secret"
      dns_name         = "${local.dns_domains.keyrock}.${var.service_domain}"
    }
  ]

  #! Do not edit.
  helm_config_map_path = "${path.module}/config/configmaps"
  helm_conf_yaml_path  = "${path.module}/config/helm_values"
  dns_dir              = { for prop in local.cert_properties : prop.id => prop.dns_name if contains(values(local.dns_domains), prop.id) }
  secrets_tls          = { for prop in local.cert_properties : prop.id => prop.spec_secret_name if contains(values(local.dns_domains), prop.id) }
  cert_properties_map = {
    for cert in local.cert_properties : cert.metadata_name => {
      spec_secret_name = cert.spec_secret_name
      dns_name         = cert.dns_name
    }
  }
  did_methods = {
    web = "did:web:${local.dns_dir[local.dns_domains.walt_id]}:did"
    key = "did:key" # TODO: change to real did:key
  }
}
