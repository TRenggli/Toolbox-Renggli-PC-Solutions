# HISTORIAL DE CAMBIOS

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
