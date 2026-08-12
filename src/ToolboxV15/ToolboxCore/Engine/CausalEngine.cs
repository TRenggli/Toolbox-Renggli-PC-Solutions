using ToolboxCore.Models;

namespace ToolboxCore.Engine;

public class CausalEngine
{
    public List<Finding> Analyze(List<ExecutionResult> results)
    {
        var allFindings = results.SelectMany(r => r.Findings).ToList();
        var correlated = new List<Finding>();

        foreach (var rule in BuildRules())
        {
            var match = rule.Evaluate(results);
            if (match != null) correlated.AddRange(match);
        }

        return correlated;
    }

    private List<CausalRule> BuildRules()
    {
        return new List<CausalRule>
        {
            new("disk-failure", results =>
            {
                var smart = results.FirstOrDefault(r => r.ModuleId.Contains("smart"));
                var events = results.FirstOrDefault(r => r.ModuleId.Contains("event"));
                if (smart != null && smart.Findings.Any(f => f.Severity >= Severity.High && f.Category.Contains("disk")))
                    return new List<Finding> { new("disk-failure", "storage", Severity.Critical,
                        "Fallo de disco inminente detectado",
                        "SMART reporta errores y eventos confirman degradacion",
                        Confidence.Confirmed, "Reemplazar disco y restaurar desde backup", null) };
                return null;
            }),
            new("memory-pressure", results =>
            {
                var ram = results.FirstOrDefault(r => r.ModuleId.Contains("ram") || r.ModuleId.Contains("memory"));
                if (ram != null && ram.Findings.Any(f => f.Category.Contains("memory") && f.Severity >= Severity.Medium))
                    return new List<Finding> { new("memory-pressure", "memory", Severity.High,
                        "Presion de memoria detectada",
                        "Alta utilizacion de RAM con paginacion elevada",
                        Confidence.Probable, "Cerrar aplicaciones innecesarias o ampliar RAM", null) };
                return null;
            }),
            new("dns-misconfig", results =>
            {
                var dns = results.FirstOrDefault(r => r.ModuleId.Contains("dns"));
                var net = results.FirstOrDefault(r => r.ModuleId.Contains("network") && r.ModuleId.Contains("speed"));
                if (dns != null && dns.Findings.Any(f => f.Severity >= Severity.Medium) && net is { Status: ExecutionStatus.Success })
                    return new List<Finding> { new("dns-misconfig", "network", Severity.Medium,
                        "Configuracion DNS problematica",
                        "La red funciona pero DNS falla",
                        Confidence.Possible, "Verificar servidores DNS configurados", null) };
                return null;
            }),
            new("service-dependency-failure", results =>
            {
                var svc = results.FirstOrDefault(r => r.ModuleId.Contains("service"));
                if (svc != null && svc.Findings.Any(f => f.Severity >= Severity.High && f.Category.Contains("service")))
                    return new List<Finding> { new("svc-dep-failure", "services", Severity.High,
                        "Servicio critico detenido",
                        "Un servicio требуется por otros componentes no esta funcionando",
                        Confidence.Probable, "Reiniciar servicio y verificar dependencias", null) };
                return null;
            }),
            new("driver-issues", results =>
            {
                var drv = results.FirstOrDefault(r => r.ModuleId.Contains("driver"));
                if (drv != null && drv.Findings.Any(f => f.Severity >= Severity.Medium))
                    return new List<Finding> { new("driver-issue", "drivers", Severity.Medium,
                        "Problema de driver detectado",
                        "Controladores desactualizados o con conflictos",
                        Confidence.Possible, "Actualizar o reinstalar drivers problematicos", null) };
                return null;
            }),
            new("thermal-throttle", results =>
            {
                var res = results.FirstOrDefault(r => r.ModuleId.Contains("resource"));
                if (res != null && res.Findings.Any(f => f.Category.Contains("temperature") && f.Severity >= Severity.Medium))
                    return new List<Finding> { new("thermal", "hardware", Severity.High,
                        "Thermal throttling detectado",
                        "Temperaturas elevadas causando reduccion de rendimiento",
                        Confidence.Probable, "Verificar ventilacion y disipadores", null) };
                return null;
            }),
            new("update-pending-reboot", results =>
            {
                var upd = results.FirstOrDefault(r => r.ModuleId.Contains("update"));
                if (upd != null && upd.Findings.Any(f => f.Category.Contains("reboot")))
                    return new List<Finding> { new("pending-reboot", "updates", Severity.Medium,
                        "Reinicio pendiente por actualizaciones",
                        "Hay actualizaciones que requieren reinicio para completarse",
                        Confidence.Confirmed, "Reiniciar el sistema", null) };
                return null;
            }),
            new("artec-scanner-usb", results =>
            {
                var scanner = results.FirstOrDefault(r => r.ModuleId.Contains("scanner-detect"));
                if (scanner != null && scanner.Findings.Any(f => f.Category.Contains("usb")))
                    return new List<Finding> { new("scanner-usb", "artec", Severity.High,
                        "Escaner no detectado via USB",
                        "El escaner UP3D no se detecta - posible problema USB 3.0",
                        Confidence.Probable, "Verificar cable USB 3.0, puerto y driver", null) };
                return null;
            }),
            new("artec-mill-network", results =>
            {
                var mill = results.FirstOrDefault(r => r.ModuleId.Contains("mill-network"));
                if (mill != null && mill.Status == ExecutionStatus.Failed)
                    return new List<Finding> { new("mill-net", "artec", Severity.Critical,
                        "Fresadora sin comunicacion de red",
                        "La fresadora no responde en la red",
                        Confidence.Confirmed, "Verificar IP, cable de red y switch", null) };
                return null;
            })
        };
    }
}

internal record CausalRule(string Id, Func<List<ExecutionResult>, List<Finding>?> Evaluate);