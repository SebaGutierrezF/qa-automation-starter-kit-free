<h1 align="center">🧪 QA Automation Starter Kit</h1>

<p align="center"><strong>Community Free · v0.1.1 (Alpha)</strong></p>

<p align="center">
  A small Python project for practicing API tests with pytest and browser tests with Selenium.<br />
  Four tests against an included local demo app — no production accounts or websites.
</p>

<p align="center">
  <a href="https://github.com/SebaGutierrezF/qa-automation-starter-kit-free/releases/download/v0.1.1/qa-automation-starter-kit-free-v0.1.1.zip">
    <img alt="Download Free v0.1.1 ZIP" src="https://img.shields.io/badge/Download-Free%20ZIP-2E8B67?style=for-the-badge" />
  </a>
  <a href="free-v0.1.1/">
    <img alt="Browse the source code" src="https://img.shields.io/badge/Browse-Source-3677B8?style=for-the-badge" />
  </a>
  <a href="https://github.com/SebaGutierrezF/qa-automation-starter-kit-free/issues">
    <img alt="Report an issue" src="https://img.shields.io/badge/Share-Feedback-56677B?style=for-the-badge" />
  </a>
</p>

<p align="center">
  <img alt="Python 3.12" src="https://img.shields.io/badge/Python-3.12-3776AB?logo=python&logoColor=white" />
  <img alt="Selenium 4.28.1" src="https://img.shields.io/badge/Selenium-4.28.1-43B02A?logo=selenium&logoColor=white" />
  <img alt="pytest 8.3.4" src="https://img.shields.io/badge/pytest-8.3.4-0A9EDC?logo=pytest&logoColor=white" />
  <img alt="Windows 10 and 11" src="https://img.shields.io/badge/Windows-10%20%2F%2011-0078D4?logo=windows&logoColor=white" />
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-2F8F56" /></a>
</p>

---

## Preview

<p align="center">
  <a href="docs/assets/free-preview.svg">
    <img src="docs/assets/free-preview.svg" alt="Illustration of the local login demo and the four pytest checks" width="900" />
  </a>
</p>

*Illustration based on the included demo app and test cases, not an actual application screenshot. The release has no hosted dashboard.*

## What does it test?

The release contains **four tests**:

| Test | Check |
| --- | --- |
| [`test_api_001_health`](free-v0.1.1/tests/api/test_catalog.py) | The local `GET /api/health` endpoint returns HTTP 200 and the expected data. |
| [`test_api_002_catalog`](free-v0.1.1/tests/api/test_catalog.py) | The demo catalog returns two products with positive prices. |
| [`test_ui_001_login_success`](free-v0.1.1/tests/ui/test_login.py) | A fictional user can sign in and see the dashboard. |
| [`test_ui_002_invalid_login`](free-v0.1.1/tests/ui/test_login.py) | A wrong password produces an error message. |

The source also includes a [local demo server](free-v0.1.1/demo_shop/server.py), a small [API client](free-v0.1.1/src/qa_starter/api_client.py), a [Selenium Page Object](free-v0.1.1/src/qa_starter/pages/login_page.py), and PowerShell scripts to run the tests.

This is a **small learning example**, not a production-ready testing framework or a tool that automatically adapts to other websites. The demo server binds to `127.0.0.1` only.

## What you need

- Windows 10/11, PowerShell and Python **3.12** (the version validated locally).
- For API tests: pytest **8.3.4**.
- For UI tests: Selenium **4.28.1**, Chrome, and a matching local ChromeDriver.

**Known setup limitation:** dependencies, wheel files, Chrome and ChromeDriver are **not bundled**. The setup script is offline-only and **does not download missing packages**. You must already have a compatible Python environment or supply a complete local `wheelhouse/`. This is not a one-click installer.

## Running the tests

Download and extract the release ZIP, then open PowerShell in the **extracted folder** that contains `tools/` and `tests/`.

First, inspect which Python environments and drivers are already available:

```powershell
.\tools\inspect_offline_environment.ps1
```

**Option A — use an existing Python environment with the pinned packages:**

```powershell
# Replace both paths with your own.
$python = 'C:\path\to\venv\Scripts\python.exe'

# API tests: no browser required
.\tools\verify_api.ps1 -PythonExecutable $python

# All four tests: Chrome and ChromeDriver required
$env:CHROMEDRIVER_PATH = 'C:\path\to\chromedriver.exe'
.\tools\verify_free.ps1 -PythonExecutable $python
```

