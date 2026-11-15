"""One small, inspectable Page Object for the local demo login."""
from __future__ import annotations

from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


class LoginPage:
    def __init__(self, driver, base_url: str):
        self.driver = driver
        self.base_url = base_url

    def open(self) -> None:
        self.driver.get(f"{self.base_url}/login")
        WebDriverWait(self.driver, 5).until(EC.visibility_of_element_located((By.ID, "login-submit")))

    def submit(self, username: str, password: str) -> None:
        self.driver.find_element(By.ID, "username").send_keys(username)
        self.driver.find_element(By.ID, "password").send_keys(password)
        self.driver.find_element(By.ID, "login-submit").click()

    def wait_for_dashboard(self) -> str:
        element = WebDriverWait(self.driver, 5).until(
            EC.visibility_of_element_located((By.ID, "dashboard-title"))
        )
        return element.text

    def wait_for_error(self) -> str:
        element = WebDriverWait(self.driver, 5).until(
            EC.visibility_of_element_located((By.ID, "login-error"))
        )
        return element.text
