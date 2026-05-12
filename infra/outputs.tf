output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group associated with the EKS control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region used for the cluster."
  value       = var.aws_region
}

output "vpc_id" {
  description = "Dedicated VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnets used by the cluster."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnets available for NAT-backed VPC workloads."
  value       = module.network.private_subnet_ids
}
