# Copilot agentStop hook: reads the hook JSON from stdin, finds the last assistant reply in the transcript, speaks it.
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not (Test-Path (Join-Path $dir 'enabled'))) { exit 0 }
try {
    $in = [Console]::In.ReadToEnd() | ConvertFrom-Json
    $path = if ($in.transcriptPath) { $in.transcriptPath } else { $in.transcript_path }
    if (-not $path -or -not (Test-Path $path)) { exit 0 }
    $last = $null
    foreach ($l in Get-Content $path -Tail 200) {
        if ($l -notmatch '"type":"assistant.message"') { continue }
        $e = $l | ConvertFrom-Json
        if ($e.data.content) { $last = $e.data.content }
    }
    if (-not $last) { exit 0 }
    $speak = Join-Path $dir 'speak.ps1'
    $last | & powershell -NoProfile -File $speak -Stdin
} catch { exit 0 }
