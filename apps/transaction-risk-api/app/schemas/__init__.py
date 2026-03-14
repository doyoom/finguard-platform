"""Request/response schemas for validation"""
from typing import Optional


def validate_score_request(data: dict) -> Optional[str]:
    """Validate /score request payload. Returns error message or None."""
    required_fields = {
        "amount": (int, float),
        "merchant_category": (str,),
        "country": (str,),
        "transaction_hour": (int,),
        "device_changed": (bool,),
        "recent_txn_count_24h": (int,),
    }

    if not data:
        return "Request body is required"

    for field, types in required_fields.items():
        if field not in data:
            return f"Missing required field: {field}"
        if not isinstance(data[field], types):
            return f"Invalid type for {field}: expected {types}"

    if not (0 <= data["transaction_hour"] <= 23):
        return "transaction_hour must be between 0 and 23"

    if data["amount"] < 0:
        return "amount must be non-negative"

    if data["recent_txn_count_24h"] < 0:
        return "recent_txn_count_24h must be non-negative"

    return None
