# Manual Tecnico de Blindaje V1

> Estado: **Anexo tecnico**.
> La guia operativa principal de la opcion 21 ya esta integrada en `Manuales/README_ES.md` y `Manuales/CATALOGO_OPCIONES_ES.md`.
> Este archivo se conserva como referencia tecnica ampliada.

Este manual describe el motor de Blindaje V1 ahora integrado en la opcion 21 ^(Perfil Seguridad Alta^) de:

- `Windows/toolbox.bat`
- `Windows/toolbox_corporate.bat`

El motor se opera desde esa opcion integrada de Windows.

## Objetivo del motor

El motor integrado prepara un entorno escolar para un usuario alumno con estas metas:

- exponer Trabajos Alumnos como unidad T:
- ocultar y bloquear C: desde Explorer
- mantener acceso diario a Escritorio, Documentos, Descargas, Musica, Imagenes y Videos
- endurecer el manejo de borrado y papelera
- ofrecer dos modos de proteccion ^(estricto y suave^)
- usar usuario objetivo fijo: Usuario
- permitir configurar carpeta raiz y letra de unidad sin editar el script principal

## Uso del menu

Opciones principales en pantalla:

1. Aplicar blindaje estricto
2. Aplicar bloqueo suave
3. Deshacer todo
4. Verificar estado actual
5. Configurar ruta/unidad
6. Salir
7. Revision/Limpieza temporales ^(manual^)
8. Programar limpieza automatica ^(tarea local^)
9. Guia despliegue masivo ^(dominio/sin dominio^)
10. Desactivar limpieza automatica

El script muestra siempre la configuracion activa ^(alumno, carpeta y unidad^) para evitar aplicar con datos equivocados.
Para verificar o deshacer, prioriza el contexto guardado al aplicar ^(Student/RootDir/Drive^) para actuar sobre el blindaje realmente activo.

Alcance de cambios:

- Politicas de Explorer ^(NoDrives, NoViewOnDrive, etc.^): solo para el usuario objetivo fijo ^(Usuario^).
- ACL sobre la carpeta raiz y mapeo de unidad virtual: impacto a nivel equipo.

## Modos disponibles

### Blindaje estricto

Prioriza que no se borre nada dentro de Trabajos Alumnos.

Aplica:

- mapeo persistente de T:
- validacion de conflicto de letra antes de mapear unidad
- ACL NTFS con denegacion DE/DC en entradas separadas para reforzar bloqueo sobre archivos y carpetas
- bloqueo de renombrado de carpetas
- politicas de Explorer para ocultar C:, bloquear su apertura y endurecer borrado/papelera
- excepcion diaria: redireccion de Escritorio, Documentos, Descargas, Musica, Imagenes y Videos a `%BL_ROOT_DIR%\PERFIL\{usuario}`
- permisos ACL normales en carpetas diarias redirigidas ^(el alumno puede borrar ahi^)
- copia inicial de Escritorio y Musica al nuevo destino ^(sin borrar origen^)
- re-mapeo automatico de unidad al iniciar sesion del usuario objetivo
- si existe C:\BGInfo, se expone como T:\BGInfo

Tradeoff:

- puede volver mas rigido mover o renombrar archivos porque NTFS trata esas operaciones muy cerca de borrado
- puede afectar guardado de Office/Adobe u otras apps que usan temporales + reemplazo atomico en carpetas academicas

### Bloqueo suave

Prioriza compatibilidad de guardado sin permitir que desaparezca la estructura escolar.

Aplica:

- misma base de T:, NoDrives/NoViewOnDrive, papelera endurecida y redireccion diaria a `%BL_ROOT_DIR%\PERFIL\{usuario}`
- permisos normales sobre `SECUNDARIA` y `PRIMARIA` para que Office/Adobe y apps similares guarden normal
- proteccion especifica de las carpetas madre y subcarpetas escolares para que no puedan borrarse completas
- permiso de borrado normal sobre archivos individuales dentro de carpetas academicas

Tradeoff:

- protege la estructura de carpetas, pero un archivo individual si puede borrarse por el alumno

## Hallazgos tecnicos importantes

### NoDrives no alcanza solo

Segun la documentacion de Microsoft, NoDrives oculta la letra de unidad en Explorer pero no bloquea por si mismo el acceso por otras rutas visuales o tipeando caminos.

