@echo off
setlocal
rem Copia el logo del frontend web y genera iconos Android de MoviCredito.
set "APP_ROOT=%~dp0.."
set "SOURCE=%APP_ROOT%\..\movicredito_frontend\public\logo.jpg"
set "DEST_DIR=%APP_ROOT%\assets\icon"
set "DEST=%DEST_DIR%\app_icon.jpg"

if not exist "%SOURCE%" (
  echo ERROR: No se encontro el logo del proyecto web:
  echo %SOURCE%
  echo Verifica que movicredito_frontend y movicredito_app esten en C:\Desarrollo\MoviCredito.
  exit /b 1
)
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"
copy /Y "%SOURCE%" "%DEST%" >nul
if errorlevel 1 (
  echo ERROR: No se pudo copiar el logo.
  exit /b 1
)
cd /d "%APP_ROOT%"
echo Preparando dependencias de Flutter...
call flutter pub get
if errorlevel 1 exit /b 1
echo Generando iconos Android...
call dart run flutter_launcher_icons
if errorlevel 1 exit /b 1
echo.
echo Listo. El icono de MoviCredito se genero desde el logo del frontend.
echo Para probarlo: flutter run --dart-define=API_URL=http://192.168.1.74:4000
endlocal
