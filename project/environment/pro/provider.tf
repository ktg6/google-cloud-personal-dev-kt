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
    }
}

provider "google" {
    credentials = file("account-learngcp.json")
    project = "learngcp-335008"
    region  = "asia-northeast1"
    zone    = "asia-northeast1-a"
}
