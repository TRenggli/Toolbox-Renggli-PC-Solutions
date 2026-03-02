# HISTORIAL DE CAMBIOS

Documento único y cronológico del proyecto (Windows, Linux, macOS y documentación).

## 2026-03-02 — Simplificación de estructura (alineada a operación)

### Cambios principales
- Se limpió la carpeta `Windows/` para dejar únicamente los dos ejecutables operativos.
- Se retiraron documentos técnicos auxiliares y artefactos que ya no formaban parte del flujo principal.
- Se eliminaron carpetas auxiliares no operativas en raíz para simplificar la entrega.

### Detalle por plataforma
- **Windows**
  - Se eliminaron: `Windows/FIX_WMIC_DEPRECADO.md`, `Windows/INTEGRACION_MAS.md`, `Windows/MEJORA_UX_CORPORATE.md`, `Windows/MAS_AIO.cmd` y `Windows/Logs/`.
  - Se mantienen únicamente: `Windows/toolbox.bat` y `Windows/toolbox_corporate.bat`.
- **Linux**
  - Sin cambios estructurales. Se mantienen: `Linux/toolbox.sh` y `Linux/toolbox_corporate.sh`.
- **macOS**
  - Sin cambios estructurales. Se mantienen: `Mac/toolbox.sh` y `Mac/toolbox_corporate.sh`.
- **Documentación**
  - Se eliminaron de raíz las carpetas `Scripts/` y `herramienta mas/`.
  - Se mantiene `HISTORIAL_DE_CAMBIOS.md` como registro oficial de cambios globales.

---

## 2026-02-27 — Integración MAS autocontenida + ajuste de salida sin log

### Cambios principales
- Se integró MAS directamente dentro de `Windows/toolbox.bat` (arquitectura autocontenida).
- Se eliminó la dependencia obligatoria de `Windows/MAS_AIO.cmd` para ejecutar la opción MAS desde el toolbox.
- Se ajustó la salida `00` para salir sin generar reporte y sin conservar log de sesión en los scripts principales.

### Detalle por plataforma
- **Windows**
  - `Windows/toolbox.bat`: nuevo flujo para extraer y ejecutar MAS embebido en tiempo de ejecución.
  - `Windows/toolbox_corporate.bat`: actualización de comportamiento de salida `00`.
  - Se documentó la arquitectura autocontenida de MAS (archivo técnico retirado en limpieza estructural 2026-03-02).
- **Linux**
  - `Linux/toolbox.sh` y `Linux/toolbox_corporate.sh`: salida `00` alineada al nuevo comportamiento.
- **macOS**
  - `Mac/toolbox.sh` y `Mac/toolbox_corporate.sh`: salida `00` alineada al nuevo comportamiento.
- **Documentación**
  - `README.md` y manuales (`Manuales/README_ES.md`, `Manuales/README_EN.md`) actualizados para reflejar cambios de menú/salida.

### Commits relacionados
- `d1f5aa8` — Integrate MAS_AIO.cmd content directly into toolbox.bat (self-contained)
- `032fa3d` — Actualizar opciones de salida en los scripts para salir sin generar log

---

## 2026-02-25 — Reorganización de menú y mejora de auditoría de red (Windows)

### Cambios principales
- Reorganización de opciones del menú principal para mejorar legibilidad y flujo operativo.
- Ajustes en auditoría de red dentro de la edición Windows.

### Detalle por plataforma
- **Windows**
  - `Windows/toolbox.bat`: reorganización de opciones y mejoras funcionales en auditoría de red.

### Commit relacionado
- `132d36b` — Reorganización de opciones en el menú y mejoras en la auditoría de red

---

## 2026-02-12 — Estandarización multiplataforma y speedtest-cli

### Cambios principales
- Simplificación/estandarización del flujo de salida en herramientas multiplataforma.
- Instalación/uso de `speedtest-cli` y reemplazo de comandos anteriores de prueba de velocidad.
- Actualización del historial y manuales para mantener coherencia operativa.

### Detalle por plataforma
- **Windows**
  - `Windows/toolbox.bat` y `Windows/toolbox_corporate.bat`: ajustes de menús/salida y pruebas de red.
- **Linux**
  - `Linux/toolbox.sh` y `Linux/toolbox_corporate.sh`: integración de cambios en salida y speedtest-cli.
- **macOS**
  - `Mac/toolbox.sh` y `Mac/toolbox_corporate.sh`: integración de cambios en salida y speedtest-cli.
- **Documentación**
  - `HISTORIAL_DE_CAMBIOS.md` y manuales (`Manuales/README_ES.md`, `Manuales/README_EN.md`, `Manuales/README_CN.md`) actualizados.

### Commits relacionados
- `7c9925a` — Instalación de speedtest-cli y reemplazo de comandos
- `6986fa1` — Actualización del historial de cambios y simplificación de opciones de salida en herramientas multiplataforma

---

## 2026-02-11 — Publicación inicial de la suite y documentación

### Cambios principales
- Publicación base del proyecto con scripts para Windows, Linux y macOS.
- Incorporación de manuales en ES/EN/CN y assets para generación de PDFs.
- Inclusión de documentación técnica adicional para Windows (MAS, WMIC, UX corporate).
- Actualización del README principal (v2.0).

### Detalle por plataforma
- **Windows**
  - `Windows/toolbox.bat`, `Windows/toolbox_corporate.bat`, `Windows/MAS_AIO.cmd` y documentos técnicos asociados.
- **Linux**
  - `Linux/toolbox.sh` y `Linux/toolbox_corporate.sh`.
- **macOS**
  - `Mac/toolbox.sh` y `Mac/toolbox_corporate.sh`.
- **Documentación y soporte**
  - `README.md`, carpeta `Manuales/`, scripts de generación PDF en `Scripts/`.
  - Carpeta histórica `herramienta mas/` con variantes y activadores separados.

### Commits relacionados
- `da24cfd` — Add files via upload
- `f4c10d1` — Readme Github 2.0

---

## Notas de mantenimiento

- Este archivo es la fuente oficial de cambios globales del proyecto.
- Se recomienda registrar cada release con:
  - Fecha (`YYYY-MM-DD`)
  - Resumen de cambios
  - Impacto por plataforma (Windows/Linux/macOS/Documentación)
  - Hash de commit(s) relevantes
