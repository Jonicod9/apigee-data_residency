##########################################################
# Copyright 2023 Google LLC.
# This software is provided as-is, without warranty or
# representation for any use or purpose.
# Your use of it is subject to your agreement with Google.
#
# Sample Terraform script to set up an Apigee X instance 
##########################################################
/*resource "random_id" "random_suffix" {
  byte_length = 6
}
*/
##########################################################
### Enable the required GCP APIs
##########################################################
resource "google_project_service" "gcp_services_host" {
  for_each           = toset(var.apigee_services_list)
  project            = var.service_project_id
  service            = each.key
  disable_on_destroy = false
}


resource "google_project_service" "gcp_services" {
  for_each = toset(var.apigee_services_list)
  project = var.service_project_id
  service = each.key
  disable_on_destroy = false
}

##########################################################
### Reserve the peering ip range for Apigee
##########################################################
resource "google_compute_global_address" "apigee_instance_range" {
  project       = var.service_project_id
  name          = "apigee-instance-range-22"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 22 ##Range reserved by Apigee instances
  network       = var.apigee_network
  address = var.apigee_instance_range
}

resource "google_compute_global_address" "apigee_support_range" {
  project       = var.service_project_id
  name          = "apigee-support-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 28 ##Range reserved by Apigee instances
  network       = var.apigee_network
  address = var.apigee_support_range
}

##########################################################
### Create the peering service networking connection
##########################################################
resource "google_service_networking_connection" "apigee_vpc_connection" {
  provider                = google
  network                 = var.apigee_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_instance_range.name,google_compute_global_address.apigee_support_range.name]
  depends_on              = [google_project_service.gcp_services]
}

##########################################################
### Reserve the external IP address
##########################################################
resource "google_compute_global_address" "external_ip" {
  project      = var.service_project_id
  name         = "global-external-ip"
  address_type = "EXTERNAL"
}


locals {
  apigee_hostname = "${replace(google_compute_global_address.external_ip.address, ".", "-")}.nip.io"
  #apigee_hostname = ["api.example.com,www.example.com"]
}

/*
locals {
  apigee_hostname_dev= "api-dev.copel.com"
  apigee_hostname_hml= "api-hml.copel.com"
}
*/