# variable "aws_access_key" {}

# variable "aws_secret_key" {}

variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "ua92-wp"
}