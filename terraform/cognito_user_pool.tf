resource "aws_cognito_user_pool" "user_pool" {
  name                     = "user-pool"
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 6
    require_lowercase                = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 30
  }

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_subject         = "Account Confirmation"
    email_message_by_link = "For confirmation {##Click Here##}"
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "commit-project"
  user_pool_id                         = aws_cognito_user_pool.user_pool.id
  callback_urls                        = ["https://example.com/callback.html"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_scopes                 = ["email", "openid", "phone", "aws.cognito.signin.user.admin", "profile"]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  generate_secret                      = false
  refresh_token_validity               = 90
  prevent_user_existence_errors        = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = "commit-project1"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}
