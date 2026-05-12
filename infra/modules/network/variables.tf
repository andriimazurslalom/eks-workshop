variable "name_prefix" {
  description = "Prefix applied to network resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for subnet tagging."
  type        = string
}

variable "aws_region" {
  description = "AWS region used for regional service endpoints."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability Zones used for public subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
