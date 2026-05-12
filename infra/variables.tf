variable "project_name" {
  description = "Logical project name used in resource tags."
  type        = string
  default     = "eks-workshop"
}

variable "environment" {
  description = "Environment tag value."
  type        = string
  default     = "lab"
}

variable "name_prefix" {
  description = "Prefix applied to named resources."
  type        = string
  default     = "sample-eks"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "sample-eks-cluster"
}

variable "node_group_name" {
  description = "Managed node group name."
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string
  default     = "eu-central-1"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS control plane."
  type        = string
  default     = "1.30"
}

variable "admin_cidr" {
  description = "Public CIDR allowed to access the EKS API endpoint, for example 198.51.100.24/32."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the dedicated VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Two public subnet CIDR blocks for the learning cluster."
  type        = list(string)
  default     = ["10.42.1.0/24", "10.42.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Provide at least two public subnet CIDRs."
  }
}

variable "private_subnet_cidrs" {
  description = "Two private subnet CIDR blocks for NAT-backed workloads such as VPC-attached CI/CD runners."
  type        = list(string)
  default     = ["10.42.11.0/24", "10.42.12.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "Provide at least two private subnet CIDRs."
  }
}

variable "node_instance_types" {
  description = "Instance types used by the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired node count."
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum node count."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum node count."
  type        = number
  default     = 1
}

variable "codebuild_security_group_ids" {
  description = "Security group IDs for VPC-attached CodeBuild projects that need private access to the EKS API."
  type        = list(string)
  default     = []
}

variable "ssh_key_name" {
  description = "Optional EC2 key pair name for SSH access to worker nodes."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
