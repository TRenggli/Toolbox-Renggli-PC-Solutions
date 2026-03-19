#!/bin/bash
# ==============================================================================
# RENGGLI PC SOLUTIONS - Generador de PDFs Corporativos
# Convierte los manuales .md a .pdf con formato profesional
# ==============================================================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}=============================================================================="
echo "         RENGGLI PC SOLUTIONS - Generador de PDFs de Manuales"
echo "==============================================================================${NC}"
echo ""

ERRORS=0
FAIL_LIST=""

# Verificar si Pandoc esta instalado
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}[!] ERROR: Pandoc no esta instalado${NC}"
    echo ""
    echo "Pandoc es necesario para generar los PDFs."
    echo ""
    echo "Para instalar Pandoc:"
    echo ""
    echo "Ubuntu/Debian:"
    echo "  sudo apt install pandoc wkhtmltopdf"
    echo ""
    echo "Fedora/RHEL:"
    echo "  sudo dnf install pandoc wkhtmltopdf"
    echo ""
    echo "Arch:"
    echo "  sudo pacman -S pandoc wkhtmltopdf"
    echo ""
    echo "macOS:"
    echo "  brew install pandoc"
    echo "  brew install --cask wkhtmltopdf"
    echo ""
    exit 1
fi

echo -e "${GREEN}[i] Pandoc encontrado:${NC}"
pandoc --version | head -1
echo ""

# Seleccionar motor PDF (preferido: weasyprint, fallback: wkhtmltopdf)
PDF_ENGINE=""
if command -v weasyprint &> /dev/null; then
    PDF_ENGINE="weasyprint"
elif command -v wkhtmltopdf &> /dev/null; then
    PDF_ENGINE="wkhtmltopdf"
    echo -e "${YELLOW}[!] ADVERTENCIA: weasyprint no encontrado. Usando wkhtmltopdf como fallback.${NC}"
else
    echo -e "${RED}[!] ERROR: No se encontro motor PDF compatible.${NC}"
    echo ""
    echo "Instala uno de estos motores:"
    echo "  Preferido: weasyprint"
    echo "    pip install weasyprint"
    echo "  Fallback: wkhtmltopdf"
    echo "    Ubuntu/Debian: sudo apt install wkhtmltopdf"
    echo "    Fedora/RHEL:   sudo dnf install wkhtmltopdf"
    echo "    Arch:          sudo pacman -S wkhtmltopdf"
    echo "    macOS:         brew install --cask wkhtmltopdf"
    echo ""
    exit 1
fi

echo -e "${GREEN}[i] Motor PDF seleccionado: ${PDF_ENGINE}${NC}"
if [ "$PDF_ENGINE" = "weasyprint" ]; then
    weasyprint --version
else
    wkhtmltopdf --version
fi
echo ""

# Obtener directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Crear carpeta de salida
mkdir -p "../Manuales/PDFs"

echo -e "${CYAN}[i] Directorio de salida: ../Manuales/PDFs/${NC}"
echo ""

# Convertir manual en Espanol
echo "=============================================================================="
echo -e "${YELLOW}[1/3] Generando PDF en ESPANOL...${NC}"
echo "=============================================================================="
pandoc "../Manuales/README_ES.md" -o "../Manuales/PDFs/Manual_Toolbox_V14_ES.pdf" \
    --pdf-engine="$PDF_ENGINE" \
    --css="../Manuales/estilo_pdf_corporativo.css" \
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" \
    --metadata subtitle="Manual Completo en Español" \
    --metadata author="Renggli PC Solutions" \
    --metadata date="$(date +%Y-%m-%d)" \
    --toc \
    --toc-depth=2
RESULT_ES=$?

if [ $RESULT_ES -eq 0 ]; then
    echo -e "${GREEN}[OK] Manual en Español generado exitosamente${NC}"
else
    echo -e "${RED}[!] Error al generar manual en Español${NC}"
    ERRORS=$((ERRORS+1))
    FAIL_LIST="$FAIL_LIST ES"
fi
echo ""

# Convertir manual en Ingles
echo "=============================================================================="
echo -e "${YELLOW}[2/3] Generando PDF en INGLES...${NC}"
echo "=============================================================================="
pandoc "../Manuales/README_EN.md" -o "../Manuales/PDFs/Manual_Toolbox_V14_EN.pdf" \
    --pdf-engine="$PDF_ENGINE" \
    --css="../Manuales/estilo_pdf_corporativo.css" \
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" \
    --metadata subtitle="Complete Manual in English" \
    --metadata author="Renggli PC Solutions" \
    --metadata date="$(date +%Y-%m-%d)" \
    --toc \
    --toc-depth=2
RESULT_EN=$?

if [ $RESULT_EN -eq 0 ]; then
    echo -e "${GREEN}[OK] Manual en Inglés generado exitosamente${NC}"
else
    echo -e "${RED}[!] Error al generar manual en Inglés${NC}"
    ERRORS=$((ERRORS+1))
    FAIL_LIST="$FAIL_LIST EN"
fi
echo ""

# Convertir manual en Chino
echo "=============================================================================="
echo -e "${YELLOW}[3/3] Generando PDF en CHINO...${NC}"
echo "=============================================================================="
pandoc "../Manuales/README_CN.md" -o "../Manuales/PDFs/Manual_Toolbox_V14_CN.pdf" \
    --pdf-engine="$PDF_ENGINE" \
    --css="../Manuales/estilo_pdf_corporativo.css" \
    --metadata title="RENGGLI PC SOLUTIONS - Enterprise Toolbox V14" \
    --metadata subtitle="完整手册 (中文)" \
    --metadata author="Renggli PC Solutions" \
    --metadata date="$(date +%Y-%m-%d)" \
    --toc \
    --toc-depth=2
RESULT_CN=$?

if [ $RESULT_CN -eq 0 ]; then
    echo -e "${GREEN}[OK] Manual en Chino generado exitosamente${NC}"
else
    echo -e "${RED}[!] Error al generar manual en Chino${NC}"
    ERRORS=$((ERRORS+1))
    FAIL_LIST="$FAIL_LIST CN"
fi
echo ""

# Resumen
echo -e "${GREEN}=============================================================================="
echo "[RESUMEN]"
echo "==============================================================================${NC}"
echo ""
echo "Los manuales PDF han sido generados en: ../Manuales/PDFs/"
echo ""
ls -lh "../Manuales/PDFs/"*.pdf 2>/dev/null
echo ""
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}[!] Fallaron $ERRORS generacion(es). Idioma(s):$FAIL_LIST${NC}"
else
    echo -e "${GREEN}[OK] Generacion completada sin errores.${NC}"
fi
echo ""
echo -e "${CYAN}=============================================================================="
echo "Gracias por usar RENGGLI PC SOLUTIONS"
echo "==============================================================================${NC}"
echo ""
