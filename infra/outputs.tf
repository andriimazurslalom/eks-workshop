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

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  description = "EKS OIDC issuer URL."
  value       = module.eks.oidc_issuer_url
}

output "fluent_bit_role_arn" {
  description = "IAM role ARN for Fluent Bit IRSA."
  value       = aws_iam_role.fluent_bit.arn
}
