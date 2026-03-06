# Catalogo de Opciones - Toolbox V14 (ES)

Este documento explica cada opcion de los menus por sistema operativo.
Incluye: que hace, para que sirve, cuando usarla y recaudos.

Leyenda de riesgo:
- `[R]` = Solo lectura (sin cambios de configuracion)
- `[W]` = Escribe/cambia sistema
- `[!]` = Critico o potencialmente irreversible

Perfiles:
- `D` = Diagnostico
- `R` = Reparacion
- `A` = Administracion

## Windows (20 opciones)

| # | Opcion | Perfiles | Riesgo | Que hace | Cuando usarla | Recaudos |
|---|--------|----------|--------|----------|---------------|----------|
| 1 | Info BIOS/placa o SMART (segun menu) | D/R/A | [R] | Consulta firmware/modelo/estado de disco | Inventario o auditoria tecnica | Ninguno, solo lectura |
| 2 | RAM o recursos (segun menu) | D/R/A | [R] | Muestra memoria/CPU o lanza diagnostico RAM | Lentitud, congelamientos, chequeo preventivo | Test RAM puede reiniciar o requerir ventana fuera de toolbox |
| 3 | Recursos/RAM (segun menu) | D/R/A | [R] | Consulta hardware operativo del sistema | Ver capacidad real de equipo | Ninguno, solo lectura |
| 4 | Estado WU o DISM/SFC (segun perfil) | D/R/A | [R]/[W] | En D consulta; en R/A repara imagen y archivos | Windows da errores, integridad dudosa | No interrumpir DISM/SFC |
| 5 | DNS/Auditoria o Reparar WU (segun perfil) | D/R/A | [R]/[W] | Consulta puertos/DNS o repara componentes WU | Problemas de update o red | En modo reparacion modifica servicios/caches |
| 6 | Velocidad/limpieza/WU status (segun perfil) | D/R/A | [R]/[W] | Dependiendo de perfil: consulta o limpieza | Diagnostico o mantenimiento | Limpieza elimina temporales |
| 7 | Bateria o reset red (segun perfil) | D/R/A | [R]/[W] | Genera reporte bateria o resetea stack de red | Portatiles / fallas IP-DNS | Reset red puede cortar conectividad temporal |
| 8 | Eventos criticos / velocidad | D/R/A | [R] | Consulta eventos de error o test de red | Analisis post-fallo | Ninguno, solo lectura |
| 9 | BSOD analyzer / DNS audit | D/R/A | [R] | Lista minidumps + bugcheck o audita DNS/puertos | Pantallazos azules / diagnostico red | No modifica sistema |
| 10 | Forense procesos o formateo (A) | D/R/A | [R]/[!] | En D/R audita procesos; en A puede formatear | Sospecha de malware / preparacion de medios | Formateo: validar disco objetivo (critico) |
| 11 | RAID status o MBR->GPT (A) | D/R/A | [R]/[!] | En D/R consulta storage; en A convierte particionado | Diagnostico almacenamiento / migracion disco | Conversion de tabla puede dejar equipo inutil si se usa mal |
| 12 | RAID status / Winget / WU tools | D/R/A | [R]/[W] | Consulta storage o actualiza apps | Mantenimiento de software | Actualizaciones pueden requerir reinicio |
| 13 | Forense o Backup Drivers o MAS (normal) | R/A | [W] | En R backup drivers; en A normal activa MAS; corporate bloqueado | Pre-mantenimiento o licencia autorizada | Backup consume espacio; MAS solo en entornos autorizados |
| 14 | Eventos criticos / Apagado programado | R/A | [R]/[W] | En R consulta eventos; en A programa apagado | Investigacion o automatizacion | Riesgo de apagar equipo en produccion |
| 15 | BSOD / Bateria | R/A | [R] | Consulta bsod o genera reporte bateria | Post-fallo o salud de bateria | Solo lectura |
| 16 | Forense / Backup Drivers | R/A | [R]/[W] | Auditoria procesos o exportacion drivers | Seguridad preventiva / respaldo de controladores | Requiere espacio en disco |
| 17 | RAID status / Eventos | R/A | [R] | Consulta storage o eventos segun menu | Diagnostico avanzado | Solo lectura |
| 18 | BSOD (A) | A | [R] | Analiza minidumps y eventos bugcheck | Incidentes de estabilidad | Solo lectura |
| 19 | Forense procesos (A) | A | [R] | Busca procesos en rutas temporales y firma | Hardening y auditoria | Solo lectura |
| 20 | RAID/Storage (A) | A | [R] | Estado de virtual/physical disks y fallback WMI | Servidores o storage complejo | Solo lectura |

