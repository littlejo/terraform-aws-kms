data "aws_caller_identity" "this" {}

data "aws_iam_session_context" "this" {
  arn = data.aws_caller_identity.this.arn
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root",
      data.aws_iam_session_context.this.issuer_arn]
    }
  }

  statement {
    sid       = "Enable Encryption for LogGroup"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Decrypt*",
      "kms:Describe*",
      "kms:Encrypt*",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = var.log_groups_arn
    }

    principals {
      type        = "Service"
      identifiers = ["logs.eu-west-3.amazonaws.com"]
    }
  }
}

resource "aws_kms_key" "this" {
  description         = "EKS Workers FluentBit CloudWatch Log group KMS Key"
  policy              = data.aws_iam_policy_document.this.json
  enable_key_rotation = true
}

resource "aws_kms_alias" "this" {
  name          = var.kms_alias
  target_key_id = aws_kms_key.this.key_id
}
