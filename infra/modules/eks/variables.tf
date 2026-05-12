variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
}

variable "admin_cidr" {
  description = "CIDR allowed to access the public EKS API endpoint."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs used by EKS."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for cluster resources."
  type        = string
}

variable "codebuild_security_group_ids" {
  description = "Security group IDs for VPC-attached CodeBuild projects that need private access to the EKS API."
  type        = list(string)
  default     = []
}

variable "node_group_name" {
  description = "Managed node group name."
  type        = string
}

variable "node_instance_types" {
  description = "Node instance types."
  type        = list(string)
}

variable "desired_size" {
  description = "Desired node count."
  type        = number
}

variable "min_size" {
  description = "Minimum node count."
  type        = number
}

variable "max_size" {
  description = "Maximum node count."
  type        = number
}

variable "ssh_key_name" {
  description = "Optional EC2 key pair name for worker node SSH."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
