$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& "$projectRoot\INICIAR_DEMO.ps1"

Set-Location "$projectRoot\frontend"
Write-Host ''
Write-Host 'Preparando FinControl Web...' -ForegroundColor Cyan
flutter pub get

Write-Host ''
Write-Host 'Abrindo http://localhost:5173 no Chrome...' -ForegroundColor Green
Write-Host 'Mantenha este terminal aberto durante a demonstração.'
flutter run -d chrome --web-port 5173
