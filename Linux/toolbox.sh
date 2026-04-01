#!/bin/bash
# ==============================================================================
# Renggli PC Solution - Enterprise Toolbox V14 - Linux Edition
# Todas las funcionalidades de Windows + Características específicas de Linux
# ==============================================================================

# Keep pipelines strict, but avoid aborting the whole suite on non-critical module errors.
set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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
echo "[$(date +%H:%M:%S)] Sistema: $(uname -s) $(uname -r)" >> "$LOG_FILE"

# ==============================================================================
# VERIFICACION DE PRIVILEGIOS
# ==============================================================================
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}"
        echo "=============================================================================="
        echo "[!] ERROR: PRIVILEGIOS INSUFICIENTES"
        echo "=============================================================================="
        echo ""
        echo "Esta suite requiere permisos de ROOT/SUDO."
        echo "Por favor ejecuta: sudo $0"
        echo ""
        echo -e "${NC}"
        echo "[$(date +%H:%M:%S)] Acceso denegado: Privilegios insuficientes" >> "$LOG_FILE"
        exit 1
    fi
}

# ==============================================================================
# DETECTAR DISTRIBUCION
# ==============================================================================
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_VERSION=$VERSION_ID
    elif command -v lsb_release &> /dev/null; then
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        DISTRO_VERSION=$(lsb_release -sr)
    else
        DISTRO="unknown"
        DISTRO_VERSION="unknown"
    fi

    # Detectar gestor de paquetes
    if command -v apt &> /dev/null; then
        PKG_MANAGER="apt"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
    else
        PKG_MANAGER="unknown"
    fi
}

