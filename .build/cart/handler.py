import json
import os
import uuid
import boto3
from services.shared.utils import response, now_iso

ddb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["CART_TABLE"]

def lambda_handler(event, context):
    method = (event.get("requestContext", {}).get("http", {}).get("method") or "").upper()

    if method == "OPTIONS":
        return response(200, {"ok": True})

    if method != "POST":
        return response(405, {"error": "Method not allowed"})

    body = event.get("body") or "{}"
    try:
        payload = json.loads(body)
    except Exception:
        return response(400, {"error": "Invalid JSON body"})

    user_id = payload.get("userId") or "anonymous"
    sku = payload.get("sku")
    qty = payload.get("qty", 1)

    if not sku:
        return response(400, {"error": "sku is required"})

    cart_id = payload.get("cartId") or str(uuid.uuid4())

    table = ddb.Table(TABLE_NAME)
    item = {
        "userId": user_id,
        "cartId": cart_id,
        "sku": sku,
        "qty": int(qty),
        "updatedAt": now_iso(),
    }

    table.put_item(Item=item)

    return response(200, {
        "service": "cart",
        "message": "Item added",
        "cartId": cart_id,
        "item": item
    })