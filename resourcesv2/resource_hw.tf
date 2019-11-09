locals {
  # Desktop host KS
  desktop_hosts = {
    desktop-0 = {
      persistent_home_path = "/localhome"
      persistent_home_dev  = "/dev/disk/by-path/pci-0000:04:00.0-nvme-1-part1"
    }
  }

  # KVM host KS
  kvm_hosts = {
    kvm-0 = {
      network = {
        hw_if       = "enp1s0f0"
        host_tap_ip = "192.168.127.251"
        int_tap_ip  = local.services.renderer.vip
      }
    }
    kvm-1 = {
      network = {
        hw_if       = "enp1s0f0"
        host_tap_ip = "192.168.127.252"
        int_tap_ip  = local.services.renderer.vip
      }
    }
  }
}

module "hw" {
  source = "../modulesv2/hw"

  user              = local.user
  password          = var.password
  mtu               = local.mtu
  networks          = local.networks
  services          = local.services
  ssh_ca_public_key = tls_private_key.ssh-ca.public_key_openssh
  ca = local.ca

  # LiveOS base KS
  live_hosts = {
    live-base = {
    }
  }
  desktop_hosts = local.desktop_hosts
  kvm_hosts     = local.kvm_hosts

  # only local renderer makes sense here
  # this resource creates non-local renderers
  renderer = local.local_renderer
}

##
## client
##
locals {
  renderers = {
    for k in keys(module.hw.matchbox_rpc_endpoints) :
    k => {
      endpoint        = module.hw.matchbox_rpc_endpoints[k]
      cert_pem        = tls_locally_signed_cert.cert["matchbox-client"].cert_pem
      private_key_pem = tls_private_key.cert["matchbox-client"].private_key_pem
      ca_pem          = tls_self_signed_cert.ca["matchbox-ca"].cert_pem
    }
  }
}