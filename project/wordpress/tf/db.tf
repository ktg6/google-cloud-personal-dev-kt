resource "google_sql_database_instance" "wp_db" {
  name             = "wp-db"
  database_version = "MYSQL_8_0"
  region           = var.region

  settings {
    tier = "db-f1-micro"
  }

  lifecycle {
    ignore_changes = [
      settings[0].version
    ]
  }

  deletion_protection = false
}

resource "google_sql_database" "default" {
  name     = "ktgcom_wp1"
  instance = google_sql_database_instance.wp_db.name
}

resource "google_sql_user" "root" {
  name     = "root"
  instance = google_sql_database_instance.wp_db.name
  password = var.db_password
}

resource "google_sql_user" "wp_user" {
  name     = var.db_user
  instance = google_sql_database_instance.wp_db.name
  password = var.db_password
}

resource "google_storage_bucket" "wordpress_media" {
  name          = "${var.project_id}-wordpress-media"
  location      = var.region
  force_destroy = true
}
