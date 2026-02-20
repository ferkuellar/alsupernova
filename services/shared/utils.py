import json
from datetime import datetime, timezone

def now_iso():
    return datetime.now(timezone.utc).isoformat()

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
        "body": json.dumps(body),
    }