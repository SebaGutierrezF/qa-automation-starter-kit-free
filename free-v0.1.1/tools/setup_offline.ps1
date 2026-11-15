# QA-SK-001: installs exclusively from locally provided wheels (never PyPI).
[CmdletBinding()]
param(
    [string]$PythonLauncher = 'py',
    [string]$PythonVersion = '3.12'
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$wheelhouse = Join-Path $root 'wheelhouse'
$requirements = Join-Path $root 'requirements-offline.txt'
if (!(Test-Path -LiteralPath $requirements -PathType Leaf)) { $requirements = Join-Path $root 'editions\free\requirements-offline.txt' }
$venv = Join-Path $root '.venv'
$python = Join-Path $venv 'Scripts\python.exe'

if (!(Test-Path -LiteralPath $requirements -PathType Leaf)) { throw 'Missing requirements-offline.txt' }
if (!(Test-Path -LiteralPath $wheelhouse -PathType Container)) {
    throw "Missing $wheelhouse . Provide compatible offline wheels (including transitives); no download attempted."
}
if (!(Get-ChildItem -LiteralPath $wheelhouse -File -Filter '*.whl' | Select-Object -First 1)) {
    throw 'wheelhouse is empty. No downloads are permitted.'
}
$env:PIP_NO_INDEX = '1'
$env:PIP_DISABLE_PIP_VERSION_CHECK = '1'
if (!(Test-Path -LiteralPath $python -PathType Leaf)) {
    & $PythonLauncher "-$PythonVersion" -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw "Could not create Python $PythonVersion venv" }
}
& $python -m pip install --no-index --find-links "$wheelhouse" -r "$requirements"
if ($LASTEXITCODE -ne 0) { throw 'Offline dependency installation failed. Check wheelhouse compatibility and complete transitives.' }
& $python -c "import importlib.metadata as m; assert m.version('pytest')=='8.3.4'; assert m.version('selenium')=='4.28.1'; print('OFFLINE_DEPENDENCIES_OK')"
if ($LASTEXITCODE -ne 0) { throw 'Pinned dependency version verification failed' }
Write-Host 'QA_SK_001_SETUP_OFFLINE_OK | NO_REMOTE_FETCH=True'
