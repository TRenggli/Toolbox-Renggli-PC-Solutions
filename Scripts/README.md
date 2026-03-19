# 🔧 SCRIPTS DE GENERACIÓN DE PDFs

Esta carpeta contiene los scripts automatizados para generar PDFs de los manuales.

---

## 📁 CONTENIDO

```
Scripts/
├── generar_pdfs.bat    # Script para Windows
└── generar_pdfs.sh     # Script para Linux/Mac
```

---

## 🚀 USO RÁPIDO

### Windows:
```cmd
cd Scripts
generar_pdfs.bat
```

### Linux/Mac:
```bash
cd Scripts
./generar_pdfs.sh
```

---

## 📖 DOCUMENTACIÓN COMPLETA

Para instrucciones detalladas sobre requisitos, instalación de Pandoc/wkhtmltopdf y solución de problemas, consulta:

**`../Manuales/COMO_GENERAR_PDFS.md`**

---

## 🎯 QUÉ HACE

Estos scripts:
1. Verifican que Pandoc esté instalado
2. Seleccionan motor PDF automaticamente (preferido: weasyprint, fallback: wkhtmltopdf)
3. Convierten los 3 manuales (.md) a formato PDF
4. Aplican el estilo corporativo definido en `estilo_pdf_corporativo.css`
5. Generan tabla de contenidos automática
6. Guardan los PDFs en `../Manuales/PDFs/`

---

## ✨ RESULTADO

Los PDFs generados mantienen:
- Fondo corporativo oscuro (#0a0e27)
- Colores profesionales (Cyan, Verde, Amarillo)
- Tipografía monoespaciada
- Formato A4 con márgenes de 2cm
- Tabla de contenidos navegable

---

**© 2024 RENGGLI PC SOLUTIONS**
