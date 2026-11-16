# QA Automation Starter Kit — Community Free v0.1.1 (alpha)

A small Python project for practicing **API tests with pytest** and **browser tests with Selenium** on Windows. It includes a demo web app that runs on your machine. The tests run against that local app, not a public website or a real account.

**[Download v0.1.1 (ZIP)](https://github.com/SebaGutierrezF/qa-automation-starter-kit-free/releases/download/v0.1.1/qa-automation-starter-kit-free-v0.1.1.zip)** · [Browse source](free-v0.1.1/) · [Report an issue](https://github.com/SebaGutierrezF/qa-automation-starter-kit-free/issues)

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

The Free code is [MIT-licensed](LICENSE); dependencies have their own licenses ([notices](free-v0.1.1/THIRD_PARTY_NOTICES.md)). If it helped you, a star or feedback is appreciated. [Buy Me a Coffee](https://buymeacoffee.com/sebagutierrezf) is optional; no payment is required to use the project.
