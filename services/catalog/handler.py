from services.shared.utils import response, now_iso

# Demo catalog: "tipo Alsuper" (frescos + abarrotes)
CATALOG = [
    {"sku": "APL-001", "name": "Apple Gala (1kg)", "price": 55.0, "category": "produce"},
    {"sku": "MLK-001", "name": "Milk 1L", "price": 29.5, "category": "dairy"},
    {"sku": "BRD-001", "name": "Bread loaf", "price": 42.0, "category": "bakery"},
]

def lambda_handler(event, context):
    return response(200, {
        "service": "catalog",
        "timestamp": now_iso(),
        "items": CATALOG
    })