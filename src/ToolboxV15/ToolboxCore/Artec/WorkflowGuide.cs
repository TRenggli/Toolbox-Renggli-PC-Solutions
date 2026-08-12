namespace ToolboxCore.Artec;

public enum WorkflowStage
{
    Scan,
    Cad,
    Cam,
    MachineControl,
    PostProcessingAndQC
}

public record WorkflowStep(
    WorkflowStage Stage,
    string Title,
    string Description,
    List<string> SoftwareRequired,
    bool RequiresUserConfirmation,
    bool IsBlockingForProduction
);

public record CamSelection(
    string CamSoftware,
    bool UsesValidatedProfile,
    string Notes
);

public class WorkflowGuide
{
    public IReadOnlyList<WorkflowStep> Guide()
    {
        return new List<WorkflowStep>
        {
            new WorkflowStep(
                WorkflowStage.Scan,
                "Patient Scan Acquisition",
                "Acquire intraoral or model scans using a UP3D scanner (UP400, UP560, UP560HD). Ensure scanner calibration is current and tip lenses are clean.",
                new List<string> { "UPCAD", "DentalStation" },
                RequiresUserConfirmation: true,
                IsBlockingForProduction: true
            ),
            new WorkflowStep(
                WorkflowStage.Cad,
                "CAD Design",
                "Design restorations using DentalCAD (exocad) or UPCAD. Confirm margins, occlusion, and connector dimensions before export.",
                new List<string> { "exocad", "UPCAD" },
                RequiresUserConfirmation: true,
                IsBlockingForProduction: true
            ),
            new WorkflowStep(
                WorkflowStage.Cam,
                "CAM Toolpath Generation",
                "Generate CAM toolpaths using UPCAM or hyperDENT. Confirm post-processor, stock size, bur set, and strategy match the selected mill.",
                new List<string> { "UPCAM", "hyperDENT" },
                RequiresUserConfirmation: true,
                IsBlockingForProduction: true
            ),
            new WorkflowStep(
                WorkflowStage.MachineControl,
                "Mill Machine Control",
                "Load stock into the mill (P42, P42Plus, P52, P53) and start the job. For wet mills, verify coolant flow. For machines requiring board confirmation, ensure the safety board acknowledges the job.",
                new List<string> { "UPCAM", "hyperDENT" },
                RequiresUserConfirmation: true,
                IsBlockingForProduction: true
            ),
            new WorkflowStep(
                WorkflowStage.PostProcessingAndQC,
                "Post-processing and Quality Control",
                "Sinter, polish, and inspect restoration against design. Record QC outcome and archive files with version hash.",
                new List<string> { "DentalStation" },
                RequiresUserConfirmation: true,
                IsBlockingForProduction: true
            )
        };
    }

    public CamSelection ResolveCamSelection(string camSoftware, bool usesValidatedProfile)
    {
        if (string.IsNullOrWhiteSpace(camSoftware))
        {
            return new CamSelection(string.Empty, false, "No CAM software selected.");
        }

        if (camSoftware.Equals("UPCAM", StringComparison.OrdinalIgnoreCase))
        {
            return new CamSelection("UPCAM", true, "UPCAM is the manufacturer-supported CAM for all Artec mills.");
        }

        if (camSoftware.Equals("hyperDENT", StringComparison.OrdinalIgnoreCase))
        {
            if (!usesValidatedProfile)
            {
                return new CamSelection("hyperDENT", false, "hyperDENT REQUIRES a validated profile. Production is BLOCKED until a validated profile is loaded.");
            }
            return new CamSelection("hyperDENT", true, "hyperDENT with validated profile is approved for P-series mills.");
        }

        return new CamSelection(camSoftware, false, $"Unsupported CAM software: {camSoftware}.");
    }

    public WorkflowStep? GetStep(WorkflowStage stage)
    {
        return Guide().FirstOrDefault(s => s.Stage == stage);
    }

    public bool IsCamSelectionBlocking(CamSelection selection)
    {
        if (string.IsNullOrWhiteSpace(selection.CamSoftware)) return true;
        if (selection.CamSoftware.Equals("hyperDENT", StringComparison.OrdinalIgnoreCase) &&
            !selection.UsesValidatedProfile)
        {
            return true;
        }
        return false;
    }
}