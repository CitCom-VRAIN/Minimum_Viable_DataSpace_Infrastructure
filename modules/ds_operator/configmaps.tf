################################################################################
# Verifier                                                                     #
################################################################################
data "template_file" "did_config" {
  template = file("${local.helm_config_map_path}/verifier/did-config_import.sh")

  vars = {
    waltid_domain = local.dns_dir[local.dns_domains.walt_id]
  }
}

resource "kubernetes_config_map" "did_config" {
  metadata {
    name      = local.verifier_configmap.did_config.name
    namespace = var.namespace
  }

  data = {
    "import.sh" = data.template_file.did_config.rendered
  }
}

data "template_file" "vc_config" {
  template = file("${local.helm_config_map_path}/verifier/credential.json")

  vars = {
    did_domain = local.did_methods[var.did_option],
  }
}

#? how have the credentials been generated?
resource "kubernetes_config_map" "vc_config" {
  metadata {
    name      = local.verifier_configmap.vc_config.name
    namespace = var.namespace
  }

  data = {
    "credential.json" = data.template_file.vc_config.rendered
  }
}

################################################################################
# Kong                                                                         #
################################################################################

data "template_file" "kong_dbless" {
  template = file("${local.helm_config_map_path}/kong/dbless-kong.yaml")

  vars = {
    orion_service         = var.services_names.orion_ld,
    orion_name            = "tir", #? What is this? #FIXME
    orion_port            = var.orion_ld.broker_port,
    waltid_service        = var.services_names.walt_id,
    waltid_name           = "waltid", #? What is this? #FIXME
    waltid_custodian_port = 7003,
    portal_orion          = "portal-orion-ld" #? What is this? #FIXME
    portal_orion_name     = "vc"              #? What is this? #FIXME
  }
}

resource "kubernetes_config_map" "kong_dbless" {
  metadata {
    name      = local.kong_configmap.db_less.name
    namespace = var.namespace
  }

  data = {
    "kong.yml" = data.template_file.kong_dbless.rendered
  }
}
