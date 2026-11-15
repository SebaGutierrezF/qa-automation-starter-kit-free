# QA Automation Starter Kit — Community Free Alpha v0.1.1

**Estado:** prototipo local NO publicado. Incluye 4 pruebas: 2 UI (Selenium + ChromeDriver local) y 2 API (stdlib + pytest). La tienda de ejemplo solo se liga a `127.0.0.1` con puerto efímero.

## Requisitos

- Windows 10/11, PowerShell, Python 3.12 o 3.13, `py` disponible.
- Un directorio local `wheelhouse/` con *todas* las ruedas requeridas por pytest 8.3.4, Selenium 4.28.1 y sus dependencias transitivas, compatibles con tu Python y Windows. **No se incluyen wheels** en el ZIP.
- Chrome y ChromeDriver instalados localmente, compatibles entre sí. La ruta a `chromedriver.exe` se proporciona por `CHROMEDRIVER_PATH`.
- Sin conexiones externas. `pip` usa `--no-index` y Selenium recibe la ruta directa del driver, sin Selenium Manager.

## Preparación (en la carpeta extraída)

```powershell
$env:CHROMEDRIVER_PATH = 'C:\tools\chromedriver\chromedriver.exe'  # Cambiar a ruta real
# Opcional: $env:CHROME_BINARY = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\setup_offline.ps1
```

## Verificación completa (4 pruebas)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\verify_free.ps1
```

## Solo API (2 pruebas; no requiere ChromeDriver ni Selenium durante la ejecución)

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\verify_api.ps1
```

Si `wheelhouse/` o las dependencias están ausentes, la preparación se detiene sin descargar nada. El kit no intentará conectarse a la red. El servidor y las pruebas solo usan `127.0.0.1`, nunca credenciales de usuario ni transacciones.

Para ver manualmente la demo tras preparar el entorno (Ctrl+C para detener):

```powershell
.\.venv\Scripts\python.exe -m demo_shop.server
# http://127.0.0.1:8765/login
# Cuenta FICTICIA: qa_demo / demo-only-123
```

## Estructura del ZIP

- `demo_shop/`: servidor HTTP de demostración local.
- `src/qa_starter/`: Page Object, cliente API, factoria de Chrome.
- `tests/api/`: API-001, API-002.
- `tests/ui/`: UI-001, UI-002.
- `tools/`: preparación y verificaciones offline.
- `manifest.json`: lista de archivos y SHA-256 por archivo.

## Limitaciones

Este es un alpha de la edición gratuita, no una herramienta de seguridad, autenticación real ni producto comercial. La compatibilidad Chrome/ChromeDriver debe validarse en tu máquina. Los scripts son Windows/PowerShell; la ejecución en otros sistemas no está aprobada.

Licencia del código de esta edición: MIT. Selenium, pytest y demás dependencias se distribuyen por separado con sus respectivas licencias. Se conservan los avisos en `THIRD_PARTY_NOTICES.md`.

## QA-SK-002: Alternativa para reutilizar un entorno offline existente

```powershell
.\tools\inspect_offline_environment.ps1
# Si aparece EXACT_PIN_CANDIDATE, sustituir la ruta real:
.\tools\verify_api.ps1 -PythonExecutable 'D:\ruta\.venv\Scripts\python.exe'
# Para UI se requiere ademas CHROMEDRIVER_PATH:
.\tools\verify_free.ps1 -PythonExecutable 'D:\ruta\.venv\Scripts\python.exe'
```

No se cambian versiones aceptadas: pytest 8.3.4 y selenium 4.28.1. La búsqueda solo inspecciona entornos locales.
