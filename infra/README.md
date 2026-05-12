# Minimal Modular EKS Terraform

This project creates a dedicated AWS VPC and deploys a minimal Amazon EKS cluster into it.

For cost control and learning simplicity, the worker node group runs in public subnets. The Kubernetes API keeps public access enabled but restricted to a single trusted CIDR such as your public IP `/32`, while worker nodes use the private EKS endpoint inside the VPC. The recommended default worker size for this lab is `t3.medium` because it is materially more reliable than `t3.small` for EKS bootstrap.

## What this creates

- A dedicated VPC with two public subnets across two Availability Zones
- Internet gateway and public routing
- An EKS control plane with endpoint access restricted to `admin_cidr`
- One managed node group with a single on-demand node
- IAM roles for the EKS control plane and worker nodes

## Why no NAT gateway

NAT gateways add ongoing hourly cost. For a learning cluster, this configuration avoids NAT by placing the node group in public subnets. That is cheaper, but less production-like.

If you later want a more realistic setup, add private subnets and a NAT gateway or VPC endpoints.

## Prerequisites

- Terraform `>= 1.6`
- AWS credentials configured in your shell or environment
- An existing EC2 key pair if you set `ssh_key_name`

## Usage

1. Copy the example variables:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Update `terraform.tfvars`:

- Set `aws_region`
- Set `admin_cidr` to your public IP in CIDR form, for example `198.51.100.24/32`

3. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

4. Update kubeconfig:

```bash
aws eks update-kubeconfig --region <aws_region> --name <cluster_name>
```

You can get the cluster name from Terraform output:

```bash
terraform output cluster_name
```

## Layout

```text
.
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── terraform.tfvars.example
└── modules
    ├── network
    └── eks
```

## Notes

- I interpreted your request for a separate "VPN" as a separate AWS `VPC`.
- API access is locked to `admin_cidr`, so if your public IP changes you must update Terraform and re-apply.
- Destroy the cluster when done to avoid charges:

```bash
terraform destroy
```
