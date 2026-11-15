"""Two browser tests on the local application; Selenium + local ChromeDriver required."""
from qa_starter.pages.login_page import LoginPage


def test_ui_001_login_success(browser, demo_url):
    page = LoginPage(browser, demo_url)
    page.open()
    page.submit("qa_demo", "demo-only-123")
    assert page.wait_for_dashboard() == "QA Demo Dashboard"


def test_ui_002_invalid_login(browser, demo_url):
    page = LoginPage(browser, demo_url)
    page.open()
    page.submit("qa_demo", "wrong-for-test")
    assert page.wait_for_error() == "Invalid credentials"
