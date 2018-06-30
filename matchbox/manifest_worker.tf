##
## kube controller kickstart renderer
##
resource "matchbox_profile" "manifest_worker" {
  name           = "worker"
  generic_config = "${file("./manifest/worker.yaml.tmpl")}"
}

##
## kickstart
##
resource "matchbox_group" "manifest_worker" {
  name    = "${matchbox_profile.manifest_worker.name}"
  profile = "${matchbox_profile.manifest_worker.name}"

  selector {
    manifest = "${matchbox_profile.manifest_worker.name}"
  }

  metadata {
    kube_proxy_image = "${var.kube_proxy_image}"
    flannel_image    = "${var.flannel_image}"
    kubernetes_path  = "${var.kubernetes_path}"
  }
}
