variable "aws_my_access_key" {}
variable "aws_my_secret_key" {}

provider "aws" {
        region = "eu-west-1"
        access_key = "${var.aws_my_access_key}"
        secret_key = "${var.aws_my_secret_key}"
}

provider "google" {
  credentials = "${file("creds/gcp_key.json")}"
  project     = "rebrain"
  region      = "us-central1"
  zone = "us-central1-c"
}

data "aws_route53_zone" "rebrain" {
        name = "devops.rebrain.srwx.net."
}

resource "google_compute_instance" "las_vm_instance" {
  name         = "las-tf-inst"
  machine_type = "f1-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "las:${file("~/.ssh/id_rsa.pub")}"
 }
}

resource "aws_route53_record" "aws_instance" {
        zone_id = data.aws_route53_zone.rebrain.zone_id
        name = "las-gcp-inst.devops.rebrain.srwx.net"
        type = "A"
        ttl = "300"
        records = [google_compute_instance.las_vm_instance.network_interface[0].access_config[0].nat_ip]
}

