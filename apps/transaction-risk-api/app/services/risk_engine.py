"""Risk scoring engine — rule-based transaction risk assessment"""
from typing import Dict, List, Tuple


# ── Weight configuration ─────────────────────────────
WEIGHTS = {
    "HIGH_AMOUNT": 25,
    "OVERSEAS_TRANSACTION": 20,
    "UNUSUAL_HOUR": 15,
    "NEW_DEVICE": 20,
    "BURST_ACTIVITY": 20,
}

# ── Thresholds ───────────────────────────────────────
AMOUNT_THRESHOLD = 5_000_000       # 500만원 이상
BURST_TXN_THRESHOLD = 10           # 24시간 내 10건 이상
UNUSUAL_HOURS = set(range(0, 6))   # 0시 ~ 5시
DOMESTIC_COUNTRY = "KR"


def calculate_risk(
    amount: float,
    merchant_category: str,
    country: str,
    transaction_hour: int,
    device_changed: bool,
    recent_txn_count_24h: int,
) -> Dict:
    """
    거래 위험 점수를 계산합니다.

    Returns:
        {
            "risk_score": 0-100,
            "risk_level": "LOW" | "MEDIUM" | "HIGH",
            "reason_codes": [...]
        }
    """
    reasons: List[str] = []
    raw_score = 0

    # Rule 1: 고액 거래
    if amount >= AMOUNT_THRESHOLD:
        reasons.append("HIGH_AMOUNT")
        raw_score += WEIGHTS["HIGH_AMOUNT"]

    # Rule 2: 해외 거래
    if country != DOMESTIC_COUNTRY:
        reasons.append("OVERSEAS_TRANSACTION")
        raw_score += WEIGHTS["OVERSEAS_TRANSACTION"]

    # Rule 3: 심야 시간 거래
    if transaction_hour in UNUSUAL_HOURS:
        reasons.append("UNUSUAL_HOUR")
        raw_score += WEIGHTS["UNUSUAL_HOUR"]

    # Rule 4: 새 기기
    if device_changed:
        reasons.append("NEW_DEVICE")
        raw_score += WEIGHTS["NEW_DEVICE"]

    # Rule 5: 단기간 다량 거래
    if recent_txn_count_24h >= BURST_TXN_THRESHOLD:
        reasons.append("BURST_ACTIVITY")
        raw_score += WEIGHTS["BURST_ACTIVITY"]

    # Normalize to 0-100
    risk_score = min(raw_score, 100)
    risk_level = _to_level(risk_score)

    return {
        "risk_score": risk_score,
        "risk_level": risk_level,
        "reason_codes": reasons,
    }


def _to_level(score: int) -> str:
    if score <= 30:
        return "LOW"
    elif score <= 70:
        return "MEDIUM"
    return "HIGH"
