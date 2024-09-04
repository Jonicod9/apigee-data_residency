##########################################################
### Create the Apigee Organization
##########################################################

resource "google_apigee_organization" "apigee_org" {
  provider = google-beta

  api_consumer_data_location            = var.api_consumer_data_location
  project_id                            = var.project_id
  authorized_network                    = google_compute_network.apigee_network.id
  billing_type                          = "PAYG"
  runtime_database_encryption_key_name  = google_kms_crypto_key.apigee_key.id
  api_consumer_data_encryption_key_name = google_kms_crypto_key.apigee_key.id
  retention                             = "MINIMUM"

  depends_on = [
    google_service_networking_connection.apigee_vpc_connection,
    google_kms_crypto_key_iam_member.apigee_sa_keyuser,
  ]
   lifecycle {
    prevent_destroy = false
  }
}

##########################################################
### Create the Apigee Instance
##########################################################

resource "google_apigee_instance" "apigee_instance" {
  name                     = "instance-1"
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

resource "google_apigee_envgroup_attachment" "envdev1_to_envgroup_attachment" {
  envgroup_id = google_apigee_envgroup.apigee_environment_group_dev.id
  environment = google_apigee_environment.apigee_environment_dev_01.name
}

