data "http" "portainer_agent" {
  url = var.portainer_k8s_file_config
}

data "kubectl_file_documents" "portainer_manifest" {
  content = data.http.portainer_agent.response_body
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}

resource "docker_container" "portainer_ce" {
  image        = "portainer/portainer-ce:${var.img_version}"
  name         = "portainer"
  restart      = "always"
  network_mode = "host" # This is required to access to kind cluster
  dynamic "ports" {
    for_each = var.add_ports
    content {
      internal = ports.value.internal
      external = ports.value.external
    }
  }
  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    container_path = "/data"
    volume_name    = docker_volume.portainer_data.name
  }
}

resource "kubectl_manifest" "portainerAgent_cluster" {
  for_each  = data.kubectl_file_documents.portainer_manifest.manifests
  yaml_body = each.value
}
