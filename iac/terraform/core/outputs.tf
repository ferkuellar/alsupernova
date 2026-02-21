output "web_bucket_name" {
  value = aws_s3_bucket.web.bucket
}

output "cloudfront_domain" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "api_base_url" {
  value = data.terraform_remote_state.backend.outputs.api_base_url
}
