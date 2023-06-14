resource "proxmox_virtual_environment_vm" "k3s_cp_01" {
  name        = "${var.machine_name}-01"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = "<your proxmox node>"

  cpu {
    cores = var.cp_cores
  }

  memory {
    dedicated = var.cp_memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.debian_cloud_image.id
    interface    = "scsi0"
    size         = var.cp_disk_size
  }

  serial_device {} # The Debian cloud image expects a serial port to be present

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  
  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --cluster
            --context k3s \
            --ssh-key ~/.ssh/id_rsa.pub \
            --user ${var.username} \
            # --k3s-extra-args '--no-deploy -traefik'
        EOT
  }
}

resource "proxmox_virtual_environment_vm" "k3s_cp_02" {
  name        = "${var.machine_name}-02"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = "<your proxmox node>"

  cpu {
    cores = var.cp_cores
  }

  memory {
    dedicated = var.cp_memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.debian_cloud_image.id
    interface    = "scsi0"
    size         = var.cp_disk_size
  }

  serial_device {} # The Debian cloud image expects a serial port to be present

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id
    
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  
  provisioner "local-exec" {
    command = <<EOT
            k3sup install \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --server
            --server-ip ${proxmox_virtual_environment_vm.k3s_cp_01.network_interface[0].access_config[0].nat_ip} \
            --context k3s \
            --ssh-key ~/.ssh/id_rsa.pub \
            --user ${var.username} \
            # --k3s-extra-args '--no-deploy -traefik'
        EOT
  }
}

resource "proxmox_virtual_environment_vm" "k3s_worker_01" {
  name        = "${var.machine_name}-worker-01"
  description = "Managed by Terraform"
  tags        = ["terraform"]
  node_name   = "<your proxmox node>"

  cpu {
    cores = var.worker_cores
  }

  memory {
    dedicated = var.worker_memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_file.debian_cloud_image.id
    interface    = "scsi0"
    size         = var.worker_disk_size
  }

  serial_device {} # The Debian cloud image expects a serial port to be present

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    
    datastore_id      = "local-lvm"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
  
  provisioner "local-exec" {
    command = <<EOT
            k3sup join \
            --ip ${self.network_interface[0].access_config[0].nat_ip} \
            --server-ip ${proxmox_virtual_environment_vm.k3s_cp_01.network_interface[0].access_config[0].nat_ip} \
            --ssh-key ~/.ssh/id_rsa.pub \
            --user var.username
        EOT
  }
}
