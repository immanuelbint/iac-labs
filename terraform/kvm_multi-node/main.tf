# --- Master node resources --- #

data "template_file" "master_user_data" {
    count       = var.master_count
    template    = file("${path.module}/conf/user_data.yaml")
    vars        = {
        hostname = "${var.master_hostname}-${count.index}"
        domain   = var.vm_domain
    }
}

data "template_file" "master_network_config" {
    count       = var.master_count
    template    = file("${path.module}/conf/network_config.yaml")
    vars        = {
    ip_address = var.master_ip_address[count.index]
  }
}

resource "libvirt_volume" "master_instance_vol" {
    count   = var.master_count
    name    = "${var.master_hostname}-vol.${count.index}"
    pool    = var.libvirt_pool_name
    source  = var.base_image_path
    format  = "qcow2"
}

resource "libvirt_cloudinit_disk" "master_cloudinit" {
    count           = var.master_count
    name            = "${var.master_hostname}-cloudinit.${count.index}.iso"
    user_data       = data.template_file.master_user_data[count.index].rendered
    network_config  = data.template_file.master_network_config[count.index].rendered
    pool            = var.libvirt_pool_name
}

resource "libvirt_domain" "master_node" {
    count       = var.master_count
    name        = "${var.master_hostname}-${count.index}"
    memory      = var.master_memory
    vcpu        = var.master_cpu
    cloudinit   = libvirt_cloudinit_disk.master_cloudinit[count.index].id
    autostart   = true

    cpu {
        mode = "host-passthrough"
    }

    network_interface {
        macvtap         = "enp4s7"
        wait_for_lease  = "false"
        hostname        = "${var.master_hostname}-${count.index}"
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
        volume_id   = libvirt_volume.master_instance_vol[count.index].id
    }
}

# --- Worker node resources --- #

data "template_file" "worker_user_data" {
    count       = var.worker_count
    template    = file("${path.module}/conf/user_data.yaml")
    vars        = {
        hostname = "${var.worker_hostname}-${count.index}"
        domain   = var.vm_domain
    }
}

data "template_file" "worker_network_config" {
    count       = var.worker_count
    template    = file("${path.module}/conf/network_config.yaml")
    vars        = {
    ip_address = var.worker_ip_address[count.index]
  }
}

# Worker Main Disk
resource "libvirt_volume" "worker_instance_vol" {
    count   = var.worker_count
    name    = "${var.worker_hostname}-vol.${count.index}"
    pool    = var.libvirt_pool_name
    source  = var.base_image_path
    format  = "qcow2"
}

# Worker Data Volume
resource "libvirt_volume" "worker_data_volume" {
    for_each    = {
        for volume in var.data_volume : volume.name => volume
    }

    name    = "${var.worker_hostname}-${each.value.name}"
    pool    = each.value.pool
    size    = each.value.size * 1024 * 1024 * 1024
    format  = each.value.format
}

resource "libvirt_cloudinit_disk" "worker_cloudinit" {
    count           = var.worker_count
    name            = "${var.worker_hostname}-cloudinit.${count.index}.iso"
    user_data       = data.template_file.worker_user_data[count.index].rendered
    network_config  = data.template_file.worker_network_config[count.index].rendered
    pool            = var.libvirt_pool_name
}

resource "libvirt_domain" "worker_node" {
    count       = var.worker_count
    name        = "${var.worker_hostname}-${count.index}"
    memory      = var.worker_memory
    vcpu        = var.worker_cpu
    cloudinit   = libvirt_cloudinit_disk.worker_cloudinit[count.index].id
    autostart   = true

    cpu {
        mode = "host-passthrough"
    }

    network_interface {
        macvtap         = "enp4s7"
        wait_for_lease  = "false"
        hostname        = "${var.worker_hostname}-${count.index}"
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
        volume_id   = libvirt_volume.worker_instance_vol[count.index].id
    }

    dynamic "disk" {
        for_each    = libvirt_volume.worker_data_volume
        content {
            volume_id   = disk.value.id
        }
    }
}