**Option B — install from a complete offline wheelhouse:**

Copy compatible wheels, including transitive dependencies, into a `wheelhouse/` folder next to `tools/`, then run:

```powershell
.\tools\setup_offline.ps1
.\tools\verify_api.ps1

$env:CHROMEDRIVER_PATH = 'C:\path\to\chromedriver.exe'
.\tools\verify_free.ps1
```

With the required environment, the API script expects **2 passing tests** and the full script expects **4 passing tests**. Missing dependencies or a missing driver cause a visible error; browser tests are not silently skipped.

After **Option B** you can view the demo manually:

```powershell
.\.venv\Scripts\python.exe -m demo_shop.server
# Open http://127.0.0.1:8765/login
```

Stop it with Ctrl+C. The login details displayed by the demo are fictional test data.

## Manual GitHub Actions check (API only)

A [manual CI workflow](.github/workflows/manual-free-api-pytest.yml) is available for **API-001** and **API-002**, using a standard Ubuntu runner with Python 3.12 and pytest 8.3.4.

To run it, open **Actions → QA Free API tests (manual) → Run workflow → main**. It runs **only on request** (not on push, PR, or a schedule) and has a 5-minute job timeout.

The workflow runs the demo HTTP server on loopback through pytest fixtures and checks that the JUnit XML contains **exactly the two expected API case names**, without failures, errors or skips. It installs pytest from PyPI in the ephemeral CI runner; **this does not change the offline-only setup behavior of the released ZIP**.

**Scope:** this is **not** the four-test API+Selenium suite, and the workflow does not install Chrome or ChromeDriver. The four-test Windows execution and its [sanitized evidence](https://sebagutierrezf.github.io/proyectos/evidencia-qa.html) are documented separately. The first successful CI run is still required before claiming the API workflow itself has passed.

## Release integrity

The [v0.1.1 ZIP](https://github.com/SebaGutierrezF/qa-automation-starter-kit-free/releases/tag/v0.1.1) has this SHA-256:

```text
f88f82e98db0de6c7cc290205ee3e132f5388fcd6b23d6a1a5111767b32b1646
```

To verify a download on Windows:

```powershell
Get-FileHash .\qa-automation-starter-kit-free-v0.1.1.zip -Algorithm SHA256
```

The [`free-v0.1.1/` source snapshot](free-v0.1.1/) is preserved as released. Its bundled README and manifest still say **“not published”** because they were generated *before* the GitHub release; that wording is outdated archival metadata. The original ZIP and its hash have not been changed.

## Feedback

I'm looking for feedback from people who didn't build this project. If you try it, [open an issue](https://github.com/SebaGutierrezF/qa-automation-starter-kit-free/issues) and tell me what you ran, where setup stopped, and which instructions were confusing.

Include Python/browser/driver versions and the relevant error message, but **remove personal paths, usernames, tokens or other private data** first.

I know the offline dependency requirement makes onboarding harder. I want to learn whether the examples and docs are useful before expanding this alpha.

## License and optional support

The Free code is [MIT-licensed](LICENSE); dependencies have their own licenses ([third-party notices](free-v0.1.1/THIRD_PARTY_NOTICES.md)). Feedback and stars are appreciated. Supporting development is optional and never required to download or use Free.

<p align="center">
  <a href="https://buymeacoffee.com/sebagutierrezf">
    <img alt="Buy Me a Coffee — optional support" src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Optional%20support-FFDD00?logo=buymeacoffee&logoColor=black" />
  </a>
</p>

<details>
<summary><strong>Optional Pro edition — $49 one-time purchase</strong></summary>

[QA Automation Starter Kit Pro v1.0.0](https://sebagutierrez3.gumroad.com/l/qa-automation-starter-kit-pro) is a separate proprietary source-code ZIP with **16 Pro tests and 2 local Helpdesk examples**, reusable Page Object components, an HTML report for the 16 core cases, and JUnit results. It was validated by the seller on Windows.

**Before buying:** the documented setup requires Python 3.12, Chrome, a matching ChromeDriver and a prepared offline wheelhouse. ChromeDriver and wheel files are **not included**. This is a developer toolkit, not a one-click installer; adapting it to other apps requires programming work.

Free remains available independently under the MIT license. You do not need Pro to run the four Free tests.

</details>
