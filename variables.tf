##########################################################
# Copyright 2024 Google LLC.
# This software is provided as-is, without warranty or
# representation for any use or purpose.
# Your use of it is subject to your agreement with Google.
#
# Sample Terraform script to set up required variables 
##########################################################

variable "project_id" {
  type = string
  description = "Apigee dedicated Project ID"
}

variable "apigee_services_list" {
    type = list(string)
    description = "Required Services for Apigee X"
}


variable "api_consumer_data_location" {
  type    = string
  description = "The consumer data location region"
}

variable "instance_region" {
  type    = string
  description = "The Apigee Instance region"
}

variable "apigee_keyring_location" {
  type    = string
  description = "The Apigee keyring location"
}


variable "apigee_environment_group_dev" {
  type    = string
  description = "The Apigee Environment dev group name"
}

variable "apigee_environment_dev_01" {
  type    = string
  description = "The Apigee Environment dev01 name"
}

variable "apigee_network" {
  type    = string
  description = "VPC Network name"
}

variable "apigee_subnetwork" {
  type    = string
  description = "VPC Subnetwork name"
}

variable "xlb_name" {
  description = "External LB name"
  type        = string
}

variable "instance_ip_range" {
  description = "ip range  /22 for Apigee Instance"
  type        = string
}

variable "apigee_instance_range" {
  description = "ip address from /22 range for Apigee Instance, do not add /22"
  type        = string
}

variable "apigee_support_range" {
  description = "ip address from /28 range for Apigee troubleshooting/support Instance, do not add /28"
  type        = string
}




