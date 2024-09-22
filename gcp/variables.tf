variable "project_id" {
  type        = string
  description = "The ID of the project to connect."
}

variable "service_account_name" {
  type        = string
  default     = "sola-ro-integration"
  description = "Service account name"
}
