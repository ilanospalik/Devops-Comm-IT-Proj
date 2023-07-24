variable "cognito_user_pool_id" {
  default = "eu-west-2_LyS14WwyJ"
}

variable "cognito_user_pool_client_id" {
  default = "4b50kvgh8qlv479ntpnosteuhi"
}

variable "cognito_identity_pool_id" {
  default = "eu-west-2:6ee1d930-26de-492a-aac2-d91eb70be0cb"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "App_Users"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [
            "AWS/Cognito",
            "SignUpSuccesses",
            "UserPool",
            "${var.cognito_user_pool_id}",
            "UserPoolClient",
            "${var.cognito_user_pool_client_id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ],
          [
            "AWS/Cognito",
            "SignUpThrottles",
            "UserPool",
            "${var.cognito_user_pool_id}",
            "UserPoolClient",
            "${var.cognito_user_pool_client_id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ],
          [
            "AWS/Cognito",
            "SignInSuccesses",
            "UserPool",
            "${var.cognito_user_pool_id}",
            "UserPoolClient",
            "${var.cognito_user_pool_client_id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ],
          [
            "AWS/Cognito",
            "SignInThrottles",
            "UserPool",
            "${var.cognito_user_pool_id}",
            "UserPoolClient",
            "${var.cognito_user_pool_client_id}",
            {
              "stat": "Sum",
              "region": "eu-west-2",
              "period": 300
            }
          ]
        ],
        "view": "timeSeries",
        "stacked": false,
        "region": "eu-west-2",
        "title": "Cognito Metrics"
      }
    }
  ]
}
EOF
}
