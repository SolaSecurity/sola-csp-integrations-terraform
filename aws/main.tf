data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  allowed_managed_policies = [
    "ReadOnlyAccess"
  ]
  denied_custom_policies = [
    "aws-portal:*",
    "billing:*",
    "ce:*",
    "chime:*",
    "consolidatedbilling:*",
    "cost-optimization-hub:*",
    "cur:*",
    "freetier:*",
    "invoicing:*",
    "payments:*",
    "tax:*"
  ]
  allowed_custom_policies = [
    "ecs:Get*",
    "kms:ListKeyRotations",
    "kms:DescribeKey",
    "kms:GetKeyPolicy",
    "kms:GetKeyRotationStatus",
    "kms:ListAliases",
    "kms:ListKeys",
    "kms:ListResourceTags",
    "quicksight:List*",
    "quicksight:Describe*",
    "resource-explorer-2:List*",
    "resource-explorer-2:Get*",
    "resource-explorer-2:Describe*",
  ]
}

resource "aws_iam_policy" "sola_policy_deny_list" {
  name        = "SolaPolicyDenyList"
  path        = "/"
  description = "Sola's IAM policy deny list"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : local.denied_custom_policies,
        "Effect" : "Deny",
        "Resource" : "*"
      },
    ]
  })
  tags = var.tags
}

resource "aws_iam_policy" "sola_policy_allow_list" {
  name        = "SolaPolicyAllowList"
  path        = "/"
  description = "Sola's IAM policy allow list"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : local.allowed_custom_policies,
        "Effect" : "Allow",
        "Resource" : "*"
      },
    ]
  })
  tags = var.tags
}

resource "random_string" "sola_access_role_postfix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "aws_iam_role" "sola_access_role" {
  name = "${var.role_name}-${random_string.sola_access_role_postfix.result}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.sola_organization_id}:root"
        },
        "Effect" : "Allow",
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : var.role_external_id
          }
        }
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "sola_policy_deny_list" {
  role       = aws_iam_role.sola_access_role.name
  policy_arn = aws_iam_policy.sola_policy_deny_list.arn
}

resource "aws_iam_role_policy_attachment" "sola_policy_allow_list" {
  role       = aws_iam_role.sola_access_role.name
  policy_arn = aws_iam_policy.sola_policy_allow_list.arn
}

resource "aws_iam_role_policy_attachment" "sola_allowed_policies" {
  for_each   = toset(local.allowed_managed_policies)
  role       = aws_iam_role.sola_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}
