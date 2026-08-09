using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace GeorgiaGuide.Auth.Services;

public class JwtService
{
    private readonly byte[] _key;

    public JwtService()
    {
        var secret = Environment.GetEnvironmentVariable("JWT_SECRET");
        if (string.IsNullOrWhiteSpace(secret))
        {
            // Dev-only fallback. Must be >= 32 bytes: HMAC-SHA256 requires a
            // 256-bit key, otherwise token signing throws IDX10720.
            secret = "dev-only-insecure-secret-change-me-32bytes-min";
        }

        var bytes = Encoding.UTF8.GetBytes(secret);
        if (bytes.Length < 32)
        {
            throw new InvalidOperationException(
                $"JWT_SECRET must be at least 32 characters (256 bits) for HS256; got {bytes.Length}. " +
                "Update JWT_SECRET in your .env file.");
        }

        _key = bytes;
    }

    // Access token: short-lived (15 min). sub = user id.
    public string CreateAccess(long userId) => Create(userId, "access", TimeSpan.FromMinutes(15));

    // Refresh token: long-lived (30 days).
    public string CreateRefresh(long userId) => Create(userId, "refresh", TimeSpan.FromDays(30));

    private string Create(long userId, string type, TimeSpan ttl)
    {
        var creds = new SigningCredentials(new SymmetricSecurityKey(_key), SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            claims: new[]
            {
                new Claim("sub", userId.ToString()),
                new Claim("typ", type),
            },
            expires: DateTime.UtcNow.Add(ttl),
            signingCredentials: creds);
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    // Validates a refresh token and returns the user id, or null if invalid.
    public long? ValidateRefresh(string token)
    {
        try
        {
            var handler = new JwtSecurityTokenHandler();
            var principal = handler.ValidateToken(token, new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(_key),
                ValidateIssuer = false,
                ValidateAudience = false,
                ClockSkew = TimeSpan.FromSeconds(30),
            }, out _);

            if (principal.FindFirst("typ")?.Value != "refresh") return null;
            var sub = principal.FindFirst("sub")?.Value;
            return long.TryParse(sub, out var id) ? id : null;
        }
        catch
        {
            return null;
        }
    }
}
