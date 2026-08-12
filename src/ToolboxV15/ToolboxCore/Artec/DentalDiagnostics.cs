using ToolboxCore.Models;

namespace ToolboxCore.Artec;

public class DentalDiagnostics
{
    public List<Finding> ScannerNotDetected(DetectionResult result)
    {
        var findings = new List<Finding>();
        if (result.DetectedScanners.Count == 0)
        {
            findings.Add(new Finding(
                Id: "artec.scanner.none-detected",
                Category: "Artec.Scanner",
                Severity: Severity.High,
                Title: "No UP3D scanner detected",
                Detail: "No UP3D PnP device was detected on this host. UP400, UP560, or UP560HD scanners require USB 3.0 connectivity.",
                Confidence: Confidence.Confirmed,
                Remediation: "Connect the scanner via a USB 3.0 port, confirm power, and reinstall UP3D drivers. Re-run detection.",
                RawData: null
            ));
        }

        if (!result.Usb3Available)
        {
            findings.Add(new Finding(
                Id: "artec.usb3.unavailable",
                Category: "Artec.Scanner",
                Severity: Severity.High,
                Title: "USB 3.0 not available",
                Detail: "No USB 3.0 host controller was detected. UP3D scanners require USB 3.0 for full bandwidth scanning.",
                Confidence: Confidence.Probable,
                Remediation: "Install USB 3.0 host controller drivers or use a dedicated USB 3.0 PCIe card.",
                RawData: null
            ));
        }

        foreach (var issue in result.Issues.Where(i => i.Contains("Scanner", StringComparison.OrdinalIgnoreCase)))
        {
            findings.Add(new Finding(
                Id: "artec.scanner.detection-error",
                Category: "Artec.Scanner",
                Severity: Severity.Medium,
                Title: "Scanner detection encountered an error",
                Detail: issue,
                Confidence: Confidence.Possible,
                Remediation: "Review detection logs and verify PnP service state.",
                RawData: null
            ));
        }

        return findings;
    }

    public List<Finding> PoorScanQuality(SoftwareAdapterResult cadResult)
    {
        var findings = new List<Finding>();
        if (!cadResult.IsInstalled && cadResult.Name.Equals("UPCAD", StringComparison.OrdinalIgnoreCase))
        {
            findings.Add(new Finding(
                Id: "artec.scan.upcad-missing",
                Category: "Artec.Cad",
                Severity: Severity.High,
                Title: "UPCAD not installed",
                Detail: "UPCAD is required to process scan acquisitions from UP3D scanners.",
                Confidence: Confidence.Confirmed,
                Remediation: "Install UPCAD from the Artec install media and verify license activation.",
                RawData: null
            ));
        }

        findings.Add(new Finding(
            Id: "artec.scan.calibration",
            Category: "Artec.Scanner",
            Severity: Severity.Medium,
            Title: "Scan quality may be degraded",
            Detail: "Poor scan quality is frequently caused by lens contamination, ambient lighting, or expired scanner calibration.",
            Confidence: Confidence.Possible,
            Remediation: "Clean tip lenses, recalibrate scanner, and confirm ambient lighting meets manufacturer spec.",
            RawData: null
        ));

        return findings;
    }

    public List<Finding> CalibrationNeeded()
    {
        return new List<Finding>
        {
            new Finding(
                Id: "artec.calibration.scanner-due",
                Category: "Artec.Scanner",
                Severity: Severity.Medium,
                Title: "Scanner calibration due",
                Detail: "UP3D scanners require periodic calibration. Expired calibration degrades scan accuracy.",
                Confidence: Confidence.Possible,
                Remediation: "Run scanner calibration in UPCAD and verify the calibration certificate date.",
                RawData: null
            ),
            new Finding(
                Id: "artec.calibration.mill-due",
                Category: "Artec.Mill",
                Severity: Severity.Medium,
                Title: "Mill calibration due",
                Detail: "P-series mills require axis calibration and bur alignment verification on schedule.",
                Confidence: Confidence.Possible,
                Remediation: "Run mill axis calibration and inspect spindle alignment.",
                RawData: null
            )
        };
    }

    public List<Finding> ExportIssues()
    {
        return new List<Finding>
        {
            new Finding(
                Id: "artec.export.format-mismatch",
                Category: "Artec.Cad",
                Severity: Severity.High,
                Title: "CAD to CAM export format mismatch",
                Detail: "CAD designs must be exported in a format supported by the CAM stage (STL, PLY, or manufacturer native format).",
                Confidence: Confidence.Possible,
                Remediation: "Confirm export settings (units, format, resolution) match the CAM import profile.",
                RawData: null
            ),
            new Finding(
                Id: "artec.export.units",
                Category: "Artec.Cad",
                Severity: Severity.Medium,
                Title: "Unit inconsistency in export",
                Detail: "Mixing millimeters and microns during export causes dimensional errors in CAM.",
                Confidence: Confidence.Possible,
                Remediation: "Standardize all exports in millimeters and verify in CAM preview.",
                RawData: null
            )
        };
    }

