variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "service_name" {
  type    = string
  default = "devops-starter-kit"
}

variable "image" {
  type        = string
  description = "Container image, e.g. ghcr.io/OWNER/devops-starter-kit:SHA"
}

variable "app_version" {
  type    = string
  default = "dev"
}

variable "database_url" {
  type        = string
  description = "SQLAlchemy URL (use RDS Postgres in production; move to Secrets Manager for real secrets)"
  default     = "sqlite:////tmp/app.db"
  sensitive   = true
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
