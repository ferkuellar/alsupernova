# Demo Runbook (ALSUPERNOVA)

## Prereqs

- Core infra deployed (S3 + CloudFront)
- Backend deployed (API Gateway + Lambdas + DynamoDB)

## Steps

1) Open CloudFront URL (see `terraform output cloudfront_domain`)
2) Paste API base URL (see `terraform output api_base_url`) and click Save
3) Ping API
4) Load Catalog
5) Add to Cart
6) Create Order
7) Get Order using orderId

## Evidence

See `/docs/evidence/` screenshots for billing guardrails, infra, backend tests, and UI demo.