    public List<Finding> CadToCamProblems()
    {
        return new List<Finding>
        {
            new Finding(
                Id: "artec.cadcam.connector",
                Category: "Artec.Cam",
                Severity: Severity.High,
                Title: "Connector dimensions invalid for selected bur",
                Detail: "Connector thickness in CAD must exceed the smallest CAM bur diameter.",
                Confidence: Confidence.Possible,
                Remediation: "Increase connector thickness in CAD or select a smaller bur set in CAM.",
                RawData: null
            ),
            new Finding(
                Id: "artec.cadcam.margin",
                Category: "Artec.Cam",
                Severity: Severity.Medium,
                Title: "Margin lines not transferred to CAM",
                Detail: "Margin lines defined in CAD must be exported; missing margins cause incorrect toolpaths.",
                Confidence: Confidence.Possible,
                Remediation: "Re-export design including margin lines and confirm in CAM.",
                RawData: null
            )
        };
    }

    public List<Finding> MachineNotOnNetwork(DetectionResult result)
    {
        var findings = new List<Finding>();
        if (result.DetectedMills.Count == 0)
        {
            findings.Add(new Finding(
                Id: "artec.mill.offline",
                Category: "Artec.Mill",
                Severity: Severity.Critical,
                Title: "No mill detected on network",
                Detail: "P-series mills are network-attached. No device responded in 192.168.1.x.",
                Confidence: Confidence.Confirmed,
                Remediation: "Verify mill power, network cabling, IP configuration, and host NIC on the same subnet.",
                RawData: null
            ));
        }

        if (result.NetworkAdapters.Count == 0)
        {
            findings.Add(new Finding(
                Id: "artec.mill.no-nic",
                Category: "Artec.Mill",
                Severity: Severity.High,
                Title: "No active network adapter",
                Detail: "No active network adapters were detected on the host.",
                Confidence: Confidence.Confirmed,
                Remediation: "Enable and configure a network adapter on the 192.168.1.x subnet.",
                RawData: null
            ));
        }

        return findings;
    }

    public List<Finding> InterruptedMilling()
    {
        return new List<Finding>
        {
            new Finding(
                Id: "artec.mill.interrupted",
                Category: "Artec.Mill",
                Severity: Severity.High,
                Title: "Milling job interrupted",
                Detail: "Milling interruptions are commonly caused by bur breakage, stock slip, coolant loss, or spindle faults.",
                Confidence: Confidence.Probable,
                Remediation: "Inspect burs and stock, verify spindle load log, and resume from the last valid checkpoint.",
                RawData: null
            ),
            new Finding(
                Id: "artec.mill.recovery",
                Category: "Artec.Mill",
                Severity: Severity.Medium,
                Title: "Job recovery not started",
                Detail: "P-series mills retain the last job state. Recovery requires operator confirmation at the machine console.",
                Confidence: Confidence.Possible,
                Remediation: "Acknowledge the fault on the mill board and confirm job recovery in UPCAM.",
                RawData: null
            )
        };
    }

    public List<Finding> AirExtractionIssues()
    {
        return new List<Finding>
        {
            new Finding(
                Id: "artec.dust.extraction-low",
                Category: "Artec.Environment",
                Severity: Severity.High,
                Title: "Dust extraction airflow low",
                Detail: "Dry milling produces zirconia or PMMA dust. Insufficient airflow degrades air quality and machine components.",
                Confidence: Confidence.Possible,
                Remediation: "Inspect extraction filter, clear ducts, and verify airflow sensor reading at the mill inlet.",
                RawData: null
            ),
            new Finding(
                Id: "artec.dust.filter-clogged",
                Category: "Artec.Environment",
                Severity: Severity.Medium,
                Title: "Extraction filter clogged",
                Detail: "Clogged filters reduce suction and risk dust buildup in the spindle area.",
                Confidence: Confidence.Possible,
                Remediation: "Replace or clean the primary extraction filter per the maintenance schedule.",
                RawData: null
            )
        };
    }

    public List<Finding> ToolCoolingIssues()
    {
        return new List<Finding>
        {
            new Finding(
                Id: "artec.coolant.flow-low",
                Category: "Artec.Mill",
                Severity: Severity.Critical,
                Title: "Coolant flow low on wet mill",
                Detail: "P42 and P42Plus are wet mills. Low coolant flow causes bur overheating and restoration damage.",
                Confidence: Confidence.Probable,
                Remediation: "Verify coolant reservoir level, pump operation, and flow sensor. Replace coolant if expired.",
                RawData: null
            ),
            new Finding(
                Id: "artec.coolant.nozzle",
                Category: "Artec.Mill",
                Severity: Severity.Medium,
                Title: "Coolant nozzle misaligned",
                Detail: "Misaligned nozzles reduce cooling effectiveness at the cutting interface.",
                Confidence: Confidence.Possible,
                Remediation: "Realign coolant nozzles to target the bur tip during milling.",
                RawData: null
            ),
            new Finding(
                Id: "artec.coolant.contamination",
                Category: "Artec.Mill",
                Severity: Severity.Medium,
                Title: "Coolant contamination suspected",
                Detail: "Discolored or particulate-laden coolant indicates contamination or biological growth.",
                Confidence: Confidence.Possible,
                Remediation: "Drain, flush, and replace coolant with manufacturer-approved fluid.",
                RawData: null
            )
        };
    }
}