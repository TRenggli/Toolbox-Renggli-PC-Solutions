# Plantillas de Módulos - Toolbox (Windows)

Guía para agregar tus propios módulos a `Windows/toolbox.bat`.

Hay dos formas de agregar un módulo:

1. **Módulo interno** (una etiqueta `:MOD_...` dentro del `.bat`): ideal para acciones cortas.
2. **Módulo externo** (un `.bat` propio en `Windows/modules/` que el motor llama): ideal para módulos grandes o reutilizables. Es como está hecho el **Gestor PostgreSQL**, y es la forma recomendada para no inflar el archivo principal.

Para cualquiera de las dos, recordá siempre:

- Registrar el módulo en **3 lugares**: el menú del perfil, el bloque de despacho interactivo, y el bloque `MENU_*_EXEC` (ejecución no interactiva por parámetro).
- Incluir **logging**: `echo [%time%] Tu accion >> "!LOG_FILE!"`.
- Dar **feedback visual** al usuario y una `pause` al final si corresponde.

---

## 1. Módulo simple (solo lectura, cualquier perfil)

```bat
:MOD_MI_FUNCION
cls
color 0B
echo  ==============================================================================
echo   [MI FUNCION] Descripcion de mi funcion
echo  ==============================================================================
echo.
echo  [i] Ejecutando mi operacion...
echo.

REM Aqui va tu codigo (ejemplo solo lectura):
REM explorer "C:\Users\%username%\Downloads"

echo  [OK] Operacion completada.
echo [%time%] Ejecutado: MI_FUNCION >> "!LOG_FILE!"
pause
exit /b
```

---

## 2. Módulo con validación de perfil (requiere REPARACIÓN o superior)

```bat
:MOD_MI_FUNCION_AVANZADA
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Esta operacion requiere perfil REPARACION o superior.
    echo [%time%] Funcion bloqueada: perfil insuficiente >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0A
echo  [i] Ejecutando operacion que modifica el sistema...

REM Aqui va tu codigo avanzado

echo  [OK] Operacion completada.
echo [%time%] Ejecutado: MI_FUNCION_AVANZADA >> "!LOG_FILE!"
pause
exit /b
```

---

## 3. Módulo crítico (requiere ADMINISTRACIÓN + confirmación fuerte)

```bat
:MOD_MI_FUNCION_CRITICA
if not "%PROFILE_MODE%"=="3" (
    cls
    color 0C
    echo  [!] ACCESO DENEGADO - requiere perfil ADMINISTRACION.
    echo [%time%] Funcion critica bloqueada: perfil insuficiente >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0C
echo  [!] ATENCION: Esta operacion es irreversible.
echo.
set /p "confirmacion=Escriba 'CONFIRMO' para continuar: "
if /i not "%confirmacion%"=="CONFIRMO" (
    echo  [i] Operacion cancelada por el usuario.
    echo [%time%] Operacion critica cancelada >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Ejecutando operacion critica...
echo [%time%] INICIANDO OPERACION CRITICA >> "!LOG_FILE!"

REM Aqui va tu codigo critico

echo  [OK] Operacion critica completada.
pause
exit /b
```

Reutilizá el helper existente `:MODULE_CONFIRM "titulo" "advertencia"` (devuelve `errorlevel 1` si el usuario cancela) en vez de reescribir el prompt.

---

## 4. Módulo externo (recomendado para módulos grandes)

Creá tu lógica en un archivo propio dentro de `Windows/modules/`, por ejemplo `Windows/modules/mi_modulo.bat`, con su propio `setlocal`. Puede leer el log de la suite desde la variable de entorno `LOG_FILE` (el motor ya la exporta).

Luego, en el motor (`toolbox.bat`), agregá un wrapper delgado:

```bat
:MOD_MI_MODULO
if not "%PROFILE_MODE%"=="3" (
    echo  [!] Requiere perfil ADMINISTRACION.
    pause
    exit /b
)
echo [%time%] Mi modulo: ingreso >> "!LOG_FILE!"
if not exist "%~dp0modules\mi_modulo.bat" (
    echo  [X] No se encuentra modules\mi_modulo.bat
    pause
    exit /b
)
call "%~dp0modules\mi_modulo.bat"
exit /b
```

Ventaja: el motor principal no crece y el módulo se puede probar por separado, sin inflar el archivo principal.

### Registro en los 3 puntos del menú de Administración

```bat
REM 1) En :MENU_ADMINISTRACION (texto del menu)
echo    22. [W] Mi modulo

REM 2) En el despacho interactivo del mismo menu
if "%choice%"=="22" (call :MOD_MI_MODULO & goto :MAIN_MENU)

REM 3) En :MENU_ADMINISTRACION_EXEC (ejecucion por parametro /perfil:3 /mod:22)
if "%choice%"=="22" (call :MOD_MI_MODULO & goto :MAIN_MENU)
```
