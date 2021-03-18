variable "name" {
  description = "The name for the artifact bucket."
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Mapping of tags for the artifact bucket."
}

variable "cors_rule_inputs" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = null
}

variable "allow_log_delivery_write" {
  description = "Defines if the LogDelivery group gets WRITE and READ_ACP permissions on the bucket. If not, the private canned ACL will be used."
  default     = false
  type        = bool
}

variable "block_all_public_access" {
  description = "Defines if to turn on all four settings for block public access. Otherwise, the all options will be turned off."
  default     = false
  type        = bool
}