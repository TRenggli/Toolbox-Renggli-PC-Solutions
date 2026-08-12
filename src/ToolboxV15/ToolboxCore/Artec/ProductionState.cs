namespace ToolboxCore.Artec;

public enum ProductionState
{
    Received,
    Scanning,
    Cad,
    Cam,
    Queued,
    Milling,
    QC,
    Completed,
    Blocked,
    Cancelled,
    Rework
}