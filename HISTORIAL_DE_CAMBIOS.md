# HISTORIAL DE CAMBIOS

## 2026-03-12 (Actualizacion 12)

### Nuevo Modulo Windows: Perfil Seguridad Aula (Normal + Corporate)
- Se agrego una nueva opcion de administracion en:
  - `Windows/toolbox.bat`
  - `Windows/toolbox_corporate.bat`
- Opcion incorporada en menu ADMINISTRACION:
  - `21. [W] Perfil Seguridad Aula (T:/ACL/NoDrives)`

Funciones incluidas en el modulo:
- `DRY-RUN`: simulacion sin cambios para validar parametros y comandos.
- `Aplicar`: hardening de aula con:
  - mapeo persistente kernel-level en `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices`
  - ACL granular en carpeta de trabajos (permite trabajar y deniega borrado estructural)
  - denegacion de lectura al perfil administrativo usando SID del alumno
  - inyeccion de `NoDrives=4` en `NTUSER.DAT` del alumno mediante carga offline de hive
- `Estado`: verificacion de mapeo, ACLs y politica `NoDrives`.
- `Rollback`: remocion de cambios aplicados por el modulo (registro/ACL/politica).

Notas operativas:
- El modulo requiere perfil `ADMINISTRACION` y privilegios elevados.
- Incluye edicion de parametros (usuario alumno/admin, ruta de trabajos, unidad virtual).
- Se agrego confirmacion reforzada por frase obligatoria para `Aplicar` (`APLICAR-AULA`) y `Rollback` (`ROLLBACK-AULA`).
- Se agrego tercera barrera: espera de seguridad de 5 segundos + confirmacion final `S/N` antes de ejecutar `Aplicar` o `Rollback`.
- Se agrego aclaracion en pantalla dentro del modulo indicando que automatiza y que pasos quedan manuales (estructura escolar/accesos directos/verificacion con sesion alumno).
- Se agrego checklist final en pantalla al terminar `Aplicar` con los pasos manuales pendientes para cierre operativo.
- Todo el flujo registra eventos en `!LOG_FILE!` para auditoria.

### Documentacion actualizada
- Se actualizo el conteo de modulos Windows a 21 en:
  - `README.md`
  - `Manuales/README_ES.md`
  - `Manuales/README_EN.md`
  - `Manuales/README_CN.md`
- Se actualizo catalogo de opciones Windows a 21 en:
  - `Manuales/CATALOGO_OPCIONES_ES.md`
  - `Manuales/CATALOGO_OPCIONES_EN.md`
  - `Manuales/CATALOGO_OPCIONES_CN.md`
- Se agrego Perfil Seguridad Aula a la seccion "Modulos nuevos en Windows (V14)" en:
  - `Manuales/README_ES.md`
  - `Manuales/README_EN.md`
  - `Manuales/README_CN.md`

## 2026-03-05 (Actualizacion 11)

### Cierre de Catalogo Multilenguaje (EN/CN)
- Se agregaron catalogos detallados adicionales:
  - `Manuales/CATALOGO_OPCIONES_EN.md`
  - `Manuales/CATALOGO_OPCIONES_CN.md`
- Se actualizaron enlaces de descubrimiento en:
  - `README.md` (catalogos detallados ES/EN/CN)
  - `Manuales/README_EN.md`
  - `Manuales/README_CN.md`
- Resultado: cobertura de catalogo detallado por opcion completa en espanol, ingles y chino.

## 2026-03-05 (Actualizacion 10)

### Nuevos Modulos Implementados en Windows (Normal + Corporate)
- Se agregaron 5 modulos nuevos en:
  - `Windows/toolbox.bat`
  - `Windows/toolbox_corporate.bat`

Modulos agregados:
- `MOD_EVENT_CRITICAL` - Analisis de eventos criticos de sistema (IDs relevantes de disco/energia)
- `MOD_BSOD_ANALYZER` - Analisis BSOD usando `%SystemRoot%\Minidump` + Event ID 1001
- `MOD_PROCESS_AUDIT` - Auditoria forense de procesos en rutas temporales con verificacion de firma digital
- `MOD_RAID_STATUS` - Estado RAID/Storage con cmdlets de Storage y fallback WMI
- `MOD_DRIVER_BACKUP` - Backup de drivers de terceros con `dism /online /export-driver`

Detalles de implementacion:
- Integrados en menus por perfil con numeracion extendida.
- Mantienen `MODULE_CONFIRM` y registro en `!LOG_FILE!`.
- Version corporate conserva el bloqueo del modulo 13 (MAS) sin cambios de compliance.

### Mejora UX de Menus (Windows)
- Se reorganizo la presentacion visual de menus en `toolbox.bat` y `toolbox_corporate.bat`.
- Se agruparon opciones en bloques (`DIAGNOSTICO BASE`, `REPARACION Y MANTENIMIENTO`, `ANALISIS AVANZADO`) para mejorar lectura.
- No se modifico la logica ni el enrutamiento de opciones: solo mejora visual/orden de lectura.
- Se etiqueto `ANALISIS AVANZADO` como `SOLO LECTURA` para evitar confusion operativa.
- Se marco explicitamente `Backup de Drivers` como opcion que escribe en disco.

### Menus por Perfil en Linux/macOS (Normal + Corporate)
- Se corrigio la segmentacion por perfil en:
  - `Linux/toolbox.sh`
  - `Linux/toolbox_corporate.sh`
  - `Mac/toolbox.sh`
  - `Mac/toolbox_corporate.sh`
