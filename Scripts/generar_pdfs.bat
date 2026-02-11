@echo off
REM ==============================================================================
REM RENGGLI PC SOLUTIONS - Generador de PDFs Corporativos
REM Convierte los manuales .md a .pdf con formato profesional
REM ==============================================================================

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

REM Crear carpeta de salida
if not exist "..\Manuales\PDFs" mkdir "..\Manuales\PDFs"

echo [i] Directorio de salida: ..\Manuales\PDFs\
echo.

REM Convertir manual en Espanol
echo ==============================================================================
echo [1/3] Generando PDF en ESPANOL...
echo ==============================================================================
pandoc "..\Manuales\README_ES.md" -o "..\Manuales\PDFs\Manual_Toolbox_V14_ES.pdf" ^
    --pdf-engine=wkhtmltopdf ^
    --css="..\Manuales\estilo_pdf_corporativo.css" ^
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" ^
    --metadata subtitle="Manual Completo en Espanol" ^
    --metadata author="Renggli PC Solutions" ^
    --metadata date="%date%" ^
    --toc ^
    --toc-depth=2

if %errorlevel% equ 0 (
    echo [OK] Manual en Espanol generado exitosamente
) else (
    echo [!] Error al generar manual en Espanol
)
echo.

REM Convertir manual en Ingles
echo ==============================================================================
echo [2/3] Generando PDF en INGLES...
echo ==============================================================================
pandoc "..\Manuales\README_EN.md" -o "..\Manuales\PDFs\Manual_Toolbox_V14_EN.pdf" ^
    --pdf-engine=wkhtmltopdf ^
    --css="..\Manuales\estilo_pdf_corporativo.css" ^
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" ^
    --metadata subtitle="Complete Manual in English" ^
    --metadata author="Renggli PC Solutions" ^
    --metadata date="%date%" ^
    --toc ^
    --toc-depth=2

if %errorlevel% equ 0 (
    echo [OK] Manual en Ingles generado exitosamente
) else (
    echo [!] Error al generar manual en Ingles
)
echo.

REM Convertir manual en Chino
echo ==============================================================================
echo [3/3] Generando PDF en CHINO...
echo ==============================================================================
pandoc "..\Manuales\README_CN.md" -o "..\Manuales\PDFs\Manual_Toolbox_V14_CN.pdf" ^
    --pdf-engine=wkhtmltopdf ^
    --css="..\Manuales\estilo_pdf_corporativo.css" ^
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" ^
    --metadata subtitle="完整手册 (中文)" ^
    --metadata author="Renggli PC Solutions" ^
    --metadata date="%date%" ^
    --toc ^
    --toc-depth=2

if %errorlevel% equ 0 (
    echo [OK] Manual en Chino generado exitosamente
) else (
    echo [!] Error al generar manual en Chino
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
echo [i] Para abrir la carpeta de PDFs, presiona Enter...
pause >nul
explorer "..\Manuales\PDFs"
echo.
echo ==============================================================================
echo Gracias por usar RENGGLI PC SOLUTIONS
echo ==============================================================================
echo.
pause
