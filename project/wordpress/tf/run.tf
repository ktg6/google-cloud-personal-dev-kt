resource "google_artifact_registry_repository" "ktg_repo" {
  location      = var.region
  repository_id = "ktg-repo"
  format        = "DOCKER"
  description   = "Docker repository"
}

resource "google_cloud_run_v2_service" "wp_ktg" {
  name     = "wp-ktg"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {

    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/ktg-wp/ktg-com"

        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.wp_db.connection_name
        }
        env {
          name  = "DB_USER"
          value = var.db_user
        }
        env {
          name  = "DB_PASSWORD"
          value = var.db_password
        }
        env {
          name  = "DB_NAME"
          value = var.db_name
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }

        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.wp_db.connection_name]
      }
    }
  }
  depends_on = [
    google_sql_database_instance.wp_db,
    google_artifact_registry_repository.ktg_repo
  ]
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}
