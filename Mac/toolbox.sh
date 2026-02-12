#!/bin/bash
# ==============================================================================
# RENGGLI PC SOLUTIONS - Enterprise Toolbox V14 - macOS Edition
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==============================================================================
# CONFIGURACION DE LOGS Y ENTORNO
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/Logs"
mkdir -p "$LOG_DIR"

ISO_DATE=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/Audit_$ISO_DATE.log"

echo "[$(date +%H:%M:%S)] --- INICIO DE SESION: $USER ---" >> "$LOG_FILE"

# ==============================================================================
# VERIFICACION DE PRIVILEGIOS
# ==============================================================================
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!] ERROR: PRIVILEGIOS INSUFICIENTES${NC}"
        echo "Esta suite requiere permisos de ROOT/SUDO."
        echo "[$(date +%H:%M:%S)] Acceso denegado: Privilegios insuficientes" >> "$LOG_FILE"
        exit 1
    fi
}

# ==============================================================================
# SELECCION DE PERFIL
# ==============================================================================
profile_select() {
    clear
    echo -e "${CYAN}=============================================================================================================="
    echo "                          RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (macOS)"
    echo "=============================================================================================================="
    echo "Log Actual: $LOG_FILE"
    echo ""
    echo "[SELECCION DE PERFIL]"
    echo ""
    echo "1. DIAGNOSTICO     - Solo lectura, auditoria y consultas (sin modificaciones)"
    echo "2. REPARACION      - Mantenimiento y reparaciones automatizadas"
    echo "3. ADMINISTRACION  - Acceso completo"
    echo ""
    read -p "Seleccione perfil [1-3]: " PROFILE_MODE

    case $PROFILE_MODE in
        1) echo "[$(date +%H:%M:%S)] Perfil seleccionado: DIAGNOSTICO" >> "$LOG_FILE" ;;
        2) echo "[$(date +%H:%M:%S)] Perfil seleccionado: REPARACION" >> "$LOG_FILE" ;;
        3) echo "[$(date +%H:%M:%S)] Perfil seleccionado: ADMINISTRACION" >> "$LOG_FILE" ;;
        *) profile_select ;;
    esac
}

# ==============================================================================
# MENU PRINCIPAL
# ==============================================================================
main_menu() {
    while true; do
        clear
        echo -e "${CYAN}=============================================================================================================="
        echo "                          RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (macOS)"
        echo "=============================================================================================================="
        echo "Log Actual: $LOG_FILE"
        case $PROFILE_MODE in
            1) echo "Perfil Activo: [DIAGNOSTICO] - Solo Lectura" ;;
            2) echo "Perfil Activo: [REPARACION] - Mantenimiento" ;;
            3) echo "Perfil Activo: [ADMINISTRACION] - Acceso Completo" ;;
        esac
        case $PROFILE_MODE in
            1) echo "Este perfil es solo de consulta. No modifica el sistema." ;;
            2) echo "Incluye tareas de mantenimiento. Puede modificar el sistema." ;;
            3) echo "Acceso total. Incluye acciones criticas e irreversibles." ;;
        esac
        echo ""
        echo "   [ DIAGNOSTICO DE HARDWARE ]      [ SISTEMA Y DISCO ]              [ REDES ]"
        echo "   1. Estado de Discos              4. Info del Sistema              7. Test de Conectividad"
        echo "   2. Info de Hardware              5. Espacio en Disco              8. Info de Red"
        echo "   3. Test de Memoria               6. Limpieza de Cache             9. Puertos en Escucha"
        echo ""
        echo "   [ MANTENIMIENTO ]                [ AUTOMATIZACION ]"
        echo "   10. Actualizar Sistema           12. Reporte del Sistema"
        echo "   11. Limpiar Paquetes             13. Info de Procesos"
        echo "                                    14. Apagado Programado"
        echo ""
        echo "   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE"
        echo "=============================================================================================================="
        echo ""
        read -p "Selecciona una opcion: " choice

        case $choice in
            0) mod_system_report ; exit_script ;;
            00) exit_script ;;
            1) mod_disk_status ;;
            2) mod_hardware_info ;;
            3) mod_memory_test ;;
            4) mod_system_info ;;
            5) mod_disk_space ;;
            6) mod_clean_cache ;;
            7) mod_network_test ;;
            8) mod_network_info ;;
            9) mod_ports ;;
            10) mod_update_system ;;
            11) mod_clean_packages ;;
            12) mod_system_report ;;
            13) mod_processes ;;
            14) mod_shutdown ;;
            *) echo -e "${YELLOW}[!] Opcion no valida${NC}" && sleep 2 ;;
        esac
    done
}

