terraform {
  required_version = ">= 1.1.9"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.17"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.17"
    }
    github = {
      source  = "integrations/github"
      version = ">= 5.19.0"
    }
  }
}

provider "github" {
  owner = "ktg6"
  token = var.token
}

# resource "github_repository" "first_repo" {
#   name    = "first_repo"
#   private = true
# }
