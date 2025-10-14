param(
    [switch]$Train,
    [switch]$Ngrok
)

# Directorio del script (debe ser la carpeta Bot_Personal)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $ScriptDir

Write-Host "== Bot_Personal starter ==" -ForegroundColor Cyan

# 1) Crear venv si no existe
$venvPy = Join-Path $ScriptDir ".venv\\Scripts\\python.exe"
if (-not (Test-Path $venvPy)) {
    Write-Host "Creando entorno virtual (.venv)..." -ForegroundColor Yellow
    $created = $false
    $candidates = @('-3.10','-3.11','-3.12','-3.13','')
    foreach ($ver in $candidates) {
        try {
            if ($ver -ne '') {
                & py $ver -m venv .venv 2>$null
            } else {
                & py -m venv .venv 2>$null
            }
        } catch { }
        if (Test-Path $venvPy) { $created = $true; break }
    }
    if (-not $created) {
        try { & python -m venv .venv 2>$null } catch { }
    }
}

if (-not (Test-Path $venvPy)) {
    Write-Error "No se pudo crear/encontrar .venv. Instala Python 3.10 (recomendado) o 3.11 y vuelve a ejecutar."
    Write-Host "Sugerencia: winget install Python.Python.3.10" -ForegroundColor DarkYellow
    exit 1
}

# Advertir si no es 3.10/3.11
$pyver = & $venvPy -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
# Forzar 3.10 para compatibilidad con Rasa
if ($pyver -ne '3.10') {
    Write-Host "El venv actual usa Python $pyver. Regenerando .venv con Python 3.10..." -ForegroundColor Yellow
    try { Remove-Item -Recurse -Force (Join-Path $ScriptDir ".venv") } catch { }
    $created = $false
    foreach ($ver in @('-3.10')) {
        try { & py $ver -m venv .venv 2>$null } catch { }
        if (Test-Path (Join-Path $ScriptDir ".venv\\Scripts\\python.exe")) { $created = $true; break }
    }
    if (-not $created) { try { & python -m venv .venv 2>$null } catch { } }

    $venvPy = Join-Path $ScriptDir ".venv\\Scripts\\python.exe"
    if (-not (Test-Path $venvPy)) {
        Write-Error "No se pudo recrear .venv con 3.10. Instala Python 3.10 y reintenta."
        exit 1
    }
    $pyver = & $venvPy -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')"
}

if ($pyver -ne '3.10') {
    Write-Host "Aviso: estás usando Python $pyver. Rasa puede no soportarlo completamente. Se recomienda 3.10." -ForegroundColor DarkYellow
}

# 2) Instalar dependencias si falta rasa
$RasaExe = Join-Path $ScriptDir ".venv\Scripts\rasa.exe"
Write-Host "Instalando dependencias desde requirements.txt..." -ForegroundColor Yellow
& $venvPy -m pip install --upgrade pip
& $venvPy -m pip install -r (Join-Path $ScriptDir "requirements.txt")

# Comprobar instalación de Rasa
if (-not (Test-Path $RasaExe)) {
    Write-Error "Rasa no se instaló correctamente en el entorno. Verifica la salida de pip e intenta nuevamente."
    exit 1
}

# 3) Cargar variables de entorno desde .env (si existe)
$envFile = Join-Path $ScriptDir ".env"
if (Test-Path $envFile) {
    Write-Host "Cargando variables de .env" -ForegroundColor DarkCyan
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^[#\s]') { return }
        $parts = $_.Split('=',2)
        if ($parts.Length -eq 2) {
            $key = $parts[0].Trim()
            $val = $parts[1].Trim()
            Set-Item -Path "Env:$key" -Value $val
        }
    }
}

# 4) Chequeos opcionales
# SWI-Prolog: intentar añadir al PATH si está instalado en la ruta típica de Windows
$swiplDir = 'C:\\Program Files\\swipl\\bin'
if (Test-Path (Join-Path $swiplDir 'swipl.exe')) {
    $pathParts = $env:Path -split ';'
    if (-not ($pathParts -contains $swiplDir)) {
        $env:Path = "$swiplDir;" + $env:Path
        Write-Host "Añadido SWI-Prolog al PATH para esta sesión." -ForegroundColor DarkCyan
    }
}
try { & swipl --version | Out-Null } catch { Write-Host "Aviso: SWI-Prolog no encontrado en PATH. Acciones Prolog no funcionarán." -ForegroundColor DarkYellow }

# 5) Entrenar si se pide o si no hay modelos
$ModelsDir = Join-Path $ScriptDir "models"
$shouldTrain = $Train -or -not (Test-Path $ModelsDir) -or -not (Get-ChildItem $ModelsDir -ErrorAction SilentlyContinue)
if ($shouldTrain) {
    Write-Host "Entrenando modelo..." -ForegroundColor Green
    & $RasaExe train
}

