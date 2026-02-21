output "api_base_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "cart_table" {
  value = aws_dynamodb_table.cart.name
}

output "orders_table" {
  value = aws_dynamodb_table.orders.name
}