import json
import os
import uuid
import boto3
from services.shared.utils import response, now_iso

ddb = boto3.resource("dynamodb")
ORDERS_TABLE = os.environ["ORDERS_TABLE"]

def lambda_handler(event, context):
    http = event.get("requestContext", {}).get("http", {})
    method = (http.get("method") or "").upper()
    path = http.get("path") or ""

    if method == "OPTIONS":
        return response(200, {"ok": True})

    table = ddb.Table(ORDERS_TABLE)

    # GET /orders/{id}
    if method == "GET":
        order_id = event.get("pathParameters", {}).get("id")
        if not order_id:
            return response(400, {"error": "order id is required in path"})
        resp = table.get_item(Key={"orderId": order_id})
        item = resp.get("Item")
        if not item:
            return response(404, {"error": "order not found", "orderId": order_id})
        return response(200, {"service": "orders", "order": item})

    # POST /orders
    if method == "POST":
        body = event.get("body") or "{}"
        try:
            payload = json.loads(body)
        except Exception:
            return response(400, {"error": "Invalid JSON body"})

        user_id = payload.get("userId") or "anonymous"
        store_id = payload.get("storeId") or "store-001"
        items = payload.get("items") or []

        if not isinstance(items, list) or len(items) == 0:
            return response(400, {"error": "items must be a non-empty list"})

        order_id = str(uuid.uuid4())
        order = {
            "orderId": order_id,
            "userId": user_id,
            "storeId": store_id,
            "status": "CREATED",
            "items": items,
            "createdAt": now_iso(),
        }

        table.put_item(Item=order)

        return response(201, {"service": "orders", "message": "Order created", "order": order})

    return response(405, {"error": "Method not allowed"})