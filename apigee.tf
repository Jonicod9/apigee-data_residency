##########################################################
# Copyright 2023 Google LLC.
# This software is provided as-is, without warranty or
# representation for any use or purpose.
# Your use of it is subject to your agreement with Google.
#
# Sample Terraform script to set up an Apigee X Organization 



############################
resource "google_apigee_organization" "apigee_org" {
  analytics_region                     = var.analytics_region
  display_name                         = "apigee-org"
  retention                            = "MINIMUM"
  billing_type                         = "PAYG"
  description                          = "Terraform-provisioned Apigee Org."
  project_id                           = var.service_project_id
  authorized_network                   = var.apigee_network
  api_consumer_data_location           = "US"
  runtime_database_encryption_key_name = google_kms_crypto_key.apigee_key.id

  depends_on = [
    google_service_networking_connection.apigee_vpc_connection,
    google_kms_crypto_key_iam_member.apigee_sa_keyuser,
  ]
  lifecycle {
    prevent_destroy = false
  }
}


################################

resource "google_kms_key_ring" "apigee_keyring" {
  name     = "apigee-keyring1"
  location = "us-central1"
}

resource "google_kms_crypto_key" "apigee_key" {
  name            = "apigee-key1"
  key_ring        = google_kms_key_ring.apigee_keyring.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_service_identity" "apigee_sa" {
  provider = google-beta
  project  = var.service_project_id
  service  = "apigee.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "apigee_sa_keyuser" {
  crypto_key_id = google_kms_crypto_key.apigee_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  member = google_project_service_identity.apigee_sa.member
}
##########################################################
### Create the Apigee Instance
##########################################################
resource "google_apigee_instance" "apigee_instance" {
  name                     = "instance-11"
  location                 = var.instance_region
  description              = "Terraform-provisioned Apigee Runtime Instance"
  org_id                   = google_apigee_organization.apigee_org.id
  ip_range                = var.instance_ip_range
}

##########################################################
### Create the Apigee Environment
##########################################################
resource "google_apigee_environment" "apigee_environment_dev_01" {
  org_id = google_apigee_organization.apigee_org.id
  name   = var.apigee_environment_dev_01
}


##########################################################
### Attach the Apigee Environment to the Instance
##########################################################
resource "google_apigee_instance_attachment" "envdev1_to_instance_attachment" {
  instance_id = google_apigee_instance.apigee_instance.id
  environment = google_apigee_environment.apigee_environment_dev_01.name
}

##########################################################
### Create the Apigee Environment Group
##########################################################
resource "google_apigee_envgroup" "apigee_environment_group_dev" {
  org_id    = google_apigee_organization.apigee_org.id
  name      = var.apigee_environment_group_dev
  hostnames = [local.apigee_hostname] ##Your Environment Group hostname
}


##########################################################
### Attach the Apigee Environment to the Environment Group
##########################################################
resource "google_apigee_envgroup_attachment" "envdev1_to_envgroup_attachment" {
  envgroup_id = google_apigee_envgroup.apigee_environment_group_dev.id
  environment = google_apigee_environment.apigee_environment_dev_01.name
}

