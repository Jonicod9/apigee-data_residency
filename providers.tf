##########################################################
# Copyright 2024 Google LLC.
# This software is provided as-is, without warranty or
# representation for any use or purpose.
# Your use of it is subject to your agreement with Google.
#
# Sample Terraform script to set up Google provider 
##########################################################
terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = ">= 4.35.0"
    }
  }
}

provider "google-beta" {
  project = var.service_project_id
}

provider "google" {
  project = var.service_project_id
}