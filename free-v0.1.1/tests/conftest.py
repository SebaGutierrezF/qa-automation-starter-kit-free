"""Test fixtures start and stop the loopback server without internet access."""
from __future__ import annotations

import sys
import threading
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[1]
for source in (ROOT / "src", ROOT, ROOT.parents[1] / "shared"):
    if str(source) not in sys.path:
        sys.path.insert(0, str(source))

from demo_shop.server import make_server


@pytest.fixture(scope="session")
def demo_url():
    server = make_server(port=0)
    thread = threading.Thread(target=server.serve_forever, kwargs={"poll_interval": 0.05}, daemon=True)
    thread.start()
    try:
        yield f"http://127.0.0.1:{server.server_address[1]}"
    finally:
        server.shutdown()
        server.server_close()
        thread.join(timeout=5)


@pytest.fixture
def browser():
    from qa_starter.browser import create_chrome

    driver = create_chrome()
    try:
        yield driver
    finally:
        driver.quit()
