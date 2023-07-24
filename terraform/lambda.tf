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
        "dynamodb:PutItem",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:DescribeParameters",
        "s3:GetObject",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionAcl",
        "s3:PutObjectVersionTagging"
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

resource "aws_s3_object" "object" {
  bucket = "commit-project-ilan-moshe"
  key    = "lambda_function.zip"
  source = "lambda_function.zip"
  depends_on = [aws_s3_bucket.commit_project]
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name    = "token-dynamodb-parameter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.10"
  timeout          = 10
  memory_size      = 128
  s3_bucket        = "commit-project-ilan-moshe"
  s3_key           = "lambda_function.zip"

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.commit_project.bucket
    }
  }

  layers = [
    aws_lambda_layer_version.jwt.arn,
  ]
  depends_on = [aws_s3_object.object, aws_lambda_layer_version.jwt]
}

resource "aws_lambda_layer_version" "jwt" {
  filename   = "python.zip"
  layer_name = "jwt"
  compatible_runtimes = ["python3.10", "python3.9", "python3.8", "python3.7"]
  compatible_architectures = ["x86_64", "arm64"]
}


