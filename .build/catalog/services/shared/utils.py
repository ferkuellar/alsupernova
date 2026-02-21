import json
from datetime import datetime, timezone
from decimal import Decimal

def now_iso():
    return datetime.now(timezone.utc).isoformat()

def _json_default(o):
    if isinstance(o, Decimal):
        return int(o) if o % 1 == 0 else float(o)
    raise TypeError(f"Object of type {o.__class__.__name__} is not JSON serializable")

def response(status_code: int, body: dict, headers: dict | None = None):
    h = {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
    }
    if headers:
        h.update(headers)

    return {
        "statusCode": status_code,
        "headers": h,
        "body": json.dumps(body, default=_json_default),
    }