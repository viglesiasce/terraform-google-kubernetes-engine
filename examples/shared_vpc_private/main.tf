/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  cluster_type = "shared-vpc-private"
}

provider "google" {
  version = "~> 2.9.0"
  region  = "${var.region}"
}

provider "google-beta" {
  version = "~> 2.9.0"
  region  = "${var.region}"
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork
  project = var.network_project_id
  region  = var.region
}

data "google_client_config" "default" {
}

module "gke" {
  source             = "../../modules/private-cluster/"
  project_id         = "${var.project_id}"
  name               = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region             = "${var.region}"
  regional           = true
  network            = "${var.network}"
  network_project_id = "${var.network_project_id}"
  subnetwork         = "${var.subnetwork}"
  ip_range_pods      = "${var.ip_range_pods}"
  ip_range_services  = "${var.ip_range_services}"
  service_account    = "${var.compute_engine_service_account}"
  enable_private_endpoint = true
  enable_private_nodes    = true
  master_ipv4_cidr_block  = "${var.master_ipv4_cidr_block}"
  master_authorized_networks_config = [
    {
      cidr_blocks = [
        {
          cidr_block   = "${var.master_authorized_network}"
          display_name = "VPC"
        },
      ]
    },
  ]
}
