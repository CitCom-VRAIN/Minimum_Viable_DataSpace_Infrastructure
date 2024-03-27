cluster_name = "ds-local-cluster"
kubernetes_local_path = "~/.kube/config_DSLocal"
flags_deployment = {
    portainer = false,
    cert_trust_manager = true # if it's false, the variable flags_deployment.ca_configuration must also be false
}