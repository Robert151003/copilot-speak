# copilot-speak installer. Safe to re-run.
#   One-liner:  irm https://raw.githubusercontent.com/Robert151003/copilot-speak/main/install.ps1 | iex
#   From clone: .\install.ps1
$ErrorActionPreference = 'Stop'
$repoRaw = 'https://raw.githubusercontent.com/Robert151003/copilot-speak/main'
$files = 'speak.ps1', 'hook.ps1', 'toggle.ps1', '.env.example'
$dest = Join-Path $env:USERPROFILE '.copilot\speak'
$src = if ($PSCommandPath) { Split-Path -Parent $PSCommandPath } else { $null }

New-Item -ItemType Directory $dest -Force | Out-Null
foreach ($f in $files) {
    if ($src -and (Test-Path (Join-Path $src $f)) -and ($src -ne $dest)) {
        Copy-Item (Join-Path $src $f) (Join-Path $dest $f) -Force
    } elseif (-not $src) {
        Invoke-WebRequest "$repoRaw/$f" -OutFile (Join-Path $dest $f) -UseBasicParsing
    }
}

$envFile = Join-Path $dest '.env'
$hasKey = (Test-Path $envFile) -and (Select-String -Path $envFile -Pattern '^FISH_API_KEY=\S+' -Quiet)
if (-not $hasKey) {
    Write-Host 'Get a Fish Audio API key at https://fish.audio/app/api-keys/'
    $secure = Read-Host 'Paste your Fish Audio API key' -AsSecureString
    $key = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
    if (-not $key) { throw 'No key entered.' }
    Set-Content $envFile "FISH_API_KEY=$key"
    icacls $envFile /inheritance:r /grant:r "$($env:USERNAME):F" | Out-Null
}

# Register the Copilot agentStop hook (user-level)
$hooksDir = Join-Path $env:USERPROFILE '.copilot\hooks'
New-Item -ItemType Directory $hooksDir -Force | Out-Null
$cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$dest\hook.ps1`""
@{ version = 1; hooks = @{ agentStop = @(@{ type = 'command'; powershell = $cmd; bash = $cmd; timeoutSec = 60 }) } } |
    ConvertTo-Json -Depth 6 | Set-Content (Join-Path $hooksDir 'speak.json')

New-Item (Join-Path $dest 'enabled') -ItemType File -Force | Out-Null

Write-Host 'Installed. Testing voice...'
& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dest 'speak.ps1') 'copilot speak is installed and on.'
Write-Host "Done. Toggle with: $dest\toggle.ps1 on|off|status"
