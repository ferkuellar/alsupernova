# Backend API (MVP)

Base URL: (see Terraform output `api_base_url`)

## Endpoints

- GET /catalog
- POST /cart/items
  - body: { "userId": "fernando", "sku": "APL-001", "qty": 2, "cartId": "optional" }
- POST /orders
  - body: { "userId": "...", "storeId": "...", "items": [ { "sku": "...", "qty": 1 } ] }
- GET /orders/{id}

## Data stores

- DynamoDB Cart (PAY_PER_REQUEST)
- DynamoDB Orders (PAY_PER_REQUEST)
