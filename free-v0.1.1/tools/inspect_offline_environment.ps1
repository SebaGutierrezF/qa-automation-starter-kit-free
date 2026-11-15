# QA-SK-002. Read-only inventory. Does not install packages or access the network.
[CmdletBinding()]
param(
    [string]$SearchRoot = '',
    [string[]]$PythonPaths = @()
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not $SearchRoot) { $SearchRoot = (Resolve-Path (Join-Path $root '..')).Path }
Write-Host "QA_SK_002_OFFLINE_DIAG | ROOT=$root | NO_INSTALL=True | NETWORK=NOT_USED"
$wheelhouse = Join-Path $root 'wheelhouse'
if (Test-Path -LiteralPath $wheelhouse -PathType Container) {
    $wheels = @(Get-ChildItem -LiteralPath $wheelhouse -File -Filter '*.whl')
    Write-Host "WHEELHOUSE=FOUND | COUNT=$($wheels.Count) | PATH=$wheelhouse"
} else {
    Write-Host "WHEELHOUSE=MISSING | PATH=$wheelhouse"
}

# Only one level of sibling projects is inspected: no recursion over private repos.
$candidates = New-Object 'System.Collections.Generic.List[string]'
$seen = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
foreach ($item in $PythonPaths) { if ($item) { $candidates.Add($item) } }
if ($env:VIRTUAL_ENV) { $candidates.Add((Join-Path $env:VIRTUAL_ENV 'Scripts\python.exe')) }
$candidates.Add((Join-Path $root '.venv\Scripts\python.exe'))
if ($env:LOCALAPPDATA) {
    foreach ($pyVer in @('Python312','Python313')) {
        $candidates.Add((Join-Path $env:LOCALAPPDATA "Programs\Python\$pyVer\python.exe"))
    }
}
if (Test-Path -LiteralPath $SearchRoot -PathType Container) {
    foreach ($dir in (Get-ChildItem -LiteralPath $SearchRoot -Directory -ErrorAction SilentlyContinue)) {
        $candidates.Add((Join-Path $dir.FullName '.venv\Scripts\python.exe'))
        $candidates.Add((Join-Path $dir.FullName 'venv\Scripts\python.exe'))
    }
}
foreach ($command in @('python.exe', 'python')) {
    $cmd = Get-Command $command -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) { $candidates.Add($cmd.Source) }
}
$found = 0
$readyApi = 0
$readyUi = 0
$probe = "import sys,importlib.metadata as m; get=lambda x: next((d.version for d in m.distributions() if (d.metadata.get('Name') or '').lower()==x), 'missing'); print('PYTHON='+sys.version.split()[0]+' | PYTEST='+get('pytest')+' | SELENIUM='+get('selenium'))"
foreach ($candidate in $candidates) {
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) { continue }
    $full = (Resolve-Path -LiteralPath $candidate).Path
    if (-not $seen.Add($full)) { continue }
    $result = & $full -c $probe 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "PYTHON_PROBE_FAILED | PATH=$full"
        continue
    }
    $line = ($result | Out-String).Trim()
    Write-Host "LOCAL_PYTHON | PATH=$full | $line"
    $found++
    if ($line -match 'PYTEST=8\.3\.4') { $readyApi++ }
    if ($line -match 'PYTEST=8\.3\.4' -and $line -match 'SELENIUM=4\.28\.1') {
        $readyUi++
        Write-Host "EXACT_PIN_CANDIDATE=$full"
    }
}
Write-Host "LOCAL_PYTHONS_FOUND=$found | API_PIN_CANDIDATES=$readyApi | UI_PIN_CANDIDATES=$readyUi"
if ($env:CHROMEDRIVER_PATH -and (Test-Path -LiteralPath $env:CHROMEDRIVER_PATH -PathType Leaf)) {
    Write-Host "CHROMEDRIVER=FOUND | PATH=$env:CHROMEDRIVER_PATH"
} else {
    $driver = Get-Command chromedriver.exe -ErrorAction SilentlyContinue
    if ($driver -and $driver.Source) { Write-Host "CHROMEDRIVER_ON_PATH=$($driver.Source)" }
    else { Write-Host 'CHROMEDRIVER=NOT_CONFIGURED' }
}
$chromeKnown = @()
if ($env:ProgramFiles) { $chromeKnown += Join-Path $env:ProgramFiles 'Google\Chrome\Application\chrome.exe' }
if (${env:ProgramFiles(x86)}) { $chromeKnown += Join-Path ${env:ProgramFiles(x86)} 'Google\Chrome\Application\chrome.exe' }
$chromeKnown = @($chromeKnown | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })
if ($env:CHROME_BINARY -and (Test-Path -LiteralPath $env:CHROME_BINARY -PathType Leaf)) {
    Write-Host "CHROME=FOUND | PATH=$env:CHROME_BINARY"
} elseif ($chromeKnown.Count -gt 0) {
    Write-Host "CHROME=FOUND | PATH=$($chromeKnown[0])"
} else { Write-Host 'CHROME=NOT_FOUND_IN_DEFAULT_LOCATIONS' }
Write-Host 'QA_SK_002_DIAG_COMPLETE | NO_REMOTE_FETCH=True | NO_MUTATIONS=True'
