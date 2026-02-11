# 📄 GENERADOR DE PDFs CORPORATIVOS

Este sistema convierte automáticamente los 3 manuales (Español, Inglés, Chino) a formato PDF manteniendo el diseño corporativo profesional.

---

## 🎨 CARACTERÍSTICAS

✅ **Formato Corporativo:** Fondo oscuro (#0a0e27) con colores profesionales
✅ **Colores Mantenidos:** Cyan (#00d4ff), Verde (#00ff41), Amarillo (#ffd700)
✅ **Tipografía Monoespaciada:** Consolas/Monaco para look técnico
✅ **Tabla de Contenidos:** Generada automáticamente con navegación
✅ **Bloques de Código:** Resaltados con bordes cyan
✅ **Tablas Estilizadas:** Diseño profesional con hover effects

---

## 📋 REQUISITOS PREVIOS

### Windows
Necesitas instalar **Pandoc** y **wkhtmltopdf**:

**Opción 1 - Winget (Recomendado):**
```cmd
winget install --id JohnMacFarlane.Pandoc
winget install --id wkhtmltopdf.wkhtmltopdf
```

**Opción 2 - Chocolatey:**
```cmd
choco install pandoc wkhtmltopdf
```

**Opción 3 - Descarga Manual:**
- Pandoc: https://pandoc.org/installing.html
- wkhtmltopdf: https://wkhtmltopdf.org/downloads.html

### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install pandoc wkhtmltopdf
```

### Linux (Fedora/RHEL)
```bash
sudo dnf install pandoc wkhtmltopdf
```

### Linux (Arch)
```bash
sudo pacman -S pandoc wkhtmltopdf
```

### macOS
```bash
brew install pandoc
brew install --cask wkhtmltopdf
```

---

## 🚀 USO

### En Windows:
1. Abre una **terminal** en la carpeta principal de la herramienta
2. Ejecuta:
   ```cmd
   generar_pdfs.bat
   ```
3. Los PDFs se generarán en `Manuales\PDFs\`

### En Linux/Mac:
1. Abre una **terminal** en la carpeta principal de la herramienta
2. Ejecuta:
   ```bash
   ./generar_pdfs.sh
   ```
3. Los PDFs se generarán en `Manuales/PDFs/`

---

## 📂 ARCHIVOS GENERADOS

Los PDFs se crearán en la carpeta `Manuales/PDFs/`:

```
Manuales/PDFs/
├── Manual_Toolbox_V14_ES.pdf    (Manual en Español)
├── Manual_Toolbox_V14_EN.pdf    (Manual en Inglés)
└── Manual_Toolbox_V14_CN.pdf    (Manual en Chino)
```

---

## 🎨 PERSONALIZACIÓN DEL ESTILO

Si deseas modificar el diseño de los PDFs, edita el archivo:
```
Manuales/estilo_pdf_corporativo.css
```

**Colores principales usados:**
- Fondo: `#0a0e27` (Azul oscuro)
- Texto principal: `#00ff41` (Verde brillante)
- Encabezados H1: `#00d4ff` (Cyan)
- Encabezados H2: `#ffd700` (Amarillo dorado)
- Código: Fondo `#000000` con texto verde

---

## ⚠️ SOLUCIÓN DE PROBLEMAS

### Error: "pandoc: command not found"
**Solución:** Pandoc no está instalado. Sigue las instrucciones de [Requisitos Previos](#requisitos-previos)

### Error: "wkhtmltopdf: command not found"
**Solución:** wkhtmltopdf no está instalado. Instalalo con:
- Windows: `winget install --id wkhtmltopdf.wkhtmltopdf`
- Linux: `sudo apt install wkhtmltopdf`
- macOS: `brew install --cask wkhtmltopdf`

### Los PDFs no tienen el formato corporativo
**Solución:** Verifica que el archivo `Manuales/estilo_pdf_corporativo.css` existe y está en la ubicación correcta.

### Error: "Failed to load" en Windows
**Solución:** Asegúrate de que la ruta no tenga espacios o usa comillas:
```cmd
cd "C:\ruta con espacios\Herramienta toolbox"
generar_pdfs.bat
```

---

## 🔧 ARCHIVOS DEL SISTEMA

El sistema de generación de PDFs consta de:

1. **generar_pdfs.bat** - Script para Windows
2. **generar_pdfs.sh** - Script para Linux/Mac
3. **Manuales/estilo_pdf_corporativo.css** - Hoja de estilos corporativa
4. **Manuales/README_ES.md** - Manual fuente en Español
5. **Manuales/README_EN.md** - Manual fuente en Inglés
6. **Manuales/README_CN.md** - Manual fuente en Chino

---

## 📊 ESPECIFICACIONES TÉCNICAS

- **Motor PDF:** wkhtmltopdf (renderizado basado en WebKit)
- **Conversor:** Pandoc (conversor universal de documentos)
- **Tamaño página:** A4
- **Márgenes:** 2cm en todos los lados
- **Fuente:** Consolas, Monaco, Courier New (monoespaciada)
- **Tamaño fuente:** 10pt (cuerpo), 24pt (H1), 18pt (H2)
- **Tabla de contenidos:** Profundidad 2 niveles

---

## 📞 SOPORTE

Si tienes problemas con la generación de PDFs:
- 📧 Email: soporte@renggli-solutions.com
- 📚 Verifica que Pandoc y wkhtmltopdf estén correctamente instalados
- 🔍 Revisa los mensajes de error en la terminal

---

**© 2024 RENGGLI PC SOLUTIONS**
