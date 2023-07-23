resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "identity pool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.user_pool.endpoint
    server_side_token_check = true
  }
}

resource "aws_iam_role" "authenticated" {
  name               = "${local.name_prefix}AuthenticatedAssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_authenticated_role.json
}

resource "aws_iam_role" "unauthenticated" {
  name               = "${local.name_prefix1}UnauthenticatedAssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_unauthenticated_role.json
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.main.id
  roles = {
    "authenticated"   = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}

data "aws_iam_policy_document" "assume_unauthenticated_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    sid     = ""
    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = [aws_cognito_identity_pool.main.id]
      variable = "cognito-identity.amazonaws.com:aud"
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["unauthenticated"]
      variable = "cognito-identity.amazonaws.com:amr"
    }
  }
}

data "aws_iam_policy_document" "assume_authenticated_role" {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    sid     = ""
    principals {
      identifiers = ["cognito-identity.amazonaws.com"]
      type        = "Federated"
    }
    condition {
      test     = "StringEquals"
      values   = [aws_cognito_identity_pool.main.id]
      variable = "cognito-identity.amazonaws.com:aud"
    }
    condition {
      test     = "ForAnyValue:StringEquals"
      values   = ["authenticated"]
      variable = "cognito-identity.amazonaws.com:amr"
    }
  }
}




