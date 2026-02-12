# 🛠️ RENGGLI PC SOLUTIONS - Enterprise Toolbox V14
## Suite Multiplataforma (Windows | Linux | macOS)

**Solución profesional de diagnóstico, reparación y administración para técnicos IT**

---

## 🌍 ELIGE TU SISTEMA OPERATIVO

Este manual cubre la instalación y uso en **Windows, Linux y macOS**.

**Salta directamente a tu sección:**
- 🪟 [Instrucciones para WINDOWS](#windows)
- 🐧 [Instrucciones para LINUX](#linux)
- 🍎 [Instrucciones para macOS](#macos)

---

<h1 id="windows">🪟 WINDOWS</h1>

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
                        RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14
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

   [ DIAGNOSTICO DE HARDWARE ]      [ INFORMACION DE SISTEMA ]       [ MONITOREO ]
   1. Estado SMART de Discos        4. Info BIOS y Placa Madre       7. Test de Velocidad de Red
   2. Test de RAM (mdsched)         5. Auditoria de Puertos/DNS      8. Reporte de Bateria
   3. Info de Recursos del Sistema  6. Estado de Windows Update

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
   [99] CAMBIAR PERFIL
==============================================================================================================

=> Selecciona una opcion:
```

**Este perfil solo tiene opciones de lectura.** No modifica el sistema, solo consulta información.

#### 🔧 Si elegiste REPARACION (Perfil 2):

```
==============================================================================================================
   Perfil Activo: [REPARACION] - Mantenimiento y Reparaciones

   [ DIAGNOSTICO ]                  [ REPARACION DE SISTEMA ]        [ REDES Y ACTUALIZACIONES ]
   1. Estado SMART de Discos        5. Mantenimiento (DISM/SFC)      9. Reset de Red e IP
   2. Test de RAM (mdsched)         6. Reparar Windows Update       10. Test de Velocidad
   3. Info BIOS y Placa Madre       7. Limpieza EMMC/Temporales     11. Actualizar Apps (Winget)
   4. Reporte de Bateria            8. Auditoria de Puertos/DNS     12. Apagado Programado

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
   [99] CAMBIAR PERFIL
==============================================================================================================

=> Selecciona una opcion:
```

**Este perfil incluye diagnóstico + reparaciones del sistema.** Puede hacer mantenimiento pero no operaciones críticas.

#### ⚠️ Si elegiste ADMINISTRACION (Perfil 3):

```
==============================================================================================================
   Perfil Activo: [ADMINISTRACION] - Acceso Completo

   [ DIAGNOSTICO DE HARDWARE ]      [ REPARACION DE SISTEMA ]        [ REDES Y CONECTIVIDAD ]
   1. Estado SMART de Discos        4. Mantenimiento (DISM/SFC)      7. Reset de Red e IP
   2. Info BIOS y Placa Madre       5. Reparar Windows Update        8. Test de Velocidad Real
   3. Test de RAM (mdsched)         6. Limpieza EMMC/Temporales      9. Auditoria de Puertos/DNS

   [ GESTION DE ALMACENAMIENTO ]    [ SOFTWARE Y LICENCIAS ]         [ AUTOMATIZACION ]
   10. Formateo Seguro (Auditado)   12. Actualizar Apps (Winget)     14. Apagado Programado
   11. Conversion MBR a GPT         13. ACTIVACION MASTER (MAS)      15. Reporte de Bateria

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
   [99] CAMBIAR PERFIL
==============================================================================================================

=> Selecciona una opcion:
```

**Este perfil tiene acceso completo**, incluyendo operaciones críticas como formateo, conversión GPT y activación.

**Para usar una función:**
1. Escribe el **número de la opción** que quieres usar
2. Presiona **Enter**
3. Sigue las instrucciones en pantalla
4. La herramienta te guiará paso a paso

**Para cambiar de perfil:**
- Escribe **99** y presiona Enter en cualquier momento
- Podrás elegir un perfil diferente sin reiniciar la herramienta

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
Herramienta-toolbox\Windows\Logs\
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

---

<h1 id="linux">🐧 LINUX</h1>

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
                     RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (LINUX)
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

   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
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
Herramienta-toolbox/Linux/Logs/
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

<h1 id="macos">🍎 macOS</h1>

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

### Paso 1: Descargar la herramienta

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

**Truco:** Puedes arrastrar la carpeta a la terminal después de escribir `cd ` (con espacio).

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
                     RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (macOS)
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

El menú es similar al de Linux, con 30 opciones adaptadas para macOS.

Funciones específicas de Mac incluyen:
- FileVault status (encriptación de disco)
- Gatekeeper status (seguridad de apps)
- SIP status (System Integrity Protection)
- Time Machine backup
- App Store updates

**Opciones de salida (macOS):**
- **0** = salir sin reporte
- **00** = generar reporte y salir
- **01** = generar reporte y volver al menú
- **02** = salir sin log

---

## 📁 ¿Dónde están los logs? (macOS)

Los logs se guardan en:
```
Herramienta-toolbox/Mac/Logs/
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

## 📞 SOPORTE

¿Problemas o preguntas?
- 📧 Email: soporte@renggli-solutions.com
- 📚 Documentación completa en carpeta `Manuales/`

---

## 🎯 VERSION

**Toolbox V14 Multiplataforma**
- Windows: 15 módulos
- Linux: 30 módulos
- macOS: 30 módulos

**© 2024 RENGGLI PC SOLUTIONS**
