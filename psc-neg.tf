##########################################################
# Copyright 2023 Google LLC.
# This software is provided as-is, without warranty or
# representation for any use or purpose.
# Your use of it is subject to your agreement with Google.
#
# Sample Terraform script to set up PSC and HTTPS XLB 
##########################################################
resource "google_compute_region_network_endpoint_group" "psc_neg" {
  name                  = "psc-neg"
  region                = var.instance_region
  network               = var.apigee_network
  subnetwork            = var.apigee_subnetwork
  network_endpoint_type = "PRIVATE_SERVICE_CONNECT"
  psc_target_service    = google_apigee_instance.apigee_instance.service_attachment

  depends_on = [
    google_apigee_instance.apigee_instance
  ]
}

resource "google_compute_backend_service" "psc_backend" {
  project               = var.project_id
  name                  = "${var.xlb_name}-backend"
  port_name             = "https"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  depends_on = [
    google_compute_region_network_endpoint_group.psc_neg
  ]
    backend {
      group = google_compute_region_network_endpoint_group.psc_neg.self_link
    }
    lifecycle {
    create_before_destroy = true
    }
  }
  
resource "google_compute_url_map" "url_map" {
  project         = var.project_id
  name            = var.xlb_name
  default_service = google_compute_backend_service.psc_backend.id
}

resource "google_compute_target_https_proxy" "https_proxy" {
  project          = var.project_id
  name             = "${var.xlb_name}-proxy"
  url_map          = google_compute_url_map.url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.apigee_cert_dev.id]
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  project               = var.project_id
  name                  = "${var.xlb_name}-fr"
  target                = google_compute_target_https_proxy.https_proxy.id
  ip_address            = google_compute_global_address.external_ip.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}