Por eso el script combina:

- NoDrives=4
- NoViewOnDrive=4

Con eso C: queda oculto y tambien bloqueado desde Explorer.

Para evitar que ese bloqueo rompa el uso diario, el script redirige las carpetas conocidas a la ruta fisica `%BL_ROOT_DIR%\PERFIL\{usuario}` y mantiene T: como acceso adicional. Asi se evita el error de "Ubicacion no disponible" en equipos lentos donde Explorer puede iniciar antes de que T: se remapee.

### Politicas Explorer vs ACL NTFS

Estas politicas endurecen Explorer y la experiencia de usuario.
Sirven para la operatoria comun del alumno, pero no reemplazan una ACL NTFS fuerte.

En este script se usan como capa de interfaz, no como control absoluto del sistema de archivos.
Para permitir borrado normal en carpetas diarias, no se fuerza NoDeleteFiles.

### Control de conflicto de letra de unidad

Antes de mapear la unidad virtual, el script valida si la letra ya esta en uso:

- si ya apunta a la ruta correcta, la reutiliza
- si apunta a otra ruta o a otra unidad, detiene la aplicacion y pide cambiar letra

Esto evita sobrescribir mapeos existentes por error.

### Limite real de NTFS: mover archivo vs borrar archivo

Windows no separa de forma limpia estas dos necesidades usando solo ACL locales:

- permitir mover o renombrar archivos entre carpetas
- impedir borrar archivos individuales

La razon es que mover o renombrar archivos en el mismo volumen comparte permisos cercanos a DELETE.

Consecuencia practica:

- si bloqueas DELETE con mucha dureza, tambien podes romper mover o renombrar archivos
- si permitis mover o renombrar archivos con menos friccion, el borrado individual no queda bloqueado de forma perfecta solo con NTFS

Por eso el motor integrado ahora ofrece dos caminos: `estricto` si la prioridad absoluta es no perder archivos, y `suave` si la prioridad es que las aplicaciones guarden bien sin permitir borrar carpetas completas.

## Politicas aplicadas al alumno

El script escribe en el hive offline del alumno:

- NoDrives=4
- NoViewOnDrive=4
- NoEmptyRecycleBin=1
- ConfirmFileDelete=1
- bloqueo visual del CLSID de Papelera en Shell Extensions
- redireccion Desktop -> `%BL_ROOT_DIR%\PERFIL\{usuario}\Desktop`
- redireccion Personal (Documents) -> `%BL_ROOT_DIR%\PERFIL\{usuario}\Documents`
- redireccion {374DE290-123F-4565-9164-39C4925E467B} (Downloads) -> `%BL_ROOT_DIR%\PERFIL\{usuario}\Downloads`
- redireccion My Music -> `%BL_ROOT_DIR%\PERFIL\{usuario}\Music`
- redireccion My Pictures -> `%BL_ROOT_DIR%\PERFIL\{usuario}\Pictures`
- redireccion My Video -> `%BL_ROOT_DIR%\PERFIL\{usuario}\Videos`
- entrada en Run para re-mapeo automatico de la unidad virtual al logon

## Asistente de configuracion

El script permite cambiar parametros sin editar codigo desde la opcion 4 del menu o justo antes de aplicar:

- carpeta raiz
- letra de unidad virtual

La letra admite formato simple ^(ejemplo: T o T:^).
Si la carpeta se escribe sin unidad ^(ejemplo: Trabajos Alumnos^), el script la interpreta como C:\Trabajos Alumnos.
Al confirmar, la configuracion se guarda automaticamente en registro para futuras ejecuciones.

## Requisitos operativos

- ejecutar como administrador
- la sesion del alumno debe estar cerrada para poder cargar NTUSER.DAT
- reiniciar o cerrar sesion despues de aplicar o revertir
- en deshacer, si la sesion del alumno esta abierta, puede quedar reversion parcial de politicas del perfil

El script valida antes de aplicar que la sesion del usuario objetivo este cerrada. Si no puede cargar/descargar su hive, no inicia cambios.

## Deshacer y limpieza de carpetas

La opcion "Deshacer todo" revierte:

- mapeo de unidad virtual
- marcador de modo aplicado
- reglas ACL del usuario objetivo sobre la carpeta raiz
- politicas de Explorer del usuario objetivo
- redireccion de carpetas diarias a valores por defecto del perfil
- re-mapeo automatico al iniciar sesion del usuario objetivo

