@echo off
setlocal enabledelayedexpansion
title Renggli PC Solution - Enterprise Toolbox V15
mode con: cols=130 lines=50

echo ================================================================
echo  TOOLBOX V15 - LEGACY BRIDGE
echo  Toolbox V14 es ahora V15. Usando el nuevo CLI.
echo ================================================================
echo.

set "CLI_PROJECT=%~dp0..\src\ToolboxV15\ToolboxCore"
set "CLI_PROFILE="
set "CLI_MOD="
for %%A in (%*) do (
    set "ARG_RAW=%%~A"
    if /I "!ARG_RAW:~0,8!"=="/perfil:" set "CLI_PROFILE=!ARG_RAW:~8!"
    if /I "!ARG_RAW:~0,5!"=="/mod:" set "CLI_MOD=!ARG_RAW:~5!"
)

where dotnet >nul 2>&1
if errorlevel 1 (
    color 0C
    echo  [X] ERROR: "dotnet" no esta disponible.
    echo  [i] Toolbox V15 requiere .NET 10 SDK instalado.
    echo  [i] Descarga: https://dotnet.microsoft.com/download/dotnet/10.0
    exit /b 1
)

set "CLI_ARGS="
if /I "%CLI_PROFILE%"=="DIAGNOSTICO" (
    set "CLI_ARGS=triage --area system"
    goto :RUN_CLI
)
if /I "%CLI_PROFILE%"=="REPARACION" (
    if not defined CLI_MOD (
        echo  [X] Para /perfil:REPARACION necesita /mod:MODULE
        exit /b 1
    )
    set "CLI_ARGS=run !CLI_MOD!"
    goto :RUN_CLI
)
if /I "%CLI_PROFILE%"=="ADMINISTRACION" (
    if not defined CLI_MOD (
        echo  [X] Para /perfil:ADMINISTRACION necesita /mod:MODULE
        exit /b 1
    )
    set "CLI_ARGS=run !CLI_MOD!"
    goto :RUN_CLI
)
if defined CLI_MOD (
    set "CLI_ARGS=run !CLI_MOD!"
    goto :RUN_CLI
)
set "CLI_ARGS=--help"

:RUN_CLI
echo  [i] Ejecutando: dotnet run --project "%CLI_PROJECT%" -- !CLI_ARGS!
echo ----------------------------------------------------------------
dotnet run --project "%CLI_PROJECT%" -- !CLI_ARGS!
set "EXITCODE=%errorlevel%"
echo ----------------------------------------------------------------
if "%EXITCODE%"=="0" (
    echo  [OK] Toolbox V15 finalizo correctamente.
) else (
    echo  [X] Toolbox V15 finalizo con codigo %EXITCODE%.
)
exit /b %EXITCODE%