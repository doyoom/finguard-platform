"""Transaction model — 간단한 인메모리 저장소 (데모용)"""
from datetime import datetime
from typing import Dict, List, Optional
import uuid

# In-memory store (실 운영 시 PostgreSQL 사용)
_store: Dict[str, List[dict]] = {}


def save_transaction(customer_id: str, data: dict, risk_result: dict) -> dict:
    """거래를 저장하고 기록을 반환합니다."""
    record = {
        "transaction_id": str(uuid.uuid4()),
        "customer_id": customer_id,
        "amount": data["amount"],
        "merchant_category": data["merchant_category"],
        "country": data["country"],
        "transaction_hour": data["transaction_hour"],
        "risk_score": risk_result["risk_score"],
        "risk_level": risk_result["risk_level"],
        "reason_codes": risk_result["reason_codes"],
        "timestamp": datetime.utcnow().isoformat() + "Z",
    }

    if customer_id not in _store:
        _store[customer_id] = []
    _store[customer_id].append(record)

    return record


def get_transactions(customer_id: str) -> Optional[List[dict]]:
    """고객의 거래 내역을 반환합니다."""
    return _store.get(customer_id)
