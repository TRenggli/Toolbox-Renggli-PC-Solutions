# Manual Tecnico de blindajev1.bat

Este manual aplica solo a blindajev1.bat.
No describe la toolbox general ni otros scripts del repositorio.

## Objetivo del script

blindajev1.bat prepara un entorno escolar para un usuario alumno con estas metas:

- exponer Trabajos Alumnos como unidad T:
- ocultar y bloquear C: desde Explorer
- mantener acceso diario a Escritorio, Documentos, Descargas, Musica, Imagenes y Videos
- endurecer el manejo de borrado y papelera
- aplicar un unico modo de blindaje estricto
- usar usuario objetivo fijo: Usuario
- permitir configurar carpeta raiz y letra de unidad sin editar el .bat

## Uso del menu

Opciones principales en pantalla:

1. Aplicar blindaje estricto
2. Deshacer todo
3. Verificar estado actual
4. Configurar ruta/unidad
5. Salir

El script muestra siempre la configuracion activa ^(alumno, carpeta y unidad^) para evitar aplicar con datos equivocados.
Para verificar o deshacer, prioriza el contexto guardado al aplicar ^(Student/RootDir/Drive^) para actuar sobre el blindaje realmente activo.

Alcance de cambios:

- Politicas de Explorer ^(NoDrives, NoViewOnDrive, etc.^): solo para el usuario objetivo fijo ^(Usuario^).
- ACL sobre la carpeta raiz y mapeo de unidad virtual: impacto a nivel equipo.

## Modo disponible

### Blindaje estricto

Prioriza que no se borre nada dentro de Trabajos Alumnos.

Aplica:

- mapeo persistente de T:
- validacion de conflicto de letra antes de mapear unidad
- ACL NTFS con denegacion DE/DC en entradas separadas para reforzar bloqueo sobre archivos y carpetas
- bloqueo de renombrado de carpetas
- politicas de Explorer para ocultar C:, bloquear su apertura y endurecer borrado/papelera
- excepcion diaria: redireccion de Escritorio, Documentos, Descargas, Musica, Imagenes y Videos a T:\PERFIL\{usuario}
- permisos ACL normales en carpetas diarias redirigidas ^(el alumno puede borrar ahi^)
- copia inicial de Escritorio y Musica al nuevo destino ^(sin borrar origen^)
- re-mapeo automatico de unidad al iniciar sesion del usuario objetivo
- si existe C:\BGInfo, se expone como T:\BGInfo

Tradeoff:

- puede volver mas rigido mover o renombrar archivos porque NTFS trata esas operaciones muy cerca de borrado

## Hallazgos tecnicos importantes

### NoDrives no alcanza solo

Segun la documentacion de Microsoft, NoDrives oculta la letra de unidad en Explorer pero no bloquea por si mismo el acceso por otras rutas visuales o tipeando caminos.

Por eso el script combina:

- NoDrives=4
- NoViewOnDrive=4

Con eso C: queda oculto y tambien bloqueado desde Explorer.

Para evitar que ese bloqueo rompa el uso diario, el script redirige las carpetas conocidas a T: y realiza una copia inicial de Escritorio/Musica para evitar que aparezcan vacias.

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

Por eso blindajev1.bat adopta el modo estricto y prioriza la proteccion de datos.

## Politicas aplicadas al alumno

El script escribe en el hive offline del alumno:

- NoDrives=4
- NoViewOnDrive=4
- NoEmptyRecycleBin=1
- ConfirmFileDelete=1
- bloqueo visual del CLSID de Papelera en Shell Extensions
- redireccion Desktop -> T:\PERFIL\{usuario}\Desktop
- redireccion Personal (Documents) -> T:\PERFIL\{usuario}\Documents
- redireccion {374DE290-123F-4565-9164-39C4925E467B} (Downloads) -> T:\PERFIL\{usuario}\Downloads
- redireccion My Music -> T:\PERFIL\{usuario}\Music
- redireccion My Pictures -> T:\PERFIL\{usuario}\Pictures
- redireccion My Video -> T:\PERFIL\{usuario}\Videos
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

## Verificacion recomendada

Despues de aplicar:

1. confirmar que T: apunta a Trabajos Alumnos
2. iniciar sesion como alumno
3. validar que C: no se vea ni se pueda abrir desde Explorer
4. validar que Escritorio, Musica, Documentos, Descargas, Imagenes y Videos abren con normalidad
5. validar que T:\BGInfo abre si existe C:\BGInfo
6. probar renombrado de carpetas escolares
7. crear un archivo de prueba en una carpeta escolar y validar que no pueda eliminarse como alumno
8. crear un archivo en Escritorio/Documentos/Descargas/Imagenes/Videos y validar que si pueda eliminarse como alumno
9. probar mover un archivo entre carpetas dentro de T:
10. probar borrado normal y vaciado de papelera desde Explorer

## Recomendacion de uso

- Usar Blindaje estricto cuando la prioridad sea no perder archivos.

## Referencia tecnica

Resumen basado en documentacion publica de Microsoft sobre:

- File security and access rights
- ADMX Windows Explorer policies: NoDrives, NoViewOnDrive, ConfirmFileDelete, NoRecycleFiles y relacionadas

Este manual resume esas limitaciones para uso operativo interno.
