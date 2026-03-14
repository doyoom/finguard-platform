"""Transactions route — 고객별 거래 내역 조회"""
from flask import Blueprint, jsonify
from app.models import get_transactions

transactions_bp = Blueprint("transactions", __name__)


@transactions_bp.route("/transactions/<customer_id>", methods=["GET"])
def get_customer_transactions(customer_id: str):
    records = get_transactions(customer_id)

    if records is None:
        return jsonify({
            "error": f"No transactions found for customer: {customer_id}"
        }), 404

    return jsonify({
        "customer_id": customer_id,
        "total_transactions": len(records),
        "transactions": records,
    }), 200
