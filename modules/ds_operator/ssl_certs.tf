#! Do not edit. This is configurated by the locals variables.
resource "kubernetes_namespace" "ds_operator" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_manifest" "certs_creation" {
  # Create a certificate for the web server
  # kubectl get cert --all-namespaces
  depends_on = [kubernetes_namespace.ds_operator]
  for_each   = local.cert_properties_map
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = each.key
      namespace = var.namespace
    }
    spec = {
      secretName = each.value.spec_secret_name
      issuerRef = {
        name = var.ca_clusterissuer_name
        kind = "ClusterIssuer"
      }
      dnsNames = [each.value.dns_name]
    }
  }
}
