data "aws_caller_identity" "current" {}

# thumbprint_list intentionally omitted: AWS validates GitHub's OIDC provider
# certificate against its own trusted root CAs regardless of what's
# configured here, and the provider argument has been optional since the
# AWS SDK/Terraform AWS provider update that shipped this — see
# https://github.blog/changelog/2023-06-27-github-actions-update-on-oidc-integration-with-aws/
resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = [var.audience]
  # thumbprint_list intentionally omitted — see comment above.

  tags = var.tags
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : var.oidc_provider_arn
}

data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = [var.audience]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for env in var.github_environments :
        "repo:${var.github_org}/${var.github_repo}:environment:${env}"
      ]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.trust.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(var.managed_policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

data "aws_iam_policy_document" "scoped_iam" {
  count = var.enable_scoped_iam_actions ? 1 : 0

  statement {
    sid    = "ManageScopedIamRolesAndPolicies"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:UpdateRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_resource_prefix}*",
    ]
  }

  statement {
    sid       = "CreateServiceLinkedRoles"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
  }

  statement {
    sid       = "PassRoleToKnownServices"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.iam_resource_prefix}*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = var.pass_role_service_principals
    }
  }
}

resource "aws_iam_role_policy" "scoped_iam" {
  count = var.enable_scoped_iam_actions ? 1 : 0

  name   = "${var.name}-scoped-iam"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.scoped_iam[0].json
}
