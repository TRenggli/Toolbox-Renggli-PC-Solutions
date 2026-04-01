<!-- markdownlint-disable MD022 MD026 MD031 MD032 MD033 MD036 MD040 MD060 -->

# 🛠️ Renggli PC Solution - Enterprise Toolbox V14
## Suite Multiplataforma (Windows | Linux | macOS)

**Solución profesional de diagnóstico, reparación y administración para técnicos IT**

---

## 🌍 ELIGE TU SISTEMA OPERATIVO

Este manual cubre la instalación y uso en **Windows, Linux y macOS**.

**Salta directamente a tu sección:**
- 🪟 [Instrucciones para WINDOWS](#seccion-windows)
- 🐧 [Instrucciones para LINUX](#seccion-linux)
- 🍎 [Instrucciones para macOS](#seccion-macos)

---

## 🪟 WINDOWS {#seccion-windows}

## 📋 Requisitos del Sistema (Windows)

| Requisito | Especificación |
|-----------|----------------|
| **Sistema Operativo** | Windows 10/11 (Build 1809 o superior) |
| **PowerShell** | Versión 5.1 o superior (preinstalado) |
| **Privilegios** | Administrador (obligatorio) |
| **Espacio en disco** | 50 MB mínimo |
| **Red** | Conexión a internet (para actualizaciones) |

---

## 🚀 Instalación en Windows - PASO A PASO

### Paso 1: Descargar la herramienta

1. Descarga la carpeta completa `Herramienta-toolbox`
2. Extrae el archivo ZIP en cualquier ubicación (Ejemplo: `C:\Tools\`)
3. Verás esta estructura:
   ```
   Herramienta-toolbox/
   ├── Windows/
   │   ├── toolbox.bat
   │   └── toolbox_corporate.bat
   ├── Linux/
   ├── Mac/
   └── Manuales/
   ```

### Paso 2: Navegar a la carpeta Windows

1. Abre el **Explorador de Archivos** (Windows + E)
2. Navega hasta donde extrajiste la herramienta
3. Entra a la carpeta **`Windows`**
4. Verás los archivos:
   - `toolbox.bat` (versión completa)
   - `toolbox_corporate.bat` (versión corporativa sin MAS)

### Paso 3: Ejecutar como Administrador

🔴 **IMPORTANTE**: Debes ejecutar con permisos de administrador

**Método 1 - Clic derecho (Recomendado):**

1. Haz **clic derecho** sobre `toolbox.bat`
2. Selecciona **"Ejecutar como administrador"**
   ```
   ┌────────────────────────┐
   │ Abrir                  │
   │ Editar                 │
   │ Imprimir               │
   │ → Ejecutar como admin  │ ← ESTA OPCIÓN
   │ Compartir              │
   └────────────────────────┘
   ```
3. Si aparece el mensaje de **Control de Cuentas de Usuario (UAC)**, haz clic en **"Sí"**

**Método 2 - Desde CMD:**

1. Abre **CMD como administrador**:
   - Presiona `Windows + X`
   - Selecciona "Terminal (Administrador)" o "Símbolo del sistema (Administrador)"
2. Navega a la carpeta:
   ```cmd
   cd C:\ruta\donde\extrajiste\Herramienta-toolbox\Windows
   ```
3. Ejecuta:
   ```cmd
   toolbox.bat
   ```

**Método 3 - Desde PowerShell:**

1. Abre **PowerShell como administrador**:
   - Presiona `Windows + X`
   - Selecciona "Windows PowerShell (Administrador)"
2. Navega y ejecuta:
   ```powershell
   cd C:\ruta\donde\extrajiste\Herramienta-toolbox\Windows
   .\toolbox.bat
   ```

### Paso 4: Seleccionar Perfil de Ejecución

Al ejecutar, verás esta pantalla:

```
==============================================================================================================
                        Renggli PC Solution - SUITE ENTERPRISE V14
==============================================================================================================
Log Actual: C:\...\Logs\Audit_2024-02-10.log

[SELECCION DE PERFIL]

1. DIAGNOSTICO     - Solo lectura, auditoria y consultas (sin modificaciones)
2. REPARACION      - Mantenimiento y reparaciones automatizadas
3. ADMINISTRACION  - Acceso completo (incluye formateo y conversiones)

=> Seleccione perfil [1-3]:
```

**Elige tu perfil:**
- **1** = Solo ver información, no hace cambios
- **2** = Permite reparaciones y limpieza
- **3** = Acceso completo (cuidado con este)

Escribe el número y presiona **Enter**.

### Paso 5: Usar el Menú Principal

Después de seleccionar el perfil, verás el menú específico para ese perfil:

#### 🔍 Si elegiste DIAGNOSTICO (Perfil 1):

```
==============================================================================================================
   Perfil Activo: [DIAGNOSTICO] - Solo Lectura

   Este menu es solo de consulta. No realiza cambios en el sistema.
   Ideal para auditar hardware, recursos, red y estado de Windows Update.
   Nota: El reporte de bateria solo aplica en equipos portatiles.
   Leyenda: [R] Solo lectura  [W] Escribe/cambia sistema  [!] Critico/irreversible

   [ DIAGNOSTICO BASE ]
   1. [R] Test de RAM (mdsched)
   2. [R] Info de Recursos del Sistema
   3. [R] Info BIOS y Placa Madre
   4. [R] Estado de Windows Update
   5. [R] Auditoria de Puertos/DNS
   6. [R] Test de Velocidad de Red
   7. [R] Reporte de Bateria

   [ ANALISIS AVANZADO - SOLO LECTURA ]
   8. [R] Eventos Criticos (Sistema)
   9. [R] Analisis BSOD (Minidump)
   10. [R] Auditoria Forense de Procesos
   11. [R] Estado RAID/Storage

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
   [99] CAMBIAR PERFIL
==============================================================================================================

=> Selecciona una opcion:
```

**Este perfil solo tiene opciones de lectura.** No modifica el sistema, solo consulta información.

#### 🔧 Si elegiste REPARACION (Perfil 2):

```
==============================================================================================================
   Perfil Activo: [REPARACION] - Mantenimiento y Reparaciones

   Incluye diagnostico y tareas que modifican el sistema.
   Recomendado para mantenimiento, limpieza y reparaciones guiadas.
   Nota: El reporte de bateria solo aplica en equipos portatiles.
   Leyenda: [R] Solo lectura  [W] Escribe/cambia sistema  [!] Critico/irreversible

   [ REPARACION Y MANTENIMIENTO ]
   1. [R] Test de RAM (mdsched)
   2. [R] Info de Recursos del Sistema
   3. [R] Info BIOS y Placa Madre
   4. [W] Mantenimiento (DISM/SFC)
   5. [W] Reparar Windows Update
   6. [W] Limpieza EMMC/Temporales
   7. [W] Reset de Red e IP
   8. [R] Test de Velocidad
   9. [R] Auditoria de Puertos/DNS
   10. [W] Apagado Programado
   11. [W] Actualizar Apps (Winget)
   12. [R] Reporte de Bateria
   13. [W] Backup de Drivers (ESCRIBE EN DISCO)

   [ ANALISIS AVANZADO - SOLO LECTURA ]
   14. [R] Eventos Criticos
   15. [R] Analisis BSOD
   16. [R] Auditoria Forense de Procesos
   17. [R] Estado RAID/Storage

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
   [99] CAMBIAR PERFIL
==============================================================================================================

=> Selecciona una opcion:
```

**Este perfil incluye diagnóstico + reparaciones del sistema.** Puede hacer mantenimiento pero no operaciones críticas.

#### ⚠️ Si elegiste ADMINISTRACION (Perfil 3):

```
==============================================================================================================
   Perfil Activo: [ADMINISTRACION] - Acceso Completo

   Acceso total. Incluye acciones irreversibles y cambios criticos.
   Usa este perfil solo si comprendes el impacto de cada operacion.
   Nota: El reporte de bateria solo aplica en equipos portatiles.
   Leyenda: [R] Solo lectura  [W] Escribe/cambia sistema  [!] Critico/irreversible

   [ ADMINISTRACION OPERATIVA ]
   1. [R] Info BIOS y Placa Madre
   2. [R] Test de RAM (mdsched)
   3. [R] Info de Recursos del Sistema
   4. [W] Mantenimiento (DISM/SFC)
   5. [W] Reparar Windows Update
   6. [W] Limpieza EMMC/Temporales
   7. [W] Reset de Red e IP
   8. [R] Test de Velocidad Real
   9. [R] Auditoria de Puertos/DNS
   10. [!] Formateo Seguro (Auditado)
   11. [!] Conversion MBR a GPT
   12. [W] Actualizar Apps (Winget)
   13. [W] ACTIVACION MASTER (MAS)
   14. [W] Apagado Programado
   15. [R] Reporte de Bateria
   16. [W] Backup de Drivers (ESCRIBE EN DISCO)

   [ ANALISIS AVANZADO - SOLO LECTURA ]
   17. [R] Eventos Criticos
   18. [R] Analisis BSOD
   19. [R] Auditoria Forense de Procesos
   20. [R] Estado RAID/Storage
   21. [W] Perfil Seguridad Alta (Blindaje V1 integrado)

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
   [99] CAMBIAR PERFIL
==============================================================================================================

=> Selecciona una opcion:
```

**Este perfil tiene acceso completo**, incluyendo operaciones criticas como formateo/conversion y la opcion 21 de Blindaje V1.

> Nota: en `toolbox_corporate.bat`, la opcion 13 aparece como `MODULO 13 REMOVIDO` por compliance.

### Limpieza de temporales en aulas (opción 21)

Dentro de **Perfil 3 (Administración)**, la **opción 21 (Perfil Seguridad Alta)** ahora incluye:

- **Dos caminos de aplicación** dentro del mismo menú.
- **Blindaje estricto**: maximiza la protección sobre archivos y carpetas académicas, pero algunas apps como Office/Adobe pueden fallar al guardar si usan temporales o reemplazo atómico; incluso editar un archivo existente y guardar sobre el mismo puede fallar.
- **Bloqueo suave**: protege la estructura de carpetas académicas detectadas bajo `%BL_ROOT_DIR%` (excepto `PERFIL` y `BGInfo`), pero permite guardar y borrar archivos individuales con normalidad.
- **Redirección diaria robusta**: Escritorio/Documentos/Descargas/Música/Imágenes/Vídeos apuntan a la ruta física `%BL_ROOT_DIR%\PERFIL\Usuario`, evitando el error de “Ubicación no disponible” si `T:` tarda en aparecer al iniciar en equipos lentos.
- **Revisión/Limpieza manual segura**: busca solo temporales en `Trabajos Alumnos\SECUNDARIA` y `Trabajos Alumnos\PRIMARIA` con patrones `~$*`, `.tmp`, `.temp`.
- **Programación automática local**: crea una tarea diaria en ese equipo para la misma limpieza segura.
- **Desactivación automática local**: elimina la tarea programada cuando ya no se necesita.
- **Guía de despliegue masivo**: pasos para aplicarlo por GPO (dominio) o script remoto (sin dominio).

Esto evita borrar archivos reales de los alumnos (por ejemplo `.psd`, `.prproj`, `.aep`).

> Nota de integración: la explicación operativa de Blindaje V1 ya está integrada en este manual y en `CATALOGO_OPCIONES_ES.md`.

**Para usar una función:**
1. Escribe el **número de la opción** que quieres usar
2. Presiona **Enter**
3. Sigue las instrucciones en pantalla
4. La herramienta te guiará paso a paso

**Para cambiar de perfil:**
- Escribe **99** y presiona Enter en cualquier momento
- Podrás elegir un perfil diferente sin reiniciar la herramienta

### Ejecucion por CLI (opcional)

Tambien puedes iniciar la herramienta con parametros para preseleccionar perfil y modulo:

```cmd
toolbox.bat /perfil:X /mod:Y
```

- `X` = perfil (`1` Diagnostico, `2` Reparacion, `3` Administracion)
- `Y` = numero de modulo dentro de ese perfil

Ejemplos rapidos (version completa `toolbox.bat`):

- Perfil 1 (Diagnostico):
  - `toolbox.bat /perfil:1 /mod:1` (Test RAM)
  - `toolbox.bat /perfil:1 /mod:4` (Estado Windows Update)
  - `toolbox.bat /perfil:1 /mod:11` (Estado RAID/Storage)
- Perfil 2 (Reparacion):
  - `toolbox.bat /perfil:2 /mod:4` (DISM/SFC)
  - `toolbox.bat /perfil:2 /mod:5` (Reparar Windows Update)
  - `toolbox.bat /perfil:2 /mod:10` (Apagado programado)
- Perfil 3 (Administracion):
  - `toolbox.bat /perfil:3 /mod:10` (Formateo seguro)
  - `toolbox.bat /perfil:3 /mod:11` (Conversion MBR a GPT)
  - `toolbox.bat /perfil:3 /mod:21` (Perfil Seguridad Alta)

Ejemplos rapidos (version `toolbox_corporate.bat`):

- `toolbox_corporate.bat /perfil:1 /mod:1` (SMART)
- `toolbox_corporate.bat /perfil:2 /mod:6` (Reparar Windows Update)
- `toolbox_corporate.bat /perfil:3 /mod:10` (Formateo seguro)

Notas:
- Si `perfil/modulo` no es valido para ese perfil, la ejecucion se bloquea y se registra en log.
- Los modulos mantienen sus confirmaciones de seguridad antes de ejecutar acciones criticas.

### Paso 6: Finalizar y Ver Logs

**Para salir:**
- Escribe **0** para generar reporte HTML y salir
- Escribe **00** para salir sin generar reporte (se guarda log + checksum)

**Sobre el reporte HTML:**
- La opción **0** genera automáticamente un archivo HTML en la carpeta `Logs/`
- El reporte incluye toda la información del sistema y el log de operaciones
- Se abrirá automáticamente en tu navegador

---

## 📁 ¿Dónde están los logs?

Los logs se guardan automáticamente en:
```
Windows/Logs/
├── Audit_2024-02-10.log         (Registro de todas las operaciones)
├── Report_2024-02-10.html       (Reporte visual)
└── battery-report.html          (Si usaste la función de batería)
```

---

## ⚠️ Solución de Problemas (Windows)

### Error: "No tiene privilegios de administrador"
**Solución:** Debes ejecutar con clic derecho → "Ejecutar como administrador"

### Error: "El sistema no puede ejecutar el script"
**Solución:**
1. Windows puede haber bloqueado el archivo
2. Clic derecho en `toolbox.bat` → Propiedades
3. Si ves "Este archivo proviene de otro equipo", marca "Desbloquear"
4. Clic en Aplicar → Aceptar

### La ventana se cierra inmediatamente
**Solución:** Ejecuta desde CMD o PowerShell para ver el error

### No aparece el menú de colores
**Solución:** Usa la nueva Terminal de Windows o CMD (no PowerShell ISE)

### Error al validar scripts con `bash -n` en Windows
**Causa:** `bash.exe` depende de WSL y de una distro Linux instalada/activa.

**Qué significa:** si WSL no tiene distro configurada, el chequeo `bash -n` falla aunque el script `.sh` esté correcto.

**Solución rápida:**
1. Instalar/activar WSL y una distro (por ejemplo Ubuntu).
2. Reintentar validación de sintaxis desde Linux/WSL:
   - `bash -n Linux/toolbox.sh`
   - `bash -n Linux/toolbox_corporate.sh`
   - `bash -n Mac/toolbox.sh`
   - `bash -n Mac/toolbox_corporate.sh`

---

## 🐧 LINUX {#seccion-linux}

## 📋 Requisitos del Sistema (Linux)

| Requisito | Especificación |
|-----------|----------------|
| **Distribuciones soportadas** | Debian, Ubuntu, Fedora, RHEL, CentOS, Arch, Manjaro, OpenSUSE |
| **Bash** | Versión 4.0 o superior (preinstalado) |
| **Privilegios** | root o sudo (obligatorio) |
| **Espacio en disco** | 50 MB mínimo |
| **Gestor de paquetes** | apt, dnf, yum, pacman o zypper |

---

## 🚀 Instalación en Linux - PASO A PASO

### Paso 1: Descargar o transferir la herramienta

**Opción A - Si descargaste en Windows:**
1. Copia la carpeta `Herramienta-toolbox` a tu sistema Linux
2. Usa un USB, red compartida, o FileZilla/SCP

**Opción B - Descargar directamente en Linux:**
1. Abre una terminal
2. Descarga en tu carpeta home:
   ```bash
   cd ~
   # Aquí descarga o extrae el archivo
   ```

### Paso 2: Navegar a la carpeta Linux

1. Abre una **Terminal** (Ctrl + Alt + T en la mayoría de distribuciones)
2. Navega hasta la carpeta:
   ```bash
   cd /ruta/donde/esta/Herramienta-toolbox/Linux
   ```

   **Ejemplo:**
   ```bash
   cd ~/Descargas/Herramienta-toolbox/Linux
   ```

3. Verifica que estás en el lugar correcto:
   ```bash
   ls -l
   ```

   Deberías ver:
   ```
   toolbox.sh
   toolbox_corporate.sh
   ```

### Paso 3: Dar permisos de ejecución

🔴 **IMPORTANTE**: Los scripts necesitan permisos de ejecución

```bash
chmod +x toolbox.sh toolbox_corporate.sh
```

**Explicación:**
- `chmod +x` = Dar permisos de ejecución
- Esto solo se hace UNA vez

### Paso 4: Ejecutar con sudo

🔴 **IMPORTANTE**: Debes ejecutar con sudo (como root)

**Para la versión completa:**
```bash
sudo ./toolbox.sh
```

**Para la versión corporativa (sin módulos de activación):**
```bash
sudo ./toolbox_corporate.sh
```

**¿Qué significa cada parte?**
- `sudo` = Ejecutar como superusuario (root)
- `./` = Ejecutar desde la carpeta actual
- `toolbox.sh` = Nombre del script

**Te pedirá tu contraseña**: Escríbela y presiona Enter
(No verás nada mientras escribes, es normal por seguridad)

### Paso 5: Seleccionar Perfil de Ejecución

Verás esta pantalla:

```
==============================================================================================================
                     Renggli PC Solution - SUITE ENTERPRISE V14 (LINUX)
==============================================================================================================
Log Actual: /ruta/Logs/Audit_2024-02-10.log
Distribución: ubuntu 22.04 | Gestor de paquetes: apt

[SELECCION DE PERFIL]

1. DIAGNOSTICO     - Solo lectura, auditoria y consultas (sin modificaciones)
2. REPARACION      - Mantenimiento y reparaciones automatizadas
3. ADMINISTRACION  - Acceso completo (incluye formateo y operaciones críticas)

=> Seleccione perfil [1-3]:
```

**Elige tu perfil:**
- **1** = Solo diagnóstico, no hace cambios
- **2** = Permite reparaciones y actualizaciones
- **3** = Acceso completo (formateo de discos, conversiones)

Escribe el número y presiona **Enter**.

### Paso 6: Usar el Menú Principal

Verás un menú con **30 opciones** organizadas en categorías:

```
==============================================================================================================
   [ DIAGNOSTICO DE HARDWARE ]      [ REPARACION DE SISTEMA ]        [ REDES Y CONECTIVIDAD ]
   1. Estado SMART de Discos        6. Verificar Sistema (fsck)      11. Reset de Red
   2. Info Hardware Completo        7. Reparar Gestor Paquetes       12. Test de Velocidad
   3. Test de Memoria RAM           8. Limpieza Profunda             13. Auditoria DNS/Puertos
   4. Info Sistema Operativo        9. Reparar Bootloader (GRUB)     14. Diagnostico Firewall
   5. Temperatura y Sensores        10. Limpieza Docker              15. Monitor de Red en Vivo

   [ GESTION DE ALMACENAMIENTO ]    [ SERVICIOS Y PROCESOS ]         [ AUTOMATIZACION ]
   16. Formateo Seguro USB          21. Gestión de Servicios         26. Actualizar Sistema
   17. Conversión MBR a GPT         22. Top Procesos CPU/RAM         27. Apagado Programado
   18. Análisis de Disco            23. Ver Logs del Sistema         28. Backup de Datos
   19. Montaje de Particiones       24. Usuarios y Permisos          29. Reporte Batería
   20. Espacio en Disco             25. Monitoreo en Tiempo Real     30. Verificar Integridad

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
==============================================================================================================
```

**Para usar una función:**
1. Escribe el **número** de la opción
2. Presiona **Enter**
3. Sigue las instrucciones
4. Presiona **Enter** para continuar después de cada operación

### Paso 7: Finalizar

**Para salir:**
- Escribe **0** para generar reporte HTML y salir
- Escribe **00** para salir sin generar reporte (se guarda log + checksum)

**Sobre el reporte HTML:**
- La opción **0** genera automáticamente un archivo HTML
- El reporte incluye toda la información del sistema y el log de operaciones

---

## 📁 ¿Dónde están los logs? (Linux)

Los logs se guardan en:
```
Linux/Logs/
├── Audit_2024-02-10.log           (Registro de operaciones)
└── Report_Linux_2024-02-10.html   (Reporte visual)
```

Para ver el log:
```bash
cat Logs/Audit_2024-02-10.log
```

Para abrir el reporte HTML:
```bash
firefox Logs/Report_Linux_2024-02-10.html
# O tu navegador preferido
```

---

## ⚠️ Solución de Problemas (Linux)

### Error: "Permission denied"
**Solución:**
```bash
chmod +x toolbox.sh
sudo ./toolbox.sh
```

### Error: "No such file or directory"
**Solución:** Verifica que estás en la carpeta correcta:
```bash
pwd  # Muestra la ruta actual
ls   # Lista archivos
```

### Error: "This script requires root privileges"
**Solución:** Debes usar `sudo`:
```bash
sudo ./toolbox.sh
```

### Las dependencias no se instalan automáticamente
**Solución:** La herramienta detecta e instala automáticamente paquetes como:
- smartmontools (para SMART)
- lm-sensors (para temperaturas)
- speedtest-cli (para test de velocidad)

Si falla, instala manualmente:
```bash
# Debian/Ubuntu
sudo apt install smartmontools lm-sensors speedtest-cli

# Fedora/RHEL
sudo dnf install smartmontools lm_sensors speedtest-cli

# Arch
sudo pacman -S smartmontools lm_sensors speedtest-cli
```

---

## 🍎 macOS {#seccion-macos}

## 📋 Requisitos del Sistema (macOS)

| Requisito | Especificación |
|-----------|----------------|
| **Sistema Operativo** | macOS 10.14 (Mojave) o superior |
| **Shell** | Bash o Zsh (preinstalado) |
| **Privilegios** | Administrador con sudo (obligatorio) |
| **Espacio en disco** | 50 MB mínimo |
| **Xcode CLI Tools** | Se instala automáticamente si falta |
| **Homebrew** | Recomendado (se puede instalar automáticamente) |

---

## 🚀 Instalación en macOS - PASO A PASO

### Paso 1: Descargar la herramienta (macOS)

1. Descarga la carpeta `Herramienta-toolbox`
2. Extrae el archivo (doble clic en el .zip)
3. Mueve la carpeta a tu ubicación preferida (Ejemplo: `~/Documents/`)

### Paso 2: Abrir Terminal

**Método 1 - Spotlight:**
1. Presiona `Cmd + Espacio`
2. Escribe "Terminal"
3. Presiona Enter

**Método 2 - Finder:**
1. Abre **Finder**
2. Ve a **Aplicaciones** → **Utilidades**
3. Doble clic en **Terminal**

### Paso 3: Navegar a la carpeta Mac

En la terminal, escribe:

```bash
cd /ruta/donde/esta/Herramienta-toolbox/Mac
```

**Ejemplo:**
```bash
cd ~/Documents/Herramienta-toolbox/Mac
```

**Truco:** Puedes arrastrar la carpeta a la terminal después de escribir `cd` y luego un espacio.

Verifica que estás en el lugar correcto:
```bash
ls -l
```

Deberías ver:
```
toolbox.sh
toolbox_corporate.sh
```

### Paso 4: Dar permisos de ejecución

```bash
chmod +x toolbox.sh toolbox_corporate.sh
```

### Paso 5: Permitir ejecución en Seguridad (Primera vez)

🔴 **IMPORTANTE PARA macOS:**

macOS bloquea scripts descargados de internet. Para permitirlos:

**Opción A - Remover cuarentena:**
```bash
xattr -d com.apple.quarantine toolbox.sh toolbox_corporate.sh
```

**Opción B - Si aparece mensaje de seguridad:**
1. Intenta ejecutar el script:
   ```bash
   sudo ./toolbox.sh
   ```
2. Si macOS lo bloquea, verás un mensaje
3. Ve a **Preferencias del Sistema** → **Seguridad y Privacidad**
4. En la pestaña **General**, verás un mensaje sobre el script bloqueado
5. Haz clic en **"Permitir de todos modos"**
6. Vuelve a ejecutar el script

### Paso 6: Ejecutar con sudo

🔴 **IMPORTANTE**: Debes ejecutar con sudo

**Para la versión completa:**
```bash
sudo ./toolbox.sh
```

**Para la versión corporativa:**
```bash
sudo ./toolbox_corporate.sh
```

**Te pedirá tu contraseña de macOS**: Escríbela y presiona Enter
(No verás nada mientras escribes, es normal)

### Paso 7: Seleccionar Perfil

Verás esta pantalla:

```
==============================================================================================================
                     Renggli PC Solution - SUITE ENTERPRISE V14 (macOS)
==============================================================================================================
Log Actual: /ruta/Logs/Audit_2024-02-10.log

[SELECCION DE PERFIL]

1. DIAGNOSTICO     - Solo lectura, auditoria y consultas
2. REPARACION      - Mantenimiento y reparaciones
3. ADMINISTRACION  - Acceso completo (operaciones críticas)

=> Seleccione perfil [1-3]:
```

Elige el número y presiona Enter.

### Paso 8: Usar el Menú Principal

El menú de macOS incluye actualmente 14 opciones, organizadas por perfil.

Funciones principales de macOS incluyen:
- Diagnóstico de hardware, recursos y procesos
- Verificación de disco y sistema de archivos
- Diagnóstico y reset de red
- Actualización y limpieza del sistema
- Apagado programado y reporte del sistema

**Opciones de salida (macOS):**
- **0** = salir con reporte
- **00** = salir sin reporte y sin log

---

## 📁 ¿Dónde están los logs? (macOS)

Los logs se guardan en:
```
Mac/Logs/
├── Audit_2024-02-10.log
└── Report_Mac_2024-02-10.html
```

Para ver el log:
```bash
cat Logs/Audit_2024-02-10.log
```

Para abrir el reporte HTML:
```bash
open Logs/Report_Mac_2024-02-10.html
```

---

## ⚠️ Solución de Problemas (macOS)

### Error: "Operation not permitted"
**Solución:** Ejecuta con `sudo`:
```bash
sudo ./toolbox.sh
```

### Error: "command not found: brew"
**Solución:** Algunas funciones usan Homebrew. Instálalo:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### macOS bloquea la ejecución
**Solución:**
```bash
xattr -d com.apple.quarantine toolbox.sh
```

O ve a **Preferencias del Sistema** → **Seguridad y Privacidad** y permite el script.

### Xcode Command Line Tools no instalado
**Solución:** macOS te pedirá instalarlos automáticamente. Si no:
```bash
xcode-select --install
```

---

## 🔒 SISTEMA DE PERFILES (Todos los Sistemas)

### 1️⃣ DIAGNOSTICO (Solo Lectura)
- ✅ Ver información del hardware
- ✅ Estados y consultas
- ❌ NO hace cambios al sistema

**Ideal para:**
- Auditorías
- Chequeos preventivos
- Cuando NO tienes autorización para hacer cambios

### 2️⃣ REPARACION (Mantenimiento)
- ✅ Todo lo de DIAGNOSTICO +
- ✅ Limpieza de archivos temporales
- ✅ Reparaciones automáticas
- ✅ Actualizaciones del sistema
- ❌ NO permite formateo ni conversiones

**Ideal para:**
- Soporte técnico diario
- Mantenimiento rutinario
- Resolver problemas comunes

### 3️⃣ ADMINISTRACION (Acceso Total)
- ✅ TODO (DIAGNOSTICO + REPARACION) +
- ✅ Formateo de discos
- ✅ Conversiones MBR/GPT
- ✅ Operaciones críticas

⚠️ **CUIDADO:** Este perfil puede borrar datos

**Ideal para:**
- Técnicos senior
- Preparación de equipos nuevos
- Operaciones autorizadas críticas

---

## 📊 COMPARATIVA DE FUNCIONALIDADES

| Función | Windows | Linux | macOS |
|---------|---------|-------|-------|
| Estado SMART discos | ✅ | ✅ | ✅ |
| Info Hardware | ✅ | ✅ | ✅ |
| Test RAM | ✅ | ✅ | ⚠️ |
| Reparar Sistema | ✅ DISM/SFC | ✅ fsck | ✅ diskutil |
| Actualizaciones | ✅ Winget | ✅ apt/dnf/pacman | ✅ brew/softwareupdate |
| Reset Red | ✅ | ✅ | ✅ |
| Test Velocidad | ✅ | ✅ | ✅ |
| Formateo Discos | ✅ | ✅ | ✅ |
| MBR → GPT | ✅ | ✅ | ❌ |
| Docker | ❌ | ✅ | ✅ |
| Firewall | ✅ | ✅ UFW/firewalld | ✅ |
| Reporte Batería | ✅ | ✅ | ✅ |

---

## 🆕 MODULOS NUEVOS EN WINDOWS (V14)

Se agregaron los siguientes modulos en `Windows/toolbox.bat` y `Windows/toolbox_corporate.bat`:

- Eventos Criticos del Sistema (disco/energia)
- Analisis BSOD (Minidump + Event ID 1001)
- Auditoria Forense de Procesos (rutas temporales + firma digital)
- Estado RAID/Storage (Storage cmdlets + fallback WMI)
- Backup de Drivers (DISM export-driver)
- Perfil Seguridad Alta (Blindaje V1 integrado: modo estricto + bloqueo suave, mapeo persistente T:, NoDrives/NoViewOnDrive, redireccion de carpetas diarias a ruta fisica y deshacer/verificar)

Notas:

- Los modulos de diagnostico son de solo lectura.
- `Backup de Drivers` genera cambios en disco y requiere espacio disponible.
- `Perfil Seguridad Alta` modifica registro, ACLs y hive del alumno. Elegir `estricto` si la prioridad es no perder archivos; elegir `suave` si la prioridad es compatibilidad de guardado en Office/Adobe sin permitir borrar carpetas. Tras `Deshacer`, reiniciar y verificar manualmente en `C:\` si `Trabajos Alumnos` se elimino o si requiere limpieza manual.

---

## 👨‍💻 GUIA PARA PROGRAMADORES: COMO AGREGAR NUEVOS MODULOS

Esta seccion explica como extender la Toolbox en **Windows, Linux y macOS** de forma segura y consistente.

### 1) Conocimientos recomendados

Antes de agregar modulos, se recomienda:

- Windows: Batch (`.bat`), comandos administrativos (`DISM`, `SFC`, `PowerShell`, `netsh`, `wmic`/alternativas).
- Linux/macOS: Bash, permisos (`sudo`, `root`), utilidades de sistema (`systemctl`, `journalctl`, `ip`, `diskutil`, `launchctl`).
- Seguridad operacional: entender comandos destructivos (discos, red, usuarios, apagados) y su impacto.
- Trazabilidad: saber mantener logs legibles y auditables.
- Git y flujo de cambios: ramas, commits pequenos, validacion local y PR.

### 2) Dónde se agregan las funciones por sistema

Para mantener paridad entre ediciones normal/corporate:

- Windows normal: `Windows/toolbox.bat`
- Windows corporate: `Windows/toolbox_corporate.bat`
- Linux normal: `Linux/toolbox.sh`
- Linux corporate: `Linux/toolbox_corporate.sh`
- macOS normal: `Mac/toolbox.sh`
- macOS corporate: `Mac/toolbox_corporate.sh`

Regla general:

- Agrega la opcion en el menu del perfil correcto (`DIAGNOSTICO`, `REPARACION` o `ADMINISTRACION`).
- Enruta la opcion a un modulo dedicado (`MOD_...` en Windows, `mod_...` en Linux/macOS).
- Implementa el modulo como bloque/funcion independiente.
- Regresa siempre al menu despues de ejecutar el modulo.

### 3) Estructura minima de un modulo nuevo

Un modulo nuevo debe incluir, como minimo:

- Titulo claro en pantalla (que accion realiza).
- Validaciones previas (privilegios, existencia de comandos/archivos, parametros validos).
- Confirmacion adicional si la accion es sensible.
- Ejecucion principal con manejo de error controlado.
- Registro en log con timestamp.
- Retorno limpio al menu.

Buenas practicas de nomenclatura:

- Variables: `UPPER_SNAKE_CASE`.
- Modulos: prefijo `MOD_` (Batch) o `mod_` (Bash).
- Validaciones auxiliares: prefijo `CHECK_` / `check_`.

### 4) Seguridad obligatoria al extender

Si el modulo modifica sistema, disco o red, debes cumplir esto:

- No tocar disco/particion del sistema sin bloqueo explicito.
- No borrar con comodines amplios fuera del alcance de Toolbox.
- No romper tareas externas del sistema (cron/launchd/Task Scheduler ajenas).
- Mantener chequeos de administrador/root intactos.
- Mostrar advertencias claras antes de operaciones irreversibles.

### 5) Diferencias por plataforma que debes considerar

- Windows:
  - Usa comandos compatibles con Windows 10/11 y Server soportados.
  - Si llamas herramientas externas, valida su existencia antes.
  - Mantiene consistencia de salida con reporte HTML y checksum SHA256.

- Linux:
  - Considera variaciones por distro (apt, dnf, yum, pacman, zypper).
  - Evita asumir rutas unicas para todos los sistemas.
  - Mantiene manejo robusto en pipelines para no abortar por falsos negativos.

- macOS:
  - Verifica compatibilidad con Intel y Apple Silicon.
  - Evita dependencias no instaladas por defecto sin validacion previa.
  - Si usas `launchd`, limita cambios a identificadores de Toolbox.

### 6) Checklist rapido antes de publicar

1. El modulo aparece solo en el/los perfiles correctos.
2. Funciona en version normal y corporate (o se bloquea con mensaje claro en corporate).
3. Tiene validaciones, confirmaciones y log.
4. No rompe opciones de salida (`0` y `00`) ni el retorno al menu.
5. No introduce patrones inseguros en limpieza/apagado/disco.
6. Pruebas manuales basicas completadas en el sistema objetivo.

### 7) Documentacion que debes actualizar

Cuando cambies comportamiento o agregues modulos, actualiza:

- `HISTORIAL_DE_CAMBIOS.md`
- `Manuales/README_ES.md`
- `Manuales/README_EN.md`
- `Manuales/README_CN.md`

Y sigue el flujo de contribucion definido en:

- `CONTRIBUTING.md`

### 8) Ejemplo de flujo recomendado (resumen)

1. Diseñar el modulo y su perfil objetivo.
2. Implementarlo en script normal del sistema operativo.
3. Replicar/adaptar en script corporate.
4. Probar rutas exitosas y de error.
5. Verificar logs, salida y regreso al menu.
6. Actualizar documentacion y registrar en historial.
7. Crear PR con alcance, riesgos y validaciones realizadas.

---

## 📘 CATALOGO DETALLADO DE MENUS Y OPCIONES

Para entender **cada opcion** (que hace, para que sirve, cuando usarla y recaudos), consulta:

- `Manuales/CATALOGO_OPCIONES_ES.md`

Incluye cobertura de:

- Windows (normal y corporate)
- Linux (normal y corporate)
- macOS (normal y corporate)
- Perfiles `DIAGNOSTICO`, `REPARACION`, `ADMINISTRACION`
- Etiquetas de riesgo `[R]`, `[W]`, `[!]`

### Nota de robustez (Actualizacion 16)

- En Windows, Linux y macOS ahora se valida formato de hora `HH:MM` en apagados programados para evitar errores de entrada.
- Los reportes HTML de todas las plataformas ahora escapan caracteres especiales del log (`&`, `<`, `>`), evitando roturas visuales.
- El checksum SHA256 se guarda en archivo separado `*.sha256` para no invalidar el hash del log por auto-modificacion.

---

## 📞 SOPORTE

¿Problemas o preguntas?
- 📧 Email: [tomasrenggli@gmail.com](mailto:tomasrenggli@gmail.com)
- 📚 Documentación completa en carpeta `Manuales/`

---

## 🎯 VERSION

**Toolbox V14 Multiplataforma**
- Windows: 21 módulos
- Linux: 30 módulos
- macOS: 14 módulos

**© 2024 Renggli PC Solution**
