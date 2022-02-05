# Author: Michael Bischof <michael@nextpart.io>
# Organization: Nextpart Security Intelligence GmbH
locals {
  docker_image_tag = "latest"
  docker_base_image = "python:3.8-buster"
  docker_registry = "local"
}

variables {
  ansible_playbook  = "base"
  docker_image_name = "test"
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
  image  = "${local.docker_base_image}"
  commit = true
}

build {
  sources = ["source.docker.bootstrap"]

  provisioner "shell" {
    inline = ["echo Running ${local.docker_base_image} Docker image."]
  }

  provisioner "ansible" {
    playbook_file   = "./playbooks/${var.ansible_playbook}.yml"
    user            = "root"
    extra_arguments = ["-v"]
  }

  post-processor "docker-tag" {
    repository = "${local.docker_registry}/${var.docker_image_name}"
    tags       = ["${local.docker_image_tag}", "latest"]
  }

  # post-processor "docker-push" {

  # }

}
