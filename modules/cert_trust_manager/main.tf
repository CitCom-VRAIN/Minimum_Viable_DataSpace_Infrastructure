data "http" "cert_manager_repo" {
  url = "https://github.com/cert-manager/cert-manager/releases/download/${var.cert_manager_version}/cert-manager.crds.yaml"
}

data "kubectl_file_documents" "cert_manager_manifest" {
  content = data.http.cert_manager_repo.response_body
}

resource "kubectl_manifest" "cert_manager" {
  for_each  = data.kubectl_file_documents.cert_manager_manifest.manifests
  yaml_body = each.value
}

resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [kubectl_manifest.cert_manager, kubernetes_namespace.cert_manager_namespace]
  wait       = true

  name       = "cert-manager"
  namespace  = var.namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_version
}

resource "helm_release" "trust_manager" {
  depends_on = [helm_release.cert_manager]
  wait       = true

  name       = "trust-manager"
  namespace  = var.namespace
  repository = "https://charts.jetstack.io"
  chart      = "trust-manager"
  version    = var.trust_manager_version
}
