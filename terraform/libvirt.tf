resource "libvirt_volume" "terraform-opnsense-base-qcow2" {
  name = "terraform-opnsense-base.qcow2"
  pool = "default"
  source = "./opnsense.qcow2"
  format = "qcow2"
}

resource "libvirt_volume" "terraform-opnsense-qcow2" {
  name = "terraform-opnsense.qcow2"
  pool = "default"
  format = "qcow2"
  size = 20000000000
  base_volume_id = libvirt_volume.terraform-opnsense-base-qcow2.id
}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yaml"
}

locals {
  user_data = <<-EOT
    #cloud-config
    ${yamlencode({
      users = [{
        name = "root"
        lock_passwd: false
        plain_text_passwd: data.sops_file.secrets.data["stringData.password"]
        ssh_pwauth: true
      }]
      # runcmd only on the first boot
      runcmd = [
        "cat << EOF > /conf/config.xml\n${file("${path.module}//config/config.xml")}\nEOF",        
        "cat << EOF > /usr/local/etc/config.xml\n${file("${path.module}/config/config.xml")}\nEOF",        
        "cat << EOF > /tmp/config.xml\n${file("${path.module}/config/config.xml")}\nEOF",        
        "date > /tmp/cloud-init.txt",
        # "configctl service reload all",
        # "configctl webgui restart",
        "php -r 'require_once ( \"config.inc\" ) ; require_once ( \"auth.inc\" ) ; $user = &getUserEntryByUID(0) ; $pw = \"${data.sops_file.secrets.data["stringData.password"]}\" ; local_user_set_password($user, $pw) ; local_user_set($user) ; write_config(\"cloud-init\");'"
      ]
    })}
  EOT
}

resource "libvirt_cloudinit_disk" "terraform-opnsense-commoninit" {
  name = "terraform-opnsense-commoninit.iso"
  pool = "default"
  user_data = local.user_data
}

resource "libvirt_domain" "terraform-opnsense" {
  name   = "terraform-opnsense"
  memory = "2048"
  vcpu   = 2
  autostart = true
  qemu_agent = false

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge = "br1"
  }

  xml {
    xslt = "${file("libvirt_pci.xslt")}"
  }
  
  disk {
    volume_id = "${libvirt_volume.terraform-opnsense-qcow2.id}"
  }

  cloudinit = "${libvirt_cloudinit_disk.terraform-opnsense-commoninit.id}"

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}
