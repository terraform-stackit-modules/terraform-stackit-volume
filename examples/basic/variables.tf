variable "project_id" {
  description = "The STACKIT project ID."
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the volumes."
  type        = string
  default     = "eu01-1"
}

variable "image_id" {
  description = "The image ID used for the image-sourced volume. Defaults to a known-valid Ubuntu image in eu01."
  type        = string
  default     = "012d2f5b-ee00-4700-9bea-cdabf0e1bfa8"
}
