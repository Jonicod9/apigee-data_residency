##########################################################
### Create a VPC Network
##########################################################
resource "google_compute_network" "apigee_network" {
  provider                = google
  project                 = var.project_id
  name                    = var.apigee_network
  auto_create_subnetworks = false
  depends_on              = [google_project_service.gcp_services]
}


##########################################################
### Create a VPC Subnetwork for the PSC
##########################################################
resource "google_compute_subnetwork" "apigee_subnetwork" {
  project                  = var.project_id
  name                     = var.apigee_subnetwork
  region                   = var.instance_region
  network                  = google_compute_network.apigee_network.id
  ip_cidr_range            = "192.168.1.0/28" ##Subnet for PSC
  private_ip_google_access = true
  depends_on               = [google_project_service.gcp_services,
                              google_compute_network.apigee_network]
}