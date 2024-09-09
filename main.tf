
##########################################################
### Enable the required GCP APIs
##########################################################

resource "google_project_service" "gcp_services" {
  for_each = toset(var.apigee_services_list)
  project = var.project_id
  service = each.key
  disable_on_destroy = false
}

##########################################################
### Reserve the peering ip range for Apigee
##########################################################

resource "google_compute_global_address" "apigee_range" {
  provider = google-beta

  name          = "apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 22
  network       = google_compute_network.apigee_network.id
  project       = var.project_id
  address       = var.apigee_instance_range
}

resource "google_compute_global_address" "apigee_support_range" {
  project       = var.project_id
  name          = "apigee-support-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 28 ##Range reserved by Apigee instances
  network       = google_compute_network.apigee_network.id
  address       = var.apigee_support_range
}

##########################################################
### Create the peering service networking connection
##########################################################

resource "google_service_networking_connection" "apigee_vpc_connection" {
  
  provider                = google-beta
  network                 = google_compute_network.apigee_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name,google_compute_global_address.apigee_support_range.name]
  depends_on              = [google_project_service.gcp_services]
 
}

##########################################################
### Reserve the external IP address
##########################################################
resource "google_compute_global_address" "external_ip" {
  project      = var.project_id
  name         = "global-external-ip"
  address_type = "EXTERNAL"
}

locals {
  apigee_hostname = "${replace(google_compute_global_address.external_ip.address, ".", "-")}.nip.io"
  
}

##########################################################
### Create Apigee Keyring
##########################################################

resource "google_kms_key_ring" "apigee_keyring" {
  provider = google-beta

  name       = "apigee-keyring"
  location   = var.apigee_keyring_location
  project    = var.project_id
  
}

resource "google_kms_crypto_key" "apigee_key" {
  provider = google-beta

  name            = "apigee-key"
  key_ring        = google_kms_key_ring.apigee_keyring.id
}

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta

  project = var.project_id
  service = "apigee.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "apigee_sa_keyuser" {
  provider = google-beta

  crypto_key_id = google_kms_crypto_key.apigee_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  member = google_project_service_identity.apigee_sa.member
}

