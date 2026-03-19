@echo off
setlocal

REM Moverse al directorio del script para rutas relativas consistentes
pushd "%~dp0"
REM ==============================================================================
REM RENGGLI PC SOLUTIONS - Generador de PDFs Corporativos
REM Convierte los manuales .md a .pdf con formato profesional
REM ==============================================================================

set "ERRORS=0"
set "FAIL_LIST="

color 0B
echo.
echo ==============================================================================
echo          RENGGLI PC SOLUTIONS - Generador de PDFs de Manuales
echo ==============================================================================
echo.

REM Verificar si Pandoc esta instalado
where pandoc >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [!] ERROR: Pandoc no esta instalado
    echo.
    echo Pandoc es necesario para generar los PDFs.
    echo.
    echo Para instalar Pandoc en Windows:
    echo.
    echo 1. Descarga desde: https://pandoc.org/installing.html
    echo 2. O usa winget: winget install --id JohnMacFarlane.Pandoc
    echo 3. O usa chocolatey: choco install pandoc
    echo.
    pause
    exit /b 1
)

echo [i] Pandoc encontrado:
pandoc --version | findstr /C:"pandoc"
echo.

REM Seleccionar motor PDF (preferido: weasyprint, fallback: wkhtmltopdf)
set "PDF_ENGINE="
where weasyprint >nul 2>&1
if %errorlevel% equ 0 (
    set "PDF_ENGINE=weasyprint"
)

if not defined PDF_ENGINE (
    where wkhtmltopdf >nul 2>&1
    if %errorlevel% equ 0 (
        set "PDF_ENGINE=wkhtmltopdf"
        echo [!] ADVERTENCIA: weasyprint no encontrado. Usando wkhtmltopdf como fallback.
    )
)

if not defined PDF_ENGINE (
    if exist "C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe" (
        set "PDF_ENGINE=wkhtmltopdf"
        set "PATH=C:\Program Files\wkhtmltopdf\bin;%PATH%"
        echo [!] ADVERTENCIA: wkhtmltopdf detectado fuera de PATH. Se usara ruta local.
    )
)

if not defined PDF_ENGINE (
    color 0C
    echo [!] ERROR: No se encontro motor PDF compatible.
    echo.
    echo Instala uno de estos motores para continuar:
    echo 1. Preferido: weasyprint
    echo    - pip install weasyprint
    echo 2. Fallback: wkhtmltopdf
    echo    - winget install --id wkhtmltopdf.wkhtmltox
    echo    - o choco install wkhtmltopdf
    echo.
    pause
    exit /b 1
)

echo [i] Motor PDF seleccionado: %PDF_ENGINE%
if /I "%PDF_ENGINE%"=="weasyprint" weasyprint --version
if /I "%PDF_ENGINE%"=="wkhtmltopdf" wkhtmltopdf --version
echo.

REM Fecha ISO consistente para metadata
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "BUILD_DATE=%%a"
if not defined BUILD_DATE set "BUILD_DATE=%date%"

REM Crear carpeta de salida
if not exist "..\Manuales\PDFs" mkdir "..\Manuales\PDFs"

echo [i] Directorio de salida: ..\Manuales\PDFs\
echo.

REM Convertir manual en Espanol
echo ==============================================================================
echo [1/3] Generando PDF en ESPANOL...
echo ==============================================================================
pandoc "..\Manuales\README_ES.md" -o "..\Manuales\PDFs\Manual_Toolbox_V14_ES.pdf" ^
    --pdf-engine=%PDF_ENGINE% ^
    --css="..\Manuales\estilo_pdf_corporativo.css" ^
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" ^
    --metadata subtitle="Manual Completo en Espanol" ^
    --metadata author="Renggli PC Solutions" ^
    --metadata date="%BUILD_DATE%" ^
    --toc ^
    --toc-depth=2
set "RESULT_ES=%errorlevel%"

if %RESULT_ES% equ 0 (
    echo [OK] Manual en Espanol generado exitosamente
) else (
    echo [!] Error al generar manual en Espanol
    set /a ERRORS+=1
    set "FAIL_LIST=%FAIL_LIST% ES"
)
echo.

REM Convertir manual en Ingles
echo ==============================================================================
echo [2/3] Generando PDF en INGLES...
echo ==============================================================================
pandoc "..\Manuales\README_EN.md" -o "..\Manuales\PDFs\Manual_Toolbox_V14_EN.pdf" ^
    --pdf-engine=%PDF_ENGINE% ^
    --css="..\Manuales\estilo_pdf_corporativo.css" ^
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" ^
    --metadata subtitle="Complete Manual in English" ^
    --metadata author="Renggli PC Solutions" ^
    --metadata date="%BUILD_DATE%" ^
    --toc ^
    --toc-depth=2
set "RESULT_EN=%errorlevel%"

if %RESULT_EN% equ 0 (
    echo [OK] Manual en Ingles generado exitosamente
) else (
    echo [!] Error al generar manual en Ingles
    set /a ERRORS+=1
    set "FAIL_LIST=%FAIL_LIST% EN"
)
echo.

REM Convertir manual en Chino
echo ==============================================================================
echo [3/3] Generando PDF en CHINO...
echo ==============================================================================
pandoc "..\Manuales\README_CN.md" -o "..\Manuales\PDFs\Manual_Toolbox_V14_CN.pdf" ^
    --pdf-engine=%PDF_ENGINE% ^
    --css="..\Manuales\estilo_pdf_corporativo.css" ^
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" ^
    --metadata subtitle="完整手册 (中文)" ^
    --metadata author="Renggli PC Solutions" ^
    --metadata date="%BUILD_DATE%" ^
    --toc ^
    --toc-depth=2
set "RESULT_CN=%errorlevel%"

if %RESULT_CN% equ 0 (
    echo [OK] Manual en Chino generado exitosamente
) else (
    echo [!] Error al generar manual en Chino
    set /a ERRORS+=1
    set "FAIL_LIST=%FAIL_LIST% CN"
)
echo.

REM Resumen
color 0A
echo ==============================================================================
echo [RESUMEN]
echo ==============================================================================
echo.
echo Los manuales PDF han sido generados en: ..\Manuales\PDFs\
echo.
dir /B "..\Manuales\PDFs\*.pdf" 2>nul
echo.
if not defined ERRORS set "ERRORS=0"
if "%ERRORS%"=="0" (
    echo [OK] Generacion completada sin errores.
) else (
    color 0C
    echo [!] Fallaron %ERRORS% generacion^(es^). Idioma^(s^):%FAIL_LIST%
)
echo.
echo [i] Para abrir la carpeta de PDFs, presiona Enter...
pause >nul
explorer "..\Manuales\PDFs"
echo.
echo ==============================================================================
echo Gracias por usar RENGGLI PC SOLUTIONS
echo ==============================================================================
echo.
pause
popd
