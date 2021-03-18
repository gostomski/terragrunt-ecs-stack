variable "ecs_service_name" {
  type        = string
  description = "Backend service name, will be a part of names for ECR repository."
}

variable "repo_name" {
  type        = string
  description = "A name for ECR repository."
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "The tag mutability setting for the repository"
  validation {
    condition     = can(index(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability))
    error_message = "The image_tag_mutability value must be a valid tag mutability setting (MUTABLE or IMMUTABLE)."
  }
}

variable "scan_image_on_push" {
  type        = bool
  default     = false
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)"
}

variable "create_lifecycle_policy" {
  type        = bool
  default     = false
  description = "Whether to create a lifecycle policy"
}

variable "number_of_images_to_keep_in_repo" {
  type        = number
  default     = 4
  description = "How many images to keep in repository"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Mapping of tags for ECR repository"
}