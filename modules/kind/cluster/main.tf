resource "kind_cluster" "k8s_cluster" {
  name            = var.cluster_name
  kubeconfig_path = pathexpand(var.kubernetes_local_path)
  node_image      = var.kindest_version
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]
      dynamic "extra_port_mappings" {
        for_each = var.add_extra_ports
        content {
          container_port = extra_port_mappings.value.container_port
          host_port      = extra_port_mappings.value.host_port
          protocol       = extra_port_mappings.value.protocol
        }
      }
      dynamic "extra_mounts" {
        for_each = var.add_extra_mounts
        content {
          host_path      = extra_mounts.value.host_path
          container_path = extra_mounts.value.container_path
        }
      }
    }

    node {
      role = "worker"
      dynamic "extra_mounts" {
        for_each = var.add_extra_mounts
        content {
          host_path      = extra_mounts.value.host_path
          container_path = extra_mounts.value.container_path
        }
      }
    }

    node {
      role = "worker"
      dynamic "extra_mounts" {
        for_each = var.add_extra_mounts
        content {
          host_path      = extra_mounts.value.host_path
          container_path = extra_mounts.value.container_path
        }
      }
    }
  }
}