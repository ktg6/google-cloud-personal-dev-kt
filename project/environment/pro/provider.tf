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
            version = "~> 5.0"
        }
    }
}

provider "google" {
    credentials = file("account-learngcp.json")
    project = "learngcp-335008"
    region  = "asia-northeast1"
    zone    = "asia-northeast1-a"
}

# module "pro" {
#   source         = "../../resources"
#   region         = "asia-northeast1"
#   project_id     = "learngcp-335008"
#   env            = "pro"
#   env_location   = "pro-tokyo"
#   env_production = true
# }

provider "github" {
  owner = "ktg6"
  token = "****"
}

resource "github_repository" "first_repo" {
    name = "first_repo"
    private = false
}
