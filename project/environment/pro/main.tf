provider "google" {
  credentials = file("../../provider/gcp-credential.json")
  project     = var.project_id
  region      = var.region
}

module "pro" {
  source         = "../../resources"
  project_id     = var.project_id
  region         = var.region
  env            = "pro"
  env_location   = "pro-tokyo"
  env_production = true
}
