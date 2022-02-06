# Author: Michael Bischof <michael@nextpart.io>
# Organization: Nextpart Security Intelligence GmbH

variables {
  docker_image_tag  = "latest"
  ansible_playbook  = "base"
  docker_image_name = "test"
  docker_base_image = "python:3.8-alpine"
  docker_registry   = "local"
}

packer {
  required_plugins {
    docker = {
      version = ">= 1.0.1"
      source  = "github.com/hashicorp/docker"
    }
  }
}

source "docker" "bootstrap" {
  changes = [
    "LABEL io.nextpart.description='Splunk utility image'",
    "WORKDIR /",
    "ENTRYPOINT ./entrypoint.sh"
  ]
  image  = "${var.docker_base_image}"
  commit = true
}

build {
  sources = ["source.docker.bootstrap"]

  provisioner "shell" {
    inline = ["echo Running ${var.docker_base_image} Docker image."]
  }

  provisioner "ansible" {
    playbook_file   = "./playbooks/${var.ansible_playbook}.yml"
    user            = "root"
    extra_arguments = ["-v"]
  }

  post-processor "docker-tag" {
    repository = "${var.docker_registry}/${var.docker_image_name}"
    tags       = ["${var.docker_image_tag}"]
  }

  # post-processor "docker-push" {

  # }

}
