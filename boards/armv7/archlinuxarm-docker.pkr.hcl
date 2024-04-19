# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "~> 1"
    }
  }
}

variable "docker_password" {
  type    = string
  default = ""
}

variable "docker_repository" {
  type    = string
  default = ""
}

variable "docker_user" {
  type    = string
  default = ""
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "arm" "autogenerated_1" {
  file_checksum_type    = "md5"
  file_checksum_url     = "http://hu.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz.md5"
  file_target_extension = "tar.gz"
  file_unarchive_cmd    = ["bsdtar", "-xpf", "$ARCHIVE_PATH", "-C", "$MOUNTPOINT"]
  file_urls             = ["http://hu.mirror.archlinuxarm.org/os/ArchLinuxARM-armv7-latest.tar.gz"]
  image_build_method    = "new"
  image_partitions {
    filesystem   = "ext4"
    mountpoint   = "/"
    name         = "root"
    size         = "0"
    start_sector = "4096"
    type         = "83"
  }
  image_path                   = "armv7.tar.gz"
  image_size                   = "2G"
  image_type                   = "dos"
  qemu_binary_destination_path = "/usr/bin/qemu-arm-static"
  qemu_binary_source_path      = "/usr/bin/qemu-arm-static"
}

# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.arm.autogenerated_1"]

  provisioner "shell" {
    inline = [
      "pacman-key --init",
      "pacman-key --populate archlinuxarm",
      "echo 'Server = http://nl.mirror.archlinuxarm.org/$arch/$repo' >> /etc/pacman.d/mirrorlist"
    ]
  }

  post-processors {
    post-processor "artifice" {
      files = ["armv7.tar.gz"]
    }
    post-processor "docker-import" {
      platform   = "linux/arm/v7"
      repository = "${var.docker_repository}"
      tag        = "armv7"
    }
    post-processor "docker-push" {
      login          = true
      login_password = "${var.docker_password}"
      login_username = "${var.docker_user}"
    }
  }
}