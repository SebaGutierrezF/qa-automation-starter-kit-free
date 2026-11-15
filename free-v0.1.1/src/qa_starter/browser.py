"""Offline Selenium Chrome factory: never invokes Selenium Manager downloads."""
from __future__ import annotations

import os
from pathlib import Path


def create_chrome():
    """Create Chrome with a mandatory preinstalled ChromeDriver executable.

    Deliberately import Selenium only here: API tests stay stdlib-only.
    """
    driver_path = os.environ.get("CHROMEDRIVER_PATH", "").strip().strip('"')
    if not driver_path:
        raise RuntimeError("CHROMEDRIVER_PATH is required: install ChromeDriver locally; automatic download is disabled.")
    exe = Path(driver_path).expanduser()
    if not exe.is_file():
        raise RuntimeError(f"ChromeDriver not found: {exe}")

    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.chrome.service import Service

    options = Options()
    if os.environ.get("QA_HEADLESS", "1").strip().lower() not in ("0", "false", "no"):
        options.add_argument("--headless=new")
    options.add_argument("--window-size=1280,960")
    options.add_argument("--no-first-run")
    options.add_argument("--no-default-browser-check")
    options.add_argument("--disable-background-networking")
    options.add_argument("--disable-extensions")
    options.add_argument("--disable-sync")
    options.add_argument("--disable-component-update")
    options.add_argument("--dns-prefetch-disable")
    options.add_argument("--proxy-server=direct://")
    options.add_argument("--proxy-bypass-list=*")

    binary = os.environ.get("CHROME_BINARY", "").strip().strip('"')
    if binary:
        path = Path(binary).expanduser()
        if not path.is_file():
            raise RuntimeError(f"Chrome executable not found: {path}")
        options.binary_location = str(path)

    driver = webdriver.Chrome(service=Service(executable_path=str(exe)), options=options)
    driver.set_page_load_timeout(10)
    return driver
