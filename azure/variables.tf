variable "subscription_id" {
  type        = string
  description = "The subscription ID where the resources will be created."
}

variable "app_name" {
  type        = string
  default     = "sola-ro-integration"
  description = "Application subscription name"
}
