output "lambda_function_name" {
  value = aws_lambda_function.notification.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.notification.arn
}

output "api_gateway_endpoint" {
  value = aws_apigatewayv2_api.notification.api_endpoint
}

output "api_gateway_domain" {
  value = replace(aws_apigatewayv2_api.notification.api_endpoint, "https://", "")
}
