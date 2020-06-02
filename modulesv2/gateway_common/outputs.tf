output "templates" {
  value = {
    for host, params in var.gateway_hosts :
    host => [
      for template in var.gateway_templates :
      templatefile(template, {
        hostname                   = params.hostname
        user                       = var.user
        container_images           = var.container_images
        networks                   = var.networks
        loadbalancer_pools         = var.loadbalancer_pools
        host_network               = params.host_network
        services                   = var.services
        domains                    = var.domains
        mtu                        = var.mtu
        dns_forward_ip             = "9.9.9.9"
        dns_forward_tls_servername = "dns.quad9.net"
        # master route prioirty is slotted in between main and slave
        # when keepalived becomes master on the host
        # priority for both should be greater than 32767 (default)
        slave_default_route_table     = 240
        slave_default_route_priority  = 32780
        master_default_route_table    = 250
        master_default_route_priority = 32770
        vrrp_id                       = 247

        # Path mounted by kubelet running in container
        kubelet_path = "/var/lib/kubelet"
        # This paths should be visible by kubelet running in the container
        pod_mount_path = "/var/lib/kubelet/podconfig"
        kea_path       = "/var/lib/kea"
        kea_hooks_path = "/usr/local/lib/kea/hooks"
        kea_ha_peers = jsonencode([
          for k, v in var.gateway_hosts :
          {
            name = v.hostname
            role = v.kea_ha_role
            url  = "http://${v.host_network.sync.ip}:${var.services.kea.ports.peer}/"
          }
        ])
      })
    ]
  }
}