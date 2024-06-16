provider "google" {
  credentials = file("../../provider/gcp-credential.json")
  project     = var.project_id
  region      = var.region
}

resource "google_sql_database_instance" "wp_db" {
  name             = "wp-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection  = "true"
}

resource "google_sql_database" "default" {
  name     = "wordpress"
  instance = google_sql_database_instance.wp_db.name
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.wp_db.name
  password = var.db_password
}

resource "google_storage_bucket" "wp_media" {
  name          = "${var.project_id}-wp-media"
  location      = var.region
  force_destroy = true
}
