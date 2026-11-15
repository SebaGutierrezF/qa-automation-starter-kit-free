# Four tests, exact pin versions and exact test names; no remote driver download.
[CmdletBinding()]
param([string]$PythonExecutable = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$python = if ($PythonExecutable) { $PythonExecutable } else { Join-Path $root '.venv\Scripts\python.exe' }
$src = Join-Path $root 'src'
$tests = Join-Path $root 'tests'
$shared = $root
if (!(Test-Path -LiteralPath $tests -PathType Container)) {
    $src = Join-Path $root 'editions\free\src'
    $tests = Join-Path $root 'editions\free\tests'
    $shared = Join-Path $root 'shared'
}
if (!(Test-Path -LiteralPath $python -PathType Leaf)) {
    throw "Python environment not found: $python. Run inspect_offline_environment.ps1; provide wheels or use -PythonExecutable."
}
$python = (Resolve-Path -LiteralPath $python).Path
if ([string]::IsNullOrWhiteSpace($env:CHROMEDRIVER_PATH) -or !(Test-Path -LiteralPath $env:CHROMEDRIVER_PATH -PathType Leaf)) {
    throw 'CHROMEDRIVER_PATH must point to a LOCAL chromedriver.exe; automatic download is disabled.'
}
if ($env:CHROME_BINARY -and !(Test-Path -LiteralPath $env:CHROME_BINARY -PathType Leaf)) {
    throw 'CHROME_BINARY points to a non-existing local executable.'
}
$env:NO_PROXY = '127.0.0.1,localhost'
$env:no_proxy = '127.0.0.1,localhost'
$env:PYTHONPATH = "$src;$shared"
$env:QA_HEADLESS = if ($env:QA_HEADLESS) { $env:QA_HEADLESS } else { '1' }
$env:PIP_NO_INDEX = '1'
$env:PYTHONNOUSERSITE = '1'
$env:PYTEST_DISABLE_PLUGIN_AUTOLOAD = '1'
& $python -c "import importlib.metadata as m; assert m.version('pytest')=='8.3.4', 'Required pinned pytest==8.3.4'; assert m.version('selenium')=='4.28.1', 'Required pinned selenium==4.28.1'; print('UI_DEPENDENCIES_PINNED_OK')"
if ($LASTEXITCODE -ne 0) { throw 'Missing/mismatched pinned dependencies in LOCAL Python.' }
$report = [System.IO.Path]::GetTempFileName()
try {
    & $python -m pytest -q -ra "--junitxml=$report" "$tests"
    if ($LASTEXITCODE -ne 0) { throw "QA_SK_002_FREE_FAIL: pytest exit code $LASTEXITCODE" }
    & $python (Join-Path $PSScriptRoot 'verify_pytest_junit.py') $report test_api_001_health test_api_002_catalog test_ui_001_login_success test_ui_002_invalid_login
    if ($LASTEXITCODE -ne 0) { throw 'Full test count/names mismatch or skipped cases' }
    Write-Host 'QA_SK_002_FREE_VERIFIED | TESTS=4 | OFFLINE_LOOPBACK_ONLY=True'
} finally {
    Remove-Item -LiteralPath $report -Force -ErrorAction SilentlyContinue
}
