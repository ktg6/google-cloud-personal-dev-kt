provider "google" {
  credentials = file("gcp-credential.json")
  project     = var.project_id
  region      = var.region
  zone        = "asia-northeast1-a"
}
