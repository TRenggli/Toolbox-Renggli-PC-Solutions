using ToolboxCore.Models;

namespace ToolboxCore.Symptoms;

public class SymptomRegistry
{
    private readonly Dictionary<string, SymptomDefinition> _symptoms = new(StringComparer.OrdinalIgnoreCase);

    public SymptomRegistry()
    {
        Register("slow-system", "Sistema lento",
            "El equipo responde con lentitud o tarda en iniciar aplicaciones",
            new()
            {
                new("ram-insufficient", "Memoria RAM insuficiente o bajo uso elevado", new() { "hardware-ram", "system-processes" }),
                new("disk-fragmented", "Disco fragmentado o casi lleno", new() { "hardware-smart", "system-services" }),
                new("malware-active", "Posible malware consumiendo recursos", new() { "system-processes", "system-autostart" }),
                new("thermal-throttle", "Thermal throttling", new() { "hardware-resources" }),
            },
            new() { "hardware-ram", "hardware-resources", "hardware-smart", "system-processes", "system-autostart" });

        Register("unexpected-reboots", "Reinicios inesperados",
            "El equipo se reinicia solo o se bloquea",
            new()
            {
                new("bsod-driver", "BSOD por driver defectuoso", new() { "system-bsod", "system-events", "system-drivers" }),
                new("hardware-fault", "Falla de hardware (RAM/disco/fuente)", new() { "hardware-smart", "hardware-ram", "system-events" }),
                new("thermal-shutdown", "Apagado termico por sobrecalentamiento", new() { "hardware-resources", "system-events" }),
                new("windows-update", "Reinicio por Windows Update pendiente", new() { "system-updates", "system-events" }),
            },
            new() { "system-bsod", "system-events", "system-drivers", "hardware-smart", "hardware-ram", "hardware-resources", "system-updates" });

        Register("storage-issues", "Problemas de almacenamiento",
            "Discos lentos, casi llenos, o erroress de lectura/escritura",
            new()
            {
                new("smart-failing", "Disco con fallo SMART inminente", new() { "hardware-smart", "system-events" }),
                new("disk-full", "Disco casi lleno", new() { "hardware-smart" }),
                new("fs-corruption", "Corrupcion del sistema de archivos", new() { "repair-dism-sfc" }),
            },
            new() { "hardware-smart", "system-events", "repair-dism-sfc" });

        Register("network-problems", "Problemas de red",
            "Sin conectividad, lentitud de red o DNS fallando",
            new()
            {
                new("dns-misconfig", "Configuracion DNS incorrecta", new() { "network-dns" }),
                new("adapter-issue", "Problema de adaptador de red", new() { "network-ports" }),
                new("firewall-block", "Firewall bloqueando trafico", new() { "network-ports" }),
            },
            new() { "network-dns", "network-ports", "network-speed" });

        Register("update-problems", "Problemas de actualizaciones",
            "Windows Update o gestor de paquetes atascado o fallando",
            new()
            {
                new("wu-corrupt", "Cache de Windows Update corrupta", new() { "system-updates", "repair-wu-reset" }),
                new("pending-reboot", "Reinicio pendiente bloqueando updates", new() { "system-updates" }),
            },
            new() { "system-updates", "repair-wu-reset" });

        Register("service-failures", "Servicios deteniendose",
            "Servicios del sistema no se inician o se detienen",
            new()
            {
                new("dependency-missing", "Dependencia de servicio faltante", new() { "system-services", "system-events" }),
                new("permission-denied", "Permisos insuficientes", new() { "system-services" }),
            },
            new() { "system-services", "system-events" });

        Register("security-issues", "Problemas de seguridad",
            "Alertas de antivirus, firewall, o accessos sospechosos",
            new()
            {
                new("malware-detected", "Malware detectado o sospechoso", new() { "system-processes", "system-autostart" }),
                new("firewall-disabled", "Firewall deshabilitado", new() { "system-events" }),
            },
            new() { "system-events", "system-processes", "system-autostart" });

        Register("dental-scanner-not-detected", "Escaner dental no detectado",
            "UP3D no detectado por el sistema",
            new()
            {
                new("usb-issue", "Conexion USB 3.0 deficiente", new() { "artec-scanner-detect" }),
                new("driver-missing", "Driver del escaner no instalado", new() { "artec-scanner-detect", "artec-software-versions" }),
                new("power-issue", "Escaner sin alimentacion", new() { "artec-scanner-detect" }),
            },
            new() { "artec-scanner-detect", "artec-software-versions" });

        Register("poor-scan-quality", "Calidad de escaneo deficiente",
            "El escaner produce capturas de baja calidad",
            new()
            {
                new("calibration-needed", "Necesita calibracion", new() { "artec-scanner-calibration" }),
                new("software-version", "Version de software incompatible", new() { "artec-software-versions" }),
            },
            new() { "artec-scanner-calibration", "artec-software-versions" });

        Register("mill-communication-failure", "Fresadora sin comunicacion",
            "No se puede conectar con la fresadora",
            new()
            {
                new("network-issue", "Fresadora fuera de red", new() { "artec-mill-network" }),
                new("ip-misconfig", "IP de la fresadora mal configurada", new() { "artec-mill-network", "artec-mill-detect" }),
            },
            new() { "artec-mill-network", "artec-mill-detect" });
    }

    private void Register(string id, string title, string desc, List<CauseDefinition> causes, List<string> modules)
    {
        _symptoms[id] = new SymptomDefinition(id, title, desc, causes, modules);
    }

    public SymptomResult? GetSymptom(string id)
    {
        if (!_symptoms.TryGetValue(id, out var def))
            return null;

        return new SymptomResult(
            def.Id,
            def.Title,
            def.Description,
            def.PossibleCauses.Select(c => new CauseMatch(c.CauseId, c.Description, Confidence.Possible, c.AssociatedModules)).ToList(),
            def.RecommendedModules.ToList(),
            Confidence.Possible,
            DateTime.UtcNow,
            Guid.NewGuid()
        );
    }

    public List<SymptomDefinition> GetAll() => _symptoms.Values.ToList();
    public List<string> GetAllIds() => _symptoms.Keys.ToList();
}