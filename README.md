# QA Automation Starter Kit — Community Free v0.1.1

**A free MIT-licensed Python QA automation starter kit for local learning.**

This edition includes **4 executable examples**: **2 API tests** and **2 Selenium UI tests**, against a local demonstration shop (`127.0.0.1`). It is not a hosted service or a ready-made integration with arbitrary third-party websites.

## Get the code

- **Certified original ZIP:** [`releases/qa-automation-starter-kit-free-v0.1.1.zip`](releases/qa-automation-starter-kit-free-v0.1.1.zip) (SHA-256: `f88f82e98db0de6c7cc290205ee3e132f5388fcd6b23d6a1a5111767b32b1646`).
- **Browsable source:** [`free-v0.1.1/`](free-v0.1.1/). This is the *unchanged* source from the certified ZIP, including its original manifest and its historical alpha README.

## Requirements

Windows 10/11, PowerShell, Python 3.12, pytest **8.3.4**, Selenium **4.28.1**, Google Chrome and compatible ChromeDriver. Python dependencies, wheels, Chrome and ChromeDriver are **not bundled**. The scripts deliberately avoid network downloads; supply dependencies from an existing compatible local Python environment or complete `wheelhouse/`.

## Run locally

Extract the certified ZIP and switch into the directory that it creates, then follow its `README.md`. With a complete local wheelhouse and compatible ChromeDriver:

```powershell
$env:CHROMEDRIVER_PATH = 'C:\your-tools\chromedriver.exe' # replace with your real path
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\setup_offline.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\verify_api.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\verify_free.ps1
```

Expected: **2 API passes** and **4 total passes** in the full run. The installer will stop rather than fetch missing dependencies. The application only listens on local loopback; no real account or external service is needed.

## License

The Community Free source is MIT licensed; see [LICENSE](LICENSE) and [third-party notices](free-v0.1.1/THIRD_PARTY_NOTICES.md). Dependencies have their own terms.

## Professional Pro

A separate, proprietary Pro edition contains 16 Pro examples and 2 additional local Helpdesk examples, HTML/JUnit reporting, logging and guided setup. Its store is currently in approval/testing. **No live checkout link is provided until the seller authorizes a public launch.**

## Important

This is a small instructional kit, not a security tool, commercial SaaS product or automatic testing solution for any website. Please avoid placing credentials, production data or unauthorized URLs in tests.
