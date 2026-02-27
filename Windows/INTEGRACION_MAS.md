# 📝 INTEGRACIÓN MAS_AIO - TOOLBOX WINDOWS

## ✅ INTEGRACIÓN COMPLETADA (AUTOCONTENIDA)

Se ha integrado exitosamente **Microsoft Activation Scripts (MAS) v3.10** directamente dentro de `toolbox.bat`. Ya no se requiere el archivo externo `MAS_AIO.cmd`.

---

## 📂 ARCHIVOS

```
Windows/
├── toolbox.bat              # ✅ Autocontenido: incluye MAS embebido internamente
├── toolbox_corporate.bat    # Sin cambios (sin activación)
└── MAS_AIO.cmd             # Referencia original (ya no requerido por toolbox.bat)
```

---

## 🔧 CÓMO FUNCIONA

### Desde el Toolbox:

1. Ejecuta `toolbox.bat` como administrador
2. Selecciona perfil (Diagnóstico, Reparación o Administración)
3. En el menú principal, elige la opción **13. ACTIVACION MASTER (MAS)**
4. El toolbox extrae automáticamente el contenido MAS embebido a un archivo temporal
5. Se ejecuta MAS desde el archivo temporal
6. Al terminar, regresarás al menú del toolbox

### Desde MAS directamente:

También puedes ejecutar `MAS_AIO.cmd` directamente sin pasar por el toolbox (si dispones del archivo).

---

## 🎯 CARACTERÍSTICAS DE MAS v3.10

### Opciones principales de activación:

1. **HWID** - Activación digital de Windows (licencia permanente)
2. **Ohook** - Activación de Office sin KMS
3. **TSforge** - Activación Windows/Office/ESU
4. **Online KMS** - Activación tradicional KMS online

### Funciones adicionales:

5. Check Activation Status - Ver estado de activación
6. Change Windows Edition - Cambiar edición de Windows
7. Change Office Edition - Cambiar edición de Office
8. Troubleshoot - Solución de problemas
9. Extras - $OEM$ Folder, downloads
10. Help - Ayuda y documentación

---

## 📋 MÓDULO INTEGRADO EN TOOLBOX.BAT

### Técnica de integración (Auto-extracción):

El contenido completo de `MAS_AIO.cmd` está embebido al final de `toolbox.bat` entre los marcadores:

```
::MAS_EMBEDDED_BEGIN
[contenido completo de MAS_AIO.cmd v3.10]
::MAS_EMBEDDED_END
```

### Código del módulo `:MAS_LOGIC`:

```batch
:MAS_LOGIC
cls
color 0D
echo  [ACTIVACION MASTER - MAS v3.10]
...
set "_mas_temp=%TEMP%\MAS_AIO_toolbox_integrated.cmd"

:: Extraer contenido MAS embebido usando PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command "..."

:: Ejecutar MAS integrado desde archivo temporal
call "!_mas_temp!"
...
exit /b
```

---

## ⚙️ VALIDACIONES IMPLEMENTADAS

✅ **Auto-extracción integrada** - El contenido MAS está embebido en toolbox.bat
✅ **Extracción via PowerShell** - Extrae MAS a archivo temporal en `%TEMP%` con soporte de encoding ANSI
✅ **Verificación de extracción** - Detecta si la extracción falló e informa claramente
✅ **Sin dependencia externa** - `toolbox.bat` funciona sin necesitar `MAS_AIO.cmd` externo
✅ **Logging completo** - Toda acción se registra en el log del toolbox
✅ **Reintegración automática** - Regresa al toolbox automáticamente al terminar
✅ **Avisos legales** - Recuerda usar solo en entornos autorizados

---

## 📊 LOGS

Todas las acciones MAS se registran en el log del toolbox:

```
[12:34:56] Ejecutando MAS (Microsoft Activation Scripts)
[12:35:42] Retorno desde MAS al menu principal
```

**Ubicación del log:** `Windows\Logs\Audit_YYYY-MM-DD.log`

---

## ⚠️ IMPORTANTE - USO LEGAL

**ADVERTENCIA:** Esta herramienta debe usarse ÚNICAMENTE:
- En entornos de prueba autorizados
- Con licencias válidas de Windows/Office
- Para fines educativos y de aprendizaje
- En cumplimiento con las leyes locales

**NO usar para piratería o violación de términos de licencia de Microsoft.**

---

## 🔐 VERSIÓN CORPORATIVA

**`toolbox_corporate.bat`** NO incluye el módulo de activación.

Esta versión está diseñada para entornos empresariales donde:
- Las licencias ya están gestionadas centralizadamente
- No se requieren herramientas de activación
- Se prefiere cumplimiento estricto de políticas de software

---

## 📖 DOCUMENTACIÓN OFICIAL DE MAS

- **Homepage:** https://massgrave.dev/
- **GitHub:** https://github.com/massgravel/Microsoft-Activation-Scripts
- **Versión:** 3.10

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error: "No se pudo extraer el modulo MAS integrado"

**Causa:** El bloque `::MAS_EMBEDDED_BEGIN` / `::MAS_EMBEDDED_END` no está en `toolbox.bat` o el archivo está corrompido.

**Solución:**
1. Descarga una copia fresca de `toolbox.bat` del repositorio
2. Verifica que el archivo no haya sido truncado (debe medir aproximadamente 800 KB)
3. No edites manualmente el bloque embebido al final del archivo

### MAS no ejecuta correctamente

**Causa:** Permisos insuficientes o problemas con PowerShell

**Solución:**
1. Ejecuta `toolbox.bat` como Administrador
2. Verifica que PowerShell no esté restringido
3. Consulta la documentación oficial de MAS

---

## ✅ TESTING

Para verificar que la integración funciona:

1. Abre `cmd` como Administrador
2. Navega a la carpeta Windows: `cd "C:\ruta\a\Windows"`
3. Ejecuta: `toolbox.bat`
4. Selecciona perfil **Administración**
5. Elige opción **13**
6. Verifica que MAS se extraiga y ejecute correctamente
7. Confirma que regreses al toolbox al terminar

**Nota:** Ya no necesitas `MAS_AIO.cmd` en la misma carpeta.

---

## 📝 CHANGELOG

### v2.0 - Integración Autocontenida (2026-02-27)

- ✅ Contenido completo de MAS_AIO.cmd v3.10 embebido directamente en toolbox.bat
- ✅ Nuevo módulo `:MAS_LOGIC` con auto-extracción via PowerShell
- ✅ Eliminada dependencia del archivo externo MAS_AIO.cmd
- ✅ Extracción a archivo temporal en `%TEMP%` con soporte de encoding ANSI
- ✅ Mensajes de error actualizados para la nueva arquitectura autocontenida
- ✅ Documentación actualizada

### v1.0 - Integración Inicial (2026-02-11)

- ✅ Añadido MAS_AIO.cmd v3.10 a carpeta Windows/
- ✅ Creado módulo `:MAS_LOGIC` con verificación de archivo externo
- ✅ Integrado logging de acciones MAS
- ✅ Añadidos avisos legales
- ✅ Implementada reintegración automática al toolbox
- ✅ Versión corporativa sin cambios (sin activación)

---

**© 2024 RENGGLI PC SOLUTIONS**
**Microsoft Activation Scripts © massgravel**