# ==============================================================================
# MODULOS
# ==============================================================================

mod_disk_status() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[AUDITORIA DE DISCOS] Analizando estado de las unidades..."
    echo "=============================================================================="
    echo ""
    echo "[i] Estado de discos y particiones:"
    echo ""
    diskutil list
    echo ""
    df -h
    echo ""
    echo "[OK] Auditoria completada"
    echo "[$(date +%H:%M:%S)] Ejecutada Auditoria de Discos" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_hardware_info() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[INFO DE HARDWARE]"
    echo "=============================================================================="
    echo ""
    echo "[i] Informacion de hardware:"
    system_profiler SPHardwareDataType 2>/dev/null | sed -n '1,12p'
    echo ""
    echo "[i] CPU:"
    sysctl -n machdep.cpu.brand_string 2>/dev/null || sysctl -n hw.model
    echo "[i] Cores: $(sysctl -n hw.ncpu)"
    echo ""
    echo "[i] Memoria RAM:"
    sysctl -n hw.memsize | awk '{printf "%.2f GB\n", $1/1024/1024/1024}'
    echo ""
    echo "[i] Dispositivos PCI (si aplica):"
    system_profiler SPPCIDataType 2>/dev/null | sed -n '1,20p'
    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de hardware ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_memory_test() {
    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[TEST DE MEMORIA]"
    echo "=============================================================================="
    echo ""
    echo "[i] Informacion de memoria actual:"
    vm_stat
    echo ""
    echo "[i] Para un test completo, use Apple Diagnostics (mantener D al iniciar)"
    echo "[$(date +%H:%M:%S)] Consulta de memoria ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_system_info() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[INFO DEL SISTEMA]"
    echo "=============================================================================="
    echo ""
    echo "[i] Sistema Operativo:"
    sw_vers
    echo ""
    uname -a
    echo ""
    echo "[i] Uptime del sistema:"
    uptime
    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de sistema ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_disk_space() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[ESPACIO EN DISCO]"
    echo "=============================================================================="
    echo ""
    df -h
    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de espacio en disco" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_clean_cache() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO - Perfil DIAGNOSTICO es solo lectura${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${GREEN}=============================================================================="
    echo "[LIMPIEZA DE CACHE]"
    echo "=============================================================================="
    echo ""
    echo "[i] Limpiando cache del sistema..."
    sync
    if command -v purge &> /dev/null; then
        purge || true
    else
        echo "[i] purge no disponible en esta version de macOS"
    fi
    echo ""
    echo "[i] Limpiando archivos temporales..."
    rm -rf /tmp/* /var/tmp/* 2>/dev/null
    echo ""
    echo "[OK] Limpieza completada"
    echo "[$(date +%H:%M:%S)] Limpieza de cache ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_network_test() {
    clear
    echo -e "${BLUE}=============================================================================="
    echo "[TEST DE CONECTIVIDAD]"
    echo "=============================================================================="
    echo ""
    echo "[i] Probando conectividad..."
    ping -c 4 8.8.8.8
    echo ""
    echo "[$(date +%H:%M:%S)] Test de conectividad ejecutado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_network_info() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[INFO DE RED]"
    echo "=============================================================================="
    echo ""
    echo "[i] Interfaces de red:"
    ifconfig
    echo ""
    echo "[i] Hardware ports:"
    networksetup -listallhardwareports
    echo ""
    echo "[i] Tabla de rutas:"
    netstat -rn
    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de red ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_ports() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[PUERTOS EN ESCUCHA]"
    echo "=============================================================================="
    echo ""
    if command -v lsof &> /dev/null; then
        lsof -nP -iTCP -sTCP:LISTEN
    else
        netstat -anv | grep LISTEN
    fi
    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de puertos ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_update_system() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO - Perfil DIAGNOSTICO es solo lectura${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[ACTUALIZAR SISTEMA]"
    echo "=============================================================================="
    echo ""

    if command -v softwareupdate &> /dev/null; then
        echo "[i] Actualizando macOS..."
        softwareupdate -ia --verbose
    else
        echo "[!] softwareupdate no disponible"
    fi

    echo ""
    echo "[OK] Actualizacion completada"
    echo "[$(date +%H:%M:%S)] Actualizacion del sistema ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_clean_packages() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO - Perfil DIAGNOSTICO es solo lectura${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${GREEN}=============================================================================="
    echo "[LIMPIEZA DE PAQUETES]"
    echo "=============================================================================="
    echo ""

    if command -v brew &> /dev/null; then
        echo "[i] Limpiando paquetes Homebrew..."
        brew cleanup -s
        brew autoremove 2>/dev/null || true
    else
        echo "[!] Homebrew no detectado"
    fi

    echo ""
    echo "[OK] Limpieza completada"
    echo "[$(date +%H:%M:%S)] Limpieza de paquetes ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_system_report() {
    clear
    echo -e "${BLUE}=============================================================================="
    echo "[REPORTE DEL SISTEMA]"
    echo "=============================================================================="
    echo ""

    REPORT_FILE="$LOG_DIR/Report_$ISO_DATE.html"

    cat > "$REPORT_FILE" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reporte Renggli PC Solutions - macOS</title>
<style>
body{font-family:Consolas,monospace;background:#0a0e27;color:#00ff41;padding:20px;}
h1{color:#00d4ff;border-bottom:2px solid #00d4ff;}
.log{background:#000;padding:15px;border-left:4px solid #00ff41;white-space:pre-wrap;}
.meta{color:#ffd700;font-weight:bold;}
</style>
</head>
<body>
<h1>RENGGLI PC SOLUTIONS - Reporte de Auditoria macOS</h1>
<p class="meta">Fecha: $ISO_DATE</p>
<p class="meta">Usuario: $USER</p>
<p class="meta">Hostname: $(hostname)</p>
<h2>Log de Operaciones</h2>
<div class="log">
$(cat "$LOG_FILE" 2>/dev/null)
</div>
</body>
</html>
EOF

    echo "[OK] Reporte generado: $REPORT_FILE"
    echo "[$(date +%H:%M:%S)] Reporte HTML generado" >> "$LOG_FILE"

    # Intentar abrir reporte
    open "$REPORT_FILE" 2>/dev/null &

    read -p "Presiona Enter para continuar..."
}

mod_processes() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[INFO DE PROCESOS]"
    echo "=============================================================================="
    echo ""
    echo "[i] Top 10 procesos por uso de CPU:"
    ps -A -o %cpu,pid,comm | sort -nr | head -11
    echo ""
    echo "[i] Top 10 procesos por uso de memoria:"
    ps -A -o %mem,pid,comm | sort -nr | head -11
    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de procesos ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

# ==============================================================================
# MODULO DE APAGADO PROGRAMADO - MAC
# ==============================================================================
mod_shutdown() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO - Perfil DIAGNOSTICO es solo lectura${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[APAGADO/REINICIO PROGRAMADO]"
    echo "==============================================================================${NC}"
    echo ""

    echo "1. Apagar en X minutos (rapido)"
    echo "2. Apagar a una hora exacta (HH:MM)"
    echo "3. Programar apagado diario (launchd)"
    echo "4. Programar apagado semanal (launchd)"
    echo "5. Cancelar apagado o tarea programada"
    echo "0. Volver"
    echo ""
    read -p "Selecciona: " choice

    case $choice in
        1)
            read -p "Minutos para apagar: " mins
            sudo shutdown -h +$mins
            echo "[i] Sistema se apagara en $mins minutos"
            echo "[i] Para cancelar: sudo killall shutdown"
            echo "[$(date +%H:%M:%S)] Apagado programado: $mins min" >> "$LOG_FILE"
            ;;
        2)
            read -p "Hora de apagado (HH:MM): " at_time
            sudo shutdown -h $at_time
            echo "[i] Sistema se apagara a las $at_time"
            echo "[i] Para cancelar: sudo killall shutdown"
            echo "[$(date +%H:%M:%S)] Apagado programado (hora exacta): $at_time" >> "$LOG_FILE"
            ;;
        3)
            check_existing_launchd_shutdown
            if [ $? -eq 1 ]; then
                return
            fi
            read -p "Hora diaria (HH:MM): " daily_time
            IFS=':' read -r daily_hour daily_min <<EOF
$daily_time
EOF
            PLIST_FILE="/Library/LaunchDaemons/com.renggli.toolbox.shutdown.plist"
            cat > "$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.renggli.toolbox.shutdown</string>
    <key>ProgramArguments</key>
    <array>
        <string>/sbin/shutdown</string>
        <string>-h</string>
        <string>now</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$daily_hour</integer>
        <key>Minute</key>
        <integer>$daily_min</integer>
    </dict>
</dict>
</plist>
PLIST
            launchctl load "$PLIST_FILE" 2>/dev/null
            echo "[i] Apagado diario programado a las $daily_time"
            echo "[$(date +%H:%M:%S)] Apagado diario programado: $daily_time" >> "$LOG_FILE"
            ;;
        4)
            check_existing_launchd_shutdown
            if [ $? -eq 1 ]; then
                return
            fi
            echo "Dias: 1=Lunes, 2=Martes, 3=Miercoles, 4=Jueves, 5=Viernes, 6=Sabado, 7=Domingo"
            read -p "Dia semanal (1-7): " weekly_day
            read -p "Hora semanal (HH:MM): " weekly_time
            IFS=':' read -r weekly_hour weekly_min <<EOF
$weekly_time
EOF
            PLIST_FILE="/Library/LaunchDaemons/com.renggli.toolbox.shutdown.plist"
            cat > "$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.renggli.toolbox.shutdown</string>
    <key>ProgramArguments</key>
    <array>
        <string>/sbin/shutdown</string>
        <string>-h</string>
        <string>now</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>$weekly_day</integer>
        <key>Hour</key>
        <integer>$weekly_hour</integer>
        <key>Minute</key>
        <integer>$weekly_min</integer>
    </dict>
</dict>
</plist>
PLIST
            launchctl load "$PLIST_FILE" 2>/dev/null
            echo "[i] Apagado semanal programado (dia $weekly_day) a las $weekly_time"
            echo "[$(date +%H:%M:%S)] Apagado semanal programado: $weekly_day $weekly_time" >> "$LOG_FILE"
            ;;
        5)
            # Cancelar shutdown inmediato
            sudo killall shutdown 2>/dev/null
            # Cancelar tareas launchd
            PLIST_FILE="/Library/LaunchDaemons/com.renggli.toolbox.shutdown.plist"
            if [ -f "$PLIST_FILE" ]; then
                launchctl unload "$PLIST_FILE" 2>/dev/null
                rm -f "$PLIST_FILE"
                echo "[i] Tarea launchd eliminada"
            fi
            # Buscar otras tareas de shutdown
            FOUND_PLISTS=$(grep -rl "shutdown" /Library/LaunchDaemons /Library/LaunchAgents ~/Library/LaunchAgents 2>/dev/null)
            if [ -n "$FOUND_PLISTS" ]; then
                echo "[i] Otras tareas de apagado encontradas:"
                for plist in $FOUND_PLISTS; do
                    echo "    - $plist"
                done
            fi
            echo "[OK] Apagado/tarea cancelada"
            echo "[$(date +%H:%M:%S)] Cancelacion de apagado/tarea" >> "$LOG_FILE"
            ;;
        0) return ;;
    esac

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Detectar tareas de apagado launchd existentes
check_existing_launchd_shutdown() {
    EXISTING_PLIST=$(grep -rl "shutdown" /Library/LaunchDaemons /Library/LaunchAgents ~/Library/LaunchAgents 2>/dev/null | head -1)
    
    if [ -z "$EXISTING_PLIST" ]; then
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}[!] Ya existe una tarea de apagado programada:${NC}"
    echo "    $EXISTING_PLIST"
    echo ""
    echo "1. Reemplazar esa tarea (eliminar y crear nueva)"
    echo "2. Eliminar esa tarea y cancelar"
    echo "3. Crear otra tarea nueva (ambas coexistiran)"
    echo "0. Cancelar operacion"
    echo ""
    read -p "Selecciona una opcion [0-3]: " launchd_choice
    
    case $launchd_choice in
        1)
            # Eliminar todas las tareas de shutdown existentes
            FOUND_PLISTS=$(grep -rl "shutdown" /Library/LaunchDaemons /Library/LaunchAgents ~/Library/LaunchAgents 2>/dev/null)
            for plist in $FOUND_PLISTS; do
                launchctl unload "$plist" 2>/dev/null
                rm -f "$plist" 2>/dev/null
            done
            echo "[i] Tarea anterior eliminada. Continua configurando la nueva..."
            echo "[$(date +%H:%M:%S)] Tarea launchd anterior eliminada (reemplazo)" >> "$LOG_FILE"
            return 0
            ;;
        2)
            FOUND_PLISTS=$(grep -rl "shutdown" /Library/LaunchDaemons /Library/LaunchAgents ~/Library/LaunchAgents 2>/dev/null)
            for plist in $FOUND_PLISTS; do
                launchctl unload "$plist" 2>/dev/null
                rm -f "$plist" 2>/dev/null
            done
            echo "[OK] Tarea eliminada."
            echo "[$(date +%H:%M:%S)] Tarea launchd eliminada por usuario" >> "$LOG_FILE"
            read -p "Presiona Enter para continuar..."
            return 1
            ;;
        3)
            echo "[i] Se creara una nueva tarea. La anterior permanecera activa."
            return 0
            ;;
        0|*)
            echo "[i] Operacion cancelada."
            read -p "Presiona Enter para continuar..."
            return 1
            ;;
    esac
    
    return 0
}

# ==============================================================================
# SALIDA
# ==============================================================================
exit_script() {
    echo "[$(date +%H:%M:%S)] --- FIN DE SESION ---" >> "$LOG_FILE"
    echo ""
    echo -e "${GREEN}=============================================================================="
    echo "[FINALIZANDO]"
    echo "=============================================================================="
    echo ""
    echo "[OK] Log guardado: $LOG_FILE"
    echo ""
    exit 0
}

exit_no_log() {
    echo ""
    echo -e "${GREEN}=============================================================================="
    echo "[FINALIZANDO SIN LOG]"
    echo "=============================================================================="
    echo ""
    rm -f "$LOG_FILE" 2>/dev/null
    echo "[OK] Log eliminado. Saliendo..."
    echo ""
    exit 0
}

# ==============================================================================
# EJECUCION PRINCIPAL
# ==============================================================================
check_root
profile_select
main_menu
