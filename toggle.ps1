param([Parameter(Position = 0)][ValidateSet('on', 'off', 'status', 'key')][string]$Action = 'status')
# Usage: .\toggle.ps1 on | off | status | key
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$flag = Join-Path $dir 'enabled'
switch ($Action) {
    'on'  { New-Item $flag -ItemType File -Force | Out-Null; 'Speech is ON' }
    'off' { Remove-Item $flag -ErrorAction SilentlyContinue; 'Speech is OFF' }
    'key' {
        $env = Join-Path $dir '.env'
        if (-not (Test-Path $env)) { Copy-Item (Join-Path $dir '.env.example') $env }
        icacls $env /inheritance:r /grant:r "$($env:USERNAME):F" | Out-Null
        notepad $env
    }
    default { if (Test-Path $flag) { 'Speech is ON' } else { 'Speech is OFF' } }
}
