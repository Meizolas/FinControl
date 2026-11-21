$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectRoot

if (-not (Test-Path "$projectRoot\backend\.env")) {
  Copy-Item "$projectRoot\backend\.env.example" "$projectRoot\backend\.env"
  Write-Host 'Configuração local criada em backend\.env.'
}

if (-not (Test-Path "$projectRoot\node_modules")) {
  Write-Host 'Instalando dependências Node.js...'
  npm install
}

Write-Host 'Iniciando PostgreSQL e Keycloak...'
docker compose up -d

Write-Host 'Preparando banco demonstrativo...'
npm run db:migrate
npm run db:seed

$api = Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction SilentlyContinue
if (-not $api) {
  Write-Host 'Iniciando API FinControl...'
  Start-Process -FilePath 'node.exe' `
    -ArgumentList 'src/server.js' `
    -WorkingDirectory "$projectRoot\backend" `
    -RedirectStandardOutput "$projectRoot\backend-dev.log" `
    -RedirectStandardError "$projectRoot\backend-dev-error.log" `
    -WindowStyle Hidden
}

$deadline = (Get-Date).AddSeconds(30)
do {
  Start-Sleep -Milliseconds 500
  try { $health = Invoke-RestMethod 'http://localhost:3000/health' -TimeoutSec 2 } catch { $health = $null }
} while (-not $health -and (Get-Date) -lt $deadline)

if (-not $health) { throw 'A API não iniciou. Consulte backend-dev-error.log.' }

Write-Host ''
Write-Host 'FinControl pronto para demonstração.' -ForegroundColor Green
Write-Host 'API: http://localhost:3000'
Write-Host 'Keycloak: http://localhost:8081'
Write-Host 'Web: execute .\INICIAR_WEB.ps1'
Write-Host 'No app ou navegador, abra "Entrar no modo demonstração" e escolha um perfil.'
