terraform {
    required_version = "~> 0.12.25"
    required_providers {
        google = "~> 3.23"
    }
    backend "gcs" {
        prefix="faashug-engine"
    }
}