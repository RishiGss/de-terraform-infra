terraform {
    required_version = ">= 1.16.1"
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 7.39.0"
        }
    }

    backend "gcs" {
        bucket = "learning-dataeng-dev-tfstate-bucket"
        prefix = "envs/dev"
    }
}