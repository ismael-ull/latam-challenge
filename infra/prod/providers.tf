##############################################################################################
#                                           DATA                                             #
##############################################################################################


##############################################################################################
#                                         VARIABLES                                          #
##############################################################################################

variable "project" {}
variable "region" {}
variable "zone" {}
variable "key" {}


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
   prefix  = "production"
 }
}

provider "google" {
    project = var.project
    region = var.region
    credentials = var.key
    }


provider "tls" {
}