# 6) ngrok opcional (iniciar antes de levantar servidores para obtener URL)
$ngrokPublicUrl = $null
if ($Ngrok) {
    try {
        if ($env:NGROK_AUTHTOKEN -and $env:NGROK_AUTHTOKEN -ne "") {
            try { & ngrok config add-authtoken $env:NGROK_AUTHTOKEN | Out-Null } catch { }
        }
        # Iniciar ngrok en una ventana aparte
        Start-Process -FilePath "ngrok" -ArgumentList "http","5005" -WindowStyle Normal | Out-Null
        # Esperar hasta que el API local de ngrok exponga los túneles
        for ($i=0; $i -lt 30; $i++) {
            try {
                $tunnels = Invoke-RestMethod -Uri "http://127.0.0.1:4040/api/tunnels" -TimeoutSec 2 -ErrorAction Stop
                $httpsTunnel = $tunnels.tunnels | Where-Object { $_.proto -eq 'https' } | Select-Object -First 1
                if ($httpsTunnel) { $ngrokPublicUrl = $httpsTunnel.public_url; break }
            } catch { }
            Start-Sleep -Seconds 1
        }
        if ($ngrokPublicUrl) {
            Write-Host "ngrok URL: $ngrokPublicUrl" -ForegroundColor Cyan
        } else {
            Write-Host "No se pudo obtener la URL pública de ngrok aún. Puedes pegarla luego en credentials.yml manualmente." -ForegroundColor DarkYellow
        }
    } catch {
        Write-Host "No se pudo iniciar ngrok. Asegúrate de tenerlo instalado y en PATH." -ForegroundColor DarkYellow
    }
}

# 7) Levantar servidores en ventanas separadas
$ps = (Get-Command powershell).Source

# Action server
# Crear carpeta de logs y levantar servidores con logging
New-Item -ItemType Directory -Path (Join-Path $ScriptDir "logs") -Force | Out-Null

$actionCmd = "Set-Location `"$ScriptDir`"; $env:PYTHONIOENCODING='utf-8'; & .\.venv\\Scripts\\rasa run actions --debug 2>&1 | Tee-Object -FilePath `"$(Join-Path $ScriptDir 'logs\\actions.log')`" -Append"
Start-Process -FilePath $ps -ArgumentList "-NoExit","-Command", $actionCmd -WindowStyle Normal

# Rasa server
$credFile = Join-Path $ScriptDir "credentials.yml"
$credRest = Join-Path $ScriptDir "credentials.rest.yml"
$useCred = $credFile

$hasToken = ($env:TELEGRAM_API_TOKEN -and $env:TELEGRAM_API_TOKEN -ne "")
$hasBotUser = ($env:BOT_USERNAME -and $env:BOT_USERNAME -ne "")
$hasNgrok = ($ngrokPublicUrl -and $ngrokPublicUrl -ne "")

$hasPlaceholders = $false
if (Test-Path $credFile) {
    try { $credContent = Get-Content $credFile -Raw } catch { $credContent = "" }
    if ($credContent -match "<TU_TOKEN_DE_TELEGRAM>|<TU_USUARIO_DE_BOT>|<TU_DOMINIO_PUBLICO>") { $hasPlaceholders = $true }
} else {
    $useCred = $credRest
}

# Preferir credenciales runtime si tenemos todo para Telegram (token, usuario y URL ngrok)
if ($hasToken -and $hasBotUser -and $hasNgrok) {
    $runtimeCred = Join-Path $ScriptDir "credentials.runtime.yml"
@"
rest:

telegram:
  access_token: "$($env:TELEGRAM_API_TOKEN)"
  verify: "$($env:BOT_USERNAME)"
  webhook_url: "$($ngrokPublicUrl)/webhooks/telegram/webhook"

rasa:
  url: "http://localhost:5002/api"
"@ | Set-Content -Path $runtimeCred -NoNewline
    $useCred = $runtimeCred
    Write-Host "Generado credentials.runtime.yml con Telegram y webhook ($ngrokPublicUrl)." -ForegroundColor Cyan
} elseif ($useCred -eq $credRest -or $hasPlaceholders -or -not $hasToken) {
    $useCred = $credRest
    Write-Host "Usando credentials.rest.yml (REST solamente). Completa BOT_USERNAME y usa -Ngrok para habilitar Telegram." -ForegroundColor DarkYellow
}

$botCmd = "Set-Location `"$ScriptDir`"; $env:PYTHONIOENCODING='utf-8'; & .\\.venv\\Scripts\\rasa run --endpoints endpoints.yml --credentials `"$useCred`" --enable-api --debug 2>&1 | Tee-Object -FilePath `"$(Join-Path $ScriptDir 'logs\\server.log')`" -Append"
Start-Process -FilePath $ps -ArgumentList "-NoExit","-Command", $botCmd -WindowStyle Normal


Write-Host "Listo. Se abrieron ventanas para actions y server. Usa Ctrl+C en esas ventanas para detenerlos." -ForegroundColor Cyan