Notas Windows:
- El numero exacto puede representar una accion distinta segun perfil (D/R/A).
- En `toolbox_corporate.bat`, la opcion 13 de MAS esta removida por compliance.

## Linux (30 opciones)

| # | Opcion | Perfiles | Riesgo | Que hace | Cuando usarla | Recaudos |
|---|--------|----------|--------|----------|---------------|----------|
| 1 | Estado SMART discos | D/R/A | [R] | Lee salud SMART | Ver fallas de disco | Puede instalar smartmontools si falta |
| 2 | Info hardware completo | D/R/A | [R] | CPU/RAM/board | Inventario tecnico | Solo lectura |
| 3 | Test memoria RAM | D/R/A | [R] | Consulta memoria y sintomas | Lentitud, errores memoria | Test profundo puede requerir herramienta externa |
| 4 | Info sistema operativo | D/R/A | [R] | Version kernel/distro | Soporte y compatibilidad | Solo lectura |
| 5 | Temperatura y sensores | D/R/A | [R] | Lee sensores termicos | Diagnostico de sobrecalentamiento | Requiere utilidades de sensores |
| 6 | Verificar sistema (fsck) | R/A | [W] | Comprueba/repara filesystem | Corrupcion de disco | Puede requerir desmontar particion |
| 7 | Reparar gestor paquetes | R/A | [W] | Repara DB/estado del paquete | Dependencias rotas | Puede reinstalar paquetes |
| 8 | Limpieza profunda | R/A | [W] | Limpia caches/temporales | Falta de espacio, mantenimiento | Revisar impacto en cache |
| 9 | Reparar bootloader (GRUB) | A | [!] | Reinstala/repara arranque | Sistema no bootea | Muy sensible, usar con respaldo |
| 10 | Limpieza Docker | R/A | [W] | Prune de imagenes/volumenes | Recuperar espacio | Puede borrar datos no usados |
| 11 | Reset de red | R/A | [W] | Reinicia config/stack red | Falla de conectividad | Corte temporal de red |
| 12 | Test de velocidad | D/R/A | [R] | Mide throughput | Diagnostico de ISP/red | Solo lectura |
| 13 | Auditoria DNS/puertos | D/R/A | [R] | Lista servicios/puertos DNS | Hardening basico | Solo lectura |
| 14 | Diagnostico firewall | R/A | [W] | Revisa/aplica estado firewall | Revisiones de seguridad | Puede alterar reglas activas |
| 15 | Monitor red en vivo | D/R/A | [R] | Trafico y conexiones actuales | Incident response | Solo lectura |
| 16 | Formateo seguro USB | A | [!] | Formatea dispositivos removibles | Preparar medios limpios | Verificar dispositivo correcto |
| 17 | Conversion MBR a GPT | A | [!] | Cambia tabla de particiones | Migracion de esquema de disco | Operacion critica |
| 18 | Analisis de disco | D/R/A | [R] | Estado y estructura de discos | Diagnostico almacenamiento | Solo lectura |
| 19 | Montaje de particiones | A | [!] | Monta/remonta particiones | Mantenimiento avanzado | Riesgo en particiones productivas |
| 20 | Espacio en disco | D/R/A | [R] | Uso y capacidad de filesystems | Falta de espacio | Solo lectura |
| 21 | Gestion de servicios | R/A | [W] | systemd services start/stop/status | Recuperacion de servicios | Puede afectar disponibilidad |
| 22 | Top procesos CPU/RAM | D/R/A | [R] | Muestra procesos pesados | Performance troubleshooting | Solo lectura |
| 23 | Ver logs del sistema | D/R/A | [R] | dmesg/journalctl | Analisis de errores | Solo lectura |
| 24 | Usuarios y permisos | A | [!] | Gestion de cuentas/permisos | Administración avanzada | Riesgo de bloqueo de acceso |
| 25 | Monitoreo tiempo real | D/R/A | [R] | Vision en vivo de recursos | Diagnostico de carga | Solo lectura |
| 26 | Actualizar sistema | R/A | [W] | update/upgrade paquetes | Mantenimiento programado | Puede requerir reboot |
| 27 | Apagado programado | R/A | [W] | Agenda apagado con cron/systemctl | Automatizacion | Confirmar ventanas de servicio |
| 28 | Backup de datos | R/A | [W] | Genera respaldo comprimido | Antes de cambios | Verificar destino/espacio |
| 29 | Reporte bateria | D/R/A | [R] | Lee estado de bateria | Portatiles | En desktop puede no aplicar |
| 30 | Verificar integridad | D/R/A | [R] | Checks de estado/base | Auditoria preventiva | Solo lectura |

