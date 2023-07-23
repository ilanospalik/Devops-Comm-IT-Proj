resource "aws_api_gateway_rest_api" "App_API" {
  name = "App_API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name                   = "Authorization"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.App_API.id
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [aws_cognito_user_pool.user_pool.arn]
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.App_API.id
  resource_id   = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
}

# OPTIONS method for CORS
resource "aws_api_gateway_method" "options" {
  rest_api_id   = aws_api_gateway_rest_api.App_API.id
  resource_id   = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
  api_key_required = false
}

# Response for the OPTIONS method
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"   = true
    "method.response.header.Access-Control-Allow-Headers"  = true
    "method.response.header.Access-Control-Allow-Methods"  = true
  }

  response_models = {
    "application/json" = "Empty"  # Map the response model to "Empty" for JSON content type
  }
}

resource "aws_api_gateway_method_response" "get" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"   = true
  }

  response_models = {
    "application/json" = "Empty"  # Map the response model to "Empty" for JSON content type
  }
}

# Integration for the OPTIONS method
resource "aws_api_gateway_integration" "options" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  type = "MOCK"
    request_templates = {
    "application/json" = <<EOT
{
  "statusCode": 200
}
EOT
  }
}

# Integration response for the OPTIONS method
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method = aws_api_gateway_method.options.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
    depends_on = [
    aws_api_gateway_integration.options
  ]
}

resource "aws_api_gateway_integration" "get" {
  depends_on            = [aws_lambda_function.my_lambda_function]
  rest_api_id           = aws_api_gateway_rest_api.App_API.id
  resource_id           = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method           = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                  = "AWS_PROXY"
  uri                   = aws_lambda_function.my_lambda_function.invoke_arn
}

resource "aws_api_gateway_integration_response" "get" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id
  resource_id = aws_api_gateway_rest_api.App_API.root_resource_id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"

  depends_on = [
    aws_api_gateway_integration.get
  ]
  response_templates = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'" 
  }
}



resource "aws_lambda_permission" "get" {
  depends_on     = [aws_lambda_function.my_lambda_function]
  statement_id   = "AllowExecutionFromAPIGateway"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.my_lambda_function.arn
  principal      = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "get" {
  rest_api_id = aws_api_gateway_rest_api.App_API.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.get,
    aws_api_gateway_integration.options,
    aws_api_gateway_method.get,
    aws_api_gateway_method.options,
    aws_api_gateway_method_response.options,
    aws_api_gateway_integration_response.options,
    aws_lambda_permission.get,
  ]
}

resource "aws_api_gateway_stage" "get" {
  deployment_id = aws_api_gateway_deployment.get.id
  rest_api_id   = aws_api_gateway_rest_api.App_API.id
  stage_name    = "Dev"
}


resource "aws_lambda_permission" "api_gateway_cors_permission" {
  statement_id  = "AllowExecutionFromAPIGatewayForCORS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.App_API.execution_arn}/*/*/*"
}


