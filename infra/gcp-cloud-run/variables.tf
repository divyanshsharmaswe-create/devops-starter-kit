variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type    = string
  default = "asia-south1"
}

variable "service_name" {
  type    = string
  default = "devops-starter-kit"
}

variable "image" {
  type        = string
  description = "Container image, e.g. us-docker.pkg.dev/PROJECT/REPO/api:SHA (Cloud Run pulls from Artifact Registry)"
}

variable "app_version" {
  type    = string
  default = "dev"
}

variable "database_url" {
  type        = string
  description = "SQLAlchemy URL. Use Cloud SQL or a managed Postgres in production; SQLite is ephemeral on Cloud Run."
  default     = "sqlite:////tmp/app.db"
  sensitive   = true
}

variable "max_instances" {
  type    = number
  default = 3
}

variable "allow_public" {
  type    = bool
  default = true
}
