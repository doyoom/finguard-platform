"""Unit tests — Score endpoint & Risk engine"""
import pytest
from app import create_app


@pytest.fixture
def client():
    app = create_app()
    app.config["TESTING"] = True
    with app.test_client() as c:
        yield c


# ── /score endpoint tests ────────────────────────────

class TestScoreEndpoint:
    def test_normal_transaction_low_risk(self, client):
        """일반 국내 거래 → LOW"""
        res = client.post("/score", json={
            "amount": 50000,
            "merchant_category": "grocery",
            "country": "KR",
            "transaction_hour": 14,
            "device_changed": False,
            "recent_txn_count_24h": 2,
        })
        assert res.status_code == 200
        data = res.get_json()
        assert data["risk_level"] == "LOW"
        assert data["risk_score"] == 0
        assert data["reason_codes"] == []

    def test_high_amount_overseas_high_risk(self, client):
        """고액 해외 심야 거래 → HIGH"""
        res = client.post("/score", json={
            "amount": 10_000_000,
            "merchant_category": "electronics",
            "country": "US",
            "transaction_hour": 3,
            "device_changed": True,
            "recent_txn_count_24h": 15,
        })
        assert res.status_code == 200
        data = res.get_json()
        assert data["risk_level"] == "HIGH"
        assert data["risk_score"] == 100
        assert "HIGH_AMOUNT" in data["reason_codes"]
        assert "OVERSEAS_TRANSACTION" in data["reason_codes"]
        assert "UNUSUAL_HOUR" in data["reason_codes"]
        assert "NEW_DEVICE" in data["reason_codes"]
        assert "BURST_ACTIVITY" in data["reason_codes"]

    def test_medium_risk_scenario(self, client):
        """새 기기 + 해외 거래 → MEDIUM"""
        res = client.post("/score", json={
            "amount": 100000,
            "merchant_category": "travel",
            "country": "JP",
            "transaction_hour": 10,
            "device_changed": True,
            "recent_txn_count_24h": 1,
        })
        assert res.status_code == 200
        data = res.get_json()
        assert data["risk_level"] == "MEDIUM"
        assert "OVERSEAS_TRANSACTION" in data["reason_codes"]
        assert "NEW_DEVICE" in data["reason_codes"]

    def test_missing_field_returns_400(self, client):
        """필수 필드 누락 → 400"""
        res = client.post("/score", json={"amount": 1000})
        assert res.status_code == 400
        assert "Missing required field" in res.get_json()["error"]

    def test_invalid_hour_returns_400(self, client):
        """잘못된 transaction_hour → 400"""
        res = client.post("/score", json={
            "amount": 1000,
            "merchant_category": "food",
            "country": "KR",
            "transaction_hour": 25,
            "device_changed": False,
            "recent_txn_count_24h": 0,
        })
        assert res.status_code == 400

    def test_empty_body_returns_400(self, client):
        """빈 요청 → 400"""
        res = client.post("/score", content_type="application/json")
        assert res.status_code == 400


# ── /transactions endpoint tests ─────────────────────

class TestTransactionsEndpoint:
    def test_no_transactions_returns_404(self, client):
        res = client.get("/transactions/unknown-customer")
        assert res.status_code == 404

    def test_transactions_after_scoring(self, client):
        """스코어링 후 거래 내역 조회"""
        client.post("/score", json={
            "amount": 50000,
            "merchant_category": "food",
            "country": "KR",
            "transaction_hour": 12,
            "device_changed": False,
            "recent_txn_count_24h": 1,
            "customer_id": "test-cust-001",
        })

        res = client.get("/transactions/test-cust-001")
        assert res.status_code == 200
        data = res.get_json()
        assert data["total_transactions"] == 1
        assert data["transactions"][0]["customer_id"] == "test-cust-001"
