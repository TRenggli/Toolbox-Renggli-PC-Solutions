# Manual Tecnico de blindajev1.bat

Este manual aplica solo a blindajev1.bat.
No describe la toolbox general ni otros scripts del repositorio.

## Objetivo del script

blindajev1.bat prepara un entorno escolar para un usuario alumno con estas metas:

- exponer Trabajos Alumnos como unidad T:
- ocultar y bloquear C: desde Explorer
- endurecer el manejo de borrado y papelera
- ofrecer dos variantes operativas distintas

## Variantes disponibles

### 1. Blindaje estricto

Prioriza que no se borre nada dentro de Trabajos Alumnos.

Aplica:

- mapeo persistente de T:
- ACL NTFS con denegacion de DELETE y DELETE_CHILD sobre archivos y carpetas
- bloqueo de renombrado de carpetas
- politicas de Explorer para ocultar C:, bloquear su apertura y endurecer borrado/papelera

Tradeoff:

- puede volver mas rigido mover o renombrar archivos porque NTFS trata esas operaciones muy cerca de borrado

### 2. Organizacion controlada

Prioriza proteger la estructura escolar sin volver tan dura la operatoria diaria.

Aplica:

- mapeo persistente de T:
- ACL NTFS para bloquear borrado y renombrado de carpetas
- mantiene menos friccion para mover o renombrar archivos
- politicas de Explorer para ocultar C:, bloquear su apertura y endurecer borrado/papelera

Tradeoff:

- no puede garantizar bloqueo perfecto del borrado individual de archivos a nivel NTFS sin romper tambien mover o renombrar archivos

## Hallazgos tecnicos importantes

### NoDrives no alcanza solo

Segun la documentacion de Microsoft, NoDrives oculta la letra de unidad en Explorer pero no bloquea por si mismo el acceso por otras rutas visuales o tipeando caminos.

Por eso el script combina:

- NoDrives=4
- NoViewOnDrive=4

Con eso C: queda oculto y tambien bloqueado desde Explorer.

### NoDeleteFiles y NoEmptyRecycleBin no son ACL NTFS

Estas politicas endurecen Explorer y la experiencia de usuario.
Sirven para la operatoria comun del alumno, pero no reemplazan una ACL NTFS fuerte.

En este script se usan como capa de interfaz, no como control absoluto del sistema de archivos.

### Limite real de NTFS: mover archivo vs borrar archivo

Windows no separa de forma limpia estas dos necesidades usando solo ACL locales:

- permitir mover o renombrar archivos entre carpetas
- impedir borrar archivos individuales

La razon es que mover o renombrar archivos en el mismo volumen comparte permisos cercanos a DELETE.

Consecuencia practica:

- si bloqueas DELETE con mucha dureza, tambien podes romper mover o renombrar archivos
- si permitis mover o renombrar archivos con menos friccion, el borrado individual no queda bloqueado de forma perfecta solo con NTFS

Por eso blindajev1.bat ofrece dos variantes, en vez de prometer un comportamiento imposible de garantizar de forma limpia con ACL puras.

## Politicas aplicadas al alumno

El script escribe en el hive offline del alumno:

- NoDrives=4
- NoViewOnDrive=4
- NoEmptyRecycleBin=1
- NoDeleteFiles=1
- ConfirmFileDelete=1
- bloqueo visual del CLSID de Papelera en Shell Extensions

## Requisitos operativos

- ejecutar como administrador
- la sesion del alumno debe estar cerrada para poder cargar NTUSER.DAT
- reiniciar o cerrar sesion despues de aplicar o revertir

## Verificacion recomendada

Despues de aplicar:

1. confirmar que T: apunta a Trabajos Alumnos
2. iniciar sesion como alumno
3. validar que C: no se vea ni se pueda abrir desde Explorer
4. probar renombrado de carpetas escolares
5. probar mover un archivo entre carpetas segun la variante elegida
6. probar borrado normal y vaciado de papelera desde Explorer

## Recomendacion de uso

- Elegir Blindaje estricto cuando la prioridad sea no perder archivos.
- Elegir Organizacion controlada cuando la prioridad sea permitir operatoria diaria con menos friccion, aceptando el limite tecnico explicado arriba.

## Referencia tecnica

Resumen basado en documentacion publica de Microsoft sobre:

- File security and access rights
- ADMX Windows Explorer policies: NoDrives, NoViewOnDrive, ConfirmFileDelete, NoRecycleFiles y relacionadas

Este manual resume esas limitaciones para uso operativo interno.