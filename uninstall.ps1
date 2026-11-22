$dest = Join-Path $env:USERPROFILE '.copilot\speak'
Remove-Item (Join-Path $env:USERPROFILE '.copilot\hooks\speak.json') -ErrorAction SilentlyContinue
Remove-Item $dest -Recurse -Force -ErrorAction SilentlyContinue
Write-Host 'copilot-speak removed (hook, scripts, and saved API key).'
