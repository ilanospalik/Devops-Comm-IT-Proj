resource "aws_api_gateway_rest_api" "App_API" {
  name = "App_API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "example" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  parent_id   = aws_api_gateway_rest_api.App_API.root_resource_id
  path_part   = "project"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                   = "cognito_authorizer"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.App_API.id
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [aws_cognito_user_pool.user_pool.arn]
}

resource "aws_api_gateway_method" "example" {
  rest_api_id   = aws_api_gateway_rest_api.App_API.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# OPTIONS method for CORS
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.App_API.id
  resource_id   = aws_api_gateway_resource.example.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Response for the OPTIONS method
resource "aws_api_gateway_method_response" "Satus_200" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"   = true
    "method.response.header.Access-Control-Allow-Headers"  = true
    "method.response.header.Access-Control-Allow-Methods"  = true
  }
}

# Integration for the OPTIONS method
resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.options.http_method

  type = "MOCK"
}

# Integration response for the OPTIONS method
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"   = "'*'"
    "method.response.header.Access-Control-Allow-Headers"  = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Requested-With'"
    "method.response.header.Access-Control-Allow-Methods"  = "'GET,OPTIONS,POST,PUT'"
  }
  depends_on = [aws_api_gateway_integration.options]
}

data "aws_lambda_function" "example" {
  function_name = "Hello_Lambda"
}

resource "aws_api_gateway_integration" "example" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_resource.example.id
  http_method = aws_api_gateway_method.example.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.example.invoke_arn
}

resource "aws_lambda_permission" "example" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.example.arn
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.example,
    aws_api_gateway_integration.options
  ]
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.App_API.id
  stage_name    = "Dev"
}
