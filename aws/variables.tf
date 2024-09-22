variable "role_name" {
  type        = string
  default     = "sola-ro-integration"
  description = "IAM role name"
}

variable "role_external_id" {
  type        = string
  description = "IAM role external ID"
}

variable "sola_organization_id" {
  type        = string
  description = "Sola's AWS account ID"
}

variable "tags" {
  type        = map(any)
  default     = {}
  description = "Tags to apply to all created AWS resources"
}
