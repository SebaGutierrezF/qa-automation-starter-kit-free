"""Minimal stdlib HTTP client explicitly configured to bypass proxies."""
from __future__ import annotations

import json
from urllib.parse import urlsplit
from urllib.request import ProxyHandler, Request, build_opener

_OPENER = build_opener(ProxyHandler({}))


def get_json(base_url: str, endpoint: str) -> tuple[int, dict]:
    parsed = urlsplit(base_url)
    try:
        valid_port = 0 < (parsed.port or 0) <= 65535
    except ValueError:
        valid_port = False
    if (parsed.scheme != "http" or parsed.hostname != "127.0.0.1"
            or not valid_port or parsed.username or parsed.password
            or parsed.path or parsed.query or parsed.fragment):
        raise ValueError("Free alpha API client only allows http://127.0.0.1:<port> without credentials or paths")
    if not endpoint.startswith("/api/"):
        raise ValueError("Only demo API endpoints are allowed")
    request = Request(base_url + endpoint, headers={"Accept": "application/json"})
    with _OPENER.open(request, timeout=5) as response:
        return response.status, json.loads(response.read().decode("utf-8"))
