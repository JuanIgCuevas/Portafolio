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


## Ejecución sencilla con Telegram

1. **Copia y edita tu archivo de entorno:**
	- Copia `.env.example` a `.env`.
	- Completa los valores:
	  - `TELEGRAM_API_TOKEN=tu_token_de_telegram`
	  - `BOT_USERNAME=JuanIgCuevasBot` (o el nombre de tu bot)
	  - `NGROK_AUTHTOKEN=tu_token_de_ngrok` (si usas ngrok)

2. **Ejecuta el starter automático:**
	- Abre PowerShell en la carpeta `Bot_Personal`.
	- Ejecuta:
	  ```powershell
	  ./start.ps1 -Ngrok
	  ```
	- Esto:
	  - Crea el entorno virtual y instala dependencias si hace falta.
	  - Entrena el modelo si no existe.
	  - Inicia ngrok y obtiene la URL pública.
	  - Genera `credentials.runtime.yml` con tus datos y la URL de ngrok.
	  - Abre dos ventanas: una para el action server y otra para el bot.
	  - Guarda logs en `logs/actions.log` y `logs/server.log`.

3. **Probar el bot por Telegram:**
	- Escribe a tu bot en Telegram (@JuanIgCuevasBot).
	- Espera unos segundos si es la primera vez (puede demorar en cargar TensorFlow).
	- Si no responde, revisa los logs para ver errores.

4. **Notas sobre credenciales:**
	- No edites manualmente `credentials.runtime.yml`; el script lo genera cada vez.
	- `credentials.yml` es solo plantilla, no debe tener secretos.
	- Los secretos y logs están ignorados en `.gitignore`.

5. **Modo REST (sin Telegram):**
	- Si no completas el token o no usas ngrok, el bot se ejecuta solo por REST.
	- Puedes probar con:
	  ```powershell
	  ./start.ps1
	  ```

---

Este flujo te permite ejecutar el bot con Telegram de forma sencilla y segura, sin editar archivos de credenciales manualmente. Solo necesitas completar `.env` y correr el script.
