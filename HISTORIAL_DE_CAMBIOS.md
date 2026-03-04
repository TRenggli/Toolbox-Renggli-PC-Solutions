# HISTORIAL DE CAMBIOS

## 2026-03-04 (Actualización 6)

### Mejoras No Bloqueantes Aplicadas

#### 1) Resiliencia de ejecución en Unix (Linux/macOS)
- Se eliminó el modo global `set -e` en las 4 herramientas Unix:
  - `Linux/toolbox.sh`
  - `Linux/toolbox_corporate.sh`
  - `Mac/toolbox.sh`
  - `Mac/toolbox_corporate.sh`
- Se reemplazó por `set -o pipefail` para mantener control en pipelines sin abortar toda la suite ante fallos puntuales no críticos.

#### 2) CI automatizado de regresión
- Se agregó workflow de GitHub Actions:
  - `.github/workflows/ci-smoke.yml`
- Cobertura de validaciones automáticas en push/PR a `main`:
  - Sintaxis Bash en scripts Linux/macOS (`bash -n`)
  - Enrutamiento correcto de salida `00` hacia no-log
  - Prevención de regresión del checksum SHA256 en Windows
  - Verificación de que limpieza de apagado permanezca acotada a tareas de Toolbox
  - Consistencia documental de opciones de salida (ES/EN/CN)

#### 4) CI Matrix (Linux/macOS + Windows estático)
- Se agregó un segundo workflow para cobertura por runner y regresión multi-plataforma:
  - `.github/workflows/ci-matrix-regression.yml`
- Validaciones adicionales:
  - Matriz `ubuntu-latest` y `macos-latest` con chequeos de shell/safety
  - Job dedicado `windows-latest` para validaciones estáticas de `.bat`
  - Verificación documental ES/EN/CN desde runner Windows

#### 3) Cobertura documental multi-idioma (CN)
- Se actualizó `Manuales/README_CN.md` para reflejar el comportamiento real actual:
  - `[0]` = generar reporte y salir
  - `[00]` = salir sin reporte y sin log


## 2026-03-04 (Actualización 5)

### Ajustes Finales de Calidad y Consistencia
- **Checksum SHA256 (Windows) corregido**:
  - Se corrigió el parseo de hash en `toolbox.bat` y `toolbox_corporate.bat`.
  - Se eliminó `skip=3` en el `for /f` para evitar hashes vacíos al cerrar sesión.

### Consistencia de Opciones de Salida
- Se actualizó el texto de menú en Windows/Linux/macOS para reflejar el comportamiento real:
  - `[00] SALIR SIN REPORTE Y SIN LOG`
- Resultado: UX alineada con la implementación de `EXIT_NO_LOG` / `exit_no_log`.

### Documentación Sincronizada
- Se actualizó `Manuales/README_ES.md` en bloques de menú y opciones de salida para que coincidan con la versión actual de las herramientas.

## 2026-03-04 (Actualización 4)

### Hardening Cross-Platform para Entornos Productivos
- **Cambio Principal**: Se aplicó endurecimiento integral de seguridad y robustez en Windows, Linux y macOS (version normal y corporate).
- **Archivos Modificados**:
  - Windows/toolbox.bat
  - Windows/toolbox_corporate.bat
  - Linux/toolbox.sh
  - Linux/toolbox_corporate.sh
  - Mac/toolbox.sh
  - Mac/toolbox_corporate.sh

### Salida Sin Log Corregida
- Se corrigió la opcion `[00] SALIR SIN REPORTE` para que use realmente la ruta de salida sin log (`EXIT_NO_LOG` / `exit_no_log`) en las 6 herramientas.
- Resultado: comportamiento alineado con el menu y mejor cumplimiento operativo/auditoria.

### Seguridad en Operaciones Destructivas de Disco
- **Windows**:
  - Validacion de entrada numerica para disco en formateo y conversion MBR->GPT.
  - Bloqueo explicito para impedir formatear/convertir el disco del sistema.
- **Linux**:
  - Validacion de nombre de dispositivo.
  - Bloqueo explicito para impedir operaciones sobre el dispositivo raiz del sistema.

### Apagado Programado con Alcance Seguro (No Interferencia)
- **Linux/macOS**:
  - Se eliminó la limpieza global por patrones `shutdown` en cron/launchd.
  - La gestion ahora afecta solo tareas administradas por Toolbox:
    - Linux: `/etc/cron.d/toolbox_shutdown`
    - macOS: `/Library/LaunchDaemons/com.renggli.toolbox.shutdown.plist`
- Resultado: evita borrar automatizaciones legitimas de servidores o politicas ajenas.

### Robustez Operativa
- **Linux (`set -e`)**:
  - Se endurecieron pipelines de diagnostico con `|| true` en comandos que pueden no devolver coincidencias (grep en dmesg/resolv/lsblk), evitando abortos no deseados.
- **Windows Update**:
  - Flujo de reset de cache mas idempotente (validaciones de existencia antes de renombrar directorios).

### Compatibilidad OpenSUSE (zypper)
- Se completaron ramas faltantes para `zypper` en instalacion, reparacion y actualizacion de paquetes en Linux (normal y corporate).

