# Aviso de terceros — Microsoft Activation Scripts (MAS)

Los archivos de esta carpeta (`MAS_AIO.cmd` y `Separate-Files-Version/`) pertenecen al
proyecto de código abierto **Microsoft Activation Scripts (MAS)**, no son obra de
Renggli PC Solution y se incluyen tal cual ("as is") solo por conveniencia.

- Proyecto original: https://github.com/massgravel/Microsoft-Activation-Scripts
- Licencia: **GNU General Public License v3.0 (GPL-3.0)** — ver el repositorio original.
- Copyright de MAS: sus respectivos autores (massgrave.dev).

## Uso previsto

Estas utilidades se incluyen para **pruebas, testeo y activación en entornos con
licencias autorizadas**. El uso debe cumplir con los términos de licenciamiento de
Microsoft aplicables en tu jurisdicción y organización. Renggli PC Solution no se
responsabiliza por el uso indebido.

## Notas de integración

- El módulo de activación del Toolbox (opción 13, solo `toolbox.bat`) llama a
  `Windows/MAS_AIO.cmd`. Esa es la copia que usa la herramienta.
- Esta carpeta (`herramienta mas/`) conserva la distribución completa de MAS
  (AIO + versión de archivos separados) como referencia.
- Algunos antivirus (p. ej. Windows Defender) marcan estos scripts como *HackTool*
  y pueden ponerlos en cuarentena o borrarlos. Es un falso positivo conocido por su
  naturaleza; si desaparecen, restaurá con `git restore` o excluí la carpeta del AV.
