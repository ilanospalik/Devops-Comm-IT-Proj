resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
##NEED TO GIVE LESS RESOURCE
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "s3:GetObject",
        "dynamodb:PutItem",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:DescribeParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name    = "token-dynamodb-parameter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 10
  memory_size      = 128
  # Uncomment the following two lines and provide the appropriate values
  # s3_bucket        = "moshedabush-devops"
  s3_bucket        = "commit-project-ilan-and-moshe"
  s3_key           = "lambda_function.zip"

  layers = [
    "arn:aws:lambda:eu-central-1:164980749225:layer:jwt:2"
    # "arn:aws:lambda:eu-west-1:169244118978:layer:jwt:3"
  ]
}