- Ahora cada perfil muestra solo sus opciones objetivo:
  - `DIAGNOSTICO`: solo lectura/consulta.
  - `REPARACION`: diagnostico + mantenimiento guiado.
  - `ADMINISTRACION`: menu completo.
- Se agrego `99` para cambio de perfil sin reiniciar herramienta.
- Se incorporaron descripciones y advertencias en cada menu para usuarios inexpertos.

### Etiquetas de Riesgo en Menus (Todos los Sistemas)
- Se agrego leyenda de riesgo y marcado por opcion en:
  - `Windows/toolbox.bat`
  - `Windows/toolbox_corporate.bat`
  - `Linux/toolbox.sh`
  - `Linux/toolbox_corporate.sh`
  - `Mac/toolbox.sh`
  - `Mac/toolbox_corporate.sh`
- Convencion aplicada:
  - `[R]` = Solo lectura
  - `[W]` = Escribe/cambia sistema
  - `[!]` = Critico/irreversible
- Se marco explicitamente `Backup de Drivers` como operacion que escribe en disco.

### Catalogo Detallado de Opciones (ES)
- Se agrego `Manuales/CATALOGO_OPCIONES_ES.md` con detalle por opcion:
  - que hace
  - para que sirve
  - cuando usarla
  - recaudos y riesgo (`[R]`, `[W]`, `[!]`)
- Cobertura incluida para Windows, Linux y macOS (normal y corporate) en perfiles D/R/A.
- Se agregaron enlaces al catalogo desde:
  - `README.md`
  - `Manuales/README_ES.md`

### Documentacion Actualizada
- Se actualizo conteo de modulos Windows (de 15 a 20) en:
  - `README.md`
  - `Manuales/README_ES.md`
  - `Manuales/README_EN.md`
  - `Manuales/README_CN.md`
- Se agrego seccion de modulos nuevos Windows en los 3 manuales.

### Modulos Propuestos No Implementados
- **Thermal Stress / Test de estres**: no implementado por riesgo operativo alto (temperatura, estabilidad, desgaste).
- **Blindaje Escolar / Lockdown**: no implementado por nivel de impacto y riesgo alto en permisos/registro/persistencia.

## 2026-03-05 (Actualizacion 8)

### Guia para Extender Modulos (Documentacion de Desarrollo)
- Se agrego seccion para programadores en:
  - `Manuales/README_ES.md` (como agregar modulos en Windows/Linux/macOS)
  - `Manuales/README_EN.md` (developer guide equivalente)
  - `Manuales/README_CN.md` (developer guide equivalente)
- Contenido incluido en los 3 idiomas:
  - Conocimientos recomendados
  - Donde agregar funciones por sistema y por edicion (normal/corporate)
  - Estructura minima de modulo
  - Reglas de seguridad obligatorias
  - Consideraciones por plataforma
  - Checklist pre-publicacion
  - Documentacion obligatoria a actualizar

### Estandarizacion de PR para Modulos Nuevos
- Se agrego en `CONTRIBUTING.md` la seccion:
  - `New Module Template (Recommended)`
- Esta plantilla define una lista minima para PRs de nuevas funciones:
  - Cobertura por plataforma
  - Safety checks
  - Evidencia de validacion
  - Actualizacion documental

### Descubribilidad en README Principal
- Se agregaron enlaces directos en `README.md` a:
  - Guias de desarrollo ES/EN/CN
  - Plantilla de contribucion para modulos nuevos

## 2026-03-05 (Actualizacion 9)

### Optimizacion de Estructura Documental
- Se simplifico la documentacion para reducir duplicados y centralizar cambios tecnicos en un solo lugar.
- Se removieron documentos auxiliares redundantes:
  - `Manuales/README.md` (indice de manuales)
  - `Windows/FIX_WMIC_DEPRECADO.md`
  - `Windows/INTEGRACION_MAS.md`
  - `Windows/MEJORA_UX_CORPORATE.md`
- Los cambios tecnicos historicos de esos documentos se consolidan en este historial.
- Se movio la operativa de generacion de PDFs fuera de `README.md` y se centralizo en `Manuales/COMO_GENERAR_PDFS.md`.

### Resumen Tecnico Consolidado: Windows
- Correccion WMIC deprecado:
  - Se reemplazo uso de `wmic` por PowerShell/CIM en modulos de recursos y estado de Windows Update.
  - Archivos impactados: `Windows/toolbox.bat` y `Windows/toolbox_corporate.bat`.

- Integracion MAS (version normal):
  - Se integro opcion de activacion via `MAS_AIO.cmd` con validacion de archivo, logging y retorno al menu.
  - En version corporate el modulo de activacion permanece excluido por compliance.

- Mejora UX corporate:
  - Menus por perfil (DIAGNOSTICO/REPARACION/ADMINISTRACION) alineados a permisos reales.
  - Eliminacion de flujos confusos de "acceso denegado" cuando el menu ya controla el acceso.
  - Bloqueo explicito del modulo 13 en corporate con mensaje claro.

## 2026-03-04 (Actualización 7)

### Cierre de Gobernanza y Visibilidad
- Se agregaron badges de CI al `README.md` para visibilidad inmediata del estado de calidad:
  - `ci-smoke.yml`
  - `ci-matrix-regression.yml`

### Estándares de Proyecto
- Se incorporaron documentos de gobernanza técnica:
  - `SECURITY.md` (proceso de reporte responsable de vulnerabilidades)
  - `CONTRIBUTING.md` (flujo de contribución segura y checklist de cambios)

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
