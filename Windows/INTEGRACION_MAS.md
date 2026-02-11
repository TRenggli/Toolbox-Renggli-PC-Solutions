# 📝 INTEGRACIÓN MAS_AIO - TOOLBOX WINDOWS

## ✅ INTEGRACIÓN COMPLETADA

Se ha integrado exitosamente **Microsoft Activation Scripts (MAS) v3.10** en el Toolbox de Windows.

---

## 📂 ARCHIVOS AÑADIDOS

```
Windows/
├── toolbox.bat              # ✅ Actualizado con módulo MAS
├── toolbox_corporate.bat    # Sin cambios (sin activación)
└── MAS_AIO.cmd             # 🆕 Herramienta MAS integrada (744 KB)
```

---

## 🔧 CÓMO FUNCIONA

### Desde el Toolbox:

1. Ejecuta `toolbox.bat` como administrador
2. Selecciona perfil (Diagnóstico, Reparación o Administración)
3. En el menú principal, elige la opción **13. ACTIVACION MASTER (MAS)**
4. El toolbox verificará que `MAS_AIO.cmd` exista
5. Se ejecutará automáticamente MAS_AIO.cmd
6. Al terminar, regresarás al menú del toolbox

### Desde MAS directamente:

También puedes ejecutar `MAS_AIO.cmd` directamente sin pasar por el toolbox.

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

### Código del módulo `:MAS_LOGIC`:

```batch
:MAS_LOGIC
cls
color 0D
echo  ==============================================================================
echo   [ACTIVACION MASTER - MAS v3.10]
echo  ==============================================================================
echo.
echo  [i] Redirigiendo a Microsoft Activation Scripts (MAS)...
echo  [i] Herramienta de activacion profesional integrada.
echo.
echo  [!] IMPORTANTE: Usa esta herramienta solo en entornos autorizados.
echo  [!] Recuerda que la activacion debe ser legal y conforme a licencias.
echo.
echo  [i] Detectando archivo MAS_AIO.cmd...
echo.

:: Verificar si MAS_AIO.cmd existe
if not exist "%~dp0MAS_AIO.cmd" (
    color 0C
    echo  [ERROR] No se encuentra MAS_AIO.cmd en el directorio Windows/
    echo.
    echo  [i] Asegurate de que MAS_AIO.cmd este en la misma carpeta que toolbox.bat
    echo.
    echo [%time%] ERROR: MAS_AIO.cmd no encontrado >> "!LOG_FILE!"
    pause
    exit /b
)

echo  [OK] MAS_AIO.cmd encontrado. Iniciando...
echo.
echo [%time%] Ejecutando MAS (Microsoft Activation Scripts) >> "!LOG_FILE!"
echo.
timeout /t 2 >nul

:: Ejecutar MAS_AIO.cmd
call "%~dp0MAS_AIO.cmd"

:: Retorno al toolbox
cls
color 0B
echo  ==============================================================================
echo   [RETORNO AL TOOLBOX]
echo  ==============================================================================
echo.
echo  [OK] Proceso MAS finalizado.
echo  [i] Regresando al menu principal de Toolbox...
echo.
echo [%time%] Retorno desde MAS al menu principal >> "!LOG_FILE!"
timeout /t 2 >nul
exit /b
```

---

## ⚙️ VALIDACIONES IMPLEMENTADAS

✅ **Verificación de archivo** - Detecta si MAS_AIO.cmd está presente
✅ **Mensaje de error claro** - Si falta el archivo, muestra error informativo
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

### Error: "No se encuentra MAS_AIO.cmd"

**Causa:** El archivo MAS_AIO.cmd no está en la carpeta Windows/

**Solución:**
1. Verifica que `MAS_AIO.cmd` esté en la misma carpeta que `toolbox.bat`
2. Extrae correctamente todo el contenido de la carpeta Windows/
3. No muevas archivos individualmente, mantén la estructura

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
4. Selecciona perfil (cualquiera sirve)
5. Elige opción **13**
6. Verifica que MAS se ejecute correctamente
7. Confirma que regreses al toolbox al terminar

---

## 📝 CHANGELOG

### v1.0 - Integración Inicial (2026-02-11)

- ✅ Añadido MAS_AIO.cmd v3.10 a carpeta Windows/
- ✅ Creado módulo `:MAS_LOGIC` con verificación de archivo
- ✅ Integrado logging de acciones MAS
- ✅ Añadidos avisos legales
- ✅ Implementada reintegración automática al toolbox
- ✅ Versión corporativa sin cambios (sin activación)

---

**© 2024 RENGGLI PC SOLUTIONS**
**Microsoft Activation Scripts © massgravel**
