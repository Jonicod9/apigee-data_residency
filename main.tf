provider "google-beta" {
  apigee_custom_endpoint = "https://eu-apigee.googleapis.com/v1/"
}


resource "google_compute_network" "apigee_network" {
  provider = google-beta

  name       = "apigee-network"
  project    = "ep-latam-finops"
  #depends_on = [google_project_service.compute]
}

resource "google_compute_global_address" "apigee_range" {
  provider = google-beta

  name          = "apigee-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.apigee_network.id
  project       = "ep-latam-finops"
}

resource "google_service_networking_connection" "apigee_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.apigee_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.apigee_range.name]
 # depends_on              = [google_project_service.servicenetworking]
}

resource "google_kms_key_ring" "apigee_keyring" {
  provider = google-beta

  name       = "apigee-keyring"
  location   = "europe-central2"
  project    = "ep-latam-finops"
  #depends_on = [google_project_service.kms]
}

resource "google_kms_crypto_key" "apigee_key" {
  provider = google-beta

  name            = "apigee-key"
  key_ring        = google_kms_key_ring.apigee_keyring.id
}

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta

  project = "ep-latam-finops"
  service = "apigee.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "apigee_sa_keyuser" {
  provider = google-beta

  crypto_key_id = google_kms_crypto_key.apigee_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  member = google_project_service_identity.apigee_sa.member
}

resource "google_apigee_organization" "apigee_org" {
  provider = google-beta

  api_consumer_data_location            = "europe-central2"
  project_id                            = "ep-latam-finops"
  authorized_network                    = google_compute_network.apigee_network.id
  billing_type                          = "PAYG"
  runtime_database_encryption_key_name  = google_kms_crypto_key.apigee_key.id
  api_consumer_data_encryption_key_name = google_kms_crypto_key.apigee_key.id
  retention                             = "MINIMUM"

  depends_on = [
    google_service_networking_connection.apigee_vpc_connection,
    #google_project_service.apigee,
    google_kms_crypto_key_iam_member.apigee_sa_keyuser,
  ]
}
