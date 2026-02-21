# Runbook: API Gateway → Lambda Invoke Permissions (HTTP API)

## Symptom

- API returns HTTP 500
- Lambda works with direct `aws lambda invoke`
- CloudWatch logs show no new invocations for API requests

## Root cause

- Missing Lambda resource-based policy allowing API Gateway (`apigateway.amazonaws.com`) to invoke functions.

## Fix (example)

Grant permission using execute-api SourceArn:

arn:aws:execute-api:`<region>`:<account_id>:<api_id>/*/*/*

Apply for each Lambda used by the API (catalog/cart/orders).
