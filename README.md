# ALSUPERNOVA 🛒⚡ (Retail Omnichannel MVP on AWS)

**Role:** Head / Senior AWS Cloud Architect  
**Focus:** Serverless-first • Security-by-default • Observability • FinOps (AWS credits discipline)  
**Deliverables:** Terraform IaC • Functional UI • Productized API • Runbooks • ADRs • Diagrams • Evidence (screenshots)

---

## Executive Summary (for CV / Interview)

**ALSUPERNOVA** is a regional retail (Alsuper-like) commercial MVP where I designed and built an **omnichannel core** (catalog, cart, orders) on **AWS** using a **serverless-first** architecture. The solution is **secure by default**, **observable**, and **FinOps-driven** to run safely under **AWS credits** (avoiding “idle spend”).  
This repo includes **Terraform**, a **working end-to-end UI**, **API endpoints**, **ADRs**, **runbooks**, **diagrams**, and **evidence** to demonstrate real operation and architectural discipline.

---

## What’s Included

### Business Capabilities (Retail MVP)
- **Product catalog** (demo data: groceries + fresh products)
- **Cart** per user (add/update items)
- **Orders** (create order by store/branch + line items)
- **Order query** by `orderId`
- **End-to-end demo UI** (no frameworks) to execute the full flow

### AWS Architecture (Cost-Controlled & Modern)
- **Frontend:** S3 (private) + CloudFront + **OAC** (origin protected)
- **Backend:** API Gateway (HTTP API) + AWS Lambda (Catalog/Cart/Orders)
- **Data:** DynamoDB **PAY_PER_REQUEST** (Cart + Orders) → near-zero idle cost
- Designed to evolve into **event-driven** (fulfillment/notifications/analytics)

---

## Architecture Overview

```mermaid
flowchart LR
  U[User Browser] --> CF[CloudFront]
  CF -->|OAC| S3[(S3 Private Bucket)]
  U --> API[API Gateway HTTP API]
  API --> L1[Lambda: Catalog]
  API --> L2[Lambda: Cart]
  API --> L3[Lambda: Orders]
  L2 --> D1[(DynamoDB: Cart)]
  L3 --> D2[(DynamoDB: Orders)]
  L1 -->|demo data / optional table| D3[(Optional: DynamoDB Catalog)]
  L1 --> CW[(CloudWatch Logs)]
  L2 --> CW
  L3 --> CW
````

---

## Why This Architecture (Rationale + Tradeoffs)

### Serverless-first = scale without buying capacity

* **Lambda + HTTP API**: pay per request/compute, no servers waiting for traffic.
* **DynamoDB On-Demand**: no capacity planning, absorbs spikes (promos/quincena/weekends).

### Secure-by-default frontend (not “public bucket and vibes”)

* **S3 is private**; only CloudFront can read via **OAC**.
* Reduced exposure and better governance posture.

### Production mindset from day 1

* **CloudWatch alarms** (errors/throttles) for minimum viable operations.
* **Log retention enforced** (7 days) to avoid infinite logging costs.
* **Runbooks + evidence**: repeatable demo/ops, not just screenshots of a UI.

### FinOps discipline (AWS credits mode)

* **Budgets** with buffer + **Anomaly Detection**
* Cost allocation **tags** (Project/Env/Owner/CostCenter)
* **Kill switch**: destroy dev and return to ~zero baseline cost
* Explicit decisions to avoid “ghost spend” (e.g., **no NAT Gateway**, no always-on DB)

### Tradeoffs (what I intentionally didn’t choose)

* **EKS**: operational overhead for an MVP (great later, not day 1).
* **RDS/Aurora always-on**: constant baseline spend; not justified for early-stage.
* **NAT Gateway**: classic surprise bill; avoided until required.

---

## Repo Structure

```text
.
├─ infra/
│  ├─ terraform/
│  │  ├─ modules/
│  │  ├─ envs/
│  │  │  ├─ dev/
│  │  │  └─ prod/
│  │  └─ backend/              # remote state (if used)
├─ src/
│  ├─ ui/                      # static UI (no framework)
│  ├─ lambdas/
│  │  ├─ catalog/
│  │  ├─ cart/
│  │  └─ orders/
├─ docs/
│  ├─ adr/                     # Architecture Decision Records
│  ├─ runbooks/
│  ├─ diagrams/
│  └─ evidence/                # screenshots index + proof
└─ scripts/
   ├─ deploy.sh
   ├─ destroy.sh               # kill switch
   └─ smoke-test.sh
