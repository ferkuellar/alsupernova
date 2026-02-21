# ADR-005: IAM Least Privilege for Serverless MVP

## Decision

Split DynamoDB permissions by domain (Cart vs Orders) and avoid granting broad table access.

## Why

- Reduces blast radius
- Aligns with security best practices for serverless
- Strengthens interview narrative (security-first design)s
