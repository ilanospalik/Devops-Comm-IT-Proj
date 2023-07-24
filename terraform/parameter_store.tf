variable "parameters" {
  description = "List of parameters to create in AWS Parameter Store"
  type        = list(string)
  default     = ["Hello", "Hey", "Hi"]  # my parameter names
}

resource "aws_ssm_parameter" "project_parameter" {
  count = length(var.parameters)
  name  = var.parameters[count.index]
  type  = "String"
  value = var.parameters[count.index]  # value for each parameter
}