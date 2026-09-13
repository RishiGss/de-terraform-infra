terraform {
  required_version = ">= 1.16.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.39.0"
    }
  }

  backend "gcs" {
    # The backend is initialized before Terraform evaluates variables, resources, locals, etc.
    # Terraform needs to know where the state is stored before it can even load the state and start evaluating the configuration.
    bucket = "learning-dataeng-dev-tfstate-bucket"
    prefix = "envs/dev"
  }
}