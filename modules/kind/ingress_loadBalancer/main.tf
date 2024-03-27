data "http" "ingress_web_manifest" {
  url = var.ingress_config_file
}

data "http" "loadbalancer_web_manifest" {
  url = var.loadbalancer_config_file
}

data "kubectl_file_documents" "ingress_manifest" {
  content = data.http.ingress_web_manifest.response_body
}

data "kubectl_file_documents" "loadbalancer_manifest" {
  content = data.http.loadbalancer_web_manifest.response_body
}

resource "kubectl_manifest" "ingress" {
  wait = true

  for_each  = data.kubectl_file_documents.ingress_manifest.manifests
  yaml_body = each.value
}

resource "kubectl_manifest" "load_balancer" {
  depends_on = [kubectl_manifest.ingress]
  wait       = true

  for_each  = data.kubectl_file_documents.loadbalancer_manifest.manifests
  yaml_body = each.value
}

resource "null_resource" "loadBalancer_installation" {
  depends_on = [kubectl_manifest.load_balancer]
  # metallb-config.yaml download from https://kind.sigs.k8s.io/examples/loadbalancer/metallb-config.yaml
  provisioner "local-exec" {
    command = <<-EOF
        set -e
        TEMPFILE=$(mktemp)
        cp ${path.module}/config/metallb-config.yaml $TEMPFILE
        VALUE=$(${path.module}/scripts/ips_for_loadBalancer.sh)
        sed -i "s|172.19.255.200-172.19.255.250|$VALUE|" $TEMPFILE
        kubectl apply \
            --context kind-${var.cluster_name} \
            --kubeconfig ${var.kubernetes_local_path} \
            -f $TEMPFILE
        rm $TEMPFILE
    EOF
  }
  triggers = {
    always_run = "${timestamp()}"
  }
}
