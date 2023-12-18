variable "naming_prefix" {
  type = string
}

variable "vpc_cidr_block" {
  type        = string
  description = "Base CIDR Block for VPC"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID from network module"
}