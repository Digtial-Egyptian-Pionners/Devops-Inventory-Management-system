data "archive_file" "placeholder" {
  type        = "zip"
  output_path = "${path.module}/placeholder.zip"

  source {
    content  = "Placeholder artifact replaced by CI/CD deployment."
    filename = "README.txt"
  }
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "notification_lambda" {
  name               = "${var.project_name}-${var.environment}-notif-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.notification_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "lambda_secrets" {
  statement {
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [var.rds_secret_arn]
  }
}

resource "aws_iam_role_policy" "lambda_secrets" {
  name   = "${var.project_name}-${var.environment}-notif-secrets"
  role   = aws_iam_role.notification_lambda.id
  policy = data.aws_iam_policy_document.lambda_secrets.json
}

resource "aws_lambda_function" "notification" {
  function_name    = "${var.project_name}-${var.environment}-notification-handler"
  role             = aws_iam_role.notification_lambda.arn
  runtime          = "java21"
  handler          = "com.apex.inventory.notification.handler.NotificationApiHandler::handleRequest"
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  memory_size      = 512
  timeout          = 30

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      NOTIFICATION_DB_URL        = "jdbc:postgresql://${var.db_address}:${var.db_port}/${var.db_name}"
      NOTIFICATION_DB_SCHEMA     = "notification"
      NOTIFICATION_DB_SECRET_ARN = var.rds_secret_arn
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-notification-handler"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_api" "notification" {
  name          = "${var.project_name}-${var.environment}-notification-api"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.project_name}-${var.environment}-notification-api"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "notification" {
  api_id                 = aws_apigatewayv2_api.notification.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.notification.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "notification_proxy" {
  api_id    = aws_apigatewayv2_api.notification.id
  route_key = "ANY /api/notifications/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.notification.id}"
}

resource "aws_apigatewayv2_route" "notification_root" {
  api_id    = aws_apigatewayv2_api.notification.id
  route_key = "ANY /api/notifications"
  target    = "integrations/${aws_apigatewayv2_integration.notification.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.notification.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.notification.execution_arn}/*/*"
}
