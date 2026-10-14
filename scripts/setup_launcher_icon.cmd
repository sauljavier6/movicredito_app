@echo off
setlocal
rem Genera iconos Android desde los PNG recortados del logo original.
set "APP_ROOT=%~dp0.."
set "ICON_DIR=%APP_ROOT%\assets\icon"
for %%F in (launcher_icon.png adaptive_foreground.png adaptive_background.png) do (
  if not exist "%ICON_DIR%\%%F" (
    echo ERROR: Falta %ICON_DIR%\%%F
    echo Descarga movicredito_iconos_android.zip y extraelo en la carpeta movicredito_app.
    exit /b 1
  )
)
cd /d "%APP_ROOT%"
call flutter pub get
if errorlevel 1 exit /b 1
call dart run flutter_launcher_icons
if errorlevel 1 exit /b 1
echo.
echo Iconos de MoviCredito generados correctamente.
echo Ejecuta flutter run para reinstalar la app en el Samsung.
endlocal
