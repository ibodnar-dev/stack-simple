variable "postgres_host" {
  description = "PostgreSQL database host"
  type        = string
  default     = "db"
}

variable "postgres_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "app"
}

variable "postgres_user" {
  description = "PostgreSQL database user"
  type        = string
  default     = "app"
}

variable "postgres_password" {
  description = "PostgreSQL database password"
  type        = string
  default     = "app"
  sensitive   = true
}
