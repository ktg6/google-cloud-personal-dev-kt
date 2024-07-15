resource "google_artifact_registry_repository" "ktg_repo" {
  location      = var.region
  repository_id = "ktg-repo"
  format        = "DOCKER"
  description   = "Docker repository"
}

resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_secret_manager_secret" "wp_password" {
  secret_id = "wp-db-pass"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "wp_password" {
  secret      = google_secret_manager_secret.wp_password.name
  secret_data = var.db_password
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_service_account" "run_service_account" {
  account_id   = "run-sa"
  display_name = "Cloud Run Service Account"
}

resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.run_service_account.email}"
}

resource "google_secret_manager_secret_iam_member" "secret-access" {
  secret_id = google_secret_manager_secret.wp_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.run_service_account.email}"
  depends_on = [google_secret_manager_secret.wp_password]
}

resource "google_cloud_run_v2_service" "wp_ktg" {
  name     = "wp-ktg"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.run_service_account.email

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = "default"
        subnetwork = "default"
      }
    }

    scaling {
      max_instance_count = 1
      min_instance_count = 0
    }

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/ktg-repo/ktg-com"
      name  = "ktg-com-1"

      ports {
        container_port = 80
      }

      env {
        name  = "DB_HOST"
        value = "34.81.90.214"
      }

      env {
        name  = "DB_USER"
        value = var.db_user
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.wp_password.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "DB_NAME"
        value = var.db_name
      }

      resources {
        cpu_idle = true
        limits = {
          cpu    = "1000m"
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

  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      client,
      etag,
      generation,
      last_modifier,
      latest_created_revision,
      latest_ready_revision,
      observed_generation,
      terminal_condition,
      update_time,
      template[0].containers
    ]
  }

  depends_on = [
    google_sql_database_instance.wp_db,
    google_artifact_registry_repository.ktg_repo,
    google_project_service.secretmanager
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role    = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_v2_service.wp_ktg.location
  project  = google_cloud_run_v2_service.wp_ktg.project
  service  = google_cloud_run_v2_service.wp_ktg.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}
