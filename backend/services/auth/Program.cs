using GeorgiaGuide.Auth.Data;
using GeorgiaGuide.Auth.Services;
using Microsoft.AspNetCore.Server.Kestrel.Core;

var builder = WebApplication.CreateBuilder(args);

// Listen on HTTP/2 (h2c) for internal gRPC — no TLS between containers.
var port = Environment.GetEnvironmentVariable("PORT") ?? "5001";
builder.WebHost.ConfigureKestrel(o =>
{
    o.ListenAnyIP(int.Parse(port), lo => lo.Protocols = HttpProtocols.Http2);
});

builder.Services.AddGrpc();
builder.Services.AddSingleton<UserRepository>();
builder.Services.AddSingleton<JwtService>();

var app = builder.Build();
app.MapGrpcService<AuthGrpcService>();
app.MapGet("/", () => "Auth service (gRPC).");
app.Run();
