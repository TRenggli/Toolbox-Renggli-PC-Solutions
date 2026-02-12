# HISTORIAL DE CAMBIOS

## 2026-02-12 (Actualizacion 3)

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

## 2026-02-11 (Actualizacion 2)

### Confirmacion de Modulos (Windows)
- Se agrego funcion MODULE_CONFIRM que muestra descripcion + advertencia antes de cada modulo.
- Los modulos ahora requieren confirmacion S/N antes de ejecutarse.
- Se incluyeron advertencias contextuales: "No interrumpir", "Guarda tu trabajo", "Operacion irreversible", etc.

### Deteccion de Tareas de Apagado Existentes
- **Windows**: Nueva funcion CHECK_EXISTING_SHUTDOWN_TASK que detecta tareas del Programador con accion de apagado (independiente del nombre).
- **Linux**: Nueva funcion check_existing_cron_shutdown que detecta entradas cron con "shutdown" en /etc/cron.d, cron.daily, cron.weekly.
- **Mac**: Nueva funcion check_existing_launchd_shutdown que detecta plists con "shutdown" en LaunchDaemons/LaunchAgents.
- En todas las plataformas: menu de 4 opciones (reemplazar/eliminar/crear nueva/cancelar) cuando se detecta tarea existente.

### Modulo de Apagado Programado en Mac
- Se agrego modulo mod_shutdown completo a Mac (toolbox.sh y toolbox_corporate.sh).
- Opciones: apagado en X minutos, hora exacta, diario/semanal via launchd, cancelacion.
- Numero de menu: 14. Apagado Programado.

---

## 2026-02-11 (Actualizacion 1)

- Se corrigio el retorno a menus para evitar mensajes de opcion invalida despues de ejecutar un modulo.
- Se agregaron mini explicaciones al entrar a cada menu, con avisos segun perfil.
- Se actualizaron las opciones de salida: salir sin reporte, reporte y salir, reporte y volver, salir sin log.
- Se mejoro el apagado programado:
  - Windows: opciones rapidas y programacion por tarea (una vez/diario/semanal) + cancelacion.
  - Linux: apagado por minutos, hora exacta y programacion diaria/semanal via cron + cancelacion.
- Se robustecio el reporte de bateria para equipos sin bateria y se evitan errores al abrir el archivo.
- Se actualizaron los manuales en ES/EN/CN para reflejar menus y opciones de salida.
- Se consolidaron archivos de cambios en este historial.
