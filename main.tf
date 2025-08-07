terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.45.0"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.74.100:8006/api2/json"
  username = "root@pam"
  password = ""
  insecure = true
}

locals {
  base_name = "aldpro"
  domain_name    = "ald-aa.pro"
  names = [
    "audit",
    "client1",
    "client3",
    "cups",
    "dhcp",
    "mon",
    "pxe",
    "repo",
    "smb",
    "dc1",
    "dc2"
  ]
}

resource "proxmox_virtual_environment_vm" "vms" {
  count      = length(local.names)
  name       = "${local.names[count.index]}.${local.domain_name}"
  node_name  = "pve"

  clone {
    vm_id = 119  # укажи здесь **ID** шаблона (не имя!)
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  disk {
    datastore_id = "SSD1TB"
    interface    = "scsi0"
    size         = 30
  }

  network_device {
    model        = "virtio"
    bridge       = "vmbr1"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "10.10.10.${150 + count.index}/24"
        gateway = "10.10.10.1"
      }
    }
    dns {
      servers = ["77.88.8.8"]
    }
    user_account {
      username = "astra"
      password = "astra"
      keys     = [
        ""
      ]
    }
  }
}

output "vm_ips" {
  value = {
    for i in range(length(local.names)) :
    "${local.names[i]}.${local.domain_name}" => "10.10.10.${150 + i}"
  }
}
