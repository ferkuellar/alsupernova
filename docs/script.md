# Interview Demo Script (2–3 minutes)

## 0) Setup (10s)

"I designed a retail omnichannel MVP on AWS with strict cost controls (credits mode). It's serverless-first and ready for event-driven evolution."

## 1) Show the UI (30s)

- Open CloudFront URL (global edge)
- Paste API base URL → Save → Ping API
  "I keep the site private in S3 and only CloudFront can read it via OAC."

## 2) Show retail flow (60–90s)

- Load Catalog (GET /catalog)
- Add to Cart (POST /cart/items → DynamoDB)
- Create Order (POST /orders → DynamoDB)
- Get Order (GET /orders/{id})

"This demonstrates the core transactional path. DynamoDB is PAY_PER_REQUEST to avoid idle cost."

## 3) Show Ops / Head Architect posture (45s)

- CloudWatch alarms (Errors/Throttles)
- Log retention enforced (7 days)
- Budget + anomaly detection evidence
- Mention teardown script to zero-cost dev

"I enforced guardrails in IaC to prevent surprise bills and to keep an operational baseline similar to production."

## 4) Close (15s)

"Next step is to add EventBridge + SQS for fulfillment/notifications and a lakehouse for promo ROI and out-of-stock analytics."