# ==============================================================================
# SELECCION DE PERFIL
# ==============================================================================
profile_select() {
    clear
    echo -e "${CYAN}=============================================================================================================="
    echo "                          Renggli PC Solution - SUITE ENTERPRISE V14 (LINUX)"
    echo "=============================================================================================================="
    echo "Log Actual: $LOG_FILE"
    echo "Distribución: $DISTRO $DISTRO_VERSION | Gestor de paquetes: $PKG_MANAGER"
    echo ""
    echo "[SELECCION DE PERFIL]"
    echo ""
    echo "1. DIAGNOSTICO     - Solo lectura, auditoria y consultas (sin modificaciones)"
    echo "2. REPARACION      - Mantenimiento y reparaciones automatizadas"
    echo "3. ADMINISTRACION  - Acceso completo (incluye formateo y operaciones críticas)"
    echo ""
    read -p "=> Seleccione perfil [1-3]: " PROFILE_MODE

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
        echo "                          Renggli PC Solution - SUITE ENTERPRISE V14 (LINUX)"
        echo "=============================================================================================================="
        echo "Log: $LOG_FILE"
        case $PROFILE_MODE in
            1)
                echo "Perfil: [DIAGNOSTICO] - Solo Lectura"
                echo "Este perfil solo consulta estado de hardware, sistema y red."
                echo "No realiza modificaciones. Ideal para auditoria preventiva."
                echo "Leyenda: [R] lectura  [W] cambios de sistema  [!] critico/irreversible"
                echo ""
                echo "   [ DIAGNOSTICO BASE ]"
                echo "   1. [R] Estado SMART de Discos"
                echo "   2. [R] Info Hardware Completo"
                echo "   3. [R] Test de Memoria RAM"
                echo "   4. [R] Info Sistema Operativo"
                echo "   5. [R] Temperatura y Sensores"
                echo "   12. [R] Test de Velocidad"
                echo "   13. [R] Auditoria DNS/Puertos"
                echo "   15. [R] Monitor de Red en Vivo"
                echo "   18. [R] Analisis de Disco"
                echo "   20. [R] Espacio en Disco"
                echo "   22. [R] Top Procesos CPU/RAM"
                echo "   23. [R] Ver Logs del Sistema"
                echo "   25. [R] Monitoreo en Tiempo Real"
                echo "   29. [R] Reporte Bateria"
                echo "   30. [R] Verificar Integridad"
                ;;
            2)
                echo "Perfil: [REPARACION] - Mantenimiento"
                echo "Incluye diagnostico y reparaciones guiadas."
                echo "Puede modificar el sistema. Guarda trabajo antes de ejecutar modulos."
                echo "Leyenda: [R] lectura  [W] cambios de sistema  [!] critico/irreversible"
                echo ""
                echo "   [ DIAGNOSTICO + REPARACION ]"
                echo "   1. [R] Estado SMART de Discos"
                echo "   2. [R] Info Hardware Completo"
                echo "   3. [R] Test de Memoria RAM"
                echo "   4. [R] Info Sistema Operativo"
                echo "   5. [R] Temperatura y Sensores"
                echo "   6. [W] Verificar Sistema (fsck)"
                echo "   7. [W] Reparar Gestor Paquetes"
                echo "   8. [W] Limpieza Profunda"
                echo "   10. [W] Limpieza Docker"
                echo "   11. [W] Reset de Red"
                echo "   12. [R] Test de Velocidad"
                echo "   13. [R] Auditoria DNS/Puertos"
                echo "   14. [W] Diagnostico Firewall"
                echo "   15. [R] Monitor de Red en Vivo"
                echo "   18. [R] Analisis de Disco"
                echo "   20. [R] Espacio en Disco"
                echo "   21. [W] Gestion de Servicios"
                echo "   22. [R] Top Procesos CPU/RAM"
                echo "   23. [R] Ver Logs del Sistema"
                echo "   25. [R] Monitoreo en Tiempo Real"
                echo "   26. [W] Actualizar Sistema"
                echo "   27. [W] Apagado Programado"
                echo "   28. [W] Backup de Datos"
                echo "   29. [R] Reporte Bateria"
                echo "   30. [R] Verificar Integridad"
                ;;
            3)
                echo "Perfil: [ADMINISTRACION] - Acceso Completo"
                echo "Incluye todas las opciones, incluso tareas criticas e irreversibles."
                echo "PRECAUCION: revisa disco/particion/usuarios antes de confirmar acciones destructivas."
                echo "Leyenda: [R] lectura  [W] cambios de sistema  [!] critico/irreversible"
                echo ""
                echo "   [ MENU COMPLETO ]"
                echo "   1. [R] Estado SMART de Discos    6. [W] Verificar Sistema (fsck)  11. [W] Reset de Red"
                echo "   2. [R] Info Hardware Completo    7. [W] Reparar Gestor Paquetes   12. [R] Test de Velocidad"
                echo "   3. [R] Test de Memoria RAM       8. [W] Limpieza Profunda         13. [R] Auditoria DNS/Puertos"
                echo "   4. [R] Info Sistema Operativo    9. [!] Reparar Bootloader (GRUB) 14. [W] Diagnostico Firewall"
                echo "   5. [R] Temperatura y Sensores    10. [W] Limpieza Docker          15. [R] Monitor de Red en Vivo"
                echo "   16. [!] Formateo Seguro USB      21. [W] Gestion de Servicios     26. [W] Actualizar Sistema"
                echo "   17. [!] Conversion MBR a GPT     22. [R] Top Procesos CPU/RAM     27. [W] Apagado Programado"
                echo "   18. [R] Analisis de Disco        23. [R] Ver Logs del Sistema     28. [W] Backup de Datos"
                echo "   19. [!] Montaje de Particiones   24. [!] Usuarios y Permisos      29. [R] Reporte Bateria"
                echo "   20. [R] Espacio en Disco         25. [R] Monitoreo en Tiempo Real 30. [R] Verificar Integridad"
                ;;
        esac

        echo ""
        echo "   [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG"
        echo "   [99] CAMBIAR PERFIL"
        echo "=============================================================================================================="
        echo -e "${NC}"
        read -p "=> Selecciona una opcion: " choice

        case $choice in
            0) generate_report ; exit_script ;;
            00) exit_no_log ;;
            99) profile_select ;;
            1) mod_smart ;;
            2) mod_hardware ;;
            3) mod_memory ;;
            4) mod_sysinfo ;;
            5) mod_sensors ;;
            6) if [ "$PROFILE_MODE" -ge 2 ]; then mod_fsck; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            7) if [ "$PROFILE_MODE" -ge 2 ]; then mod_pkg_repair; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            8) if [ "$PROFILE_MODE" -ge 2 ]; then mod_deep_clean; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            9) if [ "$PROFILE_MODE" -eq 3 ]; then mod_grub; else echo -e "${RED}[!] Requiere perfil ADMINISTRACION${NC}"; sleep 2; fi ;;
            10) if [ "$PROFILE_MODE" -ge 2 ]; then mod_docker_clean; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            11) if [ "$PROFILE_MODE" -ge 2 ]; then mod_net_reset; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            12) mod_speed_test ;;
            13) mod_dns_audit ;;
            14) if [ "$PROFILE_MODE" -ge 2 ]; then mod_firewall; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            15) mod_net_monitor ;;
            16) if [ "$PROFILE_MODE" -eq 3 ]; then mod_format; else echo -e "${RED}[!] Requiere perfil ADMINISTRACION${NC}"; sleep 2; fi ;;
            17) if [ "$PROFILE_MODE" -eq 3 ]; then mod_mbr_gpt; else echo -e "${RED}[!] Requiere perfil ADMINISTRACION${NC}"; sleep 2; fi ;;
            18) mod_disk_analysis ;;
            19) if [ "$PROFILE_MODE" -eq 3 ]; then mod_mount; else echo -e "${RED}[!] Requiere perfil ADMINISTRACION${NC}"; sleep 2; fi ;;
            20) mod_disk_space ;;
            21) if [ "$PROFILE_MODE" -ge 2 ]; then mod_services; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            22) mod_processes ;;
            23) mod_logs ;;
            24) if [ "$PROFILE_MODE" -eq 3 ]; then mod_users; else echo -e "${RED}[!] Requiere perfil ADMINISTRACION${NC}"; sleep 2; fi ;;
            25) mod_monitor ;;
            26) if [ "$PROFILE_MODE" -ge 2 ]; then mod_update; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            27) if [ "$PROFILE_MODE" -ge 2 ]; then mod_shutdown; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            28) if [ "$PROFILE_MODE" -ge 2 ]; then mod_backup; else echo -e "${RED}[!] Requiere perfil REPARACION${NC}"; sleep 2; fi ;;
            29) mod_battery ;;
            30) mod_integrity ;;
            *) echo -e "${YELLOW}[!] Opcion no valida${NC}" && sleep 2 ;;
        esac
    done
}

# ==============================================================================
# MODULOS - DIAGNOSTICO DE HARDWARE
# ==============================================================================

