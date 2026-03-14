"""FinGuard — Transaction Risk API"""
import os
from flask import Flask


def create_app():
    app = Flask(__name__)

    app.config["DB_HOST"] = os.getenv("DB_HOST", "localhost")
    app.config["DB_PORT"] = os.getenv("DB_PORT", "5432")
    app.config["DB_NAME"] = os.getenv("DB_NAME", "finguard")

    # Register blueprints
    from app.routes.health import health_bp
    from app.routes.score import score_bp
    from app.routes.transactions import transactions_bp

    app.register_blueprint(health_bp)
    app.register_blueprint(score_bp)
    app.register_blueprint(transactions_bp)

    return app
