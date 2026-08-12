using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;

namespace ToolboxClinical.Auth;

public class ApiKeyAuthOptions : AuthenticationSchemeOptions
{
    public string ApiKey { get; set; } = string.Empty;
}