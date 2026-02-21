# FinOps Runbook (Credits Mode)

## Budget model

- Credits available: $116
- Budget set: $100 (buffer $16)
- Target burn rate: ~$3.57/day
- Anomaly detection enabled

## Controls

- No NAT Gateway in MVP
- No always-on DB in MVP
- CloudWatch Logs retention: 7 days
- Cost allocation tags on key resources
- One-command teardown for dev: `scripts/destroy-dev.sh`

## Weekly check

- Billing → Budgets status
- Cost Explorer: top services by cost
- CloudWatch: Lambda errors/throttles alarms
