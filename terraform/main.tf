resource "proxmox_vm_qemu" "servers" {
    count = length(var.qemu_config)

    name        = var.qemu_config[count.index].name
    vmid        = var.qemu_config[count.index].vmid
    cpu         = "host"
    bootdisk    = "scsi0"
    scsihw      = "virtio-scsi-single"
    os_type     = "cloud-init"
    memory      = var.qemu_config[count.index].memory
    sockets     = var.qemu_config[count.index].sockets
    cores       = var.qemu_config[count.index].cores
    onboot       = var.qemu_config[count.index].onboot
    full_clone  = true
    agent       = var.qemu_config[count.index].agent
    ipconfig0   = "ip=${var.qemu_config[count.index].ip0}/24,gw=192.168.100.1"
    target_node = var.qemu_config[count.index].node
    clone       = var.qemu_config[count.index].template
    sshkeys     = join("\n",var.ssh_key)

    disks {
        ide {
            ide2 {
                cloudinit {
                    storage = "local-lvm"
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    storage = "local-lvm"
                    size = var.qemu_config[count.index].root_disk
                }
            }
        }
    }
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "sleep 120 && export ANSIBLE_SSH_ARGS='-o StrictHostKeyChecking=no' && ansible-playbook -i /app/ansible/inventory/hosts /app/ansible/site.yml"
  }

  depends_on = [proxmox_vm_qemu.servers]
}