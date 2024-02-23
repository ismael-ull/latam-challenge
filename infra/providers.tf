##############################################################################################
#                                           DATA                                             #
##############################################################################################


##############################################################################################
#                                         VARIABLES                                          #
##############################################################################################

variable "project" {}
variable "region" {}
variable "zone" {}
variable "tf-sa" {}
variable "prefix" {}


##############################################################################################
#                                    MODULES AND RESOURCES                                   #
##############################################################################################

terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
  backend "gcs" {
   bucket  = "lc-tf-states"
   prefix  = var.prefix
 }
}

provider "google" {
    project = var.project
    region = var.region
    impersonate_service_account_email = var.tf-sa
    }


provider "tls" {
}