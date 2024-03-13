locals {
  kubernetes_path       = "~/.kube/config"
  ca_clusterissuer_name = "ca-certificates"
}

#! Use makefile command to create a local k8s cluster.


module "ca_configuration" {
  source              = "../../modules/ca_configuration/"
  count               = var.flags_deployment.ca_configuration ? 1 : 0 # count =: number of instances to create
  namespace           = "cert-manager"
  clusterissuer_name  = local.ca_clusterissuer_name
  secret_ca_container = "ca-cert-manager"
}

module "local_ds_operator" {
  source     = "../../modules/ds_operator/"
  depends_on = [module.ca_configuration]
  providers = {
    helm = helm
  }

  namespace = "ds-operator"
  flags_deployment = {
    mongodb = true
    mysql   = true
    walt_id = true
    kong = true
    # depends on: mongodb
    orion_ld = true
    # depends on: mysql
    credentials_config_service = true
    trusted_issuers_list       = true
    # depends on: orion_ld
    trusted_participants_registry = true
    # depends on: credentials_config_service, kong, verifier
    portal = false
    # depends on: walt_id, credentials_config_service, trusted_issuers_list
    verifier = true

    pdp = false
    keyrock = false
  }
}
