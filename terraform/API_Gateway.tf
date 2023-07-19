# resource "aws_api_gateway_rest_api" "App_API" {
#   body = jsonencode({
#     openapi = "3.0.1"
#     info = {
#       title   = "App_API"
#       version = "1.0"
#     }
#     paths = {
#       "/project" = {
#         get = {
#           x-amazon-apigateway-integration = {
#             httpMethod           = "GET"
#             payloadFormatVersion = "1.0"
#             type                 = "LAMBDA"
#             LambdaRegion         = "eu-north-1"
#             LambdaFunction       = "from_parameter_store"
#           }
#         }
#       }
#     }
#   })

#   name = "App_API"

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

# resource "aws_api_gateway_deployment" "example" {
#   rest_api_id = aws_api_gateway_rest_api.App_API.id

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_api_gateway_stage" "example" {
#   deployment_id = aws_api_gateway_deployment.example.id
#   rest_api_id   = aws_api_gateway_rest_api.App_API.id
#   stage_name    = "Dev"
# }