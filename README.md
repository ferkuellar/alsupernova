
# ALSUPERNOVA — Retail Omnichannel MVP on AWS (Credits-Safe)

Commercial-grade portfolio project modeled after a regional grocery retailer (catalog, cart, orders, inventory ledger) built with **serverless-first** architecture and **strict cost controls** (AWS credits mode).

## Why this project exists

Retail has spiky traffic (promos, weekends, payday). The MVP optimizes for:

- predictable spend under AWS credits
- fast delivery with minimal operational overhead
- event-ready design for future scale (fulfillment, notifications, analytics)

---

## Architecture (MVP)

**Frontend**

- S3 (static site, private)
- CloudFront with OAC (secure origin access)

**Backend**

- API Gateway (HTTP API)
- Lambda (Catalog, Cart, Orders)
- DynamoDB (PAY_PER_REQUEST): Cart + Orders

**Operations**

- CloudWatch log retention enforced (7 days)
- CloudWatch alarms (Errors, Throttles)
- Cost guardrails: budgets + anomaly detection + tags + teardown script

---

## Diagrams

See `/docs/diagrams/` (Mermaid ready for draw.io).

---

## API Endpoints

Base URL: Terraform output `api_base_url`

- `GET /catalog`
- `POST /cart/items`
  - body: `{ "userId": "fernando", "sku": "APL-001", "qty": 2, "cartId": "optional" }`
- `POST /orders`
  - body: `{ "userId": "...", "storeId": "...", "items": [ { "sku": "...", "qty": 1 } ] }`
- `GET /orders/{id}`

---

## How to run the demo (2 minutes)

1) Deploy core infra (S3 + CloudFront)
2) Deploy backend (API + Lambdas + DynamoDB)
3) Open CloudFront URL
4) Paste API base URL into UI → Save → Ping
5) Load Catalog → Add to Cart → Create Order → Get Order

Detailed runbook: `/docs/demo-runbook.md`

---

## Cost guardrails (Credits Mode)

- Budget: $100 (buffer $16)
- Anomaly detection enabled
- No NAT Gateway in MVP
- No always-on DB in MVP
- CloudWatch retention: 7 days
- Cost allocation tags on key resources
- One-command teardown: `scripts/destroy-dev.sh`

---

## Repo structure

- `/iac/terraform/core`     → S3 + CloudFront (OAC)
- `/iac/terraform/backend`  → API GW + Lambdas + DynamoDB + alarms
- `/frontend`               → Static UI
- `/services`               → Lambda handlers
- `/docs`                   → diagrams, ADRs, runbooks, evidence screenshots
- `/scripts`                → operational scripts (destroy dev)

---

## Evidence

Screenshots live in `/docs/evidence/` (budgets, anomaly detection, infra, backend tests, UI demo, alarms, tags).
