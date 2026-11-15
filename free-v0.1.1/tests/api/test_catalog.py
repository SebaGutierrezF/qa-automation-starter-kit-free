"""Two pure-stdlib HTTP tests against loopback API endpoints."""
from qa_starter.api_client import get_json


def test_api_001_health(demo_url):
    status, payload = get_json(demo_url, "/api/health")
    assert status == 200
    assert payload == {"status": "ok", "service": "demo_shop"}


def test_api_002_catalog(demo_url):
    status, payload = get_json(demo_url, "/api/catalog")
    assert status == 200
    assert payload["count"] == 2
    assert [item["id"] for item in payload["items"]] == [1, 2]
    assert all(item["price"] > 0 for item in payload["items"])
