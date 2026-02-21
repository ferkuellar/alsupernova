locals {
  name = var.project
}

# -------------------------
# DynamoDB (On-demand)
# -------------------------
resource "aws_dynamodb_table" "cart" {
  name         = "${local.name}-Cart"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "cartId"

  attribute {
    name = "userId"
    type = "S"
  }
  attribute {
    name = "cartId"
    type = "S"
  }

  tags = {
    Project     = local.name
    Environment = "dev"
    Owner       = "Fernando"
    CostCenter  = "Portfolio"
  }
}

resource "aws_dynamodb_table" "orders" {
  name         = "${local.name}-Orders"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "orderId"

  attribute {
    name = "orderId"
    type = "S"
  }

  tags = {
    Project     = local.name
    Environment = "dev"
    Owner       = "Fernando"
    CostCenter  = "Portfolio"
  }
}

# -------------------------
# IAM role for Lambdas
# -------------------------
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${local.name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Basic CloudWatch logs
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# DynamoDB access (least-ish privilege for MVP)
# data "aws_iam_policy_document" "ddb_policy" {
#  statement {
#    actions = [
#      "dynamodb:PutItem",
#      "dynamodb:GetItem",
#      "dynamodb:UpdateItem",
#      "dynamodb:DeleteItem",
#      "dynamodb:Query",
#      "dynamodb:Scan"
#    ]
#    resources = [
#      aws_dynamodb_table.cart.arn,
#      aws_dynamodb_table.orders.arn
#    ]
#  }
# }

#resource "aws_iam_policy" "ddb_policy" {
#  name   = "${local.name}-ddb-policy"
#  policy = data.aws_iam_policy_document.ddb_policy.json
#}

#resource "aws_iam_role_policy_attachment" "ddb_attach" {
#  role       = aws_iam_role.lambda_role.name
#  policy_arn = aws_iam_policy.ddb_policy.arn
#}

# Cart Lambda -> only Cart table
data "aws_iam_policy_document" "cart_ddb_policy_doc" {
  statement {
    actions = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.cart.arn]
  }
}

resource "aws_iam_policy" "cart_ddb_policy" {
  name   = "${local.name}-cart-ddb-policy"
  policy = data.aws_iam_policy_document.cart_ddb_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "cart_ddb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cart_ddb_policy.arn
}

# Orders Lambda -> only Orders table
data "aws_iam_policy_document" "orders_ddb_policy_doc" {
  statement {
    actions = ["dynamodb:PutItem", "dynamodb:GetItem"]
    resources = [aws_dynamodb_table.orders.arn]
  }
}

resource "aws_iam_policy" "orders_ddb_policy" {
  name   = "${local.name}-orders-ddb-policy"
  policy = data.aws_iam_policy_document.orders_ddb_policy_doc.json
}

resource "aws_iam_role_policy_attachment" "orders_ddb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.orders_ddb_policy.arn
}

# -------------------------
# Package Lambdas (zip)
# We zip each service folder + shared utils via a temp build folder pattern.
# -------------------------
resource "null_resource" "prepare_build" {
  triggers = {
    # re-run build when code changes (simple approach)
    always = timestamp()
  }

  provisioner "local-exec" {
    command = "python3 ../../../scripts/build_lambda_packages.py"
  }
}

data "archive_file" "catalog_zip" {
  type        = "zip"
  source_dir  = "../../../.build/catalog"
  output_path = "../../../.build/catalog.zip"
  depends_on  = [null_resource.prepare_build]
}

data "archive_file" "cart_zip" {
  type        = "zip"
  source_dir  = "../../../.build/cart"
  output_path = "../../../.build/cart.zip"
  depends_on  = [null_resource.prepare_build]
}

data "archive_file" "orders_zip" {
  type        = "zip"
  source_dir  = "../../../.build/orders"
  output_path = "../../../.build/orders.zip"
  depends_on  = [null_resource.prepare_build]
}

# -------------------------
# Lambda functions
# -------------------------
resource "aws_lambda_function" "catalog" {
  function_name = "${local.name}-catalog"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.catalog_zip.output_path
  source_code_hash = data.archive_file.catalog_zip.output_base64sha256

  memory_size = 256
  timeout     = 10
}

resource "aws_lambda_function" "cart" {
  function_name = "${local.name}-cart"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.cart_zip.output_path
  source_code_hash = data.archive_file.cart_zip.output_base64sha256

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      CART_TABLE = aws_dynamodb_table.cart.name
    }
  }
}

resource "aws_lambda_function" "orders" {
  function_name = "${local.name}-orders"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.orders_zip.output_path
  source_code_hash = data.archive_file.orders_zip.output_base64sha256

  memory_size = 256
  timeout     = 10

  environment {
    variables = {
      ORDERS_TABLE = aws_dynamodb_table.orders.name
    }
  }
}

# -------------------------
# CloudWatch Log Groups (retention)
# -------------------------
resource "aws_cloudwatch_log_group" "lg_catalog" {
  name              = "/aws/lambda/${aws_lambda_function.catalog.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lg_cart" {
  name              = "/aws/lambda/${aws_lambda_function.cart.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lg_orders" {
  name              = "/aws/lambda/${aws_lambda_function.orders.function_name}"
  retention_in_days = 7
}

# -------------------------
# CloudWatch Alarms (MVP)
# -------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_errors_catalog" {
  alarm_name          = "${local.name}-catalog-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.catalog.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors_cart" {
  alarm_name          = "${local.name}-cart-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.cart.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors_orders" {
  alarm_name          = "${local.name}-orders-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.orders.function_name
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles_orders" {
  alarm_name          = "${local.name}-orders-throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.orders.function_name
  }
}

# -------------------------
# API Gateway HTTP API
# -------------------------
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Integrations
resource "aws_apigatewayv2_integration" "catalog" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.catalog.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "cart" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.cart.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "orders" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.orders.invoke_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "get_catalog" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /catalog"
  target    = "integrations/${aws_apigatewayv2_integration.catalog.id}"
}

resource "aws_apigatewayv2_route" "post_cart" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /cart/items"
  target    = "integrations/${aws_apigatewayv2_integration.cart.id}"
}

resource "aws_apigatewayv2_route" "post_orders" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /orders"
  target    = "integrations/${aws_apigatewayv2_integration.orders.id}"
}

resource "aws_apigatewayv2_route" "get_order" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /orders/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.orders.id}"
}

# Permissions: allow API Gateway to invoke lambdas
resource "aws_lambda_permission" "allow_apigw_catalog" {
  statement_id  = "AllowAPIGWInvokeCatalog"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.catalog.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_cart" {
  statement_id  = "AllowAPIGWInvokeCart"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cart.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "allow_apigw_orders" {
  statement_id  = "AllowAPIGWInvokeOrders"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.orders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}