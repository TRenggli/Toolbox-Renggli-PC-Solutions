using System.IdentityModel.Tokens;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using ToolboxApi.Auth;
using ToolboxApi.Models;
using ToolboxApi.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi();

var authCfg = builder.Configuration.GetSection("Auth");
var jwtKey = authCfg["JwtSigningKey"] ?? throw new InvalidOperationException("JwtSigningKey missing");
var apiKey = authCfg["ApiKey"] ?? throw new InvalidOperationException("ApiKey missing");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = "Hybrid";
    options.DefaultChallengeScheme = "Hybrid";
})
.AddPolicyScheme("Hybrid", "Jwt or ApiKey", options =>
{
    options.ForwardDefaultSelector = ctx =>
    {
        if (ctx.Request.Headers.TryGetValue("X-API-Key", out var k) && !string.IsNullOrWhiteSpace(k))
            return "ApiKey";
        return JwtBearerDefaults.AuthenticationScheme;
    };
})
.AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
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
})
.AddScheme<ApiKeyAuthOptions, ApiKeyAuthHandler>("ApiKey", options =>
{
    options.ApiKey = apiKey;
});

builder.Services.AddAuthorization();

var origins = builder.Configuration.GetSection("Cors:Origins").Get<string[]>() ?? Array.Empty<string>();
builder.Services.AddCors(o => o.AddPolicy("panel", p => p
    .WithOrigins(origins)
    .AllowAnyHeader()
    .AllowAnyMethod()
    .AllowCredentials()));

builder.Services.AddHealthChecks();
builder.Services.AddSingleton<AgentService>();
builder.Services.AddSingleton<JobService>();
builder.Services.AddSingleton<AuditService>();
builder.Services.AddSingleton<BackupService>();

var app = builder.Build();

app.UseCors("panel");
app.UseAuthentication();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.MapHealthChecks("/health").AllowAnonymous();

app.MapPost("/api/agents/enroll", async (EnrollRequest req, AgentService agents, AuditService audit, HttpContext ctx) =>
{
    var ip = ctx.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    var response = agents.Enroll(req, ip);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "agent.enroll",
        Actor = req.Token[..Math.Min(8, req.Token.Length)],
        Target = response.AgentId.ToString(),
        Details = $"host={req.Hostname};os={req.Os}"
    });
    return Results.Ok(response);
}).AllowAnonymous();

app.MapGet("/api/agents", (AgentService agents) => Results.Ok(agents.List()))
   .RequireAuthorization();

app.MapGet("/api/agents/{id:guid}/status", (Guid id, AgentService agents) =>
{
    var s = agents.GetStatus(id);
    return s is null ? Results.NotFound() : Results.Ok(s);
}).RequireAuthorization();

app.MapPost("/api/modules", async (ModuleUpload upload, AuditService audit, HttpContext ctx) =>
{
    await audit.AppendAsync(new AuditEntry
    {
        Action = "module.upload",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = upload.Name,
        Details = $"version={upload.Version};risk={upload.Risk}"
    });
    return Results.Ok(new { uploaded = true, upload.Name, upload.Version });
}).RequireAuthorization();

app.MapGet("/api/modules", () => Results.Ok(new[] { new { Name = "demo", Version = "1.0.0" } }))
   .RequireAuthorization();

app.MapPost("/api/jobs", async (JobRequest req, JobService jobs, AuditService audit, HttpContext ctx) =>
{
    var job = jobs.Enqueue(req);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "job.create",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = job.Id.ToString(),
        Details = $"agent={req.AgentId};module={req.ModuleId}"
    });
    return Results.Created($"/api/jobs/{job.Id}", job);
}).RequireAuthorization();

app.MapGet("/api/jobs", (JobService jobs, string? status) =>
{
    var list = jobs.List(status);
    return Results.Ok(list);
}).RequireAuthorization();

app.MapPost("/api/triage/{area}", async (string area, AuditService audit, HttpContext ctx) =>
{
    await audit.AppendAsync(new AuditEntry
    {
        Action = "triage.start",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = area,
        Details = $"area={area}"
    });
    return Results.Ok(new { area, started = true, runId = Guid.NewGuid() });
}).RequireAuthorization();

app.MapGet("/api/audit", (AuditService audit, int limit = 100) =>
    Results.Ok(audit.GetLatest(limit)))
  .RequireAuthorization();

app.MapPost("/api/backup", async (BackupRequest req, BackupService backup, AuditService audit, HttpContext ctx) =>
{
    var id = await backup.TriggerAsync(req);
    await audit.AppendAsync(new AuditEntry
    {
        Action = "backup.trigger",
        Actor = ctx.User.Identity?.Name ?? "system",
        Target = id.ToString(),
        Details = $"target={req.Target};scope={req.Scope}"
    });
    return Results.Ok(new { backupId = id });
}).RequireAuthorization();

app.Run();