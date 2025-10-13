# Bot_Personal (Rasa)

Guía rápida para instalar, entrenar y ejecutar este bot en Windows (PowerShell).

## Requisitos

- Windows 10/11
- Python 3.10 instalado (recomendado)
- SWI‑Prolog instalado y en PATH (para `swiplserver`)
- Acceso a Internet (instalación de dependencias)
- Opcional: ngrok si deseas usar Telegram públicamente

## Preparar entorno

```powershell
cd c:\Users\igjua\OneDrive\Documentos\GitHub\Portafolio\Bot_Personal
py -3.10 -m venv .venv ; .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install -r requirements.txt
```

Configura el token de Telegram como variable de entorno si vas a usar Telegram:

```powershell
$env:TELEGRAM_API_TOKEN = "<TU_TOKEN_DE_TELEGRAM>"
```

## Entrenamiento

```powershell
rasa train
```

## Ejecutar

- Ventana 1: Servidor de acciones

```powershell
rasa run actions
```

- Ventana 2: Bot (con API y canales)

```powershell
rasa run --endpoints endpoints.yml --credentials credentials.yml --enable-api
```

- Prueba en consola (simple):

```powershell
rasa shell
```

Nota: Varias acciones dependen de metadatos de Telegram, por lo que podrían no funcionar en `rasa shell`. Prueba por el canal Telegram para flujo completo.

## Telegram (opcional)

1. Ajusta `credentials.yml` con tu `access_token` y `webhook_url`.
2. Lanza ngrok:

```powershell
ngrok http 5005
```

3. Copia la URL pública de ngrok en `credentials.yml` (campo `webhook_url`).
4. Reinicia `rasa run`.

## Google Calendar (opcional)

- Deja `credentials.json` en esta carpeta (ya existe).
- En el primer uso se abrirá un navegador para autorizar; se generará `token.json`.

## Prolog (opcional)

- Asegúrate de tener SWI‑Prolog instalado y en PATH (`swipl --version`).
- El archivo `Materias(Sistemas).pl` se carga desde `actions/` con ruta relativa.

## Solución de problemas

- Problemas instalando Rasa en Windows: usa Python 3.10 y actualiza `pip`. Reintenta `pip install rasa`.
- Acciones fallan en consola: prueba por Telegram; esas acciones usan `latest_message.metadata`.
- Error de Prolog: verifica que el puerto 8000 esté libre y que `swipl` esté en PATH.
- Token de Telegram no configurado: exporta `TELEGRAM_API_TOKEN` antes de correr.

## Scripts útiles

- Limpiar modelos antiguos: elimina la carpeta `models/`.
- Regenerar token de Google: borra `token.json` y vuelve a ejecutar una acción de calendario.

## Automatización (start.ps1)

Puedes arrancar todo con un script que crea el venv si hace falta, instala dependencias, entrena (si no hay modelos) y abre dos ventanas: acciones y servidor.

```powershell
# En la carpeta Bot_Personal
./start.ps1

# Forzar entrenamiento
./start.ps1 -Train

# Iniciar también ngrok (si está instalado)
./start.ps1 -Ngrok
```

Variables de entorno: copia `.env.example` a `.env` y completa `TELEGRAM_API_TOKEN` si usarás Telegram. El script las cargará automáticamente.
