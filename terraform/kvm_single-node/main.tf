data "template_file" "user_data" {
    template = file("${path.module}/conf/user_data.yaml")
    vars = {
        hostname = var.vm_hostname
        domain   = var.vm_domain
    }
}

data "template_file" "network_config" {
  template = file("${path.module}/conf/network_config.yaml")
  vars  = {
    ip_address = var.ip_address
  }
}

# Base OS volume
resource "libvirt_volume" "instance_vol" {
    name    = "${var.vm_hostname}-vol"
    pool    = var.libvirt_pool_name
    source  = var.base_image_path
    format  = "qcow2"
}

# Data Volume
resource "libvirt_volume" "data_volume" {
    name    = "${var.vm_hostname}-data-vol"
    pool    = var.libvirt_pool_name
    size    = var.data_volume * 1024 * 1024 * 1024
    format  = "qcow2"
}

resource "libvirt_cloudinit_disk" "cloudinit" {
    name            = "${var.vm_hostname}-cloudinit.iso"
    user_data       = data.template_file.user_data.rendered
    network_config  = data.template_file.network_config.rendered
    pool            = var.libvirt_pool_name
}

resource "libvirt_domain" "node" {
    name        = var.vm_hostname
    memory      = var.vm_memory
    vcpu      = var.vm_cpu
    cloudinit   = libvirt_cloudinit_disk.cloudinit.id
    autostart   = true

    cpu {
        mode = "host-passthrough"
    }

    network_interface {
        macvtap         = "enp4s7"
        wait_for_lease  = "false"
        hostname        = var.vm_hostname
    }

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_port = "1"
        target_type = "virtio"
    }

    disk {
        volume_id   = libvirt_volume.instance_vol.id
    }

    disk {
        volume_id   = libvirt_volume.data_volume.id
    }
}