mod_smart() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[AUDITORIA SMART] Analizando salud de discos..."
    echo "==============================================================================${NC}"
    echo ""

    # Verificar si smartctl está instalado
    if ! command -v smartctl &> /dev/null; then
        echo -e "${YELLOW}[!] smartctl no está instalado. Instalando smartmontools...${NC}"
        case $PKG_MANAGER in
            apt) apt install -y smartmontools ;;
            dnf|yum) $PKG_MANAGER install -y smartmontools ;;
            pacman) pacman -S --noconfirm smartmontools ;;
            zypper) zypper -n install smartmontools ;;
        esac
    fi

    echo "[i] Discos detectados:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep disk || true
    echo ""

    for disk in $(lsblk -d -n -o NAME | grep -E '^sd|^nvme|^hd'); do
        echo -e "${CYAN}[*] Analizando /dev/$disk...${NC}"
        smartctl -H /dev/$disk 2>/dev/null || echo "[!] No se pudo leer SMART de /dev/$disk"
        echo ""
    done

    echo "[OK] Auditoria SMART completada"
    echo "[$(date +%H:%M:%S)] Auditoria SMART ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_hardware() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[INFO DE HARDWARE COMPLETO]"
    echo "==============================================================================${NC}"
    echo ""
    echo "[i] Esto puede tardar unos segundos en equipos con mucho hardware detectado..."
    echo ""

    echo -e "${YELLOW}[CPU]${NC}"
    lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core|MHz"
    echo ""

    echo -e "${YELLOW}[MEMORIA RAM]${NC}"
    free -h
    if command -v dmidecode &> /dev/null; then
        echo ""
        echo "Detalles de módulos RAM:"
        dmidecode -t memory | grep -E "Size|Speed|Manufacturer|Type:" | head -20
    fi
    echo ""

    echo -e "${YELLOW}[PLACA MADRE / BIOS]${NC}"
    if command -v dmidecode &> /dev/null; then
        dmidecode -t baseboard | grep -E "Manufacturer|Product Name|Version"
        dmidecode -t bios | grep -E "Vendor|Version|Release Date"
    else
        echo "[i] dmidecode no disponible. Instala: $PKG_MANAGER install dmidecode"
    fi
    echo ""

    echo -e "${YELLOW}[DISPOSITIVOS PCI (GPU, Red, etc.)]${NC}"
    lspci | grep -E "VGA|Network|Ethernet|Audio"
    echo ""

    echo -e "${YELLOW}[DISPOSITIVOS USB]${NC}"
    lsusb
    echo ""

    echo "[$(date +%H:%M:%S)] Consulta de hardware ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_memory() {
    clear
    echo -e "${MAGENTA}=============================================================================="
    echo "[TEST DE MEMORIA RAM]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Información actual de memoria:"
    free -h
    echo ""

    echo "[i] Verificando errores de memoria en logs..."
    dmesg | grep -i "memory" | tail -20 || true
    echo ""

    if command -v memtester &> /dev/null; then
        echo "[i] memtester detectado"
        read -p "¿Ejecutar test de memoria con memtester? (s/n): " response
        if [[ "$response" == "s" ]]; then
            read -p "MB de RAM a testear (ej: 100): " mb
            memtester ${mb}M 1
        fi
    else
        echo -e "${YELLOW}[!] Para test completo instala: $PKG_MANAGER install memtester${NC}"
        echo "[i] También puedes usar memtest86+ desde el boot"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Test de memoria ejecutado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_sysinfo() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[INFORMACION DEL SISTEMA OPERATIVO]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${YELLOW}[KERNEL Y OS]${NC}"
    uname -a
    echo ""

    if [ -f /etc/os-release ]; then
        cat /etc/os-release
    fi
    echo ""

    echo -e "${YELLOW}[UPTIME Y CARGA]${NC}"
    uptime
    echo ""

    echo -e "${YELLOW}[HOSTNAME Y RED]${NC}"
    echo "Hostname: $(hostname)"
    echo "IP: $(hostname -I | awk '{print $1}')"
    echo ""

    echo -e "${YELLOW}[PARTICIONES MONTADAS]${NC}"
    df -hT
    echo ""

    echo "[$(date +%H:%M:%S)] Info del sistema consultada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_sensors() {
    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[TEMPERATURA Y SENSORES]"
    echo "==============================================================================${NC}"
    echo ""

    if ! command -v sensors &> /dev/null; then
        echo -e "${YELLOW}[!] Instalando lm-sensors...${NC}"
        case $PKG_MANAGER in
            apt) apt install -y lm-sensors ;;
            dnf|yum) $PKG_MANAGER install -y lm_sensors ;;
            pacman) pacman -S --noconfirm lm_sensors ;;
            zypper) zypper -n install sensors ;;
        esac
        sensors-detect --auto
    fi

    echo "[i] Temperaturas del sistema:"
    sensors 2>/dev/null || echo "[!] No se detectaron sensores"
    echo ""

    echo "[i] Uso de CPU:"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "Uso: " 100 - $1"%"}'
    echo ""

    echo "[$(date +%H:%M:%S)] Sensores consultados" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

# ==============================================================================
# MODULOS - REPARACION DE SISTEMA
# ==============================================================================

