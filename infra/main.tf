provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

module "network" {
  source = "./modules/network"

  name_prefix          = var.name_prefix
  cluster_name         = var.cluster_name
  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  azs                  = local.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.common_tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name                 = var.cluster_name
  kubernetes_version           = var.kubernetes_version
  admin_cidr                   = var.admin_cidr
  subnet_ids                   = module.network.public_subnet_ids
  vpc_id                       = module.network.vpc_id
  codebuild_security_group_ids = var.codebuild_security_group_ids
  node_group_name              = var.node_group_name
  node_instance_types          = var.node_instance_types
  desired_size                 = var.desired_size
  min_size                     = var.min_size
  max_size                     = var.max_size
  ssh_key_name                 = var.ssh_key_name
  tags                         = local.common_tags
}

locals {
  eks_oidc_issuer_hostpath = replace(module.eks.oidc_issuer_url, "https://", "")
}

data "aws_iam_policy_document" "fluent_bit_cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:*:log-group:/eks/${var.cluster_name}/*",
      "arn:aws:logs:${var.aws_region}:*:log-group:/eks/${var.cluster_name}/*:log-stream:*",
    ]
  }
}

resource "aws_iam_policy" "fluent_bit_cloudwatch" {
  name        = "${var.cluster_name}-fluent-bit-cloudwatch"
  description = "Allow Fluent Bit to write logs to CloudWatch Logs"
  policy      = data.aws_iam_policy_document.fluent_bit_cloudwatch.json
}

data "aws_iam_policy_document" "fluent_bit_irsa_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_issuer_hostpath}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:fluent-bit"]
    }
  }
}

resource "aws_iam_role" "fluent_bit" {
  name               = "${var.cluster_name}-fluent-bit-role"
  assume_role_policy = data.aws_iam_policy_document.fluent_bit_irsa_assume_role.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "fluent_bit_cloudwatch" {
  role       = aws_iam_role.fluent_bit.name
  policy_arn = aws_iam_policy.fluent_bit_cloudwatch.arn
}