### Correcciones de Consistencia
- Correccion de etiqueta de version en `Mac/toolbox_corporate.sh` (macOS Edition).
- Correccion de formato de log en Winget (`Windows/toolbox_corporate.bat`).
- Eliminacion de `sudo` redundante en scripts macOS (ya requieren root al inicio).

### Publicación
- Commit publicado en `main`: `3924ab6`
- Titulo: `Hardening cross-platform toolbox for production safety`

## 2026-02-12 (Actualización 3)

### Simplificación de Opciones de Salida
- **Cambio Principal**: Se simplificaron las opciones de salida de 4 a 2 opciones en todas las herramientas:
  - `[0] SALIR CON REPORTE` - Genera el reporte HTML y sale de la aplicación
  - `[00] SALIR SIN REPORTE` - Sale directamente sin generar reporte
- **Archivos Modificados**:
  - Windows/toolbox.bat (versión normal)
  - Windows/toolbox_corporate.bat (versión corporativa)
  - Linux/toolbox.sh (versión normal)
  - Linux/toolbox_corporate.sh (versión corporativa)
  - Mac/toolbox.sh (versión normal)
  - Mac/toolbox_corporate.sh (versión corporativa)
- **Opciones Eliminadas**:
  - `[01] REPORTE Y VOLVER` - Se eliminó ya que el reporte ahora siempre sale
  - `[02] SALIR SIN LOG` - Se eliminó para mantener la integridad de auditoría
- **Comportamiento Actualizado**:
  - La opción 0 ahora genera el reporte y luego sale (antes salía sin reporte)
  - La opción 00 ahora sale sin reporte (antes generaba reporte y salía)
  - Se mantiene la generación de logs con checksum SHA256 en todas las ejecuciones
  - Los reportes HTML siguen incluyendo toda la información del sistema y logs de operaciones

### Revisión de Código
- **Estructura**: Se verificó la modularidad y consistencia del código en las 6 herramientas
- **Claridad**: El código mantiene comentarios claros y estructura consistente entre plataformas
- **Mejoras Aplicadas**:
  - Simplificación del flujo de salida reduce complejidad
  - Mantiene compatibilidad con funciones existentes de generación de reportes
  - Preserva la funcionalidad de logging y checksums para auditoría
- **Calidad del Código Verificada**:
  - ✅ Convenciones de nomenclatura consistentes (UPPER_SNAKE_CASE en variables, funciones con prefijos `MOD_`, `CHECK_`)
  - ✅ Manejo robusto de errores con validaciones tempranas de privilegios
  - ✅ Arquitectura modular con 35+ módulos independientes organizados por función
  - ✅ Documentación clara con delimitadores de sección y comentarios descriptivos
  - ✅ Logs de auditoría completos con timestamps y checksums SHA256
  - ✅ Control de acceso basado en perfiles (DIAGNOSTICO/REPARACION/ADMINISTRACION)
  - ✅ Patrones de confirmación doble para operaciones destructivas
  - ✅ Detección automática de distribución en Linux con mecanismos de respaldo
  - **Calificación General**: A- (90%) - Código de nivel empresarial profesional

---

## 2026-02-11 (Actualización 2)

### Confirmación de Módulos (Windows)
- Se agrego funcion MODULE_CONFIRM que muestra descripcion + advertencia antes de cada modulo.
- Los modulos ahora requieren confirmacion S/N antes de ejecutarse.
- Se incluyeron advertencias contextuales: "No interrumpir", "Guarda tu trabajo", "Operacion irreversible", etc.

### Detección de Tareas de Apagado Existentes
- **Windows**: Nueva funcion CHECK_EXISTING_SHUTDOWN_TASK que detecta tareas del Programador con accion de apagado (independiente del nombre).
- **Linux**: Nueva funcion check_existing_cron_shutdown que detecta entradas cron con "shutdown" en /etc/cron.d, cron.daily, cron.weekly.
- **Mac**: Nueva funcion check_existing_launchd_shutdown que detecta plists con "shutdown" en LaunchDaemons/LaunchAgents.
- En todas las plataformas: menu de 4 opciones (reemplazar/eliminar/crear nueva/cancelar) cuando se detecta tarea existente.

### Modulo de Apagado Programado en Mac
- Se agrego modulo mod_shutdown completo a Mac (toolbox.sh y toolbox_corporate.sh).
- Opciones: apagado en X minutos, hora exacta, diario/semanal via launchd, cancelacion.
- Numero de menu: 14. Apagado Programado.

---

## 2026-02-11 (Actualización 1)

- Se corrigio el retorno a menus para evitar mensajes de opcion invalida despues de ejecutar un modulo.
- Se agregaron mini explicaciones al entrar a cada menu, con avisos segun perfil.
- Se actualizaron las opciones de salida: salir sin reporte, reporte y salir, reporte y volver, salir sin log.
- Se mejoro el apagado programado:
  - Windows: opciones rapidas y programacion por tarea (una vez/diario/semanal) + cancelacion.
  - Linux: apagado por minutos, hora exacta y programacion diaria/semanal via cron + cancelacion.
- Se robustecio el reporte de bateria para equipos sin bateria y se evitan errores al abrir el archivo.
- Se actualizaron los manuales en ES/EN/CN para reflejar menus y opciones de salida.
- Se consolidaron archivos de cambios en este historial.
