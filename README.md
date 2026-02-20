# ALSUPERNOVA (Retail Omnichannel on AWS)

MVP omnicanal tipo retail regional (catálogo, carrito, órdenes, inventario ledger) con enfoque serverless y control estricto de costos con AWS credits.

## Scope (MVP)

- Frontend: S3 + CloudFront
- Backend: API Gateway (HTTP API) + Lambda
- Data: DynamoDB (on-demand)
- Async: EventBridge + SQS (opcional)
- Observability: CloudWatch (retention corta)

## Repo structure

- /iac/terraform/core -> base infra (S3 + CloudFront + VPC endpoints si aplica)
- /services -> lambdas
- /docs -> diagramas, ADRs, evidencias
