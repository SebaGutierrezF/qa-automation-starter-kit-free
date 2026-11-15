# Two API pytest smoke tests; allows an explicitly chosen LOCAL Python environment.
[CmdletBinding()]
param([string]$PythonExecutable = '')
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$python = if ($PythonExecutable) { $PythonExecutable } else { Join-Path $root '.venv\Scripts\python.exe' }
$src = Join-Path $root 'src'
$tests = Join-Path $root 'tests\api'
$shared = $root
if (!(Test-Path -LiteralPath $tests -PathType Container)) {
    $src = Join-Path $root 'editions\free\src'
    $tests = Join-Path $root 'editions\free\tests\api'
    $shared = Join-Path $root 'shared'
}
if (!(Test-Path -LiteralPath $python -PathType Leaf)) {
    throw "Python environment not found: $python. Run inspect_offline_environment.ps1; provide wheels or use -PythonExecutable."
}
$python = (Resolve-Path -LiteralPath $python).Path
$env:NO_PROXY = '127.0.0.1,localhost'
$env:no_proxy = '127.0.0.1,localhost'
$env:PYTHONPATH = "$src;$shared"
$env:PIP_NO_INDEX = '1'
$env:PYTHONNOUSERSITE = '1'
$env:PYTEST_DISABLE_PLUGIN_AUTOLOAD = '1'
& $python -c "import importlib.metadata as m; assert m.version('pytest')=='8.3.4', 'Required pinned pytest==8.3.4'; print('API_PYTEST_PIN_OK')"
if ($LASTEXITCODE -ne 0) { throw 'Missing/mismatched pytest==8.3.4 in selected LOCAL Python.' }
$report = [System.IO.Path]::GetTempFileName()
try {
    & $python -m pytest -q -ra "--junitxml=$report" "$tests"
    if ($LASTEXITCODE -ne 0) { throw "QA_SK_002_API_FAIL: pytest exit code $LASTEXITCODE" }
    & $python (Join-Path $PSScriptRoot 'verify_pytest_junit.py') $report test_api_001_health test_api_002_catalog
    if ($LASTEXITCODE -ne 0) { throw 'API tests count/names mismatch or skipped cases' }
    Write-Host 'QA_SK_002_API_VERIFIED | TESTS=2 | OFFLINE_LOOPBACK_ONLY=True'
} finally {
    Remove-Item -LiteralPath $report -Force -ErrorAction SilentlyContinue
}
