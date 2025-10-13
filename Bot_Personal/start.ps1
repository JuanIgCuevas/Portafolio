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
# SWI-Prolog
try { & swipl --version | Out-Null } catch { Write-Host "Aviso: SWI-Prolog no encontrado en PATH. Acciones Prolog no funcionarán." -ForegroundColor DarkYellow }

# 5) Entrenar si se pide o si no hay modelos
$ModelsDir = Join-Path $ScriptDir "models"
$shouldTrain = $Train -or -not (Test-Path $ModelsDir) -or -not (Get-ChildItem $ModelsDir -ErrorAction SilentlyContinue)
if ($shouldTrain) {
    Write-Host "Entrenando modelo..." -ForegroundColor Green
    & $RasaExe train
}

# 6) Levantar servidores en ventanas separadas
$ps = (Get-Command powershell).Source

# Action server
$actionCmd = "Set-Location `"$ScriptDir`"; & .\.venv\\Scripts\\rasa run actions"
Start-Process -FilePath $ps -ArgumentList "-NoExit","-Command", $actionCmd -WindowStyle Normal

# Rasa server
$credFile = Join-Path $ScriptDir "credentials.yml"
$credRest = Join-Path $ScriptDir "credentials.rest.yml"
$useCred = $credFile
if (Test-Path $credFile) {
    try {
        $credContent = Get-Content $credFile -Raw
    } catch { $credContent = "" }
    # Si no hay token en .env o el credentials.yml tiene placeholders, usar el de solo REST
    if (-not $env:TELEGRAM_API_TOKEN -or $env:TELEGRAM_API_TOKEN -eq "" -or ($credContent -match "<TU_TOKEN_DE_TELEGRAM>")) {
        $useCred = $credRest
        Write-Host "Usando credentials.rest.yml (REST solamente) porque no hay token de Telegram configurado." -ForegroundColor DarkYellow
    }
} else {
    $useCred = $credRest
}

$botCmd = "Set-Location `"$ScriptDir`"; & .\\.venv\\Scripts\\rasa run --endpoints endpoints.yml --credentials `"$useCred`" --enable-api"
Start-Process -FilePath $ps -ArgumentList "-NoExit","-Command", $botCmd -WindowStyle Normal

# 7) ngrok opcional
if ($Ngrok) {
    try {
        Start-Process -FilePath "ngrok" -ArgumentList "http","5005" -WindowStyle Normal
        Write-Host "ngrok iniciado. Copia la URL pública y colócala en credentials.yml (webhook_url)." -ForegroundColor Cyan
    } catch {
        Write-Host "No se pudo iniciar ngrok. Asegúrate de tenerlo instalado y en PATH." -ForegroundColor DarkYellow
    }
}

Write-Host "Listo. Se abrieron ventanas para actions y server. Usa Ctrl+C en esas ventanas para detenerlos." -ForegroundColor Cyan