## macOS (14 opciones)

| # | Opcion | Perfiles | Riesgo | Que hace | Cuando usarla | Recaudos |
|---|--------|----------|--------|----------|---------------|----------|
| 1 | Estado de discos | D/R/A | [R] | `diskutil` + estado general | Revisar almacenamiento | Solo lectura |
| 2 | Info de hardware | D/R/A | [R] | `system_profiler` y CPU/RAM | Inventario tecnico | Solo lectura |
| 3 | Test de memoria (informativo) | D/R/A | [R] | Muestra estado de memoria | Diagnostico de performance | Para test completo usar Apple Diagnostics |
| 4 | Info del sistema | D/R/A | [R] | `sw_vers`, `uname`, uptime | Soporte y compatibilidad | Solo lectura |
| 5 | Espacio en disco | D/R/A | [R] | `df -h` | Falta de espacio | Solo lectura |
| 6 | Limpieza de cache | R/A | [W] | Limpia caches y temporales | Mantenimiento rutinario | Puede cerrar/invalidar caches activas |
| 7 | Test de conectividad | D/R/A | [R] | ping y verificaciones basicas | Problemas de red | Solo lectura |
| 8 | Info de red | D/R/A | [R] | Interfaces y configuracion | Diagnostico LAN/WiFi | Solo lectura |
| 9 | Puertos en escucha | D/R/A | [R] | Servicios activos por puerto | Auditoria de exposicion | Solo lectura |
| 10 | Actualizar sistema | R/A | [W] | `softwareupdate` / `brew` segun modulo | Mantenimiento y parches | Puede requerir reinicio |
| 11 | Limpiar paquetes | R/A | [W] | Limpieza de paquetes/herramientas | Reducir residuos de software | Confirmar que no se use paquete |
| 12 | Reporte del sistema | D/R/A | [R] | Genera reporte operativo | Cierre de auditoria | Solo lectura |
| 13 | Info de procesos | D/R/A | [R] | Procesos activos y consumo | Investigacion de rendimiento | Solo lectura |
| 14 | Apagado programado | R/A | [W] | Programa apagado con launchd/shutdown | Automatizacion | Validar horario para no cortar tareas |

## Recomendacion de uso rapido por perfil

- Diagnostico: usar primero para evaluar estado y decidir intervencion.
- Reparacion: ejecutar cuando exista incidente confirmado o mantenimiento planificado.
- Administracion: reservar para tecnicos senior y ventanas controladas.

## Avisos importantes

- Toda opcion `[!]` requiere respaldo previo y confirmacion de impacto.
- Toda opcion `[W]` debe ejecutarse preferentemente fuera de horario productivo.
- Si hay duda, ejecutar primero equivalentes `[R]` y revisar logs antes de intervenir.
