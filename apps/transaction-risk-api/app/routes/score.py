"""Score route — 거래 위험 점수 산출"""
from flask import Blueprint, request, jsonify
from app.services.risk_engine import calculate_risk
from app.schemas import validate_score_request
from app.models import save_transaction

score_bp = Blueprint("score", __name__)


@score_bp.route("/score", methods=["POST"])
def score():
    data = request.get_json(silent=True)

    # Validate
    error = validate_score_request(data)
    if error:
        return jsonify({"error": error}), 400

    # Calculate risk
    result = calculate_risk(
        amount=data["amount"],
        merchant_category=data["merchant_category"],
        country=data["country"],
        transaction_hour=data["transaction_hour"],
        device_changed=data["device_changed"],
        recent_txn_count_24h=data["recent_txn_count_24h"],
    )

    # Save transaction (optional customer_id)
    customer_id = data.get("customer_id", "anonymous")
    save_transaction(customer_id, data, result)

    return jsonify(result), 200
