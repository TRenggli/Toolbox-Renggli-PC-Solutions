using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using ToolboxClinical.Auth;
using ToolboxClinical.Models;
using ToolboxClinical.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

var authCfg = builder.Configuration.GetSection("Auth");
var jwtKey = authCfg["JwtSigningKey"] ?? throw new InvalidOperationException("JwtSigningKey missing");
var mfaToken = authCfg["MfaToken"] ?? throw new InvalidOperationException("MfaToken missing");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = authCfg["JwtIssuer"],
            ValidateAudience = true,
            ValidAudience = authCfg["JwtAudience"],
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();
builder.Services.AddHealthChecks();
builder.Services.AddSingleton<ClinicalAuditService>();
builder.Services.AddSingleton<RecordService>();
builder.Services.AddSingleton<ProductionService>();
builder.Services.AddSingleton<RetentionService>(new RetentionService(
    builder.Configuration.GetValue<int>("Retention:AttachmentDays", 90)));

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapHealthChecks("/health").AllowAnonymous();

static bool ValidateMfa(HttpContext ctx, string expected)
{
    if (!ctx.Request.Headers.TryGetValue("X-MFA-Token", out var t)) return false;
    return string.Equals(t, expected, StringComparison.Ordinal);
}

app.MapPost("/clinical/records", async (ClinicalRecord record, RecordService records, ClinicalAuditService audit, HttpContext ctx) =>
{
    if (!ValidateMfa(ctx, mfaToken)) return Results.Unauthorized();
    if (string.IsNullOrWhiteSpace(record.Reason)) return Results.BadRequest(new { error = "reason required" });
    var created = records.Create(record);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "record.create",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = created.Id.ToString(),
        Details = $"patient={created.PatientId};reason={created.Reason}"
    });
    return Results.Created($"/clinical/records/{created.Id}", created);
}).RequireAuthorization();

app.MapGet("/clinical/records/{id:guid}", async (Guid id, RecordService records, ClinicalAuditService audit, HttpContext ctx) =>
{
    if (!ValidateMfa(ctx, mfaToken)) return Results.Unauthorized();
    var reason = ctx.Request.Headers["X-Access-Reason"].ToString();
    if (string.IsNullOrWhiteSpace(reason)) return Results.BadRequest(new { error = "reason required" });
    var rec = records.Get(id, TimeSpan.FromMinutes(15));
    if (rec is null) return Results.NotFound();
    await audit.AppendAsync(new AuditEntry
    {
        Action = "record.read",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = rec.Id.ToString(),
        Details = $"patient={rec.PatientId};reason={reason}"
    });
    return Results.Ok(rec);
}).RequireAuthorization();

app.MapGet("/clinical/records/{id:guid}/audit", (Guid id, RecordService records, ClinicalAuditService audit) =>
{
    var rec = records.Get(id, TimeSpan.FromHours(1));
    if (rec is null) return Results.NotFound();
    return Results.Ok(audit.GetLatest(50, target: id.ToString()));
}).RequireAuthorization();

app.MapPost("/clinical/production", async (ProductionJob job, ProductionService prod, ClinicalAuditService audit, HttpContext ctx) =>
{
    var created = prod.Create(job);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "production.create",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = created.Id.ToString(),
        Details = $"patient={created.PatientId};recipe={created.Recipe}"
    });
    return Results.Created($"/clinical/production/{created.Id}", created);
}).RequireAuthorization();

app.MapGet("/clinical/production/{id:guid}", (Guid id, ProductionService prod) =>
{
    var job = prod.Get(id);
    return job is null ? Results.NotFound() : Results.Ok(job);
}).RequireAuthorization();

app.MapPut("/clinical/production/{id:guid}/state", async (Guid id, ProductionStateUpdate update, ProductionService prod, ClinicalAuditService audit, HttpContext ctx) =>
{
    var ok = prod.UpdateState(id, update.State, update.Note);
    if (!ok) return Results.NotFound();
    await audit.AppendAsync(new AuditEntry
    {
        Action = "production.state",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = id.ToString(),
        Details = $"state={update.State};note={update.Note ?? string.Empty}"
    });
    return Results.NoContent();
}).RequireAuthorization();

app.MapGet("/clinical/patients/{id:guid}/history", async (Guid id, RecordService records, ClinicalAuditService audit, HttpContext ctx) =>
{
    if (!ValidateMfa(ctx, mfaToken)) return Results.Unauthorized();
    var reason = ctx.Request.Headers["X-Access-Reason"].ToString();
    if (string.IsNullOrWhiteSpace(reason)) return Results.BadRequest(new { error = "reason required" });
    var history = records.GetPatientHistory(id);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "patient.history",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = id.ToString(),
        Details = $"reason={reason}"
    });
    return Results.Ok(history);
}).RequireAuthorization();

app.MapPost("/clinical/attachments", async (AttachmentUpload upload, RetentionService retention, ClinicalAuditService audit, HttpContext ctx) =>
{
    if (!ValidateMfa(ctx, mfaToken)) return Results.Unauthorized();
    var attachment = retention.Store(upload, DateTime.UtcNow);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "attachment.store",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = attachment.Id.ToString(),
        Details = $"patient={attachment.PatientId};deleteAfter={attachment.DeleteAfter:O}"
    });
    return Results.Created($"/clinical/attachments/{attachment.Id}", attachment);
}).RequireAuthorization();

app.Run();