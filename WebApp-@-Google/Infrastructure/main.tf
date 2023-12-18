# This code is compatible with Terraform 4.25.0 and versions that are backwards compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration

provider "google" {
  project = "duet-ai-401215"
  credentials = "${file("credentials.json")}"
  region = "us-east5"
  zone = "us-east5-a"
}

resource "google_compute_instance" "apachewebserver" {
  boot_disk {
    auto_delete = true
    device_name = "websever-disk"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20231212"
      size  = 10
      type  = "pd-standard"
    }
    mode = "READ_WRITE"
  }
  
  metadata_startup_script =  file("../Application/apache2.sh")

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-1-0"
  }

  machine_type = "e2-small"

  metadata = {
    enable-osconfig = "TRUE"
  }

  name = "apachewebserver"
  tags = ["http-server", "https-server"]
  zone = "us-east5-a"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    subnetwork = "projects/duet-ai-401215/regions/us-east5/subnetworks/default"
  }
  
  service_account {
    email  = "808662597607-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

}
  
resource "google_compute_firewall" "web" {
  name = "default-allow-http"
  network = "default"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "tcp"
    ports = ["80", "443"]
  }
}