mod_fsck() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO - Perfil DIAGNOSTICO${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[VERIFICACION Y REPARACION DE SISTEMA DE ARCHIVOS]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${RED}[!] ADVERTENCIA: Esto verificará y reparará el sistema de archivos${NC}"
    echo ""
    lsblk -f
    echo ""

    read -p "¿Continuar? (s/n): " response
    if [[ "$response" != "s" ]]; then
        return
    fi

    echo ""
    echo "[i] Ejecutando verificación de sistema de archivos..."
    fsck -Af -M 2>&1 | tee -a "$LOG_FILE"

    echo ""
    echo "[OK] Verificación completada"
    echo "[$(date +%H:%M:%S)] fsck ejecutado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_pkg_repair() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${GREEN}=============================================================================="
    echo "[REPARACION DEL GESTOR DE PAQUETES]"
    echo "==============================================================================${NC}"
    echo ""

    case $PKG_MANAGER in
        apt)
            echo "[i] Reparando APT..."
            dpkg --configure -a
            apt-get clean
            apt-get update --fix-missing
            apt-get install -f
            apt-get autoremove -y
            apt-get autoclean
            ;;
        dnf)
            echo "[i] Reparando DNF..."
            dnf clean all
            dnf check
            dnf update --refresh
            ;;
        yum)
            echo "[i] Reparando YUM..."
            yum clean all
            yum check
            ;;
        pacman)
            echo "[i] Reparando Pacman..."
            pacman -Sc --noconfirm
            pacman -Syu --noconfirm
            ;;
        zypper)
            echo "[i] Reparando Zypper..."
            zypper -n refresh
            zypper -n verify
            zypper -n update
            ;;
        *)
            echo "[!] Gestor de paquetes no soportado"
            ;;
    esac

    echo ""
    echo "[OK] Reparación completada"
    echo "[$(date +%H:%M:%S)] Gestor de paquetes reparado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_deep_clean() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${GREEN}=============================================================================="
    echo "[LIMPIEZA PROFUNDA DEL SISTEMA]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Limpiando archivos temporales..."
    rm -rf /tmp/* 2>/dev/null
    rm -rf /var/tmp/* 2>/dev/null
    echo "[OK] Temporales eliminados"
    echo ""

    echo "[i] Limpiando cache de sistema..."
    sync
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null
    echo "[OK] Cache limpiada"
    echo ""

    echo "[i] Limpiando logs antiguos..."
    journalctl --vacuum-time=7d 2>/dev/null || echo "[i] journalctl no disponible"
    find /var/log -type f -name "*.log.*" -delete 2>/dev/null
    echo "[OK] Logs antiguos eliminados"
    echo ""

    echo "[i] Limpiando paquetes huérfanos..."
    case $PKG_MANAGER in
        apt)
            apt autoremove -y
            apt autoclean
            ;;
        dnf|yum)
            $PKG_MANAGER autoremove -y
            $PKG_MANAGER clean all
            ;;
        pacman)
            pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || echo "[i] No hay paquetes huérfanos"
            ;;
        zypper)
            zypper -n packages --orphaned || true
            zypper -n clean --all
            ;;
    esac
    echo "[OK] Paquetes huérfanos eliminados"
    echo ""

    echo "[OK] Limpieza profunda completada"
    echo "[$(date +%H:%M:%S)] Limpieza profunda ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_grub() {
    if [ "$PROFILE_MODE" != "3" ]; then
        echo -e "${RED}[!] REQUIERE PERFIL ADMINISTRACION${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[REPARACION DE BOOTLOADER GRUB]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${RED}[!] ADVERTENCIA: Operación crítica del sistema${NC}"
    echo ""

    read -p "¿Continuar con la reparación de GRUB? (s/n): " response
    if [[ "$response" != "s" ]]; then
        return
    fi

    echo ""
    echo "[i] Actualizando configuración de GRUB..."

    if [ -f /etc/default/grub ]; then
        update-grub 2>/dev/null || grub-mkconfig -o /boot/grub/grub.cfg
        echo ""
        echo "[OK] GRUB actualizado"
    else
        echo "[!] Archivo de configuración de GRUB no encontrado"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] GRUB reparado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_docker_clean() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${BLUE}=============================================================================="
    echo "[LIMPIEZA DE DOCKER]"
    echo "==============================================================================${NC}"
    echo ""

    if ! command -v docker &> /dev/null; then
        echo "[!] Docker no está instalado"
        sleep 2
        return
    fi

    echo "[i] Estado actual de Docker:"
    docker system df
    echo ""

    read -p "¿Limpiar contenedores, imágenes y volúmenes no utilizados? (s/n): " response
    if [[ "$response" == "s" ]]; then
        echo ""
        echo "[i] Limpiando Docker..."
        docker system prune -af --volumes
        echo ""
        echo "[OK] Docker limpiado"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Docker limpiado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

# ==============================================================================
# MODULOS - REDES Y CONECTIVIDAD
# ==============================================================================

mod_net_reset() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${BLUE}=============================================================================="
    echo "[RESET DE RED]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Reiniciando servicios de red..."

    if command -v systemctl &> /dev/null; then
        systemctl restart NetworkManager 2>/dev/null || systemctl restart networking 2>/dev/null
    else
        service network-manager restart 2>/dev/null || service networking restart 2>/dev/null
    fi

    echo ""
    echo "[i] Limpiando cache DNS..."
    if command -v systemd-resolve &> /dev/null; then
        systemd-resolve --flush-caches
    elif command -v resolvectl &> /dev/null; then
        resolvectl flush-caches
    fi

    echo ""
    echo "[OK] Red reiniciada"
    echo "[$(date +%H:%M:%S)] Reset de red ejecutado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_speed_test() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[TEST DE VELOCIDAD DE INTERNET]"
    echo "==============================================================================${NC}"
    echo ""

    if ! command -v speedtest-cli &> /dev/null; then
        echo "[i] speedtest-cli no esta instalado."
        read -p "Instalar speedtest-cli? (S/N): " install_speedtest
        if [[ "$install_speedtest" =~ ^[Ss]$ ]]; then
            echo "[i] Instalando speedtest-cli..."
            case $PKG_MANAGER in
                apt) apt install -y speedtest-cli ;;
                dnf|yum) $PKG_MANAGER install -y speedtest-cli ;;
                pacman) pacman -S --noconfirm speedtest-cli ;;
                zypper) zypper -n install speedtest-cli ;;
            esac
        fi
    fi

    if command -v speedtest-cli &> /dev/null; then
        echo "[i] Ejecutando test de velocidad..."
        speedtest-cli
    else
        echo "[i] Método alternativo con curl..."
        echo "[i] Test de latencia:"
        ping -c 4 8.8.8.8
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Test de velocidad ejecutado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_dns_audit() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[AUDITORIA DNS Y PUERTOS]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${YELLOW}[DNS ACTUAL]${NC}"
    cat /etc/resolv.conf | grep nameserver || true
    echo ""

    echo -e "${YELLOW}[PUERTOS EN ESCUCHA]${NC}"
    if command -v ss &> /dev/null; then
        ss -tuln
    else
        netstat -tuln
    fi
    echo ""

    echo -e "${YELLOW}[CONEXIONES ACTIVAS]${NC}"
    if command -v ss &> /dev/null; then
        ss -tun | wc -l
        echo "conexiones activas"
    fi
    echo ""

    echo "[$(date +%H:%M:%S)] Auditoria DNS/Puertos" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_firewall() {
    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[DIAGNOSTICO DE FIREWALL]"
    echo "==============================================================================${NC}"
    echo ""

    if command -v ufw &> /dev/null; then
        echo "[i] Estado de UFW:"
        ufw status verbose
    elif command -v firewall-cmd &> /dev/null; then
        echo "[i] Estado de Firewalld:"
        firewall-cmd --state
        echo ""
        firewall-cmd --list-all
    elif command -v iptables &> /dev/null; then
        echo "[i] Reglas de iptables:"
        iptables -L -n -v
    else
        echo "[!] No se detectó firewall configurado"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Diagnostico de firewall" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_net_monitor() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[MONITOR DE RED EN TIEMPO REAL]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Presiona Ctrl+C para salir"
    echo ""
    sleep 2

    if command -v iftop &> /dev/null; then
        iftop
    elif command -v nethogs &> /dev/null; then
        nethogs
    else
        echo "[!] Instala iftop o nethogs para monitoreo en vivo"
        echo "[i] Mostrando conexiones activas..."
        watch -n 1 'ss -tun | head -20'
    fi

    echo "[$(date +%H:%M:%S)] Monitor de red ejecutado" >> "$LOG_FILE"
}

# ==============================================================================
# MODULOS - ALMACENAMIENTO
# ==============================================================================

mod_format() {
    if [ "$PROFILE_MODE" != "3" ]; then
        echo -e "${RED}[!] REQUIERE PERFIL ADMINISTRACION${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${RED}=============================================================================="
    echo "[!] FORMATEO SEGURO DE DISPOSITIVO"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${YELLOW}[DISCOS DISPONIBLES]${NC}"
    lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL
    echo ""

    read -p "Dispositivo a formatear (ej: sdb): " device

    if [[ -z "$device" ]]; then
        echo "[!] Operación cancelada"
        sleep 2
        return
    fi

    if [[ ! "$device" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo "[!] Dispositivo invalido"
        sleep 2
        return
    fi

    ROOT_DEVICE=$(findmnt -n -o SOURCE / 2>/dev/null || true)
    if [[ "$ROOT_DEVICE" == /dev/${device}* ]]; then
        echo "[BLOQUEADO] No se permite formatear el dispositivo del sistema: /dev/$device"
        echo "[$(date +%H:%M:%S)] Formateo bloqueado: dispositivo de sistema /dev/$device" >> "$LOG_FILE"
        read -p "Presiona Enter para continuar..."
        return
    fi

    echo ""
    echo -e "${RED}[!] ADVERTENCIA: SE BORRARAN TODOS LOS DATOS DE /dev/$device${NC}"
    echo ""
    read -p "Escribe 'CONFIRMO' para continuar: " confirm

    if [[ "$confirm" != "CONFIRMO" ]]; then
        echo "[i] Operación cancelada"
        sleep 2
        return
    fi

    echo ""
    echo "[i] Formateando /dev/$device..."
    wipefs -a /dev/$device
    parted /dev/$device --script mklabel gpt
    parted /dev/$device --script mkpart primary ext4 0% 100%
    mkfs.ext4 -F /dev/${device}1

    echo ""
    echo "[OK] Dispositivo formateado exitosamente"
    echo "[$(date +%H:%M:%S)] Formateo de /dev/$device completado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_mbr_gpt() {
    if [ "$PROFILE_MODE" != "3" ]; then
        echo -e "${RED}[!] REQUIERE PERFIL ADMINISTRACION${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[CONVERSION MBR A GPT]"
    echo "==============================================================================${NC}"
    echo ""

    if ! command -v gdisk &> /dev/null; then
        echo "[i] Instalando gdisk..."
        case $PKG_MANAGER in
            apt) apt install -y gdisk ;;
            dnf|yum) $PKG_MANAGER install -y gdisk ;;
            pacman) pacman -S --noconfirm gptfdisk ;;
            zypper) zypper -n install gptfdisk ;;
        esac
    fi

    echo "[i] Discos disponibles:"
    lsblk -d -o NAME,SIZE,TYPE
    echo ""

    read -p "Disco a convertir (ej: sdb): " disk

    if [[ -z "$disk" ]]; then
        echo "[!] Operación cancelada"
        sleep 2
        return
    fi

    if [[ ! "$disk" =~ ^[a-zA-Z0-9]+$ ]]; then
        echo "[!] Disco invalido"
        sleep 2
        return
    fi

    ROOT_DEVICE=$(findmnt -n -o SOURCE / 2>/dev/null || true)
    if [[ "$ROOT_DEVICE" == /dev/${disk}* ]]; then
        echo "[BLOQUEADO] No se permite convertir el disco del sistema: /dev/$disk"
        echo "[$(date +%H:%M:%S)] Conversion MBR->GPT bloqueada: disco de sistema /dev/$disk" >> "$LOG_FILE"
        read -p "Presiona Enter para continuar..."
        return
    fi

    echo ""
    echo -e "${RED}[!] ADVERTENCIA: Operación irreversible${NC}"
    read -p "Escribe 'GPT-OK' para confirmar: " confirm

    if [[ "$confirm" == "GPT-OK" ]]; then
        echo ""
        echo "[i] Convirtiendo /dev/$disk a GPT..."
        gdisk /dev/$disk <<EOF
r
g
w
y
EOF
        echo ""
        echo "[OK] Conversión completada"
        echo "[$(date +%H:%M:%S)] Conversión MBR->GPT /dev/$disk" >> "$LOG_FILE"
    else
        echo "[i] Operación cancelada"
    fi

    read -p "Presiona Enter para continuar..."
}

mod_disk_analysis() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[ANALISIS COMPLETO DE DISCO]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${YELLOW}[PARTICIONES Y MONTAJE]${NC}"
    lsblk -f
    echo ""

    echo -e "${YELLOW}[USO DE ESPACIO]${NC}"
    df -hT
    echo ""

    echo -e "${YELLOW}[INODOS]${NC}"
    df -i
    echo ""

    if command -v ncdu &> /dev/null; then
        read -p "¿Analizar carpetas grandes con ncdu? (s/n): " response
        if [[ "$response" == "s" ]]; then
            ncdu /
        fi
    else
        echo "[i] Top 10 carpetas más grandes:"
        du -h / 2>/dev/null | sort -rh | head -10
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Análisis de disco ejecutado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_mount() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[MONTAJE DE PARTICIONES]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Particiones disponibles:"
    lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID
    echo ""

    echo "[i] Puntos de montaje actuales:"
    mount | column -t
    echo ""

    echo "[$(date +%H:%M:%S)] Consulta de montaje" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_disk_space() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[ESPACIO EN DISCO]"
    echo "==============================================================================${NC}"
    echo ""

    df -hT --total
    echo ""

    echo "[i] Uso por tipo de archivo en /home:"
    echo ""
    du -sh /home/* 2>/dev/null | sort -rh | head -10

    echo ""
    echo "[$(date +%H:%M:%S)] Consulta de espacio en disco" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

# ==============================================================================
# MODULOS - SERVICIOS Y PROCESOS
# ==============================================================================

mod_services() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[GESTION DE SERVICIOS]"
    echo "==============================================================================${NC}"
    echo ""

    if command -v systemctl &> /dev/null; then
        echo "[i] Servicios activos:"
        systemctl list-units --type=service --state=running
        echo ""

        echo "[i] Servicios fallidos:"
        systemctl --failed
    else
        echo "[i] Comando systemctl no disponible"
        service --status-all
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Gestión de servicios consultada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_processes() {
    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[TOP PROCESOS POR CPU Y RAM]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${CYAN}[TOP 10 PROCESOS POR CPU]${NC}"
    ps aux --sort=-%cpu | head -11
    echo ""

    echo -e "${CYAN}[TOP 10 PROCESOS POR MEMORIA]${NC}"
    ps aux --sort=-%mem | head -11
    echo ""

    echo "[$(date +%H:%M:%S)] Consulta de procesos" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_logs() {
    clear
    echo -e "${MAGENTA}=============================================================================="
    echo "[LOGS DEL SISTEMA]"
    echo "==============================================================================${NC}"
    echo ""

    echo "1. Ver últimos errores del kernel"
    echo "2. Ver logs de autenticación"
    echo "3. Ver logs del sistema (journalctl)"
    echo "4. Ver logs de Apache/Nginx"
    echo "0. Volver"
    echo ""
    read -p "Selecciona: " log_choice

    case $log_choice in
        1) dmesg | grep -i error | tail -50 || true ;;
        2) tail -100 /var/log/auth.log 2>/dev/null || tail -100 /var/log/secure ;;
        3) echo "[i] Esto puede tardar unos segundos segun el volumen del journal..."; journalctl -xe | tail -100 ;;
        4) tail -100 /var/log/apache2/error.log 2>/dev/null || tail -100 /var/log/nginx/error.log 2>/dev/null ;;
        0) return ;;
    esac

    echo ""
    echo "[$(date +%H:%M:%S)] Logs consultados" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_users() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[USUARIOS Y PERMISOS]"
    echo "==============================================================================${NC}"
    echo ""

    echo -e "${YELLOW}[USUARIOS DEL SISTEMA]${NC}"
    cat /etc/passwd | grep -v nologin | grep -v false | cut -d: -f1
    echo ""

    echo -e "${YELLOW}[USUARIOS LOGUEADOS]${NC}"
    who
    echo ""

    echo -e "${YELLOW}[ULTIMO LOGIN]${NC}"
    last | head -20
    echo ""

    echo "[$(date +%H:%M:%S)] Usuarios consultados" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_monitor() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[MONITOREO EN TIEMPO REAL]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Iniciando htop (Presiona q para salir)..."
    sleep 2

    if command -v htop &> /dev/null; then
        htop
    elif command -v top &> /dev/null; then
        top
    else
        echo "[!] htop/top no disponible"
    fi

    echo "[$(date +%H:%M:%S)] Monitor ejecutado" >> "$LOG_FILE"
}

# ==============================================================================
# MODULOS - AUTOMATIZACION
# ==============================================================================

mod_update() {
    if [ "$PROFILE_MODE" == "1" ]; then
        echo -e "${RED}[!] ACCESO RESTRINGIDO${NC}"
        sleep 2
        return
    fi

    clear
    echo -e "${GREEN}=============================================================================="
    echo "[ACTUALIZACION DEL SISTEMA]"
    echo "==============================================================================${NC}"
    echo ""
    echo "[i] Esto puede tardar varios minutos segun paquetes y velocidad de red..."
    echo ""

    case $PKG_MANAGER in
        apt)
            echo "[i] Actualizando sistema (Debian/Ubuntu)..."
            apt update
            apt upgrade -y
            apt dist-upgrade -y
            ;;
        dnf)
            echo "[i] Actualizando sistema (Fedora/RHEL)..."
            dnf upgrade -y
            ;;
        yum)
            echo "[i] Actualizando sistema (CentOS/RHEL)..."
            yum update -y
            ;;
        pacman)
            echo "[i] Actualizando sistema (Arch)..."
            pacman -Syu --noconfirm
            ;;
        zypper)
            echo "[i] Actualizando sistema (OpenSUSE)..."
            zypper -n refresh
            zypper -n update
            ;;
        *)
            echo "[!] Gestor de paquetes no soportado"
            ;;
    esac

    echo ""
    echo "[OK] Sistema actualizado"
    echo "[$(date +%H:%M:%S)] Sistema actualizado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_shutdown() {
    clear
    echo -e "${YELLOW}=============================================================================="
    echo "[APAGADO/REINICIO PROGRAMADO]"
    echo "==============================================================================${NC}"
    echo ""

    echo "1. Apagar en X minutos (rapido)"
    echo "2. Apagar a una hora exacta (HH:MM)"
    echo "3. Programar apagado diario (cron)"
    echo "4. Programar apagado semanal (cron)"
    echo "5. Cancelar apagado o tarea programada"
    echo "0. Volver"
    echo ""
    read -p "Selecciona: " choice

    case $choice in
        1)
            read -p "Minutos para apagar: " mins
            shutdown -h +$mins
            echo "[i] Sistema se apagará en $mins minutos"
            echo "[i] Para cancelar: shutdown -c"
            echo "[$(date +%H:%M:%S)] Apagado programado: $mins min" >> "$LOG_FILE"
            ;;
        2)
            read -p "Hora de apagado (HH:MM): " at_time
            if ! [[ "$at_time" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                echo "[!] Hora invalida. Usa formato HH:MM (24h), ej: 09:05 o 18:30"
                read -p "Presiona Enter para continuar..."
                return
            fi
            shutdown -h $at_time
            echo "[i] Sistema se apagará a las $at_time"
            echo "[i] Para cancelar: shutdown -c"
            echo "[$(date +%H:%M:%S)] Apagado programado (hora exacta): $at_time" >> "$LOG_FILE"
            ;;
        3)
            check_existing_cron_shutdown
            if [ $? -eq 1 ]; then
                return
            fi
            read -p "Hora diaria (HH:MM): " daily_time
            if ! [[ "$daily_time" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                echo "[!] Hora invalida. Usa formato HH:MM (24h), ej: 09:05 o 18:30"
                read -p "Presiona Enter para continuar..."
                return
            fi
            IFS=':' read -r daily_hour daily_min <<EOF
$daily_time
EOF
            CRON_FILE="/etc/cron.d/toolbox_shutdown"
            echo "$daily_min $daily_hour * * * root /sbin/shutdown -h now" > "$CRON_FILE"
            echo "[i] Apagado diario programado a las $daily_time"
            echo "[$(date +%H:%M:%S)] Apagado diario programado: $daily_time" >> "$LOG_FILE"
            ;;
        4)
            check_existing_cron_shutdown
            if [ $? -eq 1 ]; then
                return
            fi
            read -p "Dia semanal (0=Dom,1=Lun,...6=Sab): " weekly_day
            read -p "Hora semanal (HH:MM): " weekly_time
            if ! [[ "$weekly_time" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]]; then
                echo "[!] Hora invalida. Usa formato HH:MM (24h), ej: 09:05 o 18:30"
                read -p "Presiona Enter para continuar..."
                return
            fi
            IFS=':' read -r weekly_hour weekly_min <<EOF
$weekly_time
EOF
            CRON_FILE="/etc/cron.d/toolbox_shutdown"
            echo "$weekly_min $weekly_hour * * $weekly_day root /sbin/shutdown -h now" > "$CRON_FILE"
            echo "[i] Apagado semanal programado (dia $weekly_day) a las $weekly_time"
            echo "[$(date +%H:%M:%S)] Apagado semanal programado: $weekly_day $weekly_time" >> "$LOG_FILE"
            ;;
        5)
            shutdown -c 2>/dev/null
            rm -f /etc/cron.d/toolbox_shutdown
            echo "[i] Se elimino solo la tarea administrada por Toolbox (/etc/cron.d/toolbox_shutdown)."
            echo "[OK] Apagado/tarea cancelada"
            echo "[$(date +%H:%M:%S)] Cancelacion de apagado/tarea" >> "$LOG_FILE"
            ;;
        0) return ;;
    esac

    echo ""
    read -p "Presiona Enter para continuar..."
}

# Detectar tareas de apagado cron existentes
check_existing_cron_shutdown() {
    CRON_FILE="/etc/cron.d/toolbox_shutdown"
    EXISTING_CRON=""
    if [ -f "$CRON_FILE" ]; then
        EXISTING_CRON=$(cat "$CRON_FILE" 2>/dev/null)
    fi
    
    if [ -z "$EXISTING_CRON" ]; then
        return 0
    fi
    
    echo ""
    echo -e "${YELLOW}[!] Ya existe una tarea de apagado programada:${NC}"
    echo "    $EXISTING_CRON"
    echo ""
    echo "1. Reemplazar esa tarea (eliminar y crear nueva)"
    echo "2. Eliminar esa tarea y cancelar"
    echo "3. Crear otra tarea nueva (ambas coexistiran)"
    echo "0. Cancelar operacion"
    echo ""
    read -p "Selecciona una opcion [0-3]: " cron_choice
    
    case $cron_choice in
        1)
            rm -f "$CRON_FILE" 2>/dev/null
            echo "[i] Tarea anterior eliminada. Continua configurando la nueva..."
            echo "[$(date +%H:%M:%S)] Tarea cron anterior eliminada (reemplazo)" >> "$LOG_FILE"
            return 0
            ;;
        2)
            rm -f "$CRON_FILE" 2>/dev/null
            echo "[OK] Tarea eliminada."
            echo "[$(date +%H:%M:%S)] Tarea cron eliminada por usuario" >> "$LOG_FILE"
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

mod_backup() {
    clear
    echo -e "${CYAN}=============================================================================="
    echo "[BACKUP DE DATOS]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Directorio a respaldar:"
    read -p "Ruta completa: " source_dir

    if [[ ! -d "$source_dir" ]]; then
        echo "[!] Directorio no existe"
        sleep 2
        return
    fi

    BACKUP_DIR="$HOME/Backups"
    mkdir -p "$BACKUP_DIR"

    BACKUP_FILE="$BACKUP_DIR/backup_$(basename $source_dir)_$(date +%Y%m%d_%H%M%S).tar.gz"

    echo ""
    echo "[i] Creando backup en: $BACKUP_FILE"
    echo "[i] Esto puede tardar varios minutos segun tamano y cantidad de archivos..."
    tar -czf "$BACKUP_FILE" "$source_dir" 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "[OK] Backup creado exitosamente"
        echo "[i] Tamaño: $(du -h $BACKUP_FILE | cut -f1)"
    else
        echo "[!] Error al crear backup"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Backup creado: $BACKUP_FILE" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_battery() {
    clear
    echo -e "${GREEN}=============================================================================="
    echo "[REPORTE DE BATERIA]"
    echo "==============================================================================${NC}"
    echo ""

    if ! command -v upower &> /dev/null; then
        echo "[!] upower no está instalado"
        echo "[i] Instalando..."
        case $PKG_MANAGER in
            apt) apt install -y upower ;;
            dnf|yum) $PKG_MANAGER install -y upower ;;
            pacman) pacman -S --noconfirm upower ;;
            zypper) zypper -n install upower ;;
        esac
    fi

    if command -v upower &> /dev/null; then
        BATTERIES=$(upower -e 2>/dev/null | grep -i BAT || true)
        if [ -z "$BATTERIES" ]; then
            echo "[!] No se detecta bateria en este equipo"
            echo "[$(date +%H:%M:%S)] Reporte de bateria no disponible" >> "$LOG_FILE"
            read -p "Presiona Enter para continuar..."
            return
        fi
        echo "[i] Información de batería:"
        for bat in $BATTERIES; do
            upower -i "$bat"
        done
    elif command -v acpi &> /dev/null; then
        echo "[i] Información de batería (acpi):"
        acpi -V
    else
        echo "[!] No se pudo obtener información de batería"
        cat /sys/class/power_supply/BAT0/capacity 2>/dev/null && echo "% de carga"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Reporte de batería generado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

mod_integrity() {
    clear
    echo -e "${MAGENTA}=============================================================================="
    echo "[VERIFICACION DE INTEGRIDAD DEL SISTEMA]"
    echo "==============================================================================${NC}"
    echo ""

    echo "[i] Verificando archivos críticos del sistema..."
    echo ""

    # Verificar binarios importantes
    echo -e "${YELLOW}[BINARIOS CRITICOS]${NC}"
    for cmd in bash sudo ls cat systemctl; do
        if command -v $cmd &> /dev/null; then
            echo "[OK] $cmd encontrado"
        else
            echo -e "${RED}[!] $cmd NO ENCONTRADO${NC}"
        fi
    done
    echo ""

    # Verificar permisos de archivos críticos
    echo -e "${YELLOW}[PERMISOS DE ARCHIVOS CRITICOS]${NC}"
    ls -l /etc/passwd /etc/shadow /etc/sudoers 2>/dev/null
    echo ""

    # Verificar SELinux/AppArmor
    echo -e "${YELLOW}[SEGURIDAD]${NC}"
    if command -v getenforce &> /dev/null; then
        echo "SELinux: $(getenforce)"
    elif command -v aa-status &> /dev/null; then
        echo "AppArmor: Instalado"
    else
        echo "[i] No se detectó SELinux ni AppArmor"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Verificación de integridad ejecutada" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

# ==============================================================================
# GENERACION DE REPORTES
# ==============================================================================

generate_report() {
    clear
    echo -e "${BLUE}=============================================================================="
    echo "[GENERANDO REPORTE HTML]"
    echo "==============================================================================${NC}"
    echo ""

    REPORT_FILE="$LOG_DIR/Report_Linux_$ISO_DATE.html"

    cat > "$REPORT_FILE" <<EOF
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reporte Renggli PC Solution - Linux</title>
<style>
body{font-family:Consolas,monospace;background:#0a0e27;color:#00ff41;padding:20px;}
h1{color:#00d4ff;border-bottom:2px solid #00d4ff;}
h2{color:#ffd700;}
.log{background:#000;padding:15px;border-left:4px solid #00ff41;white-space:pre-wrap;}
.meta{color:#ffd700;font-weight:bold;}
.section{margin:20px 0;padding:15px;background:#111;border:1px solid #00d4ff;}
</style>
</head>
<body>
<h1>Renggli PC Solution - Reporte de Auditoria Linux</h1>
<p class="meta">Fecha: $ISO_DATE</p>
<p class="meta">Usuario: $USER</p>
<p class="meta">Hostname: $(hostname)</p>
<p class="meta">Distribución: $DISTRO $DISTRO_VERSION</p>
<p class="meta">Kernel: $(uname -r)</p>

<div class="section">
<h2>Información del Sistema</h2>
<pre>$(uname -a)</pre>
<pre>$(free -h)</pre>
<pre>$(df -h)</pre>
</div>

<div class="section">
<h2>Log de Operaciones</h2>
<div class="log">
$(sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$LOG_FILE" 2>/dev/null)
</div>
</div>
</body>
</html>
EOF

    echo "[OK] Reporte generado: $REPORT_FILE"
    echo ""

    # Intentar abrir reporte
    if command -v xdg-open &> /dev/null; then
        xdg-open "$REPORT_FILE" 2>/dev/null &
        echo "[i] Abriendo reporte en navegador..."
    elif command -v firefox &> /dev/null; then
        firefox "$REPORT_FILE" 2>/dev/null &
        echo "[i] Abriendo reporte en Firefox..."
    else
        echo "[i] Abre manualmente: $REPORT_FILE"
    fi

    echo ""
    echo "[$(date +%H:%M:%S)] Reporte HTML generado" >> "$LOG_FILE"
    read -p "Presiona Enter para continuar..."
}

# ==============================================================================
# SALIDA
# ==============================================================================
exit_script() {
    echo "[$(date +%H:%M:%S)] --- FIN DE SESION ---" >> "$LOG_FILE"
    echo ""
    echo -e "${GREEN}=============================================================================="
    echo "[FINALIZANDO Y GENERANDO CHECKSUM]"
    echo "==============================================================================${NC}"
    echo ""

    if command -v sha256sum &> /dev/null; then
        HASH=$(sha256sum "$LOG_FILE" | awk '{print $1}')
        HASH_FILE="${LOG_FILE}.sha256"
        echo "$HASH  $LOG_FILE" > "$HASH_FILE"
        echo "[i] Hash SHA256: $HASH"
        echo "[i] Hash guardado en: $HASH_FILE"
    fi

    echo "[OK] Log guardado: $LOG_FILE"
    echo ""
    echo -e "${CYAN}Gracias por usar Renggli PC Solution${NC}"
    echo ""
    exit 0
}

exit_no_log() {
    echo ""
    echo -e "${GREEN}=============================================================================="
    echo "[FINALIZANDO SIN LOG]"
    echo "==============================================================================${NC}"
    echo ""
    rm -f "$LOG_FILE" 2>/dev/null
    echo "[OK] Log eliminado. Saliendo..."
    echo ""
    exit 0
}

# ==============================================================================
# EJECUCION PRINCIPAL
# ==============================================================================
detect_distro
check_root
profile_select
main_menu

