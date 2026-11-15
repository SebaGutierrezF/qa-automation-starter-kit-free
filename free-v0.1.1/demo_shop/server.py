"""Local-only HTTP demo. No third-party requests, database or real credentials.

Only bind this demonstration server on 127.0.0.1. It is intentionally NOT a
production authentication system and should never be exposed to the internet.
"""
from __future__ import annotations

import hmac
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

_LOOPBACK = "127.0.0.1"
_DEMO_USER = "qa_demo"
_DEMO_PASS = "demo-only-123"  # Deliberately public test fixture; never a real secret.
_PRODUCTS = [
    {"id": 1, "name": "Sample Keyboard", "price": 25},
    {"id": 2, "name": "Sample Mouse", "price": 15},
]
_CSS_FILE = Path(__file__).resolve().parent / "static" / "style.css"


def _document(title: str, content: str) -> bytes:
    html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{title} | QA-SK demo</title><link rel="stylesheet" href="/static/style.css">
</head><body><main class="card"><div class="eyebrow">QA-SK-001 · LOCAL DEMO</div>
{content}</main></body></html>"""
    return html.encode("utf-8")


def _login_view(*, error: bool = False) -> bytes:
    warning = '<p id="login-error" role="alert">Invalid credentials</p>' if error else ""
    return _document("Login", f"""<h1>QA Demo Login</h1>
<p>This is a local demonstration; do not use real passwords.</p>
{warning}<form id="login-form" action="/login" method="post">
<label for="username">Username</label>
<input id="username" name="username" autocomplete="off" required>
<label for="password">Password</label>
<input id="password" name="password" type="password" autocomplete="off" required>
<button id="login-submit" type="submit">Sign in</button></form>
<p class="hint">Test account: qa_demo / demo-only-123</p>""")


class DemoHandler(BaseHTTPRequestHandler):
    server_version = "QASkLocalDemo/0.1"

    def log_message(self, fmt: str, *args: object) -> None:
        # Keep tests quiet; don't log credentials or user-supplied request bodies.
        return

    def _send(self, status: int, payload: bytes, mime: str, headers: dict[str, str] | None = None) -> None:
        self.send_response(status)
        self.send_header("Content-Type", mime)
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        for name, value in (headers or {}).items():
            self.send_header(name, value)
        self.end_headers()
        self.wfile.write(payload)

    def _json(self, status: int, value: object) -> None:
        self._send(status, json.dumps(value, separators=(",", ":")).encode("utf-8"), "application/json; charset=utf-8")

    def do_GET(self) -> None:
        path = urlsplit(self.path).path
        if path in ("/", "/login"):
            self._send(200, _login_view(), "text/html; charset=utf-8")
        elif path == "/dashboard":
            cookie = self.headers.get("Cookie", "")
            if "qa_demo_session=1" not in cookie.split("; "):
                self._send(303, b"", "text/plain", {"Location": "/login"})
                return
            self._send(200, _document("Dashboard", "<h1 id='dashboard-title'>QA Demo Dashboard</h1><p>Login successful.</p>"), "text/html; charset=utf-8")
        elif path == "/static/style.css":
            self._send(200, _CSS_FILE.read_bytes(), "text/css; charset=utf-8")
        elif path == "/api/health":
            self._json(200, {"status": "ok", "service": "demo_shop"})
        elif path == "/api/catalog":
            self._json(200, {"items": _PRODUCTS, "count": len(_PRODUCTS)})
        elif path.startswith("/api/"):
            self._json(404, {"error": "not_found"})
        else:
            self._send(404, _document("Not found", "<h1>Not found</h1>"), "text/html; charset=utf-8")

    def do_POST(self) -> None:
        if urlsplit(self.path).path != "/login":
            self._json(404, {"error": "not_found"})
            return
        try:
            size = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            self._send(400, b"Invalid request", "text/plain")
            return
        if size < 0 or size > 4096:
            self._send(413, b"Invalid request size", "text/plain")
            return
        data = parse_qs(self.rfile.read(size).decode("utf-8", errors="replace"))
        name = data.get("username", [""])[0]
        password = data.get("password", [""])[0]
        if hmac.compare_digest(name, _DEMO_USER) and hmac.compare_digest(password, _DEMO_PASS):
            self._send(303, b"", "text/plain", {
                "Location": "/dashboard",
                "Set-Cookie": "qa_demo_session=1; HttpOnly; SameSite=Strict; Path=/",
            })
        else:
            self._send(401, _login_view(error=True), "text/html; charset=utf-8")


def make_server(port: int = 0) -> ThreadingHTTPServer:
    """Create a loopback-bound server; port=0 delegates ephemeral port choice to OS."""
    server = ThreadingHTTPServer((_LOOPBACK, port), DemoHandler)
    server.daemon_threads = True
    return server


if __name__ == "__main__":
    # For manual demos only. Close with Ctrl+C.
    srv = make_server(8765)
    print("QA demo local: http://127.0.0.1:8765/login")
    try:
        srv.serve_forever(poll_interval=0.1)
    except KeyboardInterrupt:
        pass
    finally:
        srv.server_close()
