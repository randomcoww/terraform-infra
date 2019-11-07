locals {
  user               = "core"
  mtu                = 9000
  kubernetes_version = "v1.15.3"
  container_images = {
    hyperkube               = "gcr.io/google_containers/hyperkube:${local.kubernetes_version}"
    kube_apiserver          = "gcr.io/google_containers/kube-apiserver:${local.kubernetes_version}"
    kube_controller_manager = "gcr.io/google_containers/kube-controller-manager:${local.kubernetes_version}"
    kube_scheduler          = "gcr.io/google_containers/kube-scheduler:${local.kubernetes_version}"
    kube_proxy              = "gcr.io/google_containers/kube-proxy:${local.kubernetes_version}"
    kubelet                 = "randomcoww/kubelet:latest"
    etcd_wrapper            = "randomcoww/etcd-wrapper:20190609.01"
    etcd                    = "gcr.io/etcd-development/etcd:v3.4.0"
    flannel                 = "quay.io/coreos/flannel:v0.11.0-amd64"
    keepalived              = "randomcoww/keepalived:latest"
    cni_plugins             = "randomcoww/cni_plugins:v0.8.2"
    coredns                 = "coredns/coredns:1.6.3"
    external_dns            = "registry.opensource.zalan.do/teapot/external-dns:latest"
    kapprover               = "randomcoww/kapprover:v0.0.3"
    busybox                 = "busybox:latest"
    nftables                = "randomcoww/nftables:latest"
    kea                     = "randomcoww/kea:20190119.01"
    conntrack               = "randomcoww/conntrack:latest"
  }

  services = {
    # kvm services
    renderer = {
      vip = "192.168.224.1"
      ports = {
        http = 80
        rpc  = 58081
      }
    }

    # provisioner services
    kea = {
      ports = {
        peer = 58082
      }
    }
    gateway = {
      vip = "192.168.126.240"
    }
    lan_gateway = {
      vip = "192.168.62.240"
    }
    recursive_dns = {
      vip = "192.168.126.241"
      ports = {
        prometheus = 9153
      }
    }

    # kubernetes common
    kubernetes_apiserver = {
      vip = "192.168.126.245"
      ports = {
        secure = 56443
      }
    }
    kubernetes_service = {
      vip = "10.96.0.1"
    }
    kubernetes_dns = {
      vip = "10.96.0.10"
    }
    etcd = {
      ports = {
        peer   = 52380
        client = 52379
      }
    }
    internal_dns = {
      vip = "192.168.126.127"
      ports = {
        prometheus = 9153
      }
    }
  }

  domains = {
    internal           = "fuzzybunny.internal"
    kubernetes_cluster = "cluster.local"
  }

  networks = {
    # vlans
    store = {
      id        = 0
      network   = "192.168.126.0"
      cidr      = 23
      dhcp_pool = "192.168.127.64/26"
    }
    lan = {
      id        = 60
      network   = "192.168.62.0"
      cidr      = 23
      dhcp_pool = "192.168.63.64/26"
    }
    sync = {
      id      = 90
      network = "192.168.190.0"
      cidr    = 29
    }
    wan = {
      id = 30
    }
    # internal network on each hypervisor
    int = {
      network   = "192.168.224.0"
      cidr      = 23
      dhcp_pool = "192.168.225.64/26"
    }
    # kubernetes
    kubernetes = {
      network = "10.244.0.0"
      cidr    = 16
    }
    kubernetes_service = {
      network = "10.96.0.0"
      cidr    = 12
    }
    metallb = {
      network = "192.168.126.64"
      cidr    = 26
    }
  }

  ## Matchbox instance to write configs to
  ## This needs to be passed in by hostname (e.g. -var=renderer=kvm-0) for now
  ## Dynamic provider support might resolse this
  local_renderer = {
    endpoint        = "127.0.0.1:8081"
    cert_pem        = module.local-renderer.matchbox_cert_pem
    private_key_pem = module.local-renderer.matchbox_private_key_pem
    ca_pem          = module.local-renderer.matchbox_ca_pem
  }

  renderers = merge({
    local = local.local_renderer
  },
  {
    for k in keys(module.hw.matchbox_rpc_endpoints) :
    k => {
      endpoint        = module.hw.matchbox_rpc_endpoints[k]
      cert_pem        = module.hw.matchbox_cert_pem
      private_key_pem = module.hw.matchbox_private_key_pem
      ca_pem          = module.hw.matchbox_ca_pem
    }
  })
}