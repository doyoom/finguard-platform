"""Health check route"""
from flask import Blueprint, jsonify
import os

health_bp = Blueprint("health", __name__)


@health_bp.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy",
        "service": "transaction-risk-api",
        "version": os.getenv("APP_VERSION", "1.0.0"),
    }), 200