Ademas, ahora puede eliminar carpetas creadas por el blindaje:

- primero intenta borrar estructura creada solo si esta vacia
- si la carpeta raiz aun tiene contenido, ofrece opcion de borrado total ^(forzado^)
- el forzado toma posesion, normaliza ACL para Administradores y limpia atributos antes del borrado final

Esto evita borrar datos por accidente sin confirmacion.

Advertencia operativa importante:

- despues de deshacer y reiniciar, revisar manualmente `C:\` para confirmar si `Trabajos Alumnos` se elimino por completo
- si la carpeta persiste, suele deberse a archivos en uso o bloqueados, y puede requerir borrado manual

## Verificacion recomendada

Despues de aplicar:

1. confirmar que T: apunta a Trabajos Alumnos
2. iniciar sesion como alumno
3. validar que C: no se vea ni se pueda abrir desde Explorer
4. validar que Escritorio, Musica, Documentos, Descargas, Imagenes y Videos abren con normalidad
5. validar que T:\BGInfo abre si existe C:\BGInfo
6. probar renombrado de carpetas escolares
7. crear un archivo de prueba en una carpeta escolar y validar el comportamiento segun modo:
   - estricto: no deberia poder eliminarse
   - suave: deberia poder eliminarse
8. crear un archivo en Escritorio/Documentos/Descargas/Imagenes/Videos y validar que si pueda eliminarse como alumno
9. probar mover un archivo entre carpetas dentro de T:
10. probar borrado normal y vaciado de papelera desde Explorer

## Recomendacion de uso

- Usar Blindaje estricto cuando la prioridad sea no perder archivos aunque pueda bajar la compatibilidad de guardado.
- Usar Bloqueo suave cuando la prioridad sea que Office/Adobe guarden bien pero sin permitir borrar carpetas escolares.

## Limpieza de temporales en opcion 21 ^(modo simple^)

### Opcion 6 - Revision/Limpieza manual

La opcion 6 recorre unicamente:

- `%BL_ROOT_DIR%\SECUNDARIA`
- `%BL_ROOT_DIR%\PRIMARIA`

Solo considera temporales por patron:

- `~$*`
- `*.tmp`
- `*.temp`

No toca archivos de proyecto reales como `.psd`, `.prproj`, `.aep`, etc.

Flujo paso a paso en pantalla:

1. Muestra rutas analizadas.
2. Muestra patrones permitidos.
3. Permite elegir modo:
   - `1` Solo revisar ^(no borra^)
   - `2` Revisar y limpiar ^(borra solo temporales permitidos^)
4. Devuelve conteos:
   - detectados total
   - detectados en SECUNDARIA y en PRIMARIA
   - eliminados
   - bloqueados/en uso

### Opcion 7 - Tarea programada local ^(automatico en ese equipo^)

La opcion 7 crea/actualiza una tarea diaria local:

- Nombre: `Renggli_Blindaje_TempClean`
- Usuario de ejecucion: `SYSTEM`
- Privilegios: altos
- Script: `%ProgramData%\Renggli\BlindajeV1\TempClean_Task.cmd`

El script diario limpia solo temporales permitidos en SECUNDARIA/PRIMARIA y registra resultado en:

- `%ProgramData%\Renggli\BlindajeV1\Logs\TempClean.log`

### Opcion 8 - Guia de despliegue masivo

La opcion 8 muestra en pantalla y exporta una guia para:

- despliegue por dominio/GPO
- despliegue sin dominio por script remoto

Tambien guarda archivo de referencia en:

- `Windows/Logs/Guia_Despliegue_Masivo_Temporales.txt`

### Opcion 9 - Desactivar limpieza automatica local

Permite retirar en este equipo:

- tarea `Renggli_Blindaje_TempClean`
- script local `%ProgramData%\Renggli\BlindajeV1\TempClean_Task.cmd`

No elimina datos escolares ni proyectos de alumnos.

## Referencia tecnica

Resumen basado en documentacion publica de Microsoft sobre:

- File security and access rights
- ADMX Windows Explorer policies: NoDrives, NoViewOnDrive, ConfirmFileDelete, NoRecycleFiles y relacionadas

Este manual resume esas limitaciones para uso operativo interno.
