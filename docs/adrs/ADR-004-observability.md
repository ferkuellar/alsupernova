# ADR-004: Baseline Observability for MVP

## Decision

Implement CloudWatch alarms on Lambda Errors/Throttles and enforce log retention (7 days) via IaC.

## Why

- Detect failures early
- Prevent uncontrolled logging costs under AWS credits
- Provide production-like operational posture for portfolio
