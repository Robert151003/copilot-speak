param(
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$Text,
    [switch]$Stdin
)
# Reads text aloud via Fish Audio. Does nothing unless the 'enabled' flag file exists.
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path (Join-Path $dir 'enabled'))) { exit 0 }

$key = $env:FISH_API_KEY
if (-not $key) {
    $line = Get-Content (Join-Path $dir '.env') -ErrorAction SilentlyContinue | Where-Object { $_ -match '^FISH_API_KEY=' } | Select-Object -First 1
    if ($line) { $key = $line.Substring(13).Trim() }
}
if (-not $key) { Write-Error 'No FISH_API_KEY'; exit 1 }

$msg = if ($Stdin) { [Console]::In.ReadToEnd() } else { $Text -join ' ' }
$msg = ($msg -replace '```[\s\S]*?```', ' code block ' -replace '[`*#>_\[\]]', '' -replace '\s+', ' ').Trim()
if (-not $msg) { exit 0 }
if ($msg.Length -gt 600) {
    $cut = $msg.Substring(0, 600)
    $i = $cut.LastIndexOfAny([char[]]'.!?')
    $msg = if ($i -gt 100) { $cut.Substring(0, $i + 1) } else { $cut }
}

$ErrorActionPreference = 'Stop'
$out = Join-Path $env:TEMP "fishspeak-$PID.wav"
$body = @{ text = $msg; format = 'wav' } | ConvertTo-Json -Compress
$bodyFile = Join-Path $env:TEMP "fishspeak-$PID.json"
[IO.File]::WriteAllText($bodyFile, $body)
& curl.exe -sf -X POST https://api.fish.audio/v1/tts -H "Authorization: Bearer $key" -H 'model: s2.1-pro-free' -H 'Content-Type: application/json' --data-binary "@$bodyFile" -o $out
Remove-Item $bodyFile -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) { Remove-Item $out -ErrorAction SilentlyContinue; Write-Error "Fish TTS request failed ($LASTEXITCODE)"; exit 1 }

# One voice at a time: stop any earlier playback
$pidFile = Join-Path $dir 'player.pid'
if (Test-Path $pidFile) { Stop-Process -Id ([int](Get-Content $pidFile)) -ErrorAction SilentlyContinue }
Set-Content $pidFile $PID
try { (New-Object System.Media.SoundPlayer $out).PlaySync() }
finally { Remove-Item $out -ErrorAction SilentlyContinue }