```

---

## Quick Start (Local + Deploy)

### Prereqs

* AWS account with credits enabled (or standard billing)
* Terraform >= 1.x
* AWS CLI configured (`aws configure`)
* Node/Python optional (only if your Lambdas use them)

### 1) Deploy infrastructure

```bash
cd infra/terraform/envs/dev
terraform init
terraform plan
terraform apply
```

### 2) Deploy UI to S3 and invalidate CloudFront (if script exists)

```bash
./scripts/deploy.sh
```

### 3) Smoke test API

```bash
./scripts/smoke-test.sh
```

### 4) Destroy (Kill Switch)

```bash
./scripts/destroy.sh
# or:
terraform destroy
```

> **Important:** This MVP is designed to be *cheap when idle*. Still: always destroy dev environments when not in use.

---

## API Endpoints (HTTP API)

> Base URL is output by Terraform: `api_base_url`

### Catalog

* `GET /catalog`

### Cart

* `GET /cart/{userId}`
* `POST /cart/{userId}`  *(add/update items)*

### Orders

* `POST /orders` *(create order)*
* `GET /orders/{orderId}`

Example payload (create order):

```json
{
  "userId": "u-123",
  "storeId": "store-01",
  "items": [
    {"sku":"APL-001","name":"Apples","qty":2,"price":35.0},
    {"sku":"RCE-010","name":"Rice 1kg","qty":1,"price":28.0}
  ]
}
```

---

## Security Controls

* **S3 private bucket** (no public access)
* **CloudFront OAC** (only CloudFront can read from S3)
* **IAM least privilege**:

  * Separate DynamoDB permissions per domain (**Cart vs Orders**)
* **CORS controlled** at HTTP API for the UI
* Principle: small blast radius, explicit trust boundaries

---

## Observability & Operations

### CloudWatch

* Centralized logs for each Lambda
* **Retention enforced (7 days)** to prevent runaway cost

### Alarms (MVP-level)

* Lambda **Errors**
* Lambda **Throttles**
* API 5XX (if enabled / supported with metrics)

### Runbooks

* Demo flow runbook (end-to-end)
* Ops triage (where to check, what metrics matter, rollback basics)

---

## FinOps / Cost Controls (AWS Credits Mode)

* **AWS Budgets** (example: alert at $100 of $116)
* **Cost Anomaly Detection**
* **Cost allocation tags**:

  * `Project=ALSUPERNOVA`
  * `Env=dev|prod`
  * `Owner=Fernando`
  * `CostCenter=RetailMVP`
* **Avoided ghost spend**:

  * No NAT Gateway
  * No always-on databases
  * On-demand DynamoDB

---

## Evidence (Real Operation Proof)

This repo follows a disciplined loop:

> **Step → Evidence → Commit**

* `docs/evidence/` contains screenshots and an index:

  * Terraform apply outputs
  * CloudFront distribution + OAC config
  * S3 public access block
  * API Gateway routes
  * DynamoDB tables + items
  * CloudWatch logs & alarms
  * UI flow: catalog → cart → order → query

---

## ADRs (Architecture Decision Records)

See `docs/adr/` for decisions such as:

* Serverless-first rationale
* DynamoDB on-demand choice
* CloudFront + OAC security posture
* Logging retention and alarms
* Cost control strategy under credits

---

## Roadmap (Next “real retail” steps)

* Event-driven fulfillment (`orders.created` → SNS/SQS/EventBridge)
* Notifications (email/SMS/WhatsApp)
* Inventory ledger + OOS handling
* Promotions/loyalty hooks
* Analytics (Athena/Glue + curated datasets)
* WAF + rate limiting + threat modeling pack
* CI/CD (GitHub Actions) + deployment pipelines + policy checks

---

## License

Choose your license (MIT/Apache-2.0) or keep it private for portfolio use.

---

## Contact

Fernando — Cloud Architect / Data Engineer
If you’re reviewing this for an interview: ask me about the tradeoffs, cost controls, and how I’d evolve this to multi-region + real fulfillment.


---

